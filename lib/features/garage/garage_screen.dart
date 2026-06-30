import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/rendering.dart';
import '../../core/services/wallpaper_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/app_data.dart';
import '../../core/models/theme_item.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/widgets/cyber_button.dart';
import '../../core/theme/widgets/cyber_toast.dart';
import '../../core/theme/widgets/loading_modal.dart';
import '../../providers/entitlement_provider.dart';
import '../../providers/library_provider.dart';
import '../../core/models/theme_item.dart' show LibraryDraft;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/ad_service.dart';
import '../../router/app_router.dart';
import 'reward_modal.dart';
import 'set_wallpaper_modal.dart';
import 'sticker_layer.dart';

final _garageThemeProvider = StateProvider.family<ThemeItem?, int>((ref, id) {
  return kThemes.firstWhere((t) => t.id == id, orElse: () => kThemes.first);
});

class GarageScreen extends ConsumerStatefulWidget {
  final int themeId;
  final GarageArgs args;

  const GarageScreen({super.key, required this.themeId, this.args = const GarageArgs()});

  @override
  ConsumerState<GarageScreen> createState() => _GarageScreenState();
}

class _GarageScreenState extends ConsumerState<GarageScreen> {
  List<StickerLayer> _stickers = [];
  List<List<StickerLayer>> _undoStack = [];
  List<List<StickerLayer>> _redoStack = [];
  int? _selectedStickerIndex;
  bool _drawerOpen = false;

  final GlobalKey _canvasKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Load sticker layers từ draft (nếu mở từ library)
    if (widget.args.initialStickers.isNotEmpty) {
      _stickers = List.from(widget.args.initialStickers);
    }
    // Preload ad ngay khi vào Screen 4 — sẵn sàng khi user bấm Apply
    adService.preloadRewarded();
  }

  /// Capture canvas (background + stickers) thành file PNG tạm.
  /// Deselect sticker trước để không có selection UI trong ảnh.
  Future<String?> _captureCanvas() async {
    // Deselect để ẩn selection border và X button
    if (_selectedStickerIndex != null) {
      setState(() => _selectedStickerIndex = null);
      await WidgetsBinding.instance.endOfFrame;
    }
    try {
      final boundary =
          _canvasKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return null;
      final bytes = byteData.buffer.asUint8List();
      final file = File(
          '${(await getTemporaryDirectory()).path}/wp_canvas_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(bytes);
      return file.path;
    } catch (e) {
      debugPrint('[GarageCapture] Error: $e');
      return null;
    }
  }

  void _addSticker(StickerLayer s) {
    setState(() {
      _undoStack.add(List.from(_stickers));
      _redoStack.clear();
      _stickers = [..._stickers, s];
    });
  }

  void _undo() {
    if (_undoStack.isEmpty) {
      CyberToast.show(context, 'NOTHING TO UNDO');
      return;
    }
    setState(() {
      _redoStack.add(List.from(_stickers));
      _stickers = List.from(_undoStack.removeLast());
      _selectedStickerIndex = null;
    });
  }

  void _redo() {
    if (_redoStack.isEmpty) {
      CyberToast.show(context, 'NOTHING TO REDO');
      return;
    }
    setState(() {
      _undoStack.add(List.from(_stickers));
      _stickers = List.from(_redoStack.removeLast());
      _selectedStickerIndex = null;
    });
  }

  Future<bool> _onWillPop() async {
    if (_stickers.isEmpty) return true;
    final result = await _showUnsavedChangesModal();
    return result == _UnsavedAction.discard;
  }

  void _navigateBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamed('home');
    }
  }

  Future<_UnsavedAction?> _showUnsavedChangesModal() async {
    return showDialog<_UnsavedAction>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _UnsavedChangesModal(
        onSaveDraft: () async {
          // LoadingModal đè lên dialog — canvas vẫn trong tree nên vẫn capture được
          LoadingModal.show(context, message: 'SAVING...');

          final snapshotPath = await _captureCanvas();
          final stickerLayersJson =
              _stickers.map((s) => jsonEncode(s.toJson())).toList();

          final theme = kThemes.firstWhere((t) => t.id == widget.themeId);
          final draft = LibraryDraft(
            id: DateTime.now().millisecondsSinceEpoch,
            title: 'DRAFT_${theme.title}',
            backgroundImg: theme.img,
            stickerPaths: _stickers.map((s) => s.src).toList(),
            savedAt: DateTime.now(),
            snapshotPath: snapshotPath,
            stickerLayersJson: stickerLayersJson,
          );
          await ref.read(libraryProvider.notifier).saveDraft(draft);

          if (!mounted) return;
          Navigator.of(context).pop(_UnsavedAction.saveDraft); // đóng dialog
          await WidgetsBinding.instance.endOfFrame;
          LoadingModal.hide();
          if (mounted) _navigateBack();
        },
        onDiscard: () => Navigator.of(context).pop(_UnsavedAction.discard),
        onKeep: () => Navigator.of(context).pop(_UnsavedAction.keep),
      ),
    );
  }

  Future<void> _handleApply() async {
    final theme = kThemes.firstWhere((t) => t.id == widget.themeId, orElse: () => kThemes.first);
    final entitlement = ref.read(entitlementProvider).valueOrNull;

    // User premium → apply thẳng, không cần xem ads
    if (entitlement?.isPremium == true) {
      await _doApply(theme);
      return;
    }

    // Mọi trường hợp còn lại: S4 bắt buộc xem ads trước khi apply
    await RewardModal.show(
      context,
      rewardContext: RewardContext.applyS4,
      onRewarded: () async {
        if (mounted) await _doApply(theme);
      },
    );
  }

  Future<void> _doApply(ThemeItem theme) async {
    // Hiện dialog chọn target ngay — không block bằng capture trước
    final target = await showDialog<WallpaperTarget>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const SetWallpaperModal(),
    );
    if (target == null || !mounted) return;

    // Capture + prefs + set đều trong loading phase
    LoadingModal.show(context, message: 'SYSTEM APPLYING...');

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('pending_garage_theme_id', widget.themeId);
    await prefs.setStringList('pending_garage_stickers',
        _stickers.map((s) => jsonEncode(s.toJson())).toList());

    final capturedPath = await _captureCanvas();
    final imagePath = capturedPath ?? theme.img;
    await prefs.setString('pending_share_image', imagePath);

    final ok = await WallpaperService.setWallpaper(imagePath, target);

    if (!mounted) return;

    if (ok) {
      HapticFeedback.heavyImpact();
      CyberToast.show(context, 'WALLPAPER SET!', haptic: false);
      final stickerLayersJson = _stickers.map((s) => jsonEncode(s.toJson())).toList();
      // Reset state — modal vẫn đang hiển thị, user không thấy garage trống
      setState(() {
        _stickers = [];
        _undoStack = [];
        _redoStack = [];
      });
      // Buffer 1s cho MIUI kill window — modal vẫn hiển thị trong suốt thời gian này
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      // Xóa prefs ngay trước khi navigate — không còn risk double-restore
      await prefs.remove('pending_share_image');
      await prefs.remove('pending_garage_theme_id');
      await prefs.remove('pending_garage_stickers');
      LoadingModal.hide();
      context.pushNamed('share', extra: ShareArgs(
        imagePath: imagePath,
        backContext: WallpaperSetContext.garage,
        themeTitle: theme.title,
        stickerLayersJson: stickerLayersJson,
        themeId: widget.themeId,
      ));
    } else {
      LoadingModal.hide();
      CyberToast.show(context, 'SET FAILED. TRY AGAIN.', variant: ToastVariant.pink);
      await prefs.remove('pending_share_image');
      await prefs.remove('pending_garage_theme_id');
      await prefs.remove('pending_garage_stickers');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = kThemes.firstWhere(
      (t) => t.id == widget.themeId,
      orElse: () => kThemes.first,
    );

    return PopScope(
      onPopInvoked: (didPop) async {
        if (!didPop) {
          final canPop = await _onWillPop();
          if (canPop && mounted) _navigateBack();
        }
      },
      canPop: _stickers.isEmpty,
      child: Scaffold(
        backgroundColor: AppColors.bgAmoled,
        body: SafeArea(
          child: Column(
            children: [
              // Toolbar
              _GarageToolbar(
                onBack: () async {
                  if (_stickers.isEmpty) {
                    _navigateBack();
                  } else {
                    final result = await _showUnsavedChangesModal();
                    if (mounted && result == _UnsavedAction.discard) _navigateBack();
                  }
                },
                onUndo: _undo,
                onRedo: _redo,
                onToggleDrawer: () => setState(() => _drawerOpen = !_drawerOpen),
                onPreview: () => context.pushNamed('preview', extra: PreviewArgs(
                  backgroundImg: theme.img,
                  stickerPaths: _stickers.map((s) => s.src).toList(),
                )),
                onApply: _handleApply,
                drawerOpen: _drawerOpen,
              ),

              // Canvas (bọc RepaintBoundary để capture ảnh có sticker)
              Expanded(
                child: RepaintBoundary(
                  key: _canvasKey,
                  child: _GarageCanvas(
                  backgroundImg: theme.img,
                  stickers: _stickers,
                  selectedIndex: _selectedStickerIndex,
                  onStickerMoved: (i, layer) {
                    setState(() {
                      _undoStack.add(List.from(_stickers));
                      _redoStack.clear();
                      _stickers[i] = layer;
                    });
                  },
                  onStickerSelected: (i) => setState(() => _selectedStickerIndex = i),
                  onDeselect: () => setState(() => _selectedStickerIndex = null),
                  onStickerRemoved: (i) {
                    setState(() {
                      _undoStack.add(List.from(_stickers));
                      _redoStack.clear();
                      _stickers.removeAt(i);
                      _selectedStickerIndex = null;
                    });
                  },
                ),
                ), // RepaintBoundary
              ),

              // Sticker drawer
              if (_drawerOpen)
                _StickerDrawer(
                  entitlement: ref.watch(entitlementProvider).valueOrNull,
                  onStickerAdd: (src, isPremium) async {
                    if (isPremium) {
                      final entitlement = ref.read(entitlementProvider).valueOrNull;
                      final id = kStickers.firstWhere((s) => s.src == src).id;
                      if (!(entitlement?.isStickerUnlocked(id) ?? false)) {
                        await RewardModal.show(
                          context,
                          rewardContext: RewardContext.unlockItem,
                          onRewarded: () async {
                            await ref.read(entitlementProvider.notifier).unlockSticker(id);
                            _addSticker(StickerLayer(src: src));
                            CyberToast.show(context, 'STICKER UNLOCKED!', variant: ToastVariant.flash);
                          },
                        );
                        return;
                      }
                    }
                    _addSticker(StickerLayer(src: src));
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _UnsavedAction { saveDraft, discard, keep }

class _GarageToolbar extends StatelessWidget {
  final VoidCallback onBack, onUndo, onRedo, onToggleDrawer, onPreview, onApply;
  final bool drawerOpen;

  const _GarageToolbar({
    required this.onBack,
    required this.onUndo,
    required this.onRedo,
    required this.onToggleDrawer,
    required this.onPreview,
    required this.onApply,
    required this.drawerOpen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      color: AppColors.bgCyber,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.arrow_back_ios, color: AppColors.neonCyan, size: 20), onPressed: onBack),
          IconButton(icon: const Icon(Icons.undo, color: AppColors.textMuted, size: 20), onPressed: onUndo),
          IconButton(icon: const Icon(Icons.redo, color: AppColors.textMuted, size: 20), onPressed: onRedo),
          const Spacer(),
          IconButton(
            icon: Icon(Icons.layers_outlined, color: drawerOpen ? AppColors.neonCyan : AppColors.textMuted, size: 22),
            onPressed: onToggleDrawer,
          ),
          IconButton(icon: const Icon(Icons.fullscreen, color: AppColors.textMuted, size: 22), onPressed: onPreview),
          GestureDetector(
            onTap: onApply,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.neonCyan,
                boxShadow: AppTheme.cyanGlow,
              ),
              child: const Text(
                'APPLY',
                style: TextStyle(
                  color: AppColors.bgAmoled,
                  fontFamily: 'Orbitron',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Canvas giữ live gesture state, full-screen GestureDetector xử lý pan + scale
class _GarageCanvas extends StatefulWidget {
  final String backgroundImg;
  final List<StickerLayer> stickers;
  final int? selectedIndex;
  final void Function(int, StickerLayer) onStickerMoved;
  final void Function(int) onStickerSelected;
  final VoidCallback onDeselect;
  final void Function(int) onStickerRemoved;

  const _GarageCanvas({
    required this.backgroundImg,
    required this.stickers,
    required this.selectedIndex,
    required this.onStickerMoved,
    required this.onStickerSelected,
    required this.onDeselect,
    required this.onStickerRemoved,
  });

  @override
  State<_GarageCanvas> createState() => _GarageCanvasState();
}

class _GarageCanvasState extends State<_GarageCanvas> {
  double? _liveX, _liveY, _liveScale;
  double _baseScale = 1.0;

  @override
  void didUpdateWidget(_GarageCanvas old) {
    super.didUpdateWidget(old);
    // Reset live khi chuyển sang sticker khác
    if (old.selectedIndex != widget.selectedIndex) {
      _liveX = _liveY = _liveScale = null;
    }
  }

  void _scaleStart(ScaleStartDetails d) {
    if (widget.selectedIndex == null) return;
    final s = widget.stickers[widget.selectedIndex!];
    _baseScale = s.scale;
    _liveX = s.x;
    _liveY = s.y;
    _liveScale = s.scale;
  }

  void _scaleUpdate(ScaleUpdateDetails d) {
    if (widget.selectedIndex == null || _liveX == null) return;
    setState(() {
      _liveX = _liveX! + d.focalPointDelta.dx;
      _liveY = _liveY! + d.focalPointDelta.dy;
      if (d.pointerCount >= 2) {
        _liveScale = (_baseScale * d.scale).clamp(0.3, 4.0);
      }
    });
  }

  void _scaleEnd(ScaleEndDetails d) {
    if (widget.selectedIndex == null || _liveX == null) return;
    final i = widget.selectedIndex!;
    widget.onStickerMoved(
      i,
      widget.stickers[i].copyWith(x: _liveX!, y: _liveY!, scale: _liveScale!),
    );
    setState(() => _liveX = _liveY = _liveScale = null);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background — tap để deselect
        GestureDetector(
          onTap: widget.onDeselect,
          child: Image.asset(widget.backgroundImg, fit: BoxFit.cover),
        ),
        // Sticker visuals (chỉ tap để chọn, gesture do canvas xử lý)
        ...List.generate(widget.stickers.length, (i) {
          final s = widget.stickers[i];
          final selected = widget.selectedIndex == i;
          return _StickerVisual(
            layer: s,
            selected: selected,
            displayX: selected && _liveX != null ? _liveX! : s.x,
            displayY: selected && _liveY != null ? _liveY! : s.y,
            displayScale: selected && _liveScale != null ? _liveScale! : s.scale,
            onTap: () => widget.onStickerSelected(i),
            onRemove: () => widget.onStickerRemoved(i),
          );
        }),
        // Full-screen gesture overlay — translucent để tap sticker/X button vẫn được
        if (widget.selectedIndex != null)
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onScaleStart: _scaleStart,
            onScaleUpdate: _scaleUpdate,
            onScaleEnd: _scaleEnd,
          ),
      ],
    );
  }
}

// Sticker chỉ render, không tự xử lý gesture scale/pan
class _StickerVisual extends StatelessWidget {
  final StickerLayer layer;
  final bool selected;
  final double displayX, displayY, displayScale;
  final VoidCallback onTap, onRemove;

  const _StickerVisual({
    required this.layer,
    required this.selected,
    required this.displayX,
    required this.displayY,
    required this.displayScale,
    required this.onTap,
    required this.onRemove,
  });

  static const double _base = 100.0;
  static const double _xBtnSize = 24.0;
  static const double _xBtnOffset = 12.0;

  @override
  Widget build(BuildContext context) {
    final size = _base * displayScale;
    return Positioned(
      left: displayX - _xBtnOffset,
      top: displayY - _xBtnOffset,
      child: SizedBox(
        width: size + _xBtnOffset * 2,
        height: size + _xBtnOffset * 2,
        child: Stack(
          children: [
            Positioned(
              left: _xBtnOffset,
              top: _xBtnOffset,
              child: GestureDetector(
                onTap: onTap,
                child: Container(
                  width: size,
                  height: size,
                  decoration: selected
                      ? BoxDecoration(
                          border: Border.all(color: AppColors.neonCyan, width: 1.5),
                        )
                      : null,
                  child: Image.asset(layer.src, fit: BoxFit.cover),
                ),
              ),
            ),
            if (selected)
              Positioned(
                top: 0,
                right: 0,
                child: GestureDetector(
                  onTap: onRemove,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: _xBtnSize,
                    height: _xBtnSize,
                    decoration: const BoxDecoration(
                      color: AppColors.neonPink,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, color: Colors.white, size: 14),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StickerDrawer extends StatelessWidget {
  final void Function(String src, bool isPremium) onStickerAdd;
  final EntitlementState? entitlement;

  const _StickerDrawer({required this.onStickerAdd, this.entitlement});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      color: AppColors.bgCyber,
      child: GridView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 6,
          crossAxisSpacing: 6,
        ),
        itemCount: kStickers.length,
        itemBuilder: (_, i) {
          final s = kStickers[i];
          final isLocked = s.isPremium && !(entitlement?.isStickerUnlocked(s.id) ?? false);
          return GestureDetector(
            onTap: () => onStickerAdd(s.src, s.isPremium),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(4),
                  child: Image.asset(s.src),
                ),
                if (isLocked)
                  const Positioned(
                    top: 2,
                    right: 2,
                    child: Icon(Icons.lock, color: Colors.amber, size: 12),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _UnsavedChangesModal extends StatelessWidget {
  final VoidCallback onSaveDraft, onDiscard, onKeep;

  const _UnsavedChangesModal({
    required this.onSaveDraft,
    required this.onDiscard,
    required this.onKeep,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: AppColors.bgCard,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'UNSAVED CHANGES',
                style: TextStyle(color: AppColors.neonYellow, fontFamily: 'Orbitron', fontSize: 14, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              CyberButton(label: 'SAVE DRAFT', fullWidth: true, onTap: onSaveDraft),
              const SizedBox(height: 10),
              CyberButton(label: 'HỦY THAY ĐỔI', variant: CyberButtonVariant.danger, fullWidth: true, onTap: onDiscard),
              const SizedBox(height: 10),
              CyberButton(label: 'TIẾP TỤC CHỈNH SỬA', variant: CyberButtonVariant.ghost, fullWidth: true, onTap: onKeep),
            ],
          ),
        ),
      ),
    );
  }
}

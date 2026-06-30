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
import '../../core/constants/analytics_events.dart';
import '../../core/services/pending_restore_service.dart';
import '../../core/services/ad_service.dart';
import '../../core/l10n/locale_provider.dart';
import '../../core/services/analytics_service.dart';
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
  late DateTime _editStartTime;

  @override
  void initState() {
    super.initState();
    _editStartTime = DateTime.now();
    if (widget.args.initialStickers.isNotEmpty) {
      _stickers = List.from(widget.args.initialStickers);
    }
    adService.preloadRewarded();
    analyticsService.logEditorOpened(
      themeId: widget.themeId.toString(),
      source: widget.args.fromLibrary ? 'library' : 'gallery',
    );
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
          '${(await getTemporaryDirectory()).path}/wp_canvas_preview.png');
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
    analyticsService.logStickerAddedToCanvas(
      stickerId: s.src,
      themeId: widget.themeId.toString(),
      canvasStickerCount: _stickers.length,
    );
  }

  void _undo() {
    if (_undoStack.isEmpty) {
      CyberToast.show(context, ref.read(stringsProvider).nothingToUndo);
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
      CyberToast.show(context, ref.read(stringsProvider).nothingToRedo);
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
          if (!mounted) return;
          // Pop dialog TRƯỚC — LoadingModal.show() gọi popUntil(PopupRoute)
          // nên nếu show() trước, nó dismiss dialog luôn rồi pop() sau
          // sẽ pop Garage (root khi MIUI restart) → crash.
          Navigator.of(context).pop(_UnsavedAction.saveDraft);
          await WidgetsBinding.instance.endOfFrame;

          if (!mounted) return;
          LoadingModal.show(context, messageBuilder: (s) => s.saving);

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
    // Dùng .future để đảm bảo entitlement đã load xong (tránh race condition khi
    // app restart từ MIUI → valueOrNull có thể null dù user có premium)
    final entitlement = await ref.read(entitlementProvider.future);

    if (!mounted) return;

    // User premium → apply thẳng, không cần xem ads
    if (entitlement.isPremium) {
      await _doApply(theme);
      return;
    }

    // Mọi trường hợp còn lại: bắt buộc xem ads trước khi apply
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
    LoadingModal.show(context, messageBuilder: (s) => s.systemApplying);

    final stickersJson = _stickers.map((s) => jsonEncode(s.toJson())).toList();
    final capturedPath = await _captureCanvas();
    final imagePath = capturedPath ?? theme.img;

    await pendingRestoreService.saveGarageApply(
      themeId: widget.themeId,
      stickersJson: stickersJson,
      imagePath: imagePath,
    );

    await WallpaperService.startShield();
    final ok = await WallpaperService.setWallpaper(imagePath, target);
    await WallpaperService.stopShield();

    if (!mounted) return;

    if (ok) {
      HapticFeedback.heavyImpact();
      CyberToast.show(context, ref.read(stringsProvider).wallpaperSet, haptic: false);
      final editDurationSec = DateTime.now().difference(_editStartTime).inSeconds;
      analyticsService.logWallpaperExported(
        themeId: widget.themeId.toString(),
        stickerCount: _stickers.length,
        editDurationSec: editDurationSec,
        exportType: AnalyticsValue.save,
      );
      analyticsService.logWallpaperSetAs(
        themeId: widget.themeId.toString(),
        target: switch (target) {
          WallpaperTarget.home => AnalyticsValue.homeScreen,
          WallpaperTarget.lock => AnalyticsValue.lockScreen,
          WallpaperTarget.both => AnalyticsValue.both,
        },
      );
      // Reset state — modal vẫn đang hiển thị, user không thấy garage trống
      setState(() {
        _stickers = [];
        _undoStack = [];
        _redoStack = [];
      });
      // Buffer 1s cho MIUI kill window — modal vẫn hiển thị trong suốt thời gian này
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      await pendingRestoreService.clearGarageApply();
      LoadingModal.hide();
      context.pushNamed('share', extra: ShareArgs(
        imagePath: imagePath,
        backContext: WallpaperSetContext.garage,
        themeTitle: theme.title,
        stickerLayersJson: stickersJson,
        themeId: widget.themeId,
      ));
    } else {
      LoadingModal.hide();
      CyberToast.show(context, ref.read(stringsProvider).wallpaperSetFailed, variant: ToastVariant.pink);
      await pendingRestoreService.clearGarageApply();
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
                  stickerLayers: List.unmodifiable(_stickers),
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
                    final removed = _stickers[i];
                    setState(() {
                      _undoStack.add(List.from(_stickers));
                      _redoStack.clear();
                      _stickers.removeAt(i);
                      _selectedStickerIndex = null;
                    });
                    analyticsService.logStickerRemoved(
                      stickerId: removed.src,
                      themeId: widget.themeId.toString(),
                    );
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
                          isFirstUnlock: !(entitlement?.isStickerUnlocked(id) ?? false),
                          onRewarded: () async {
                            await ref.read(entitlementProvider.notifier).unlockSticker(id);
                            _addSticker(StickerLayer(src: src));
                            CyberToast.show(context, ref.read(stringsProvider).stickerUnlocked, variant: ToastVariant.flash);
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

class _GarageToolbar extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
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
              child: Text(
                ref.watch(stringsProvider).applyButton,
                style: const TextStyle(
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
  double? _liveX, _liveY, _liveScale, _liveRotation;
  double _baseScale = 1.0;
  double _baseRotation = 0.0;

  @override
  void didUpdateWidget(_GarageCanvas old) {
    super.didUpdateWidget(old);
    if (old.selectedIndex != widget.selectedIndex) {
      _liveX = _liveY = _liveScale = _liveRotation = null;
    }
  }

  void _scaleStart(ScaleStartDetails d) {
    if (widget.selectedIndex == null) return;
    final s = widget.stickers[widget.selectedIndex!];
    _baseScale = s.scale;
    _baseRotation = s.rotation;
    _liveX = s.x;
    _liveY = s.y;
    _liveScale = s.scale;
    _liveRotation = s.rotation;
  }

  void _scaleUpdate(ScaleUpdateDetails d) {
    if (widget.selectedIndex == null || _liveX == null) return;
    setState(() {
      _liveX = _liveX! + d.focalPointDelta.dx;
      _liveY = _liveY! + d.focalPointDelta.dy;
      if (d.pointerCount >= 2) {
        _liveScale = (_baseScale * d.scale).clamp(0.3, 4.0);
        _liveRotation = _baseRotation + d.rotation;
      }
    });
  }

  void _scaleEnd(ScaleEndDetails d) {
    if (widget.selectedIndex == null || _liveX == null) return;
    final i = widget.selectedIndex!;
    widget.onStickerMoved(
      i,
      widget.stickers[i].copyWith(
        x: _liveX!,
        y: _liveY!,
        scale: _liveScale!,
        rotation: _liveRotation!,
      ),
    );
    setState(() => _liveX = _liveY = _liveScale = _liveRotation = null);
  }

  void _onHandleRotateDelta(int i, double delta) {
    setState(() {
      _liveRotation = (_liveRotation ?? widget.stickers[i].rotation) + delta;
    });
  }

  void _onHandleRotateEnd(int i) {
    if (_liveRotation == null) return;
    widget.onStickerMoved(
      i,
      widget.stickers[i].copyWith(rotation: _liveRotation!),
    );
    setState(() => _liveRotation = null);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        GestureDetector(
          onTap: widget.onDeselect,
          child: Image.asset(widget.backgroundImg, fit: BoxFit.cover),
        ),
        ...List.generate(widget.stickers.length, (i) {
          final s = widget.stickers[i];
          final selected = widget.selectedIndex == i;
          return _StickerVisual(
            key: ValueKey('sticker_$i'),
            layer: s,
            selected: selected,
            displayX: selected && _liveX != null ? _liveX! : s.x,
            displayY: selected && _liveY != null ? _liveY! : s.y,
            displayScale: selected && _liveScale != null ? _liveScale! : s.scale,
            displayRotation: selected && _liveRotation != null ? _liveRotation! : s.rotation,
            onTap: () => widget.onStickerSelected(i),
            onRemove: () => widget.onStickerRemoved(i),
            onRotateDelta: (delta) => _onHandleRotateDelta(i, delta),
            onRotateEnd: () => _onHandleRotateEnd(i),
          );
        }),
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

// Sticker render + rotate handle. Scale/pan gesture handled by canvas overlay.
class _StickerVisual extends StatefulWidget {
  final StickerLayer layer;
  final bool selected;
  final double displayX, displayY, displayScale, displayRotation;
  final VoidCallback onTap, onRemove;
  final void Function(double delta) onRotateDelta;
  final VoidCallback onRotateEnd;

  const _StickerVisual({
    super.key,
    required this.layer,
    required this.selected,
    required this.displayX,
    required this.displayY,
    required this.displayScale,
    required this.displayRotation,
    required this.onTap,
    required this.onRemove,
    required this.onRotateDelta,
    required this.onRotateEnd,
  });

  @override
  State<_StickerVisual> createState() => _StickerVisualState();
}

class _StickerVisualState extends State<_StickerVisual> {
  static const double _base = 100.0;
  static const double _handleSize = 22.0;
  static const double _pad = 11.0; // half handle size, used as padding

  final _imageKey = GlobalKey();
  Offset? _lastHandlePos;

  Offset _getImageCenter() {
    final box = _imageKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return Offset.zero;
    return box.localToGlobal(Offset(box.size.width / 2, box.size.height / 2));
  }

  void _onRotateStart(DragStartDetails d) {
    _lastHandlePos = d.globalPosition;
  }

  void _onRotateUpdate(DragUpdateDetails d) {
    if (_lastHandlePos == null) return;
    final center = _getImageCenter();
    final prev = _lastHandlePos! - center;
    final curr = d.globalPosition - center;
    final delta = curr.direction - prev.direction;
    widget.onRotateDelta(delta);
    _lastHandlePos = d.globalPosition;
  }

  void _onRotateEnd(DragEndDetails d) {
    _lastHandlePos = null;
    widget.onRotateEnd();
  }

  @override
  Widget build(BuildContext context) {
    final size = _base * widget.displayScale;

    return Positioned(
      left: widget.displayX - _pad,
      top: widget.displayY - _pad,
      // Rotate the ENTIRE box (image + handles) around its center
      child: Transform.rotate(
        angle: widget.displayRotation,
        child: SizedBox(
          width: size + _pad * 2,
          height: size + _pad * 2,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Sticker image
              Positioned(
                left: _pad,
                top: _pad,
                child: GestureDetector(
                  onTap: widget.onTap,
                  child: Container(
                    key: _imageKey,
                    width: size,
                    height: size,
                    decoration: widget.selected
                        ? BoxDecoration(
                            border: Border.all(color: AppColors.neonCyan, width: 1.5),
                          )
                        : null,
                    child: Image.asset(widget.layer.src, fit: BoxFit.cover),
                  ),
                ),
              ),

              // Remove button — top-right corner
              if (widget.selected)
                Positioned(
                  top: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: widget.onRemove,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: _handleSize,
                      height: _handleSize,
                      decoration: const BoxDecoration(
                        color: AppColors.neonPink,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, color: Colors.white, size: 13),
                    ),
                  ),
                ),

              // Rotate handle — bottom-right corner (drag to rotate)
              if (widget.selected)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onPanStart: _onRotateStart,
                    onPanUpdate: _onRotateUpdate,
                    onPanEnd: _onRotateEnd,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: _handleSize,
                      height: _handleSize,
                      decoration: const BoxDecoration(
                        color: AppColors.neonCyan,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.rotate_right, color: Colors.black, size: 13),
                    ),
                  ),
                ),
            ],
          ),
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

class _UnsavedChangesModal extends ConsumerWidget {
  final VoidCallback onSaveDraft, onDiscard, onKeep;

  const _UnsavedChangesModal({
    required this.onSaveDraft,
    required this.onDiscard,
    required this.onKeep,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
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
              Text(
                s.unsavedChanges,
                style: const TextStyle(color: AppColors.neonYellow, fontFamily: 'Orbitron', fontSize: 14, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              CyberButton(label: s.saveDraft, fullWidth: true, onTap: onSaveDraft),
              const SizedBox(height: 10),
              CyberButton(label: s.discardChanges, variant: CyberButtonVariant.danger, fullWidth: true, onTap: onDiscard),
              const SizedBox(height: 10),
              CyberButton(label: s.continueEditing, variant: CyberButtonVariant.ghost, fullWidth: true, onTap: onKeep),
            ],
          ),
        ),
      ),
    );
  }
}

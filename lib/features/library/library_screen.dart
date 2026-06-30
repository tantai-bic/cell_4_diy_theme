import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/theme_item.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/widgets/cyber_toast.dart';
import '../../core/theme/widgets/loading_modal.dart';
import '../../providers/library_provider.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  bool _bulkMode = false;
  final Set<int> _selected = {};

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _deleteSelected() async {
    if (_selected.isEmpty) return;
    LoadingModal.show(context, message: 'DELETING...');
    if (_tabCtrl.index == 0) {
      await ref.read(libraryProvider.notifier).deleteWallpapers(_selected.toList());
    } else {
      await ref.read(libraryProvider.notifier).deleteDrafts(_selected.toList());
    }
    LoadingModal.hide();
    setState(() {
      _selected.clear();
      _bulkMode = false;
    });
    CyberToast.show(context, 'DELETED');
  }

  @override
  Widget build(BuildContext context) {
    final library = ref.watch(libraryProvider);

    return Scaffold(
      backgroundColor: AppColors.bgAmoled,
      appBar: AppBar(
        backgroundColor: AppColors.bgCyber,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.neonCyan),
          onPressed: () => context.pop(),
        ),
        title: const Text('LIBRARY', style: TextStyle(color: AppColors.neonCyan, fontFamily: 'Orbitron', fontSize: 14)),
        actions: [
          if (_bulkMode)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.neonPink),
              onPressed: _deleteSelected,
            ),
          IconButton(
            icon: Icon(_bulkMode ? Icons.close : Icons.select_all, color: AppColors.textMuted),
            onPressed: () => setState(() {
              _bulkMode = !_bulkMode;
              _selected.clear();
            }),
          ),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: AppColors.neonCyan,
          labelColor: AppColors.neonCyan,
          unselectedLabelColor: AppColors.textMuted,
          labelStyle: const TextStyle(fontFamily: 'Orbitron', fontSize: 11),
          tabs: const [
            Tab(text: 'WALLPAPER'),
            Tab(text: 'DRAFT'),
          ],
        ),
      ),
      body: library.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.neonCyan)),
        error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: AppColors.neonPink))),
        data: (state) => TabBarView(
          controller: _tabCtrl,
          children: [
            _WallpaperTab(
              items: state.wallpapers,
              bulkMode: _bulkMode,
              selected: _selected,
              onSelect: (key) => setState(() {
                if (_selected.contains(key)) _selected.remove(key); else _selected.add(key);
              }),
            ),
            _DraftTab(
              items: state.drafts,
              bulkMode: _bulkMode,
              selected: _selected,
              onSelect: (key) => setState(() {
                if (_selected.contains(key)) _selected.remove(key); else _selected.add(key);
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _WallpaperTab extends StatelessWidget {
  final List<LibraryWallpaper> items;
  final bool bulkMode;
  final Set<int> selected;
  final void Function(int) onSelect;

  const _WallpaperTab({required this.items, required this.bulkMode, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return _empty('NO WALLPAPERS YET');
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 9 / 16,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final w = items[i];
        final key = w.key as int? ?? i;
        return GestureDetector(
          onTap: bulkMode ? () => onSelect(key) : () => context.pushNamed('wall-detail', pathParameters: {'key': key.toString()}),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _imageWidget(w.imagePath),
              if (bulkMode && selected.contains(key))
                Container(color: AppColors.neonCyan.withOpacity(0.3),
                  child: const Icon(Icons.check_circle, color: AppColors.neonCyan, size: 32)),
            ],
          ),
        );
      },
    );
  }
}

class _DraftTab extends StatelessWidget {
  final List<LibraryDraft> items;
  final bool bulkMode;
  final Set<int> selected;
  final void Function(int) onSelect;

  const _DraftTab({required this.items, required this.bulkMode, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return _empty('NO DRAFTS YET');
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 9 / 16,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final d = items[i];
        final key = d.key as int? ?? i;
        return GestureDetector(
          onTap: bulkMode ? () => onSelect(key) : () => context.pushNamed('draft-detail', pathParameters: {'key': key.toString()}),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _draftThumbnail(d),
              Positioned(bottom: 8, left: 8, right: 8,
                child: Text(d.title, style: const TextStyle(color: AppColors.textMain, fontFamily: 'Orbitron', fontSize: 9))),
              if (bulkMode && selected.contains(key))
                Container(color: AppColors.neonCyan.withOpacity(0.3),
                  child: const Icon(Icons.check_circle, color: AppColors.neonCyan, size: 32)),
            ],
          ),
        );
      },
    );
  }
}

Widget _empty(String msg) => Center(
  child: Text(msg, style: const TextStyle(color: AppColors.textMuted, fontFamily: 'Orbitron', fontSize: 13)),
);

/// Hiển thị snapshot nếu có (file path), fallback về asset nếu không.
Widget _draftThumbnail(LibraryDraft d) {
  final snap = d.snapshotPath;
  if (snap != null && snap.isNotEmpty) {
    final f = File(snap);
    if (f.existsSync()) {
      return Image.file(f, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Image.asset(d.backgroundImg, fit: BoxFit.cover));
    }
  }
  return Image.asset(d.backgroundImg, fit: BoxFit.cover);
}

/// file path (/) → Image.file; asset path → Image.asset
Widget _imageWidget(String path, {BoxFit fit = BoxFit.cover}) {
  if (path.startsWith('/')) {
    return Image.file(File(path), fit: fit,
        errorBuilder: (_, __, ___) => Container(color: AppColors.bgCard));
  }
  return Image.asset(path, fit: fit);
}

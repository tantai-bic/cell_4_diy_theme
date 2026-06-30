import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/app_data.dart';
import '../../core/models/theme_item.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/widgets/cyber_button.dart';
import '../../providers/library_provider.dart';
import '../../router/app_router.dart';

class DraftDetailScreen extends ConsumerWidget {
  final int draftKey;
  const DraftDetailScreen({super.key, required this.draftKey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final library = ref.watch(libraryProvider).valueOrNull;
    if (library == null) return const SizedBox.shrink();

    final draft = library.drafts.firstWhere(
      (d) => (d.key as int?) == draftKey,
      orElse: () => library.drafts.first,
    );

    // Tìm themeId từ backgroundImg để navigate đúng theme
    final theme = kThemes.firstWhere(
      (t) => t.img == draft.backgroundImg,
      orElse: () => kThemes.first,
    );

    // Sticker layers với position + scale đầy đủ
    final stickerLayers = draft.stickerLayers;

    return Scaffold(
      backgroundColor: AppColors.bgAmoled,
      appBar: AppBar(
        backgroundColor: AppColors.bgCyber,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.neonCyan),
          onPressed: () => context.pop(),
        ),
        title: Text(
          draft.title,
          style: const TextStyle(
            color: AppColors.neonCyan,
            fontFamily: 'Orbitron',
            fontSize: 13,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _DraftPreview(draft: draft, stickerLayers: stickerLayers),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: CyberButton(
              label: 'CONTINUE MODDING',
              fullWidth: true,
              onTap: () => context.pushNamed(
                'garage',
                pathParameters: {'themeId': theme.id.toString()},
                extra: GarageArgs(
                  fromLibrary: true,
                  initialStickers: stickerLayers,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DraftPreview extends StatelessWidget {
  final LibraryDraft draft;
  final List stickerLayers;

  const _DraftPreview({required this.draft, required this.stickerLayers});

  @override
  Widget build(BuildContext context) {
    final snapshot = draft.snapshotPath;

    // Nếu có snapshot (background + stickers đã capture) → hiển thị nguyên
    if (snapshot != null && snapshot.isNotEmpty && File(snapshot).existsSync()) {
      return Image.file(File(snapshot), fit: BoxFit.contain, width: double.infinity);
    }

    // Fallback: reconstruct từ background + sticker paths (old drafts không có snapshot)
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(draft.backgroundImg, fit: BoxFit.cover),
        ...draft.stickerPaths.map(
          (src) => Center(child: Image.asset(src, width: 100, height: 100)),
        ),
      ],
    );
  }
}

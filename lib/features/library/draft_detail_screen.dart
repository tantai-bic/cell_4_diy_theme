import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/l10n/locale_provider.dart';
import '../../core/models/app_data.dart';
import '../../core/models/theme_item.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/widgets/banner_ad_widget.dart';
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

    final theme = kThemes.firstWhere(
      (t) => t.img == draft.backgroundImg,
      orElse: () => kThemes.first,
    );

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
      // Button + Banner luôn dưới cùng
      bottomNavigationBar: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              color: AppColors.bgCyber,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: CyberButton(
                label: ref.watch(stringsProvider).continueMod,
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
            const BannerAdWidget(),
          ],
        ),
      ),
      body: SizedBox.expand(
        child: _DraftPreview(draft: draft, stickerLayers: stickerLayers),
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

    if (snapshot != null && snapshot.isNotEmpty && File(snapshot).existsSync()) {
      return Image.file(
        File(snapshot),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }

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

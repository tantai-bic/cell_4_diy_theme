import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../router/app_router.dart';

class PreviewScreen extends StatefulWidget {
  final PreviewArgs args;
  const PreviewScreen({super.key, required this.args});

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  bool _showClock = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background
          if (widget.args.backgroundImg.isNotEmpty)
            Image.asset(widget.args.backgroundImg, fit: BoxFit.cover),

          // Stickers (no controls)
          ...widget.args.stickerPaths.map((src) => Center(
                child: Image.asset(src, width: 100, height: 100),
              )),

          // Mock HUD overlay
          if (_showClock)
            Positioned(
              top: 80,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  const Text(
                    '21:43',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 64,
                      fontFamily: 'Orbitron',
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  Text(
                    'SUN, 29 JUN 2026',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontFamily: 'Rajdhani',
                      fontSize: 16,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            )
          else
            // App grid mock
            Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 20,
                runSpacing: 20,
                children: List.generate(
                  8,
                  (_) => Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.bgCard.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),

          // Toggle Clock/Apps
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => setState(() => _showClock = !_showClock),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.bgCard.withOpacity(0.7),
                      border: Border.all(color: AppColors.neonCyan.withOpacity(0.5)),
                    ),
                    child: Text(
                      _showClock ? 'APP GRID' : 'CLOCK',
                      style: const TextStyle(
                        color: AppColors.neonCyan,
                        fontFamily: 'Orbitron',
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Close X
          Positioned(
            top: 48,
            right: 16,
            child: GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.bgCard.withOpacity(0.7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: AppColors.textMain, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

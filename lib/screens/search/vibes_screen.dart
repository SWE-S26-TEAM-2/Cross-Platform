import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_project/constants/app_colors.dart';
import 'package:my_project/constants/app_dimensions.dart';
import 'package:my_project/constants/app_text_styles.dart';
import 'package:my_project/models/track.dart';
import 'package:my_project/providers/music_providers.dart';
import 'package:my_project/screens/library/context_menu_sheet.dart';
import 'package:my_project/screens/library/widgets/track_tile.dart';

class VibeScreen extends StatelessWidget {
  final String vibe;

  const VibeScreen({super.key, required this.vibe});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(title: Text(vibe)),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spaceLarge,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppDimensions.spaceExtraLarge),
                  Text(
                    vibe,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimensions.spaceExtraLarge),

            const TabBar(
              labelColor: AppColors.textPrimary,
              labelStyle: AppTextStyles.button,
              dividerColor: AppColors.background,
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorColor: AppColors.textPrimary,
              unselectedLabelColor: AppColors.textSecondary,
              overlayColor: WidgetStatePropertyAll(AppColors.background),
              tabs: [
                Tab(text: "Trending"),
                Tab(text: "Playlists"),
                Tab(text: "Albums"),
              ],
            ),

            const SizedBox(height: AppDimensions.spaceMedium),

            Expanded(
              child: TabBarView(
                children: [
                  // ───────── TRENDING (BACKEND + MENU) ─────────
                  Consumer(
                    builder: (context, ref, _) {
                      final asyncTracks = ref.watch(searchTracksProvider("a"));

                      return asyncTracks.when(
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (e, _) => Center(
                          child: Text(
                            "Error: $e",
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),
                        data: (tracks) {
                          if (tracks.isEmpty) {
                            return const Center(
                              child: Text(
                                "No trending tracks",
                                style: TextStyle(color: Colors.white70),
                              ),
                            );
                          }

                          return ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.spaceSmall,
                            ),
                            itemCount: tracks.length,
                            itemBuilder: (context, index) {
                              final track = tracks[index];

                              return TrackTile(
                                track: track,
                                onTap: () {},
                                onMoreTap: () {
                                  showTrackContextMenu(context, track);
                                },
                              );
                            },
                          );
                        },
                      );
                    },
                  ),

                  // ───────── PLAYLISTS (UNCHANGED FOR NOW) ─────────
                  const Center(
                    child: Text(
                      "Playlists tab",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),

                  // ───────── ALBUMS (UNCHANGED FOR NOW) ─────────
                  const Center(
                    child: Text(
                      "Albums tab",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

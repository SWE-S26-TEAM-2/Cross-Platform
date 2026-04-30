import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../providers/library_providers.dart';
import '../library/widgets/track_tile.dart';
import 'context_menu_sheet.dart';

class RecentlyPlayedScreen extends ConsumerWidget {
  final VoidCallback? onBack;

  const RecentlyPlayedScreen({super.key, this.onBack});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentlyPlayedAsync = ref.watch(recentlyPlayedProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 28),
          onPressed: onBack ?? () => Navigator.of(context).maybePop(),
        ),
        title: const Text('Recently played', style: AppTextStyles.heading2),
      ),
      body: recentlyPlayedAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const Center(
          child: Text(
            'Failed to load recently played.',
            style: AppTextStyles.artistName,
          ),
        ),
        data: (tracks) => tracks.isEmpty
            ? const Center(
                child: Text(
                  'Nothing played recently.',
                  style: AppTextStyles.artistName,
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.only(bottom: 100),
                itemCount: tracks.length,
                itemBuilder: (context, index) => TrackTile(
                  track: tracks[index],
                  onTap: () {},
                  onMoreTap: () => showTrackContextMenu(context, tracks[index]),
                ),
              ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_dimensions.dart';
import '../../constants/app_text_styles.dart';
import '../../models/track.dart';
import '../../providers/library_providers.dart';
import '../library/widgets/track_tile.dart';
import 'context_menu_sheet.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  final VoidCallback? onBack;

  const HistoryScreen({super.key, this.onBack});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  List<Track>? _tracks;

  Future<void> _confirmClear() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => const _ClearHistoryDialog(),
    );
    if (confirmed == true) {
      setState(() => _tracks = []);
    }
  }

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(listeningHistoryProvider);

    return historyAsync.when(
      loading: () => _scaffold(
        tracks: null,
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => _scaffold(
        tracks: const [],
        body: const Center(
          child: Text(
            'Failed to load listening history.',
            style: AppTextStyles.artistName,
          ),
        ),
      ),
      data: (fetched) {
        final tracks = _tracks ?? fetched;
        return _scaffold(
          tracks: tracks,
          body: tracks.isEmpty
              ? const Center(
                  child: Text(
                    'No listening history yet.',
                    style: AppTextStyles.artistName,
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 100),
                  itemCount: tracks.length,
                  itemBuilder: (context, index) => TrackTile(
                    track: tracks[index],
                    onTap: () {},
                    onMoreTap: () =>
                        showTrackContextMenu(context, tracks[index]),
                  ),
                ),
        );
      },
    );
  }

  Widget _scaffold({required List<Track>? tracks, required Widget body}) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 28),
          onPressed: widget.onBack ?? () => Navigator.of(context).maybePop(),
        ),
        title: const Text('Listening history', style: AppTextStyles.heading2),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppDimensions.spaceMedium),
            child: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: (tracks == null || tracks.isEmpty)
                  ? null
                  : _confirmClear,
            ),
          ),
        ],
      ),
      body: body,
    );
  }
}

// ── Confirmation dialog ──────────────────────────────────────────────────────

class _ClearHistoryDialog extends StatelessWidget {
  const _ClearHistoryDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surfaceLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.spaceLarge,
          AppDimensions.spaceLarge,
          AppDimensions.spaceLarge,
          0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Clear listening history?',
              style: AppTextStyles.heading2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spaceSmall),
            const Text(
              'This will permanently clear your listening history.',
              style: AppTextStyles.artistName,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spaceLarge),
            const Divider(height: 1, color: AppColors.divider),
            IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(
                        'Cancel',
                        style: AppTextStyles.artistName.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const VerticalDivider(width: 1, color: AppColors.divider),
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text(
                        'Confirm',
                        style: AppTextStyles.artistName.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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

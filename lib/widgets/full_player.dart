// widgets/full_player.dart

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:my_project/constants/app_colors.dart';
import 'package:my_project/constants/app_dimensions.dart';
import 'package:my_project/constants/app_text_styles.dart';
import 'package:my_project/models/track.dart';
import 'package:my_project/providers/followers_provider.dart';

class FullPlayer extends ConsumerStatefulWidget {
  const FullPlayer({
    super.key,
    required this.track,
    required this.player,
    required this.onPlayPause,
    required this.onSeek,
  });

  final Track track;
  final AudioPlayer player;
  final VoidCallback onPlayPause;
  final ValueChanged<Duration> onSeek;

  @override
  ConsumerState<FullPlayer> createState() => _FullPlayerState();
}

class _FullPlayerState extends ConsumerState<FullPlayer> {
  bool isLiked = false;

  final List<double> waveform = List.generate(
    70,
    (index) => 0.2 + ((index % 7) * 0.08),
  );

  String formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _seekFromDx(double dx, double width, Duration totalDuration) {
    if (width <= 0 || totalDuration.inMilliseconds <= 0) return;

    final newProgress = (dx / width).clamp(0.0, 1.0);
    final targetMs = (newProgress * totalDuration.inMilliseconds).round();

    widget.onSeek(Duration(milliseconds: targetMs));
  }

  @override
  Widget build(BuildContext context) {
    // ── Follow state ─────────────────────────────────────────────────────────
    final artistUsername = widget.track.artist?.username;
    final artistUserId = widget.track.artist?.userId;

    final followKey = (artistUsername != null && artistUserId != null)
        ? (userId: artistUserId, username: artistUsername)
        : null;

    final followState = followKey != null
        ? ref.watch(followProvider(followKey))
        : null;

    final isFollowing = followState?.isFollowing ?? false;
    final isFollowLoading = followState?.isLoading ?? false;

    return StreamBuilder<PlayerState>(
      stream: widget.player.playerStateStream,
      builder: (context, playerStateSnapshot) {
        final isPlaying = playerStateSnapshot.data?.playing ?? false;

        return StreamBuilder<Duration?>(
          stream: widget.player.durationStream,
          builder: (context, durationSnapshot) {
            final totalDuration =
                durationSnapshot.data ??
                Duration(seconds: widget.track.durationSeconds ?? 0);

            return StreamBuilder<Duration>(
              stream: widget.player.positionStream,
              initialData: widget.player.position,
              builder: (context, positionSnapshot) {
                final currentPosition = positionSnapshot.data ?? Duration.zero;

                final totalMs = totalDuration.inMilliseconds;
                final currentMs = currentPosition.inMilliseconds.clamp(
                  0,
                  totalMs > 0 ? totalMs : 1,
                );

                final progress = totalMs > 0 ? currentMs / totalMs : 0.0;
                final elapsed = currentPosition.inSeconds;
                final totalSeconds = totalDuration.inSeconds > 0
                    ? totalDuration.inSeconds
                    : widget.track.durationSeconds ?? 0;

                final coverUrl = widget.track.coverImageUrl;

                return Scaffold(
                  backgroundColor: Colors.black,
                  // Tap anywhere → pause (when playing).
                  // Buttons/waveform are descendants and win the gesture arena,
                  // so they are unaffected.
                  body: GestureDetector(
                    onTap: isPlaying ? widget.onPlayPause : null,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // ── Background: blurred cover art ─────────────────
                        _buildBackground(coverUrl),

                        // ── Dim overlay when paused ────────────────────────
                        if (!isPlaying)
                          const ColoredBox(
                            color: Color(0x66000000),
                            child: SizedBox.expand(),
                          ),

                        // ── All UI (always visible) ────────────────────────
                        SafeArea(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildTopSection(
                                context,
                                isFollowing: isFollowing,
                                isFollowLoading: isFollowLoading,
                                followKey: followKey,
                              ),
                              const Spacer(),
                              _buildWaveform(
                                elapsed: elapsed,
                                totalSeconds: totalSeconds,
                                progress: progress,
                                totalDuration: totalDuration,
                              ),
                              _buildCommentBar(),
                              _buildBottomBar(),
                              const SizedBox(height: AppDimensions.spaceSmall),
                            ],
                          ),
                        ),

                        // ── Center play button (paused only) ──────────────
                        if (!isPlaying)
                          Center(
                            child: GestureDetector(
                              onTap: widget.onPlayPause,
                              child: Container(
                                width: 64,
                                height: 64,
                                decoration: const BoxDecoration(
                                  color: AppColors.textPrimary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.play_arrow_rounded,
                                  color: AppColors.background,
                                  size: 36,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildTopSection(
    BuildContext context, {
    required bool isFollowing,
    required bool isFollowLoading,
    required FollowKey? followKey,
  }) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.spaceMedium),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.track.title, style: AppTextStyles.heading2),
                const SizedBox(height: 4),
                Text(
                  widget.track.artist?.displayName ?? 'Unknown Artist',
                  style: AppTextStyles.artistName,
                ),
                const SizedBox(height: AppDimensions.spaceSmall),
                const Row(
                  children: [
                    Icon(
                      Icons.graphic_eq,
                      color: AppColors.textMuted,
                      size: 14,
                    ),
                    SizedBox(width: 4),
                    Text('Behind this track', style: AppTextStyles.caption),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
                color: AppColors.textSecondary,
                onPressed: () => Navigator.pop(context),
              ),

              // ── Follow / Unfollow button ──────────────────────────────────
              IconButton(
                icon: isFollowLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.textSecondary,
                        ),
                      )
                    : Icon(
                        isFollowing
                            ? Icons.person_remove_outlined
                            : Icons.person_add_alt_1_outlined,
                        color: isFollowing
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                tooltip: isFollowing ? 'Unfollow' : 'Follow',
                onPressed: (isFollowLoading || followKey == null)
                    ? null
                    : () =>
                          ref.read(followProvider(followKey).notifier).toggle(),
              ),

              IconButton(
                icon: const Icon(Icons.grid_view_rounded),
                color: AppColors.textSecondary,
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWaveform({
    required int elapsed,
    required int totalSeconds,
    required double progress,
    required Duration totalDuration,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            return GestureDetector(
              onHorizontalDragUpdate: (details) {
                _seekFromDx(
                  details.localPosition.dx,
                  constraints.maxWidth,
                  totalDuration,
                );
              },
              onTapDown: (details) {
                _seekFromDx(
                  details.localPosition.dx,
                  constraints.maxWidth,
                  totalDuration,
                );
              },
              child: SizedBox(
                height: 80,
                width: double.infinity,
                child: CustomPaint(
                  painter: WaveformPainter(
                    waveform: waveform,
                    progress: progress,
                  ),
                ),
              ),
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spaceMedium,
            vertical: AppDimensions.spaceExtraSmall,
          ),
          child: Row(
            children: [
              Text(
                formatTime(elapsed),
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: AppDimensions.spaceSmall),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final knobLeft = (progress * (constraints.maxWidth - 12))
                        .clamp(0.0, constraints.maxWidth - 12);

                    return GestureDetector(
                      onTapDown: (details) {
                        _seekFromDx(
                          details.localPosition.dx,
                          constraints.maxWidth,
                          totalDuration,
                        );
                      },
                      onHorizontalDragUpdate: (details) {
                        _seekFromDx(
                          details.localPosition.dx,
                          constraints.maxWidth,
                          totalDuration,
                        );
                      },
                      child: SizedBox(
                        height: 20,
                        child: Stack(
                          alignment: Alignment.centerLeft,
                          children: [
                            Container(
                              height: 3,
                              decoration: BoxDecoration(
                                color: AppColors.waveformInactive,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            FractionallySizedBox(
                              widthFactor: progress,
                              child: Container(
                                height: 3,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                            Positioned(
                              left: knobLeft,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: AppDimensions.spaceSmall),
              Text(formatTime(totalSeconds), style: AppTextStyles.caption),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCommentBar() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        margin: const EdgeInsets.all(AppDimensions.spaceSmall),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spaceMedium,
          vertical: AppDimensions.spaceSmall,
        ),
        decoration: const ShapeDecoration(
          color: AppColors.surface,
          shape: StadiumBorder(
            side: BorderSide(color: AppColors.textMuted, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Comment...',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ),
            const Text('🔥', style: TextStyle(fontSize: 18)),
            const SizedBox(width: AppDimensions.spaceSmall),
            const Text('👏', style: TextStyle(fontSize: 18)),
            const SizedBox(width: AppDimensions.spaceSmall),
            const Text('🥹', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        GestureDetector(
          onTap: () {
            setState(() => isLiked = !isLiked);
          },
          child: Row(
            children: [
              Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                color: AppColors.primary,
                size: 22,
              ),
              const SizedBox(width: 4),
              Text(
                '${widget.track.likeCount}',
                style: AppTextStyles.caption.copyWith(color: AppColors.primary),
              ),
            ],
          ),
        ),
        const Icon(
          Icons.chat_bubble_outline,
          color: AppColors.textSecondary,
          size: 22,
        ),
        const Icon(Icons.ios_share, color: AppColors.textSecondary, size: 22),
        const Icon(Icons.queue_music, color: AppColors.textSecondary, size: 22),
        const Icon(Icons.more_horiz, color: AppColors.textSecondary, size: 22),
      ],
    );
  }

  Widget _buildBackground(String? coverUrl) {
    if (coverUrl == null || coverUrl.isEmpty) {
      return Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(-0.3, -0.3),
            radius: 1.3,
            colors: [Color(0xFF8B1A1A), Color(0xFF3A0808), Color(0xFF0D0303)],
          ),
        ),
      );
    }
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
      child: Image.network(
        coverUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) =>
            Container(color: Colors.black),
      ),
    );
  }
}

class WaveformPainter extends CustomPainter {
  final List<double> waveform;
  final double progress;

  WaveformPainter({required this.waveform, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (waveform.isEmpty) return;

    final count = waveform.length;
    final barWidth = size.width / count;
    final gap = barWidth * 0.3;
    final midY = size.height * 0.6;
    final progressX = size.width * progress;

    for (int i = 0; i < count; i++) {
      final x = i * barWidth + gap / 2;
      final w = barWidth - gap;
      final h = waveform[i] * midY;
      final played = x < progressX;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, midY - h, w, h),
          const Radius.circular(2),
        ),
        Paint()
          ..color = played ? AppColors.textPrimary : AppColors.waveformInactive,
      );
    }

    canvas.drawLine(
      Offset(progressX, 0),
      Offset(progressX, size.height),
      Paint()
        ..color = AppColors.primary
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(WaveformPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.waveform != waveform;
  }
}

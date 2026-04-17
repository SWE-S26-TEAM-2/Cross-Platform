import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:my_project/constants/app_colors.dart';
import 'package:my_project/constants/app_dimensions.dart';
import 'package:my_project/constants/app_text_styles.dart';
import 'package:my_project/models/track.dart';

class FullPlayer extends StatefulWidget {
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
  State<FullPlayer> createState() => _FullPlayerState();
}

class _FullPlayerState extends State<FullPlayer> {
  bool showControls = false;
  bool isLiked = false;
  bool _initializedControls = false;

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
    return StreamBuilder<PlayerState>(
      stream: widget.player.playerStateStream,
      builder: (context, playerStateSnapshot) {
        final isPlaying = playerStateSnapshot.data?.playing ?? false;

        if (!_initializedControls) {
          showControls = !isPlaying;
          _initializedControls = true;
        }

        return StreamBuilder<Duration?>(
          stream: widget.player.durationStream,
          builder: (context, durationSnapshot) {
            final totalDuration =
                durationSnapshot.data ??
                Duration(seconds: widget.track.duration);

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
                    : widget.track.duration;

                return Scaffold(
                  backgroundColor: Colors.black,
                  body: GestureDetector(
                    onTap: showControls
                        ? null
                        : () {
                            setState(() => showControls = true);
                          },
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Container(
                          decoration: const BoxDecoration(
                            gradient: RadialGradient(
                              center: Alignment(-0.3, -0.3),
                              radius: 1.3,
                              colors: [
                                Color(0xFF8B1A1A),
                                Color(0xFF3A0808),
                                Color(0xFF0D0303),
                              ],
                            ),
                          ),
                        ),
                        SafeArea(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildTopSection(context),
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
                        if (showControls) _buildPlayOverlay(isPlaying),
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

  Widget _buildTopSection(BuildContext context) {
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
                Text(widget.track.artist, style: AppTextStyles.artistName),
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
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              IconButton(
                icon: const Icon(Icons.person_add_alt_1_outlined),
                color: AppColors.textSecondary,
                onPressed: () {},
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

  Widget _buildPlayOverlay(bool isPlaying) {
    return Positioned.fill(
      child: Container(
        color: Colors.black45,
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  widget.onPlayPause();
                  setState(() => showControls = false);
                },
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: AppColors.textPrimary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: AppColors.background,
                    size: 30,
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.spaceLarge),
              GestureDetector(
                onTap: () {},
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.surface.withOpacity(0.85),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.textMuted),
                  ),
                  child: const Icon(
                    Icons.skip_next_rounded,
                    color: AppColors.textPrimary,
                    size: 24,
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

import 'package:flutter/material.dart';
import 'package:my_project/constants/app_colors.dart';
import 'package:my_project/constants/app_dimensions.dart';
import 'package:my_project/constants/app_text_styles.dart';
import 'package:my_project/models/track.dart';

class FullPlayer extends StatefulWidget {
  const FullPlayer({
    super.key,
    required this.track,
    required this.isPlaying,
    required this.onPlayPause,
  });

  final Track track;
  final bool isPlaying;
  final VoidCallback onPlayPause;

  @override
  State<FullPlayer> createState() => _FullPlayerState();
}

class _FullPlayerState extends State<FullPlayer> {
  bool showControls = false;
  bool isLiked = false;
  bool _initializedControls = false;
  double progress = 0.0;

  List<double> waveform = [];

  String formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    if (!_initializedControls) {
      showControls = !widget.isPlaying;
      _initializedControls = true;
    }

    final int elapsed = (progress * widget.track.duration).round();

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: showControls
            ? null
            : () {
                print('Screen tapped is pressed !!');
                setState(() => showControls = true);
              },
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── 1. Background ─────────────────────────────────────────
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

            // ── 2. Main UI ────────────────────────────────────────────
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopSection(context),
                  const Spacer(),
                  _buildWaveform(elapsed),
                  _buildCommentBar(),
                  _buildBottomBar(),
                  const SizedBox(height: AppDimensions.spaceSmall),
                ],
              ),
            ),

            // ── 3. Play/Pause overlay ─────────────────────────────────
            if (showControls) _buildPlayOverlay(),
          ],
        ),
      ),
    );
  }

  // ── Top Section ───────────────────────────────────────────────────────────
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
                  print('Close is pressed !!');
                  Navigator.pop(context);
                },
              ),
              IconButton(
                icon: const Icon(Icons.person_add_alt_1_outlined),
                color: AppColors.textSecondary,
                onPressed: () => print('Follow is pressed !!'),
              ),
              IconButton(
                icon: const Icon(Icons.grid_view_rounded),
                color: AppColors.textSecondary,
                onPressed: () => print('Cast is pressed !!'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Waveform ──────────────────────────────────────────────────────────────
  Widget _buildWaveform(int elapsed) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onHorizontalDragUpdate: (details) {
            final RenderBox box = context.findRenderObject() as RenderBox;
            final double newProgress =
                (details.localPosition.dx / box.size.width).clamp(0.0, 1.0);
            print(
              'Waveform seeked to ${(newProgress * 100).toStringAsFixed(0)}% is pressed !!',
            );
            setState(() => progress = newProgress);
          },
          onTapDown: (details) {
            final RenderBox box = context.findRenderObject() as RenderBox;
            final double newProgress =
                (details.localPosition.dx / box.size.width).clamp(0.0, 1.0);
            print(
              'Waveform seeked to ${(newProgress * 100).toStringAsFixed(0)}% is pressed !!',
            );
            setState(() => progress = newProgress);
          },
          child: SizedBox(
            height: 80,
            width: double.infinity,
            child: CustomPaint(
              painter: WaveformPainter(waveform: waveform, progress: progress),
            ),
          ),
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
                child: GestureDetector(
                  onTapDown: (details) {
                    final RenderBox box =
                        context.findRenderObject() as RenderBox;
                    final double tapX = details.localPosition.dx;
                    final double newProgress = (tapX / box.size.width).clamp(
                      0.0,
                      1.0,
                    );
                    print('Progress line is pressed !!');
                    setState(() => progress = newProgress);
                  },
                  onHorizontalDragUpdate: (details) {
                    final RenderBox box =
                        context.findRenderObject() as RenderBox;
                    final double newProgress =
                        (details.localPosition.dx / box.size.width).clamp(
                          0.0,
                          1.0,
                        );
                    print(
                      'Progress line dragged to ${(newProgress * 100).toStringAsFixed(0)}% is pressed !!',
                    );
                    setState(() => progress = newProgress);
                  },
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
                        left:
                            (progress *
                                    (MediaQuery.of(context).size.width -
                                        AppDimensions.spaceMedium * 2 -
                                        AppDimensions.spaceSmall * 2 -
                                        20))
                                .clamp(0, double.infinity),
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
              ),
              const SizedBox(width: AppDimensions.spaceSmall),
              Text(
                formatTime(widget.track.duration),
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Comment Bar ───────────────────────────────────────────────────────────
  Widget _buildCommentBar() {
    return GestureDetector(
      onTap: () => print('Comment bar is pressed !!'),
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
            GestureDetector(
              onTap: () => print('Fire emoji is pressed !!'),
              child: const Text('🔥', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(width: AppDimensions.spaceSmall),
            GestureDetector(
              onTap: () => print('Clap emoji is pressed !!'),
              child: const Text('👏', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(width: AppDimensions.spaceSmall),
            GestureDetector(
              onTap: () => print('Cry emoji is pressed !!'),
              child: const Text('🥹', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }

  // ── Bottom Bar ────────────────────────────────────────────────────────────
  Widget _buildBottomBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        GestureDetector(
          onTap: () {
            print('Like is pressed !!');
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

        GestureDetector(
          onTap: () => print('Comments is pressed !!'),
          child: const Icon(
            Icons.chat_bubble_outline,
            color: AppColors.textSecondary,
            size: 22,
          ),
        ),

        GestureDetector(
          onTap: () => print('Share is pressed !!'),
          child: const Icon(
            Icons.ios_share,
            color: AppColors.textSecondary,
            size: 22,
          ),
        ),

        GestureDetector(
          onTap: () => print('Queue is pressed !!'),
          child: const Icon(
            Icons.queue_music,
            color: AppColors.textSecondary,
            size: 22,
          ),
        ),

        GestureDetector(
          onTap: () => print('More is pressed !!'),
          child: const Icon(
            Icons.more_horiz,
            color: AppColors.textSecondary,
            size: 22,
          ),
        ),
      ],
    );
  }

  // ── Play Overlay ──────────────────────────────────────────────────────────
  Widget _buildPlayOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black45,
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Play / Pause
              GestureDetector(
                onTap: () {
                  print('Play/Pause is pressed !!');
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
                    widget.isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    color: AppColors.background,
                    size: 30,
                  ),
                ),
              ),

              const SizedBox(width: AppDimensions.spaceLarge),

              // Skip next
              GestureDetector(
                onTap: () => print('Skip next is pressed !!'),
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

// ─────────────────────────────────────────────────────────────────────────────
//  WAVEFORM PAINTER
// ─────────────────────────────────────────────────────────────────────────────
class WaveformPainter extends CustomPainter {
  final List<double> waveform;
  final double progress;

  WaveformPainter({required this.waveform, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (waveform.isEmpty) return;

    final int count = waveform.length;
    final double barWidth = size.width / count;
    final double gap = barWidth * 0.3;
    final double midY = size.height * 0.6;
    final double progressX = size.width * progress;

    for (int i = 0; i < count; i++) {
      final double x = i * barWidth + gap / 2;
      final double w = barWidth - gap;
      final double h = waveform[i] * midY;
      final bool played = x < progressX;

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
  bool shouldRepaint(WaveformPainter old) =>
      old.progress != progress || old.waveform != waveform;
}

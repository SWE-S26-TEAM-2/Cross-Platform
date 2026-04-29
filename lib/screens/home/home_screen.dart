import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_project/models/track.dart';
import '../../models/feed_response.dart';
import 'package:my_project/screens/home/activity.dart';
import '../../constants/app_dimensions.dart';
import '../../providers/feed_provider.dart';
import '../../providers/notifications_provider.dart';
import 'your_likes_card.dart';
import 'today_pick_card.dart';
import 'more_like_section.dart';
import 'albums_for_you_section.dart';

// ─── FeedTrackItem → Track conversion ────────────────────────────────────────

extension FeedTrackItemToTrack on FeedTrackItem {
  Track toTrack() => Track(
    trackId: trackId,
    title: title,
    description: description,
    genre: genre,
    tags: tags,
    releaseDate: releaseDate,
    coverImageUrl: coverImageUrl,
    streamUrl: streamUrl,
    userId: artist.userId,
    artist: TrackArtist(
      userId: artist.userId,
      username: artist.username,
      displayName: artist.displayName,
      profilePicture: artist.profilePicture,
      followerCount: artist.followerCount,
    ),
    visibility: 'public',
    processingStatus: 'ready',
    playCount: playCount,
    durationSeconds: durationSeconds,
    likeCount: likeCount,
    repostCount: repostCount,
    commentCount: commentCount,
    isLiked: isLiked,
    isReposted: isReposted,
    createdAt: createdAt,
  );
}

// ─── HomeScreen ───────────────────────────────────────────────────────────────

class HomeScreen extends ConsumerStatefulWidget {
  final void Function(Track)? onTrackTap;
  const HomeScreen({super.key, this.onTrackTap});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Future<void> _onRefresh() async {
    await Future.wait([
      ref.read(followingFeedProvider.notifier).refresh(),
      ref.read(discoverFeedProvider.notifier).refresh(),
      ref.read(cachedDiscoverFeedProvider.notifier).refresh(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = ref.watch(unreadNotificationsCountProvider).value ?? 0;
    final followingFeed = ref.watch(followingFeedProvider);
    final discoverFeed = ref.watch(discoverFeedProvider);
    final cachedFeed = ref.watch(cachedDiscoverFeedProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_upload_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => Activity()),
            ),
          ),
          Badge(
            isLabelVisible: unreadCount > 0,
            label: Text('$unreadCount'),
            child: IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => Activity()),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppDimensions.spaceSmall),

              // ── Your Likes — first 6 tracks from /feed/following ──────────
              followingFeed.when(
                loading: () => const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => _ErrorTile(
                  message: 'Could not load following feed',
                  onRetry: () =>
                      ref.read(followingFeedProvider.notifier).refresh(),
                ),
                data: (state) {
                  if (state.items.isEmpty) return const SizedBox();
                  return YourLikesCard(
                    tracks: state.items
                        .take(6)
                        .map((i) => i.toTrack())
                        .toList(),
                    onTrackTap: widget.onTrackTap,
                  );
                },
              ),

              const SizedBox(height: AppDimensions.spaceLarge),

              // ── Today's Pick — first track from /feed/discover ────────────
              discoverFeed.when(
                loading: () => const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => _ErrorTile(
                  message: 'Could not load discover feed',
                  onRetry: () =>
                      ref.read(discoverFeedProvider.notifier).refresh(),
                ),
                data: (state) => state.items.isNotEmpty
                    ? TodayPickCard(
                        track: state.items.first.toTrack(),
                        onTrackTap: widget.onTrackTap,
                      )
                    : const SizedBox(),
              ),

              const SizedBox(height: AppDimensions.spaceLarge),

              // ── More of what you like — tracks 7–16 from following feed ───
              followingFeed.when(
                loading: () => const SizedBox(),
                error: (_, __) => const SizedBox(),
                data: (state) {
                  final tracks = state.items
                      .skip(6)
                      .take(10)
                      .map((i) => i.toTrack())
                      .toList();
                  if (tracks.isEmpty) return const SizedBox();
                  return MoreLikeSection(
                    sectionTitle: 'More of what you like',
                    tracks: tracks,
                    onTrackTap: widget.onTrackTap,
                  );
                },
              ),

              const SizedBox(height: AppDimensions.spaceLarge),

              // ── Mixed for You — tracks 2–11 from discover feed ────────────
              discoverFeed.when(
                loading: () => const SizedBox(),
                error: (_, __) => const SizedBox(),
                data: (state) {
                  final tracks = state.items
                      .skip(1)
                      .take(10)
                      .map((i) => i.toTrack())
                      .toList();
                  if (tracks.isEmpty) return const SizedBox();
                  return MoreLikeSection(
                    sectionTitle: 'Mixed for You',
                    tracks: tracks,
                    onTrackTap: widget.onTrackTap,
                  );
                },
              ),

              const SizedBox(height: AppDimensions.spaceLarge),

              // ── Albums for You — placeholder until album endpoint is wired ─
              const AlbumsForYouSection(
                sectionTitle: 'Albums for You',
                albums: [],
              ),

              const SizedBox(height: AppDimensions.spaceLarge),

              // ── Cache debug banner (visible while testing) ─────────────────
              cachedFeed.when(
                loading: () => const SizedBox(),
                error: (_, __) => const SizedBox(),
                data: (state) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Cache: ${state.cacheHit ? "HIT ✓" : "MISS"} | '
                    '${state.queryTimeMs?.toStringAsFixed(1)}ms | '
                    'TTL ${state.cacheTtlSeconds}s',
                    style: const TextStyle(color: Colors.grey, fontSize: 10),
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.spaceLarge),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Error tile with retry ────────────────────────────────────────────────────

class _ErrorTile extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorTile({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

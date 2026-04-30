import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_project/constants/app_text_styles.dart';
import 'package:my_project/models/track.dart';
import '../../providers/feed_provider.dart';
import '../../models/feed_response.dart';

// ─── Convert Feed → Track ────────────────────────────────────────────────────

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

// ─── FEED SCREEN ─────────────────────────────────────────────────────────────

class FeedScreen extends ConsumerStatefulWidget {
  final void Function(Track)? onTrackTap;

  const FeedScreen({super.key, required this.onTrackTap});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildFeed(List<Track> tracks) {
    return PageView.builder(
      scrollDirection: Axis.vertical,
      physics: const PageScrollPhysics(parent: BouncingScrollPhysics()),
      itemCount: tracks.length,

      onPageChanged: (index) {
        setState(() => currentIndex = index);
        widget.onTrackTap?.call(tracks[index]);
      },

      itemBuilder: (context, index) {
        final track = tracks[index];
        final isActive = index == currentIndex;

        return Stack(
          fit: StackFit.expand,
          children: [
            if (track.coverImageUrl != null)
              Image.network(track.coverImageUrl!, fit: BoxFit.cover)
            else
              Container(color: Colors.black),

            Container(color: Colors.black.withOpacity(0.4)),

            Positioned(
              bottom: 120,
              left: 20,
              right: 80,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    track.artist?.displayName ?? "Unknown Artist",
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            Positioned(
              right: 12,
              bottom: 140,
              child: Column(
                children: [
                  Icon(Icons.favorite_border, color: Colors.white, size: 32),
                  const SizedBox(height: 18),
                  Icon(
                    Icons.chat_bubble_outline,
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(height: 18),
                  Icon(Icons.share, color: Colors.white, size: 32),
                  const SizedBox(height: 18),
                  Icon(Icons.more_horiz, color: Colors.white, size: 32),
                ],
              ),
            ),

            Positioned(
              bottom: 40,
              left: 20,
              child: Icon(
                isActive ? Icons.play_circle_fill : Icons.circle_outlined,
                color: Colors.white,
                size: 50,
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final discover = ref.watch(discoverFeedProvider);
    final following = ref.watch(followingFeedProvider);

    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 8),
            child: TabBar(
              controller: _tabController,

              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: Colors.white24,
              ),

              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,

              dividerColor: Colors.transparent,
              splashFactory: NoSplash.splashFactory,
              overlayColor: const WidgetStatePropertyAll(Colors.transparent),

              tabs: const [
                Tab(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    child: Text("Discover", style: AppTextStyles.button),
                  ),
                ),
                Tab(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    child: Text("Following", style: AppTextStyles.button),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      body: TabBarView(
        controller: _tabController,
        children: [
          // DISCOVER
          discover.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Center(child: Text("Error loading feed")),
            data: (state) {
              final tracks = state.items.map((e) => e.toTrack()).toList();
              return _buildFeed(tracks);
            },
          ),

          // FOLLOWING (ONLY CHANGE IS HERE)
          following.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Center(child: Text("Error loading feed")),
            data: (state) {
              final tracks = state.items.map((e) => e.toTrack()).toList();

              if (tracks.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Your Feed appears to be empty",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          "Follow some artists or like tracks and try again",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return _buildFeed(tracks);
            },
          ),
        ],
      ),
    );
  }
}

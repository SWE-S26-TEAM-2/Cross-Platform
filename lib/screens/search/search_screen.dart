import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_project/constants/app_colors.dart';
import 'package:my_project/constants/app_dimensions.dart';
import 'package:my_project/constants/app_text_styles.dart';
import 'package:my_project/models/playlist.dart';
import 'package:my_project/models/track.dart';
import 'package:my_project/providers/playlist_provider.dart';
import 'package:my_project/providers/music_providers.dart';
import 'package:my_project/screens/library/collections_screen.dart';
import 'package:my_project/screens/search/search_bar.dart';
import 'package:my_project/screens/search/vibes_section.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;
  String _query = '';

  // 🔧 Fix backend URLs
  String fixImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';

    if (url.startsWith('http')) return url;

    if (url.startsWith('/')) {
      return 'https://streamline-swp.duckdns.org$url';
    }

    return url;
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 400), () {
      final query = value.trim();

      setState(() => _query = query);

      ref.read(playlistProvider.notifier).searchPlaylists(query);
      ref.invalidate(searchTracksProvider(query));
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playlistState = ref.watch(playlistProvider);
    final trackState = ref.watch(searchTracksProvider(_query));

    final isSearching = _query.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: SafeArea(
        child: Column(
          children: [
            SearchBar1(controller: _controller, onChanged: _onSearchChanged),
            const SizedBox(height: 10),

            Expanded(
              child: isSearching
                  ? _buildResults(playlistState, trackState)
                  : const SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 20),
                        child: VibesSection(),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults(
    PlaylistState playlistState,
    AsyncValue<List<Track>> trackState,
  ) {
    if (playlistState.isSearching || trackState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final playlists = playlistState.searchResults;
    final tracks = trackState.value ?? [];

    if (playlists.isEmpty && tracks.isEmpty) {
      return const Center(
        child: Text(
          'No results found',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return ListView(
      children: [
        // ───── TRACKS ─────
        if (tracks.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              "Tracks",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),

          ...tracks.map((t) {
            final artistName = t.artist?.displayName ?? 'Unknown Artist';
            final image = fixImageUrl(t.coverImageUrl);

            return ListTile(
              leading: SizedBox(
                width: 50,
                height: 50,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: image.isNotEmpty
                      ? Image.network(
                          image,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const ColoredBox(
                            color: Colors.black26,
                            child: Icon(Icons.music_note, color: Colors.white),
                          ),
                        )
                      : const ColoredBox(
                          color: Colors.black26,
                          child: Icon(Icons.music_note, color: Colors.white),
                        ),
                ),
              ),
              title: Text(t.title, style: const TextStyle(color: Colors.white)),
              subtitle: Text(
                artistName,
                style: const TextStyle(color: Colors.white70),
              ),
            );
          }),
        ],

        // ───── PLAYLISTS ─────
        if (playlists.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              "Playlists",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),

          ...playlists.map((p) {
            final image = fixImageUrl(p.coverUrl);

            return ListTile(
              onTap: () => _openPlaylist(p),
              leading: SizedBox(
                width: 50,
                height: 50,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: image.isNotEmpty
                      ? Image.network(
                          image,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const ColoredBox(
                            color: Colors.black26,
                            child: Icon(Icons.queue_music, color: Colors.white),
                          ),
                        )
                      : const ColoredBox(
                          color: Colors.black26,
                          child: Icon(Icons.queue_music, color: Colors.white),
                        ),
                ),
              ),
              title: Text(p.name, style: const TextStyle(color: Colors.white)),
              subtitle: Text(
                p.description,
                style: const TextStyle(color: Colors.white70),
              ),
            );
          }),
        ],
      ],
    );
  }

  Future<void> _openPlaylist(Playlist playlist) async {
    final detailed = await ref
        .read(playlistProvider.notifier)
        .getPlaylistDetails(playlist.id);

    if (!mounted) return;

    if (detailed == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CollectionDetailsScreen(
          playlistId: detailed.id,
          data: CollectionDetailsData(
            type: CollectionType.playlist,
            title: detailed.name,
            artworkPath: detailed.coverUrl,
            ownerName: detailed.owner,
            ownerAvatarPath: '',
            yearText: '2026',
            likesText: '0',
            tracks: detailed.tracks
                .map(
                  (track) => CollectionTrack(
                    id: track.id,
                    title: track.title,
                    artist: track.artist,
                    artworkPath: track.artworkUrl,
                    isAvailable: true,
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}

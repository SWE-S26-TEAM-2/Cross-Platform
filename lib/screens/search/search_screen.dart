import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_project/constants/app_colors.dart';
import 'package:my_project/constants/app_dimensions.dart';
import 'package:my_project/constants/app_text_styles.dart';
import 'package:my_project/models/playlist.dart';
import 'package:my_project/providers/playlist_provider.dart';
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

  void _onSearchChanged(String value) {
    _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      final query = value.trim();

      setState(() {
        _query = query;
      });

      ref.read(playlistProvider.notifier).searchPlaylists(query);
    });
  }

  CollectionDetailsData _mapPlaylistToCollection(Playlist playlist) {
    return CollectionDetailsData(
      type: CollectionType.playlist,
      title: playlist.name,
      artworkPath: playlist.coverUrl,
      ownerName: playlist.owner,
      ownerAvatarPath: '',
      yearText: '2026',
      likesText: '0',
      tracks: playlist.tracks
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
    );
  }

  Future<void> _openPlaylist(Playlist playlist) async {
    final detailedPlaylist = await ref
        .read(playlistProvider.notifier)
        .getPlaylistDetails(playlist.id);

    if (!mounted) return;

    if (detailedPlaylist == null) {
      final error =
          ref.read(playlistProvider).error ?? 'Failed to open playlist.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CollectionDetailsScreen(
          playlistId: detailedPlaylist.id,
          data: _mapPlaylistToCollection(detailedPlaylist),
        ),
      ),
    );
  }

  Future<void> _likePlaylist(Playlist playlist) async {
    await ref.read(playlistProvider.notifier).likePlaylist(playlist.id);

    final state = ref.read(playlistProvider);

    if (!mounted) return;

    if (state.error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(state.error!)));
      return;
    }

    if (state.successMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(state.successMessage!)));
      ref.read(playlistProvider.notifier).clearMessages();
    }
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
    final isSearching = _query.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SearchBar1(controller: _controller, onChanged: _onSearchChanged),
            const SizedBox(height: 10),
            Expanded(
              child: isSearching
                  ? _buildPlaylistResults(playlistState)
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

  Widget _buildPlaylistResults(PlaylistState playlistState) {
    if (playlistState.isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (playlistState.error != null && playlistState.searchResults.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            playlistState.error!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    final results = playlistState.searchResults;

    if (results.isEmpty) {
      return const Center(
        child: Text(
          'No Results found',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final playlist = results[index];

        return Material(
          color: AppColors.background,
          child: InkWell(
            borderRadius: BorderRadius.circular(
              AppDimensions.borderRadiusMedium,
            ),
            onTap: () => _openPlaylist(playlist),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spaceMedium,
                vertical: AppDimensions.spaceMedium,
              ),
              child: Row(
                children: [
                  _PlaylistCover(url: playlist.coverUrl),
                  const SizedBox(width: AppDimensions.spaceMedium),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          playlist.name,
                          style: AppTextStyles.trackTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppDimensions.spaceExtraSmall),
                        Text(
                          playlist.description.isEmpty
                              ? '${playlist.trackCount} tracks'
                              : playlist.description,
                          style: AppTextStyles.artistName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: playlistState.isLiking
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(
                            Icons.favorite_border,
                            color: AppColors.primary,
                          ),
                    onPressed: playlistState.isLiking
                        ? null
                        : () => _likePlaylist(playlist),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PlaylistCover extends StatelessWidget {
  final String url;

  const _PlaylistCover({required this.url});

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSmall),
        ),
        child: const Icon(Icons.queue_music, color: Colors.white70),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSmall),
      child: Image.network(
        url,
        width: 54,
        height: 54,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: 54,
          height: 54,
          color: AppColors.surface,
          child: const Icon(Icons.queue_music, color: Colors.white70),
        ),
      ),
    );
  }
}

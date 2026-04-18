import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_dimensions.dart';
import '../../constants/app_text_styles.dart';
import '../../models/playlist.dart';
import '../../providers/playlist_provider.dart';
import '../library/widgets/playlist_tiles.dart';
import 'collections_screen.dart';

enum PlaylistsSortOption { recentlyAdded, firstAdded, playlistName }

class PlaylistsScreen extends ConsumerStatefulWidget {
  final VoidCallback? onBack;

  const PlaylistsScreen({super.key, this.onBack});

  @override
  ConsumerState<PlaylistsScreen> createState() => _PlaylistsScreenState();
}

class _PlaylistsScreenState extends ConsumerState<PlaylistsScreen> {
  PlaylistsSortOption _sortOption = PlaylistsSortOption.recentlyAdded;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(playlistProvider.notifier).fetchTestPlaylist();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
              title: track.title,
              artist: track.artist,
              artworkPath: track.artworkUrl,
              isAvailable: true,
            ),
          )
          .toList(),
    );
  }

  void _openPlaylistDetails(Playlist playlist) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            CollectionDetailsScreen(data: _mapPlaylistToCollection(playlist)),
      ),
    );
  }

  void _showSortBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.borderRadiusMedium),
        ),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppDimensions.spaceLarge,
            horizontal: AppDimensions.spaceMedium,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Sort by', style: AppTextStyles.heading2),
              const SizedBox(height: AppDimensions.spaceMedium),
              _SortOption(
                label: 'Recently Added',
                selected: _sortOption == PlaylistsSortOption.recentlyAdded,
                onTap: () {
                  setState(
                    () => _sortOption = PlaylistsSortOption.recentlyAdded,
                  );
                  Navigator.pop(context);
                },
              ),
              _SortOption(
                label: 'First Added',
                selected: _sortOption == PlaylistsSortOption.firstAdded,
                onTap: () {
                  setState(() => _sortOption = PlaylistsSortOption.firstAdded);
                  Navigator.pop(context);
                },
              ),
              _SortOption(
                label: 'Playlist Name',
                selected: _sortOption == PlaylistsSortOption.playlistName,
                onTap: () {
                  setState(
                    () => _sortOption = PlaylistsSortOption.playlistName,
                  );
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCreatePlaylistSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.borderRadiusMedium),
        ),
      ),
      builder: (_) => const _CreatePlaylistSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final playlistState = ref.watch(playlistProvider);

    List<Playlist> playlists = [];
    if (playlistState.playlist != null) {
      playlists = [playlistState.playlist!];
    }

    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      playlists = playlists
          .where(
            (p) =>
                p.name.toLowerCase().contains(query) ||
                p.owner.toLowerCase().contains(query),
          )
          .toList();
    }

    if (_sortOption == PlaylistsSortOption.firstAdded) {
      playlists = playlists.reversed.toList();
    } else if (_sortOption == PlaylistsSortOption.playlistName) {
      playlists.sort((a, b) => a.name.compareTo(b.name));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Stack(
              children: [
                Positioned(
                  right: -30,
                  top: -10,
                  child: _StackedSquaresDecoration(),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 12, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.chevron_left,
                                color: Colors.white,
                                size: 28,
                              ),
                              onPressed: () => widget.onBack?.call(),
                            ),
                            Expanded(
                              child: Container(
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E1E1E),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: (_) => setState(() {}),
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 14,
                                  ),
                                  decoration: const InputDecoration(
                                    hintText: 'Search your playlists',
                                    hintStyle: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 14,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.search,
                                      color: AppColors.textSecondary,
                                      size: 20,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: _showSortBottomSheet,
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.borderRadiusPill,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.sort,
                                  color: AppColors.primary,
                                  size: 22,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Padding(
                          padding: EdgeInsets.only(
                            left: AppDimensions.spaceSmall,
                          ),
                          child: Text(
                            'Playlists',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.spaceSmall,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: _ActionButton(
                                  icon: Icons.download_outlined,
                                  label: 'Import',
                                  onTap: () {},
                                ),
                              ),
                              const SizedBox(width: AppDimensions.spaceSmall),
                              Expanded(
                                child: _ActionButton(
                                  icon: Icons.add,
                                  label: 'Create',
                                  onTap: _showCreatePlaylistSheet,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (playlistState.isLoading)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (playlistState.error != null)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    playlistState.error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              ),
            )
          else
            SliverToBoxAdapter(
              child: PlaylistTiles(
                title: '',
                playlists: playlists,
                onPlaylistTap: _openPlaylistDetails,
                onMoreTap: (_) {},
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

class _CreatePlaylistSheet extends StatefulWidget {
  const _CreatePlaylistSheet();

  @override
  State<_CreatePlaylistSheet> createState() => _CreatePlaylistSheetState();
}

class _CreatePlaylistSheetState extends State<_CreatePlaylistSheet> {
  static const int _maxLength = 100;
  final TextEditingController _nameController = TextEditingController(
    text: 'Untitled playlist',
  );
  bool _isPublic = true;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _nameController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _nameController.text.length,
      );
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimensions.borderRadiusMedium),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spaceMedium,
            vertical: AppDimensions.spaceLarge,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 40),
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.textMuted,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.close,
                      color: AppColors.textSecondary,
                      size: 22,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spaceExtraLarge),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _nameController,
                      autofocus: true,
                      maxLength: _maxLength,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: const InputDecoration(
                        counterText: '',
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(color: AppColors.textMuted),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: AppColors.textMuted),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        contentPadding: EdgeInsets.only(
                          bottom: AppDimensions.spaceSmall,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spaceSmall),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      '${_nameController.text.length}/$_maxLength',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spaceExtraLarge),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Make this playlist public',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                    ),
                  ),
                  Switch(
                    value: _isPublic,
                    onChanged: (val) => setState(() => _isPublic = val),
                    activeColor: Colors.white,
                    activeTrackColor: AppColors.primary,
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: AppColors.textMuted,
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spaceExtraLarge),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.textSecondary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.borderRadiusPill,
                      ),
                    ),
                  ),
                  child: const Text(
                    'Create playlist',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.spaceMedium),
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.spaceSmall),
            ],
          ),
        ),
      ),
    );
  }
}

class _StackedSquaresDecoration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        children: List.generate(6, (i) {
          final offset = i * 12.0;
          return Positioned(
            right: offset,
            top: offset,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.15 + i * 0.04),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(
                  AppDimensions.borderRadiusSmall,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSmall),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.textPrimary, size: 18),
            const SizedBox(width: AppDimensions.spaceSmall),
            Text(label, style: AppTextStyles.button),
          ],
        ),
      ),
    );
  }
}

class _SortOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SortOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        label,
        style: TextStyle(
          color: selected ? AppColors.primary : AppColors.textPrimary,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          fontSize: 15,
        ),
      ),
      trailing: selected
          ? const Icon(Icons.check, color: AppColors.primary, size: 20)
          : null,
      onTap: onTap,
    );
  }
}

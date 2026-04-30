import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_dimensions.dart';
import '../../constants/app_text_styles.dart';
import '../../models/album.dart';
import '../../providers/album_provider.dart';
import 'widgets/album_tile.dart';
import 'collections_screen.dart';
import 'collections_details_mapper.dart';
import 'context_menu_sheet.dart';

enum AlbumsSortOption { recentlyAdded, firstAdded, albumName }

class AlbumsScreen extends ConsumerStatefulWidget {
  final VoidCallback? onBack;
  const AlbumsScreen({super.key, this.onBack});

  @override
  ConsumerState<AlbumsScreen> createState() => _AlbumsScreenState();
}

class _AlbumsScreenState extends ConsumerState<AlbumsScreen> {
  AlbumsSortOption _sortOption = AlbumsSortOption.recentlyAdded;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(albumProvider.notifier).fetchLikedAlbums();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openAlbumDetails(Album album) async {
    // Fetch full album details (includes tracks)
    final detailed = await ref
        .read(albumProvider.notifier)
        .getAlbumDetails(album.id);

    if (!mounted) return;

    if (detailed == null) {
      final error = ref.read(albumProvider).error ?? 'Failed to open album.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CollectionDetailsScreen(
          data: CollectionDetailsMapper.fromAlbum(detailed),
        ),
      ),
    );
  }

  void _applySort(AlbumsSortOption option) {
    setState(() => _sortOption = option);
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
      builder: (_) => Padding(
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
              selected: _sortOption == AlbumsSortOption.recentlyAdded,
              onTap: () {
                Navigator.pop(context);
                _applySort(AlbumsSortOption.recentlyAdded);
              },
            ),
            _SortOption(
              label: 'First Added',
              selected: _sortOption == AlbumsSortOption.firstAdded,
              onTap: () {
                Navigator.pop(context);
                _applySort(AlbumsSortOption.firstAdded);
              },
            ),
            _SortOption(
              label: 'Album Name',
              selected: _sortOption == AlbumsSortOption.albumName,
              onTap: () {
                Navigator.pop(context);
                _applySort(AlbumsSortOption.albumName);
              },
            ),
          ],
        ),
      ),
    );
  }

  List<Album> _sorted(List<Album> source) {
    final query = _searchController.text.trim().toLowerCase();

    List<Album> result = query.isEmpty
        ? List.from(source)
        : source
              .where(
                (a) =>
                    a.title.toLowerCase().contains(query) ||
                    a.artist.toLowerCase().contains(query),
              )
              .toList();

    switch (_sortOption) {
      case AlbumsSortOption.recentlyAdded:
        break; // API order = most recent first
      case AlbumsSortOption.firstAdded:
        result = result.reversed.toList();
        break;
      case AlbumsSortOption.albumName:
        result.sort((a, b) => a.title.compareTo(b.title));
        break;
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final albumState = ref.watch(albumProvider);
    final albums = _sorted(albumState.likedAlbums);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () => ref.read(albumProvider.notifier).fetchLikedAlbums(),
        child: CustomScrollView(
          slivers: [
            // ── Header ──────────────────────────────────────────────────
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
                          // ── Search bar row ───────────────────────────
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
                                      hintText: 'Search albums',
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
                              'Albums',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Body states ──────────────────────────────────────────────
            if (albumState.isLoadingLiked)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (albumState.error != null && albumState.likedAlbums.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      albumState.error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
              )
            else if (albums.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text(
                    'No liked albums yet.',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              )
            else
              // ── Album list ─────────────────────────────────────────────
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => AlbumTile(
                    album: albums[index],
                    onTap: () => _openAlbumDetails(albums[index]),
                    onMoreTap: () => showCollectionContextMenu(context),
                  ),
                  childCount: albums.length,
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}

// ── Stacked squares background decoration ───────────────────────────────────
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

// ── Sort option tile ─────────────────────────────────────────────────────────
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

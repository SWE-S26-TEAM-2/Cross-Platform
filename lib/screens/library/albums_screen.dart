import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_dimensions.dart';
import '../../constants/app_text_styles.dart';
import '../../models/album.dart';
import '../../mock_data/mock_albums.dart';
import 'widgets/album_tile.dart';
import 'collections_screen.dart';
import 'collections_details_mapper.dart';
import 'collections_screen.dart';
import 'context_menu_sheet.dart';

enum AlbumsSortOption { recentlyAdded, firstAdded, albumName }

class AlbumsScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const AlbumsScreen({super.key, this.onBack});

  @override
  State<AlbumsScreen> createState() => _AlbumsScreenState();
}

class _AlbumsScreenState extends State<AlbumsScreen> {
  AlbumsSortOption _sortOption = AlbumsSortOption.recentlyAdded;
  final TextEditingController _searchController = TextEditingController();
  List<Album> _filteredAlbums = [];
  List<Album> _allAlbums = [];

  @override
  void initState() {
    super.initState();
    _allAlbums = List.from(MockAlbums.featuredAlbums);
    _filteredAlbums = List.from(_allAlbums);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredAlbums = _allAlbums
          .where(
            (a) =>
                a.title.toLowerCase().contains(query) ||
                a.artist.toLowerCase().contains(query),
          )
          .toList();
    });
  }

  void _applySort(AlbumsSortOption option) {
    setState(() {
      _sortOption = option;
      switch (option) {
        case AlbumsSortOption.recentlyAdded:
          _filteredAlbums = List.from(_allAlbums);
          break;
        case AlbumsSortOption.firstAdded:
          _filteredAlbums = List.from(_allAlbums.reversed);
          break;
        case AlbumsSortOption.albumName:
          _filteredAlbums.sort((a, b) => a.title.compareTo(b.title));
          break;
      }
    });
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
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
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 14,
                                  ),
                                  decoration: const InputDecoration(
                                    hintText: 'Search 4 albums',
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

                        // ── Title ────────────────────────────────────
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

          // ── Album list ───────────────────────────────────────────────
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => AlbumTile(
                album: _filteredAlbums[index],
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CollectionDetailsScreen(
                      data: CollectionDetailsMapper.fromAlbum(
                        _filteredAlbums[index],
                      ),
                    ),
                  ),
                ),
                onMoreTap: () => showCollectionContextMenu(context),
              ),
              childCount: _filteredAlbums.length,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

// ── Stacked squares background decoration ──────────────────────────────────
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

// ── Sort option tile ────────────────────────────────────────────────────────
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

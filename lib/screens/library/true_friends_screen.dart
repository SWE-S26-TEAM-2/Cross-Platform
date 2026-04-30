import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../constants/app_dimensions.dart';
import '../../models/follower.dart';
import '../../providers/followers_provider.dart';
import 'widgets/user_tile.dart';

class TrueFriendsScreen extends ConsumerStatefulWidget {
  final VoidCallback? onBack;
  const TrueFriendsScreen({super.key, this.onBack});

  @override
  ConsumerState<TrueFriendsScreen> createState() => _TrueFriendsScreenState();
}

class _TrueFriendsScreenState extends ConsumerState<TrueFriendsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _showAllFollowers = false;

  // Local set of userIds we're following — updated optimistically
  Set<String>? _localFollowingIds;

  // In-flight requests
  final Set<String> _loadingIds = {};

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(
        () => _searchQuery = _searchController.text.toLowerCase().trim(),
      );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Follower> _applySearch(List<Follower> list) {
    if (_searchQuery.isEmpty) {
      return list;
    }
    return list.where((f) {
      final name = (f.displayName ?? f.username ?? f.userId).toLowerCase();
      final user = (f.username ?? f.userId).toLowerCase();
      return name.contains(_searchQuery) || user.contains(_searchQuery);
    }).toList();
  }

  Future<void> _unfollow(Follower follower) async {
    final userId = follower.userId;
    final identifier = follower.apiIdentifier;
    if (identifier.isEmpty || _loadingIds.contains(userId)) {
      return;
    }

    setState(() {
      _loadingIds.add(userId);
      _localFollowingIds?.remove(userId);
    });

    try {
      await ref
          .read(followersServiceProvider)
          .unfollowUser(username: identifier);
      ref.invalidate(myFollowingProvider);
    } catch (e) {
      debugPrint('[TrueFriendsScreen] Unfollow failed: $e');
      setState(() {
        _localFollowingIds?.add(userId);
      });
    } finally {
      if (mounted) {
        setState(() => _loadingIds.remove(userId));
      }
    }
  }

  Future<void> _follow(Follower follower) async {
    final userId = follower.userId;
    final identifier = follower.apiIdentifier;
    if (identifier.isEmpty || _loadingIds.contains(userId)) {
      return;
    }

    setState(() {
      _loadingIds.add(userId);
      _localFollowingIds?.add(userId);
    });

    try {
      await ref.read(followersServiceProvider).followUser(username: identifier);
      ref.invalidate(myFollowingProvider);
    } catch (e) {
      debugPrint('[TrueFriendsScreen] Follow failed: $e');
      setState(() {
        _localFollowingIds?.remove(userId);
      });
    } finally {
      if (mounted) {
        setState(() => _loadingIds.remove(userId));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final followersAsync = ref.watch(myFollowersProvider);
    final followingAsync = ref.watch(myFollowingProvider);

    final isLoading = followersAsync.isLoading || followingAsync.isLoading;
    final hasError = followersAsync.hasError || followingAsync.hasError;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.white, size: 28),
          onPressed: () => widget.onBack?.call(),
        ),
        title: Text(
          _showAllFollowers ? 'All Followers' : 'True Friends',
          style: AppTextStyles.heading2,
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ── Toggle pill ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spaceMedium,
              vertical: AppDimensions.spaceSmall,
            ),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(
                  AppDimensions.borderRadiusPill,
                ),
              ),
              child: Row(
                children: [
                  _ToggleTab(
                    label: 'True Friends',
                    selected: !_showAllFollowers,
                    onTap: () => setState(() => _showAllFollowers = false),
                  ),
                  _ToggleTab(
                    label: 'All Followers',
                    selected: _showAllFollowers,
                    onTap: () => setState(() => _showAllFollowers = true),
                  ),
                ],
              ),
            ),
          ),

          // ── Search bar ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spaceMedium,
            ),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: _showAllFollowers
                    ? 'Search followers...'
                    : 'Search true friends...',
                hintStyle: AppTextStyles.caption.copyWith(
                  color: AppColors.textMuted,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.textMuted,
                  size: 20,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear,
                          color: AppColors.textMuted,
                          size: 18,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: AppDimensions.spaceSmall,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    AppDimensions.borderRadiusPill,
                  ),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          const SizedBox(height: AppDimensions.spaceSmall),

          // ── Content ────────────────────────────────────────────────
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : hasError
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.wifi_off,
                          color: AppColors.textMuted,
                          size: 48,
                        ),
                        const SizedBox(height: AppDimensions.spaceSmall),
                        Text(
                          'Failed to load. Please try again.',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.spaceMedium),
                        TextButton(
                          onPressed: () {
                            ref.invalidate(myFollowersProvider);
                            ref.invalidate(myFollowingProvider);
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : _buildList(
                    followers: followersAsync.value!.followers,
                    following: followingAsync.value!.following,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildList({
    required List<Follower> followers,
    required List<Follower> following,
  }) {
    // Seed local following IDs once; optimistic updates take over after
    _localFollowingIds ??= following.map((f) => f.userId).toSet();

    final displayed = _showAllFollowers
        ? followers
        : followers
              .where((f) => _localFollowingIds!.contains(f.userId))
              .toList();

    final filtered = _applySearch(displayed);

    if (filtered.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spaceMedium),
          child: Text(
            _searchQuery.isNotEmpty
                ? 'No results for "$_searchQuery".'
                : _showAllFollowers
                ? 'You have no followers yet.'
                : 'No one follows you back yet.',
            style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: filtered.length,
      padding: const EdgeInsets.only(bottom: 100),
      itemBuilder: (context, index) {
        final follower = filtered[index];
        final isFollowingBack = _localFollowingIds!.contains(follower.userId);
        final isLoading = _loadingIds.contains(follower.userId);

        return UserTile(
          avatarUrl: follower.avatarUrl,
          userName:
              follower.displayName ?? follower.username ?? follower.userId,
          location: null,
          followers: null,
          isFollowing: isFollowingBack,
          isFollowLoading: isLoading,
          onFollowTap: () =>
              isFollowingBack ? _unfollow(follower) : _follow(follower),
          onTap: () {},
        );
      },
    );
  }
}

class _ToggleTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ToggleTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(AppDimensions.borderRadiusPill),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: selected ? Colors.white : AppColors.textMuted,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

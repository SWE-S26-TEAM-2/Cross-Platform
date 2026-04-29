import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_dimensions.dart';
import '../../constants/app_text_styles.dart';
import '../../models/user.dart';
import '../../mock_data/mock_users.dart';
import 'widgets/user_tile.dart';
import 'true_friends_screen.dart';

class FollowingScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const FollowingScreen({super.key, this.onBack});

  @override
  State<FollowingScreen> createState() => _FollowingScreenState();
}

class _FollowingScreenState extends State<FollowingScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<User> _filteredUsers = [];
  List<User> _allUsers = [];

  @override
  void initState() {
    super.initState();
    _allUsers = List.from(mockUsers);
    _filteredUsers = List.from(_allUsers);
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
      _filteredUsers = _allUsers
          .where((u) => (u.userName ?? '').toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.white, size: 28),
          onPressed: () => widget.onBack?.call(),
        ),
        title: const Text('Following', style: AppTextStyles.heading2),
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          // ── "People who follow you back" banner ──────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.spaceMedium),
              child: GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        TrueFriendsScreen(onBack: () => Navigator.pop(context)),
                  ),
                ),

                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spaceMedium,
                    vertical: AppDimensions.spaceMedium,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(
                      AppDimensions.borderRadiusSmall,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.textSecondary,
                            width: 1.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.group_outlined,
                          color: AppColors.textSecondary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.spaceMedium),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'People who follow you back',
                              style: AppTextStyles.trackTitle,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'See your true friends',
                              style: AppTextStyles.artistName,
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        color: AppColors.textSecondary,
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── User list ────────────────────────────────────────────────
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final user = _filteredUsers[index];
              return UserTile(
                avatarUrl: user.avatarUrl,
                userName: user.userName,
                location: user.location,
                followers: user.followers,
                isFollowing: true,
                onNotificationTap: () {},
                onTap: () {},
              );
            }, childCount: _filteredUsers.length),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

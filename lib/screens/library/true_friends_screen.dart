import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../constants/app_dimensions.dart';
import '../../models/user.dart';
import '../../mock_data/mock_users.dart';
import 'widgets/user_tile.dart';

class TrueFriendsScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const TrueFriendsScreen({super.key, this.onBack});

  @override
  State<TrueFriendsScreen> createState() => _TrueFriendsScreenState();
}

class _TrueFriendsScreenState extends State<TrueFriendsScreen> {
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
        title: const Text('Your true friends', style: AppTextStyles.heading2),
        centerTitle: true,
      ),
      body: _allUsers.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(AppDimensions.spaceMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No one followed you back yet',
                    style: AppTextStyles.heading2,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'People who follow you back will show up here.',
                    style: AppTextStyles.artistName,
                  ),
                ],
              ),
            )
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.spaceMedium),
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
                          hintText: 'Search',
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
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ),
                ),
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

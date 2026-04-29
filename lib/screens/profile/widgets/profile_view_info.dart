import 'package:flutter/material.dart';
import '../../../models/user.dart';

void showProfileViewInfo(BuildContext context, {required User user}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 1.0,
      minChildSize: 0.5,
      maxChildSize: 1.0,
      expand: false,
      builder: (__, scrollController) =>
          ProfileViewInfo(user: user, scrollController: scrollController),
    ),
  );
}

class ProfileViewInfo extends StatelessWidget {
  const ProfileViewInfo({super.key, required this.user, this.scrollController});

  final User user;
  final ScrollController? scrollController;

  static const Color _bg = Color(0xFF111111);

  @override
  Widget build(BuildContext context) {
    final bio = user.bio ?? '';

    return Container(
      decoration: const BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          controller: scrollController,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              const SizedBox(height: 10),
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Bio section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bio',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    bio.isNotEmpty
                        ? Text(
                            bio,
                            style: TextStyle(
                              color: Colors.grey[300],
                              fontSize: 15,
                              height: 1.5,
                            ),
                          )
                        : Text(
                            'No bio yet.',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 15,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

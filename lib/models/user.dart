class User {
  final String email;
  final String? id;
  final String? userName;
  final String? avatarUrl;
  String? password;
  final String? location;
  final int? followers;
  final int? following;
  final String? bio;

  User({
    this.id,
    required this.email,
    this.userName,
    this.avatarUrl,
    this.password,
    this.location,
    this.followers,
    this.following,
    this.bio,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id']?.toString() ?? json['user_id']?.toString(),
    email: json['email']?.toString() ?? '',
    userName: json['username']?.toString() ?? json['display_name']?.toString(),
    avatarUrl: (() {
      final raw =
          json['avatar_url']?.toString() ?? json['profile_picture']?.toString();

      if (raw == null || raw.isEmpty) return null;
      if (raw.startsWith('http')) return raw;

      return 'https://streamline-swp.duckdns.org/api/$raw';
    })(),
    location: json['location']?.toString(),
    bio: json['bio']?.toString(),
    followers: json['followers'] is int
        ? json['followers']
        : json['follower_count'] is int
        ? json['follower_count']
        : int.tryParse(
            json['followers']?.toString() ??
                json['follower_count']?.toString() ??
                '',
          ),
    following: json['following'] is int
        ? json['following']
        : json['following_count'] is int
        ? json['following_count']
        : int.tryParse(
            json['following']?.toString() ??
                json['following_count']?.toString() ??
                '',
          ),
  );
}

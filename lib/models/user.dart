class User {
  final String email;
  final String? id;
  final String? userName;
  final String? avatarUrl;
  String? password;
  final String? location;
  final int? followers;
  final int? following;

  User({
    this.id,
    required this.email,
    this.userName,
    this.avatarUrl,
    this.password,
    this.location,
    this.followers,
    this.following,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id']?.toString() ?? json['user_id']?.toString(),
    email: json['email']?.toString() ?? '',
    userName: json['username']?.toString() ?? json['display_name']?.toString(),
    avatarUrl: json['avatar_url']?.toString(),
    location: json['location']?.toString(),
    followers: json['followers'] is int
        ? json['followers']
        : int.tryParse(json['followers']?.toString() ?? ''),
    following: json['following'] is int
        ? json['following']
        : int.tryParse(json['following']?.toString() ?? ''),
  );
}

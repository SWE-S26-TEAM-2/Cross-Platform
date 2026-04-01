class User {
  /// Password to be reomved & Values to be not nullable (Not needed to be stored here in the UI)
  final String email;
  final String? id;
  final String? userName;
  final String? avatarUrl;
  String? password;

  /// For 'Change-Password' purposes it is not final.
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
    id: json['id'],
    email: json['email'],
    userName: json['username'],
    avatarUrl: json['avatar_url'],
    location: json['location'],
    followers: json['followers'],
    following: json['following'],
  );
}

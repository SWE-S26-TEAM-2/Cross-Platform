class User {
  /// Password to be reomved & Values to be not nullable (Not needed to be stored here in the UI)
  final String email;
  final String? id;
  final String? userName;
  final String? avatarUrl;
  final String? password;

  const User({
    this.id,
    required this.email,
    this.userName,
    this.avatarUrl,
    this.password,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    email: json['email'],
    userName: json['username'],
    avatarUrl: json['avatar_url'],
  );
}

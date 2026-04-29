import '../models/user.dart';

final List<User> mockUsers = [
  User(email: 'test@gmail.com', password: '12345678', userName: 'test'),
  User(
    email: 'mohamed@gmail.com',
    password: 'password123',
    userName: 'mohamed',
  ),

  User(
    email: 'amira@gmail.com',
    userName: 'Amira Elwakeel',
    location: 'Giza, Egypt',
    followers: 0,
    following: 0,
    avatarUrl: '',
  ),
];

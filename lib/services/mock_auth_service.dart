import '../models/user.dart';
import '../mock_data/mock_users.dart';

class MockAuthService {
  bool emailExists(String email) {
    final cleanEmail = email.trim().toLowerCase();
    return mockUsers.any((user) => user.email.toLowerCase() == cleanEmail);
  }

  bool signup(String email, String password) {
    final cleanEmail = email.trim();

    if (emailExists(cleanEmail)) {
      return false;
    }

    mockUsers.add(User(email: cleanEmail, password: password));
    return true;
  }

  bool login(String email, String password) {
    final cleanEmail = email.trim().toLowerCase();
    return mockUsers.any(
      (user) =>
          user.email.toLowerCase() == cleanEmail && user.password == password,
    );
  }
}

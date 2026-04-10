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

  bool changePassword(String email, String newPassword) {
    final cleanEmail = email.trim().toLowerCase();

    for (final user in mockUsers) {
      if (user.email.toLowerCase() == cleanEmail) {
        user.password = newPassword;
        return true;
      }
    }

    return false;
  }

  String? getUserPassword(String email) {
    final cleanEmail = email.trim().toLowerCase();

    for (final user in mockUsers) {
      if (user.email.toLowerCase() == cleanEmail) {
        return user.password;
      }
    }

    return null;
  }
}

import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  Future<String?> signInAndGetIdToken() async {
    await _googleSignIn.initialize(
      serverClientId:
          '131502557560-n154lh2ivl345pb3936apmum8kcn5e9p.apps.googleusercontent.com',
    );

    final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

    final GoogleSignInAuthentication googleAuth = googleUser.authentication;

    return googleAuth.idToken;
  }

  Future<void> signOut() async {
    await _googleSignIn.disconnect();
  }
}

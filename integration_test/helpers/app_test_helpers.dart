import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:my_project/models/auth_token.dart';
import 'package:my_project/models/feed_response.dart';
import 'package:my_project/main.dart' as app;
import 'package:my_project/mock_data/mock_users.dart';
import 'package:my_project/models/playlist.dart';
import 'package:my_project/models/user.dart';
import 'package:my_project/providers/auth_providers.dart';
import 'package:my_project/providers/feed_provider.dart';
import 'package:my_project/providers/playlist_provider.dart';
import 'package:my_project/services/auth_service.dart';
import 'package:my_project/services/feee_service.dart';
import 'package:my_project/services/playlist_service.dart';
import 'package:my_project/services/user_profile_services.dart';

/// Optional credentials for integration runs against the **deployed** API.
/// When both are non-empty, [loginAsSeededUser] uses them instead of
/// [TestAccounts.existingEmail] / [TestAccounts.existingPassword].
///
/// Example:
///   flutter test integration_test/auth/logout_test.dart \
///     --dart-define=E2E_EXISTING_EMAIL=user@example.com \
///     --dart-define=E2E_EXISTING_PASSWORD='your-password'
const String _kE2eExistingEmail = String.fromEnvironment(
  'E2E_EXISTING_EMAIL',
  defaultValue: '',
);
const String _kE2eExistingPassword = String.fromEnvironment(
  'E2E_EXISTING_PASSWORD',
  defaultValue: '',
);

String get _seededLoginEmail =>
    _kE2eExistingEmail.isNotEmpty && _kE2eExistingPassword.isNotEmpty
    ? _kE2eExistingEmail
    : TestAccounts.existingEmail;

String get _seededLoginPassword =>
    _kE2eExistingEmail.isNotEmpty && _kE2eExistingPassword.isNotEmpty
    ? _kE2eExistingPassword
    : TestAccounts.existingPassword;

class TestAccounts {
  static const existingEmail = 'test@gmail.com';
  static const existingPassword = '12345678';
  static const alternateEmail = 'mohamed@gmail.com';
  static const alternatePassword = 'password123';
  static const missingEmail = 'nobody@example.com';
  static const newEmail = 'integration_new@example.com';
  static const newPassword = 'password123';
}

final List<User> _baselineUsers = [
  User(
    email: TestAccounts.existingEmail,
    password: TestAccounts.existingPassword,
  ),
  User(
    email: TestAccounts.alternateEmail,
    password: TestAccounts.alternatePassword,
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

class _TestAuthNotifier extends AuthNotifier {
  _TestAuthNotifier() : super(AuthService(dio: Dio()), UserService(dio: Dio()));

  User? _findUser(String email, String password) {
    final cleanEmail = email.trim().toLowerCase();
    for (final user in mockUsers) {
      if (user.email.toLowerCase() == cleanEmail && user.password == password) {
        return user;
      }
    }
    return null;
  }

  @override
  Future<void> register({
    required String email,
    required String username,
    required String password,
    required String displayName,
    String accountType = 'listener',
  }) async {
    final cleanEmail = email.trim();
    state = const AuthState(isLoading: true);
    await Future<void>.delayed(Duration.zero);

    if (mockUsers.any(
      (user) => user.email.toLowerCase() == cleanEmail.toLowerCase(),
    )) {
      state = const AuthState(
        error: 'This email is already registered, login instead',
      );
      return;
    }

    mockUsers.add(
      User(
        email: cleanEmail,
        password: password,
        userName: username.isEmpty ? displayName : username,
      ),
    );
    state = const AuthState(
      successMessage: 'Account created! Check your email to verify.',
    );
  }

  @override
  Future<void> verifyEmail(String token) async {
    state = const AuthState(isLoading: true);
    await Future<void>.delayed(Duration.zero);
    if (token.trim().isEmpty) {
      state = const AuthState(error: 'Verification token is required');
      return;
    }
    state = const AuthState(
      successMessage: 'Email verified! You can now log in.',
    );
  }

  @override
  Future<void> resendVerification(String email) async {
    state = const AuthState(successMessage: 'Verification email resent.');
  }

  @override
  Future<void> login(String identifier, String password) async {
    state = const AuthState(isLoading: true);
    await Future<void>.delayed(Duration.zero);

    final user = _findUser(identifier, password);
    if (user == null) {
      state = const AuthState(error: 'Invalid email or password');
      return;
    }

    state = AuthState(
      tokens: const AuthTokens(
        accessToken: 'integration-test-access-token',
        refreshToken: 'integration-test-refresh-token',
      ),
      user: User(
        id: user.id ?? 'integration-test-user',
        email: user.email,
        password: user.password,
        userName: user.userName ?? user.email.split('@').first,
        location: user.location,
        followers: user.followers,
        following: user.following,
        avatarUrl: user.avatarUrl,
        bio: user.bio,
      ),
    );
  }

  @override
  Future<void> forgotPassword(String email) async {
    state = const AuthState(isLoading: true);
    await Future<void>.delayed(Duration.zero);
    final exists = mockUsers.any(
      (user) => user.email.toLowerCase() == email.trim().toLowerCase(),
    );
    if (!exists) {
      state = const AuthState(error: 'No account found with this email');
      return;
    }
    state = const AuthState(
      successMessage:
          'If an account with that email exists, a reset link has been sent.',
    );
  }

  @override
  Future<void> resetPassword(String token, String newPassword) async {
    state = const AuthState(isLoading: true);
    await Future<void>.delayed(Duration.zero);
    if (token.trim().isEmpty) {
      state = const AuthState(
        error: 'Invalid token or password does not meet requirements.',
      );
      return;
    }
    state = const AuthState(
      successMessage: 'Password updated successfully. You can now log in.',
    );
  }

  @override
  Future<void> logout() async {
    state = const AuthState();
  }
}

class _TestFeedService extends FeedService {
  _TestFeedService() : super(dio: Dio());

  static final _artist = FeedArtist(
    userId: 'integration-artist',
    username: 'integration_artist',
    displayName: 'Integration Artist',
    followerCount: 1200,
  );

  static List<FeedTrackItem> _items(String prefix) =>
      List.generate(12, (index) {
        final number = index + 1;
        return FeedTrackItem(
          trackId: '$prefix-$number',
          title: number == 1 ? 'luther' : '$prefix track $number',
          description: 'Integration test track',
          genre: 'Pop',
          tags: const ['integration'],
          releaseDate: '2026-01-01',
          coverImageUrl: '',
          streamUrl: '',
          durationSeconds: 180 + index,
          playCount: 100 + index,
          likeCount: 10 + index,
          repostCount: index,
          commentCount: index,
          isLiked: index.isEven,
          isReposted: false,
          createdAt: DateTime(2026, 1, number),
          artist: _artist,
        );
      });

  FeedResponse _feedResponse(String prefix) {
    return FeedResponse(
      success: true,
      queryTimeMs: 1,
      data: FeedData(items: _items(prefix), hasMore: false),
    );
  }

  @override
  Future<FeedResponse> getFollowingFeed({
    int limit = 20,
    String? cursor,
  }) async {
    return _feedResponse('following');
  }

  @override
  Future<FeedResponse> getDiscoverFeed({int limit = 20, String? cursor}) async {
    return _feedResponse('discover');
  }

  @override
  Future<CachedFeedResponse> getDiscoverFeedCached({
    int limit = 20,
    String? cursor,
  }) async {
    return CachedFeedResponse(
      success: true,
      optimized: true,
      cacheHit: true,
      queryTimeMs: 1,
      cachedAt: DateTime(2026).toIso8601String(),
      cacheTtlSeconds: 60,
      data: FeedData(items: _items('cached-discover'), hasMore: false),
    );
  }

  @override
  Future<void> clearFeedCache() async {}
}

class _TestPlaylistNotifier extends PlaylistNotifier {
  _TestPlaylistNotifier(Ref ref) : super(PlaylistService(dio: Dio()), ref);

  static const _lutherTrack = PlaylistTrack(
    id: 'track-luther',
    title: 'luther',
    artist: 'Kendrick Lamar ft. SZA',
    artworkUrl: '',
    durationSeconds: 180,
  );

  static const _godsPlanTrack = PlaylistTrack(
    id: 'track-plan',
    title: "God's Plan",
    artist: 'Drake',
    artworkUrl: '',
    durationSeconds: 198,
  );

  static const _playlists = [
    Playlist(
      id: 'playlist-luther',
      userId: 'integration-test-user',
      name: 'luther',
      description: 'Kendrick Lamar ft. SZA',
      coverUrl: '',
      isPublic: true,
      trackCount: 1,
      tracks: [_lutherTrack],
    ),
    Playlist(
      id: 'playlist-plan',
      userId: 'integration-test-user',
      name: "God's Plan",
      description: 'Drake',
      coverUrl: '',
      isPublic: true,
      trackCount: 1,
      tracks: [_godsPlanTrack],
    ),
  ];

  @override
  Future<void> fetchLikedPlaylists() async {
    state = state.copyWith(likedPlaylists: _playlists, clearError: true);
  }

  @override
  Future<void> searchPlaylists(String keyword) async {
    final query = keyword.trim().toLowerCase();
    if (query.isEmpty) {
      state = state.copyWith(searchResults: [], clearError: true);
      return;
    }

    final results = _playlists.where((playlist) {
      return playlist.name.toLowerCase().contains(query) ||
          playlist.description.toLowerCase().contains(query) ||
          playlist.tracks.any(
            (track) =>
                track.title.toLowerCase().contains(query) ||
                track.artist.toLowerCase().contains(query),
          );
    }).toList();

    state = state.copyWith(searchResults: results, clearError: true);
  }

  @override
  Future<Playlist?> getPlaylistDetails(String playlistId) async {
    for (final playlist in _playlists) {
      if (playlist.id == playlistId) return playlist;
    }
    return null;
  }

  @override
  Future<void> likePlaylist(String playlistId) async {
    state = state.copyWith(successMessage: 'Playlist added to your playlists.');
  }
}

IntegrationTestWidgetsFlutterBinding ensureBinding() {
  return IntegrationTestWidgetsFlutterBinding.ensureInitialized()
      as IntegrationTestWidgetsFlutterBinding;
}

Future<void> resetMockUsers() async {
  mockUsers
    ..clear()
    ..addAll(
      _baselineUsers.map(
        (user) => User(
          email: user.email,
          password: user.password,
          userName: user.userName,
          location: user.location,
          followers: user.followers,
          following: user.following,
          avatarUrl: user.avatarUrl,
        ),
      ),
    );
}

Future<void> launchApp(WidgetTester tester) async {
  await resetMockUsers();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authProvider.overrideWith((ref) => _TestAuthNotifier()),
        feedServiceProvider.overrideWith((ref) => _TestFeedService()),
        playlistProvider.overrideWith((ref) => _TestPlaylistNotifier(ref)),
      ],
      child: const app.SoundCloudApp(),
    ),
  );
  await pumpUntilVisible(tester, find.text('Create an account'));
  await tester.pumpAndSettle();
}

Future<void> pumpUntilVisible(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 10),
  Duration step = const Duration(milliseconds: 100),
}) async {
  var elapsed = Duration.zero;
  while (elapsed <= timeout) {
    await tester.pump(step);
    if (finder.evaluate().isNotEmpty) {
      return;
    }
    elapsed += step;
  }
  throw TestFailure('Timed out waiting for finder: $finder');
}

// ============================================================================
// Legacy text-based finders (preserved for back-compat with existing suites)
// ============================================================================

Finder authFieldAt(int index) => find.byType(TextField).at(index);

Finder actionButton(String text) => find.widgetWithText(ElevatedButton, text);

Finder textButton(String text) => find.widgetWithText(TextButton, text);

Finder outlinedActionButton(String text) =>
    find.widgetWithText(OutlinedButton, text);

Finder textFormFieldByHint(String hintText) {
  return textFieldByHint(hintText);
}

Finder textFieldByHint(String hintText) {
  return find.byWidgetPredicate(
    (widget) => widget is TextField && widget.decoration?.hintText == hintText,
    description: 'TextField with hint "$hintText"',
  );
}

// ============================================================================
// Key-based finders (preferred for new tests). Use these alongside the legacy
// helpers above so old suites keep working.
// ============================================================================

/// Convenience wrapper around `find.byKey(Key(value))`.
Finder byKey(String value) => find.byKey(Key(value));

/// Find a [TextFormField]/[TextField] by Key. Returns the underlying
/// [Finder] which can be passed to [WidgetTester.enterText].
Finder keyedField(String value) => byKey(value);

/// Find a button (ElevatedButton/OutlinedButton/TextButton/IconButton/etc.)
/// by Key. Mirrors [actionButton]/[outlinedActionButton] but selects on
/// Key instead of visible text, which is far more robust.
Finder keyedButton(String value) => byKey(value);

/// Tap a widget by Key and pump-and-settle.
Future<void> tapKey(
  WidgetTester tester,
  String value, {
  Duration settle = const Duration(milliseconds: 300),
}) async {
  final finder = byKey(value);
  expect(
    finder,
    findsWidgets,
    reason: 'Expected at least one widget with Key($value)',
  );
  await tester.tap(finder.first);
  await tester.pumpAndSettle(settle);
}

/// Enter text into a keyed field.
Future<void> enterTextByKey(
  WidgetTester tester,
  String value,
  String text,
) async {
  final finder = byKey(value);
  expect(finder, findsOneWidget, reason: 'No field with Key($value)');
  await tester.enterText(finder, text);
  await tester.pump();
}

/// Matches the welcome tagline regardless of newline form. The original
/// asset uses `'Where artists\n& fans connect.'` while some integration
/// tests previously asserted a single-line copy. This finder accepts both
/// forms (anything starting with "Where artists") so tests no longer break
/// when the design wraps differently.
Finder welcomeTaglineFinder() => find.byWidgetPredicate(
  (widget) =>
      widget is Text &&
      (widget.data ?? '').trimLeft().startsWith('Where artists'),
  description: 'Text widget starting with "Where artists"',
);

// ============================================================================
// Common high-level helpers
// ============================================================================

Future<void> tapAndSettle(
  WidgetTester tester,
  Finder finder, {
  Duration settle = const Duration(milliseconds: 300),
}) async {
  expect(finder, findsOneWidget);
  await tester.tap(finder);
  await tester.pumpAndSettle(settle);
}

Future<void> enterLoginCredentials(
  WidgetTester tester, {
  required String email,
  required String password,
}) async {
  await tester.enterText(textFormFieldByHint('Email address'), email);
  await tester.enterText(textFormFieldByHint('Password'), password);
  await tester.pump();
}

Future<void> loginAsSeededUser(WidgetTester tester) async {
  await tapAndSettle(tester, outlinedActionButton('Log in'));
  await enterLoginCredentials(
    tester,
    email: _seededLoginEmail,
    password: _seededLoginPassword,
  );
  await tapAndSettle(tester, actionButton('Log in'));
  await pumpUntilVisible(tester, find.text('Home'));
  await tester.pumpAndSettle();
}

Future<void> openBottomTab(WidgetTester tester, String label) async {
  await tapAndSettle(tester, find.text(label));
  await pumpUntilVisible(tester, find.text(label));
}

// ============================================================================
// Additional helpers for extended test coverage
// ============================================================================

/// Clears text from a TextField by selecting all and deleting.
Future<void> clearTextField(WidgetTester tester, Finder finder) async {
  await tester.tap(finder);
  await tester.pumpAndSettle();
  await tester.enterText(finder, '');
  await tester.pump();
}

/// Performs rapid taps on a finder without waiting for settle.
/// Useful for testing debounce and duplicate-prevention logic.
Future<void> rapidTaps(
  WidgetTester tester,
  Finder finder, {
  int count = 5,
  Duration interval = const Duration(milliseconds: 50),
}) async {
  for (var i = 0; i < count; i++) {
    await tester.tap(finder);
    await tester.pump(interval);
  }
}

/// Drives the actual logout UI: opens the Library tab and taps the
/// Key('library.logout') IconButton, then waits for the WelcomeScreen to
/// reappear. Replaces the previous TODO placeholder.
Future<void> simulateLogout(WidgetTester tester) async {
  await openBottomTab(tester, 'Library');
  await tapKey(tester, 'library.logout');
  await pumpUntilVisible(tester, find.text('Create an account'));
  await tester.pumpAndSettle();
}

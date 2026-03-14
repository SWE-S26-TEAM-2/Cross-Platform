class AppDimensions {
  // ─── SPACING ──────────────────────────────────────────────
  // Used for padding, margins, and gaps between elements
  static const double spaceExtraSmall = 4.0; // icon-to-label gaps
  static const double spaceSmall = 8.0; // inner component padding
  static const double spaceMedium = 16.0; // screen edge padding (most common)
  static const double spaceLarge = 24.0; // between sections
  static const double spaceExtraLarge = 32.0; // top of screen breathing room

  // ─── TRACK ARTWORK ────────────────────────────────────────
  // The square thumbnail image shown on each track
  static const double trackArtworkSmall = 56.0; // inside a list tile row
  static const double trackArtworkMedium =
      120.0; // inside a horizontal scroll card

  // ─── PLAYER ───────────────────────────────────────────────
  static const double miniPlayerBarHeight =
      64.0; // persistent bar above bottom nav

  // ─── BOTTOM NAVIGATION ────────────────────────────────────
  static const double bottomNavBarHeight = 60.0; // the tab bar at the bottom

  // ─── BORDER RADIUS ────────────────────────────────────────
  // Controls how rounded the corners of elements are
  static const double borderRadiusSharp =
      4.0; // list tile artwork, subtle rounding
  static const double borderRadiusSmall = 8.0; // cards
  static const double borderRadiusMedium = 12.0; // modals, bottom sheets
  static const double borderRadiusPill = 20.0; // pill-shaped buttons and chips

  // ─── AVATAR / PROFILE PICTURE ─────────────────────────────
  static const double avatarSizeSmall = 32.0; // in comments and notifications
  static const double avatarSizeMedium = 44.0; // in list tiles
  static const double avatarSizeLarge = 80.0; // on profile page header
}

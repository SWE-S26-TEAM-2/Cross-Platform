const String apiOrigin = 'https://streamline-swp.duckdns.org';
const String apiBaseUrl = '$apiOrigin/api';

String resolveApiUrl(String path) {
  final normalized = path.trim();

  if (normalized.isEmpty) {
    return '';
  }

  if (normalized.startsWith('http://') || normalized.startsWith('https://')) {
    return normalized;
  }

  final trimmed = normalized.startsWith('/')
      ? normalized.substring(1)
      : normalized;

  if (trimmed.startsWith('api/')) {
    return '$apiOrigin/$trimmed';
  }

  return '$apiBaseUrl/$trimmed';
}

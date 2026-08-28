/// A deterministic 32-bit FNV-1a hash.
///
/// Dart's runtime hash codes are not a persistence contract, so generated
/// lessons use this helper for IDs and shuffle seeds that must survive rebuilds
/// and app restarts.
int stableHash32(String value) {
  var hash = 0x811c9dc5;
  for (final byte in value.codeUnits) {
    hash ^= byte;
    hash = (hash * 0x01000193) & 0xffffffff;
  }
  return hash;
}

String stableContentId(String namespace, Iterable<String?> parts) {
  final content = parts.map((part) => part?.trim() ?? '').join('\u001f');
  return '$namespace-${stableHash32(content).toRadixString(16).padLeft(8, '0')}';
}

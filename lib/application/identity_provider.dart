// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Project imports:
import 'package:words625/core/identity.dart';
import 'package:words625/core/logger.dart';

/// Owns the learner's *public* identity: the handle and avatar other people
/// see, as opposed to the Google account behind it.
///
/// See `lib/core/identity.dart` for why the two are kept apart.
class IdentityProvider extends ChangeNotifier {
  IdentityProvider();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? handle;
  String? avatarSeed;
  bool isSaving = false;

  DocumentReference<Map<String, dynamic>>? get _doc {
    final userId = _auth.currentUser?.uid;
    return userId == null ? null : _firestore.collection('users').doc(userId);
  }

  /// Gives every account a handle, including the ones created before handles
  /// existed. Runs on app open and is a no-op once a handle is set.
  Future<void> ensureHandle() async {
    final doc = _doc;
    final user = _auth.currentUser;
    if (doc == null || user == null) return;

    try {
      final snapshot = await doc.get();
      final data = snapshot.data() ?? const <String, dynamic>{};

      final existing = (data['handle'] as String?)?.trim();
      if (existing != null && existing.isNotEmpty) {
        handle = existing;
        avatarSeed = (data['avatarSeed'] as String?) ?? existing;
        notifyListeners();
        return;
      }

      final assigned = await _uniqueHandle(
        handleFromName(user.displayName),
        user.uid,
      );
      await doc.set({
        'handle': assigned,
        'avatarSeed': user.uid,
        // The Google photo is no longer shown anywhere; clear it so it cannot
        // be picked up by older screens or exported.
        'profileImage': '',
      }, SetOptions(merge: true));

      handle = assigned;
      avatarSeed = user.uid;
      notifyListeners();
    } catch (error, stackTrace) {
      logger.e('Could not assign a handle',
          error: error, stackTrace: stackTrace);
    }
  }

  /// Saves a handle the learner chose. Returns an error message, or null when
  /// it was saved.
  Future<String?> setHandle(String candidate) async {
    final trimmed = candidate.trim();
    final problem = validateHandle(trimmed);
    if (problem != null) return problem;
    if (trimmed == handle) return null;

    final doc = _doc;
    if (doc == null) return 'You need to be signed in.';

    isSaving = true;
    notifyListeners();
    try {
      if (await _isTaken(trimmed)) return 'That handle is taken.';
      await doc.set({'handle': trimmed}, SetOptions(merge: true));
      handle = trimmed;
      return null;
    } catch (error, stackTrace) {
      logger.e('Could not save handle', error: error, stackTrace: stackTrace);
      return 'Could not save. Try again.';
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  /// Rerolls the avatar. The seed is opaque, so this is just a new pattern —
  /// nothing about it is derived from the account.
  Future<void> shuffleAvatar() async {
    final doc = _doc;
    if (doc == null) return;
    final seed =
        '${_auth.currentUser?.uid}-${DateTime.now().microsecondsSinceEpoch}';
    avatarSeed = seed;
    notifyListeners();
    try {
      await doc.set({'avatarSeed': seed}, SetOptions(merge: true));
    } catch (error) {
      logger.e('Could not save avatar: $error');
    }
  }

  Future<bool> _isTaken(String candidate) async {
    final matches = await _firestore
        .collection('users')
        .where('handle', isEqualTo: candidate)
        .limit(1)
        .get();
    if (matches.docs.isEmpty) return false;
    return matches.docs.first.id != _auth.currentUser?.uid;
  }

  /// Adds a short stable suffix if the derived handle is already in use.
  Future<String> _uniqueHandle(String base, String uid) async {
    try {
      if (!await _isTaken(base)) return base;
      final withSuffix = '$base${handleSuffix(uid)}';
      if (!await _isTaken(withSuffix)) return withSuffix;
    } catch (error) {
      // A failed lookup must not block sign-in; fall through to the suffix.
      logger.e('Handle uniqueness check failed: $error');
    }
    return '$base${handleSuffix(uid)}';
  }
}

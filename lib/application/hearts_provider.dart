// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';

class HeartsState {
  final int hearts;
  final DateTime? heartsRefillAt;

  const HeartsState({
    required this.hearts,
    required this.heartsRefillAt,
  });

  bool get hasHearts => hearts > 0;
}

@injectable
class HeartsProvider extends ChangeNotifier {
  static const int maxHearts = 5;
  static const Duration refillInterval = Duration(minutes: 30);
  static const int refillCostInGems = 350;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<HeartsState> getHeartsStream() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return Stream.value(
          const HeartsState(hearts: maxHearts, heartsRefillAt: null));
    }

    return _firestore.collection('users').doc(userId).snapshots().map((doc) {
      final data = doc.data() ?? <String, dynamic>{};
      return HeartsState(
        hearts: _readInt(data['hearts'], maxHearts),
        heartsRefillAt: _parseDate(data['heartsRefillAt']),
      );
    });
  }

  Future<void> ensureHeartsInitialized() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final docRef = _firestore.collection('users').doc(userId);
    final doc = await docRef.get();
    if (!doc.exists) return;

    await docRef.set({
      'hearts': maxHearts,
      'heartsRefillAt': null,
    }, SetOptions(merge: true));

    await refillHeart();
  }

  Future<void> loseHeart() async {
    // Open-source mode: hearts are non-depleting to avoid blocking practice.
    await refillHeart();
  }

  Future<void> refillHeart() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final docRef = _firestore.collection('users').doc(userId);

    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(docRef);
      if (!doc.exists) return;

      transaction.update(docRef, {
        'hearts': maxHearts,
        'heartsRefillAt': null,
      });
    });

    notifyListeners();
  }

  Future<bool> useGemsForHearts() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return false;

    final docRef = _firestore.collection('users').doc(userId);

    final success = await _firestore.runTransaction<bool>((transaction) async {
      final doc = await transaction.get(docRef);
      if (!doc.exists) return false;

      final data = doc.data() ?? <String, dynamic>{};
      final gems = _readInt(data['gems'], 0);
      if (gems < refillCostInGems) {
        return false;
      }

      transaction.update(docRef, {
        'gems': gems - refillCostInGems,
        'hearts': maxHearts,
        'heartsRefillAt': null,
      });
      return true;
    });

    if (success) notifyListeners();
    return success;
  }

  int _readInt(dynamic value, int fallback) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return fallback;
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}

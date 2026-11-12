// Package imports:
import 'package:firebase_auth/firebase_auth.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'firebase_user.freezed.dart';
part 'firebase_user.g.dart';

@freezed
abstract class SerializableFirebaseUser with _$SerializableFirebaseUser {
  const factory SerializableFirebaseUser({
    required String? uid,
    required String? email,
    required String? displayName,
    required String? photoUrl,
  }) = _SerializableFirebaseUser;

  // Factory method to create a SerializableFirebaseUser from a Firebase User
  factory SerializableFirebaseUser.fromFirebaseUser(User user) {
    return SerializableFirebaseUser(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoURL,
    );
  }

  factory SerializableFirebaseUser.fromJson(Map<String, dynamic> json) =>
      _$SerializableFirebaseUserFromJson(json);
}

// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_route/auto_route.dart';
import 'package:chiclet/chiclet.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Project imports:
import 'package:words625/core/logger.dart';
import 'package:words625/di/injection.dart';
import 'package:words625/routing/routing.gr.dart';
import 'package:words625/service/locator.dart';
import 'package:words625/views/theme.dart';
import 'web_wrapper.dart' as web;

// Conditional import for web-only renderButton

enum AuthState { loading, authenticated, unauthenticated }

class GetStartedButton extends StatefulWidget {
  final String label;
  final double? width;

  const GetStartedButton({
    Key? key,
    this.label = 'CONTINUE WITH GOOGLE',
    this.width,
  }) : super(key: key);

  @override
  State<GetStartedButton> createState() => _GetStartedButtonState();
}

class _GetStartedButtonState extends State<GetStartedButton> {
  AuthState _authState = AuthState.unauthenticated;
  StreamSubscription<GoogleSignInAuthenticationEvent>? _authSubscription;

  @override
  void initState() {
    super.initState();
    // Listen to authentication events (works for both web and mobile).
    // On web, Google's renderButton triggers events on this stream.
    _authSubscription = GoogleSignIn.instance.authenticationEvents
        .listen(_handleAuthenticationEvent)
      ..onError(_handleAuthenticationError);
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  void _updateAuthState(AuthState authState) {
    if (mounted) {
      setState(() {
        _authState = authState;
      });
    }
  }

  Future<void> _handleAuthenticationEvent(
    GoogleSignInAuthenticationEvent event,
  ) async {
    switch (event) {
      case GoogleSignInAuthenticationEventSignIn(:final user):
        await _processSignIn(user);
      case GoogleSignInAuthenticationEventSignOut():
        _updateAuthState(AuthState.unauthenticated);
    }
  }

  void _handleAuthenticationError(Object error) {
    if (error is GoogleSignInException) {
      logger.w('Google Sign In failed: ${error.code}');
    } else {
      logger.e('Google Sign In Error: $error');
    }
    _updateAuthState(AuthState.unauthenticated);
  }

  /// Processes a successful Google sign-in and creates Firebase credential.
  Future<void> _processSignIn(GoogleSignInAccount googleUser) async {
    try {
      _updateAuthState(AuthState.loading);

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        await getIt<AppPrefs>().setFirebaseUser(firebaseUser);
        await _initializeUserDocument(firebaseUser);

        if (mounted) {
          context.router.pushAndPopUntil(
            const HomeRoute(),
            predicate: (route) => false,
          );
        }
      } else {
        logger.w('Firebase user is null after Google Sign In');
        _updateAuthState(AuthState.unauthenticated);
      }
    } catch (e, stackTrace) {
      logger.e('Firebase Sign In Error: $e');
      logger.e('Stack Trace: $stackTrace');
      _updateAuthState(AuthState.unauthenticated);
    }
  }

  /// On mobile: calls authenticate() directly.
  /// On web: authenticate() is unsupported; the renderButton handles it.
  Future<void> _handleGoogleLogin() async {
    try {
      _updateAuthState(AuthState.loading);
      // authenticate() triggers an authenticationEvents stream event,
      // which is handled by _handleAuthenticationEvent above.
      await GoogleSignIn.instance.authenticate();
    } on GoogleSignInException catch (e) {
      logger.w('Google Sign In cancelled or failed: ${e.code}');
      _updateAuthState(AuthState.unauthenticated);
    } catch (e, stackTrace) {
      logger.e('Google Sign In Error: $e');
      logger.e('Google Sign In Stack Trace: $stackTrace');
      _updateAuthState(AuthState.unauthenticated);
    }
  }

  @override
  Widget build(BuildContext context) {
    // On web, authenticate() is not supported.
    // Use Google's renderButton instead, which triggers authenticationEvents.
    if (!GoogleSignIn.instance.supportsAuthenticate()) {
      if (kIsWeb) {
        return web.renderButton();
      }
      return const Text('Sign in is not supported on this platform');
    }

    // On mobile, use the custom styled button.
    return ChicletAnimatedButton(
      width: widget.width ?? MediaQuery.of(context).size.width * 0.9,
      onPressed: _handleGoogleLogin,
      buttonType: ChicletButtonTypes.roundedRectangle,
      backgroundColor: primaryColor,
      child: _authState == AuthState.loading
          ? const SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.login, color: Colors.white, size: 18)
              ],
            ),
    );
  }

  Future<void> _initializeUserDocument(User firebaseUser) async {
    final userDoc =
        FirebaseFirestore.instance.collection('users').doc(firebaseUser.uid);

    try {
      final docSnapshot = await userDoc.get();

      if (!docSnapshot.exists) {
        await userDoc.set({
          'name': firebaseUser.displayName ?? 'Anonymous',
          'profileImage': firebaseUser.photoURL ??
              'default_image_url', // You can replace 'default_image_url' with any placeholder
          'streak': 0,
          'score': 0,
          'gems': 0,
          'hearts': 5,
          'heartsRefillAt': null,
          'streakFreezes': 0,
          'streakFreezeActive': false,
          'league': 'bronze',
          'leagueXp': 0,
          'leagueJoinedAt': FieldValue.serverTimestamp(),
          'achievements': <String>[],
          'dailyXpGoal': 50,
          'dailyXpEarned': 0,
          'lastDailyReset': DateTime.now().toIso8601String(),
          'lessonsCompleted': 0,
          'perfectLessons': 0,
          'streakWasBroken': false,
          'streakRepairRequired': false,
          'streakRepairProgress': 0,
          'streakRepairTarget': 100,
          'streakBeforeBreak': 0,
          'followRewardClaimed': false,
          'validatedShareCount': 0,
          'claimedShareCount': 0,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        logger.i(
            "User document created with initial values for userId: ${firebaseUser.uid}");
      } else {
        logger
            .i("User document already exists for userId: ${firebaseUser.uid}");
      }
    } catch (e) {
      logger.e("Error initializing user document: $e");
    }
  }
}

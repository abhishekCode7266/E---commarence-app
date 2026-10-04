import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

/// Service responsible for authentication operations.
/// Seamlessly uses real Firebase Auth when initialized, or a robust demo mock session on web previews.
class AuthService {
  final FirebaseAuth? _firebaseAuth;
  static AppUser? _mockUser;
  static final StreamController<AppUser?> _mockController =
      StreamController<AppUser?>.broadcast();

  AuthService({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = (firebaseAuth != null)
            ? firebaseAuth
            : (Firebase.apps.isNotEmpty ? FirebaseAuth.instance : null);

  /// Whether real Firebase Auth backend is active.
  bool get isFirebaseAvailable => _firebaseAuth != null;

  /// Stream of authentication state changes.
  Stream<AppUser?> get authStateChanges {
    if (isFirebaseAvailable) {
      return _firebaseAuth!.authStateChanges().map((user) {
        if (user == null) return null;
        return AppUser(
          uid: user.uid,
          email: user.email ?? '',
          displayName: user.displayName,
          createdAt: user.metadata.creationTime ?? DateTime.now(),
        );
      });
    }

    // Demo/offline mode stream
    return _mockController.stream.asBroadcastStream();
  }

  /// Currently authenticated user.
  AppUser? get currentUser {
    if (isFirebaseAvailable) {
      final user = _firebaseAuth!.currentUser;
      if (user == null) return null;
      return AppUser(
        uid: user.uid,
        email: user.email ?? '',
        displayName: user.displayName,
        createdAt: user.metadata.creationTime ?? DateTime.now(),
      );
    }
    return _mockUser;
  }

  /// Sign up a new user using email and password.
  Future<AppUser> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final cleanEmail = email.trim();

    if (isFirebaseAvailable) {
      try {
        final credential = await _firebaseAuth!.createUserWithEmailAndPassword(
          email: cleanEmail,
          password: password,
        );

        if (displayName != null && displayName.trim().isNotEmpty) {
          await credential.user?.updateDisplayName(displayName.trim());
          await credential.user?.reload();
        }

        final fbUser = _firebaseAuth!.currentUser ?? credential.user!;
        return AppUser(
          uid: fbUser.uid,
          email: fbUser.email ?? cleanEmail,
          displayName: fbUser.displayName ?? displayName,
          createdAt: fbUser.metadata.creationTime ?? DateTime.now(),
        );
      } on FirebaseAuthException catch (e) {
        throw _handleFirebaseAuthException(e);
      } catch (e) {
        throw 'An unexpected error occurred during signup. Please try again.';
      }
    }

    // Demo mode signup
    await Future.delayed(const Duration(milliseconds: 300));
    final name = (displayName != null && displayName.trim().isNotEmpty)
        ? displayName.trim()
        : cleanEmail.split('@').first;
    final newUser = AppUser(
      uid: 'demo_user_${DateTime.now().millisecondsSinceEpoch}',
      email: cleanEmail,
      displayName: name,
      createdAt: DateTime.now(),
    );
    _mockUser = newUser;
    _mockController.add(newUser);
    return newUser;
  }

  /// Sign in an existing user with email and password.
  Future<AppUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim();

    if (isFirebaseAvailable) {
      try {
        final credential = await _firebaseAuth!.signInWithEmailAndPassword(
          email: cleanEmail,
          password: password,
        );
        final fbUser = credential.user!;
        return AppUser(
          uid: fbUser.uid,
          email: fbUser.email ?? cleanEmail,
          displayName: fbUser.displayName,
          createdAt: fbUser.metadata.creationTime ?? DateTime.now(),
        );
      } on FirebaseAuthException catch (e) {
        throw _handleFirebaseAuthException(e);
      } catch (e) {
        throw 'An unexpected error occurred during login. Please try again.';
      }
    }

    // Demo mode sign in
    await Future.delayed(const Duration(milliseconds: 300));
    final name = cleanEmail.split('@').first;
    final loggedUser = AppUser(
      uid: 'demo_user_1',
      email: cleanEmail,
      displayName: name.isNotEmpty ? name[0].toUpperCase() + name.substring(1) : 'Demo User',
      createdAt: DateTime.now(),
    );
    _mockUser = loggedUser;
    _mockController.add(loggedUser);
    return loggedUser;
  }

  /// Sign out current user session.
  Future<void> signOut() async {
    if (isFirebaseAvailable) {
      try {
        await _firebaseAuth!.signOut();
      } catch (e) {
        throw 'Failed to sign out. Please try again.';
      }
    } else {
      _mockUser = null;
      _mockController.add(null);
    }
  }

  /// Send password reset email.
  Future<void> sendPasswordResetEmail(String email) async {
    if (isFirebaseAvailable) {
      try {
        await _firebaseAuth!.sendPasswordResetEmail(email: email.trim());
      } on FirebaseAuthException catch (e) {
        throw _handleFirebaseAuthException(e);
      } catch (e) {
        throw 'Failed to send password reset email. Please try again.';
      }
    } else {
      await Future.delayed(const Duration(milliseconds: 200));
    }
  }

  /// Quick sign in with Demo account.
  Future<AppUser> signInWithDemoAccount() async {
    return signInWithEmailAndPassword(
      email: 'demo@taskflow.app',
      password: 'password123',
    );
  }

  String _handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found for that email address.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect password or email. Please check your credentials.';
      case 'email-already-in-use':
        return 'The account already exists for that email.';
      case 'weak-password':
        return 'The password provided is too weak. Please use at least 6 characters.';
      case 'invalid-email':
        return 'The email address is badly formatted.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'too-many-requests':
        return 'Too many unsuccessful attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network connection failed. Please check your internet connection.';
      default:
        return e.message ?? 'Authentication failed. Please try again.';
    }
  }
}

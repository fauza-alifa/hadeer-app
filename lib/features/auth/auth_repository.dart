import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(FirebaseAuth.instance),
);

class AuthRepository {
  AuthRepository(this.auth);
  final FirebaseAuth auth;

  Future<void> signIn(String email, String password) async {
    await auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Stream<User?> watchSession() {
    return auth.authStateChanges();
  }

  String get studentName {
    final user = auth.currentUser;
    return user?.displayName ?? user?.email?.split('@').first ?? 'Siswi';
  }

  Future<void> signOut() async {
    await auth.signOut();
  }
}

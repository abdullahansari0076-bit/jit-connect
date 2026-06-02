// lib/data/repositories/auth_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_models.dart';
import '../../core/constants/app_constants.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository());

final currentUserProvider = StreamProvider<AppUser?>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return repo.authStateChanges();
});

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<AppUser?> authStateChanges() {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      return await getUser(user.uid);
    });
  }

  Future<AppUser?> getUser(String uid) async {
    try {
      final doc = await _db.collection(AppConstants.colUsers).doc(uid).get();
      if (!doc.exists) return null;
      return AppUser.fromFirestore(doc);
    } catch (e) {
      return null;
    }
  }

  Future<AppUser> signIn({required String email, required String password}) async {
    final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
    final user = await getUser(cred.user!.uid);
    if (user == null) throw Exception('User profile not found. Contact HOD.');
    if (!user.isActive) throw Exception('Your account has been deactivated. Contact HOD.');
    return user;
  }

  Future<void> signOut() async => _auth.signOut();

  Future<void> changePassword({required String currentPwd, required String newPwd}) async {
    final user = _auth.currentUser!;
    final cred = EmailAuthProvider.credential(email: user.email!, password: currentPwd);
    await user.reauthenticateWithCredential(cred);
    await user.updatePassword(newPwd);
    await _db.collection(AppConstants.colUsers).doc(user.uid).update({
      'mustChangePassword': false,
    });
  }

  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // HOD creates teacher/student account
  Future<AppUser> createUserAccount({
    required String email,
    required String password,
    required UserRole role,
    required String name,
    required String employeeId,
    required String phone,
  }) async {
    // Create secondary auth instance to avoid signing out HOD
    final secondaryApp = await FirebaseAuth.instanceFor(
      app: FirebaseAuth.instance.app,
    );
    final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email, password: password,
    );
    final uid = cred.user!.uid;
    final user = AppUser(
      uid: uid, role: role, name: name, employeeId: employeeId,
      email: email, phone: phone, isActive: true,
      mustChangePassword: true, createdAt: DateTime.now(),
    );
    await _db.collection(AppConstants.colUsers).doc(uid).set(user.toFirestore());
    return user;
  }
}

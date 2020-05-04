import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';

abstract class BaseAuth {
  Future<String> signIn(String email, String password);

  Future<String> signInAnonymously();

  Future<String> signUp(String email, String password, String username);

  Future<FirebaseUser> getCurrentUser();

  Future<void> sendEmailVerification();

  Future<void> signOut();

  Future<bool> isEmailVerified();
}

class AuthUtil implements BaseAuth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Future<String> signIn(String email, String password) async {
    final result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
    final user = result.user;
    return user.uid;
  }

  @override
  Future<String> signInAnonymously() async {
    final user = (await _firebaseAuth.signInAnonymously()).user;
    assert(user != null);
    assert(user.isAnonymous);
    assert(!user.isEmailVerified);
    assert(await user.getIdToken() != null);
    if (Platform.isIOS) {
      // Anonymous auth doesn't show up as a provider on iOS
      assert(user.providerData.isEmpty);
    } else if (Platform.isAndroid) {
      // Anonymous auth does show up as a provider on Android
      assert(user.providerData.length == 1);
      assert(user.providerData[0].providerId == 'firebase');
      assert(user.providerData[0].uid != null);
      assert(user.providerData[0].displayName == null);
      assert(user.providerData[0].photoUrl == null);
      assert(user.providerData[0].email == null);
    }
    final currentUser = await _firebaseAuth.currentUser();
    assert(user.uid == currentUser.uid);
    return user.uid;
  }

  @override
  Future<String> signUp(String email, String password, String username) async {
    final result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
    final user = result.user;

    final UserUpdateInfo userUpdateInfo = UserUpdateInfo();
    userUpdateInfo.displayName = username;
    await user.updateProfile(userUpdateInfo);

    return user.uid;
  }

  @override
  Future<FirebaseUser> getCurrentUser() async {
    final user = await _firebaseAuth.currentUser();
    return user;
  }

  @override
  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }

  @override
  Future<void> sendEmailVerification() async {
    final user = await _firebaseAuth.currentUser();
    await user.sendEmailVerification();
  }

  @override
  Future<bool> isEmailVerified() async {
    final user = await _firebaseAuth.currentUser();
    return user.isEmailVerified;
  }
}

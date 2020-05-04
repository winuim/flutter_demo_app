import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthUserModel with ChangeNotifier {
  AuthUserModel() {
    getCurrentUser();
  }

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  FirebaseUser _user;
  FirebaseUser get user => _user;

  Future<void> getCurrentUser() async {
    final user = await _firebaseAuth.currentUser();
    assert(user != null);
    assert(await user.getIdToken() != null);
    _user = user;
    notifyListeners();
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    final user = await _firebaseAuth.currentUser();
    assert(user == null);
    _user = null;
    notifyListeners();
  }

  Future<void> signIn(String email, String password) async {
    final result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
    assert(result != null);
    assert(result.user != null);
    assert(await result.user.getIdToken() != null);
    _user = result.user;
    notifyListeners();
  }

  Future<void> signInAnonymously() async {
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
    _user = currentUser;
    notifyListeners();
  }

  Future<void> signUp(String email, String password, String username) async {
    final result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
    assert(result != null);
    assert(result.user != null);
    final user = result.user;
    assert(await user.getIdToken() != null);
    final userUpdateInfo = UserUpdateInfo();
    userUpdateInfo.displayName = username;
    await user.updateProfile(userUpdateInfo);
    assert(user.displayName == username);
    _user = user;
    notifyListeners();
  }
}

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pickme_mobile/spec/properties.dart';

import '../sharePreference.dart';
import 'firebaseProfile.dart';

String? firebaseUserId;
final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

abstract class BaseAuth {
  Future<String> signIn({@required String email});

  Future<String> signUp({@required String email});

  Future<User> getCurrentUser();

  Future<void> sendVerification();

  Future<bool> isEmailVerified();

  Future<void> signOut();

  Future<String?> getToken();
}

class FireAuth implements BaseAuth {
  final FireProfile _firebaseProfile = new FireProfile();

  @override
  Future<User> getCurrentUser() async {
    User user = _firebaseAuth.currentUser!;
    return user;
  }

  @override
  Future<void> signOut() {
    return _firebaseAuth.signOut();
  }

  @override
  Future<String> signUp({
    @required String? email,
    @required String? password,
  }) async {
    UserCredential result = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email!,
      password: password!,
    );
    User user = result.user!;
    return user.uid;
  }

  @override
  Future<String> signIn({
    @required String? email,
    @required String? userId,
    @required String? name,
    String password = Properties.defaultPassword,
  }) async {
    String? ret = "";
    await signOut();
    try {
      UserCredential result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email!,
        password: password,
      );
      User user = result.user!;
      debugPrint("fire out ${user.uid}");
      //add user details to db
      await _firebaseProfile.createAccount(
        email: email,
        firebaseUserId: user.uid,
        userId: userId,
        name: name,
      );
      firebaseUserId = user.uid;
      await saveStringShare(key: "firebaseUserId", data: firebaseUserId);
      await saveToken();
      return user.uid;
    } on FirebaseAuthException catch (e) {
      //create new account if log in successfully
      debugPrint(e.toString());
      debugPrint("codes ${e.code}");
      if (e.code == 'user-not-found' || e.code == "invalid-credential") {
        signUp(email: email, password: password).then((value) {
          signIn(
            email: email,
            userId: userId,
            name: name,
            password: password,
          );
          ret = "login";
        });
      } else if (e.code == 'wrong-password') {
        if (kDebugMode) {
          print('Wrong password provided for that user.');
        }
      } else {
        if (kDebugMode) {
          print('Error: ${e.code} - ${e.message}');
        }
      }
    } catch (e) {
      //create new account if log in successfully
      debugPrint(e.toString());
    }
    return ret!;
  }

  @override
  Future<bool> isEmailVerified() async {
    User user = _firebaseAuth.currentUser!;
    return user.emailVerified;
  }

  @override
  Future<void> sendVerification() async {
    User user = _firebaseAuth.currentUser!;
    return user.sendEmailVerification();
  }

  @override
  // ignore: override_on_non_overriding_member
  Future getCurrentUserId() async {
    User user = _firebaseAuth.currentUser!;
    return user.uid;
  }

  Future<void> saveToken() async {
    String? fcmToken = await FirebaseMessaging.instance.getToken();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey("firebaseUserId")) {
      firebaseUserId = prefs.getString("firebaseUserId");
      CollectionReference collection = FirebaseFirestore.instance.collection("AllDeviceToken");
      collection.doc(firebaseUserId).set({
        "id": firebaseUserId,
        "token": fcmToken,
        "createdAt": Timestamp.now(),
        "platform": Platform.operatingSystem,
        "version": Properties.versionNumber,
      });
    } else {
      debugPrint("No firebase Id = log in yet");
    }
  }

  @override
  Future<String?> getToken() async {
    String? fcmToken = await FirebaseMessaging.instance.getToken();
    return fcmToken;
  }
}

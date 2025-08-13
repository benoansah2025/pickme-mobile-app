import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../sharePreference.dart';

abstract class BaseProfile {
  Future<void> createAccount();
}

class FireProfile implements BaseProfile {
  final CollectionReference _collection = FirebaseFirestore.instance.collection("Users");

  static List<String>? users;

  @override
  Future<void> createAccount({
    @required String? firebaseUserId,
    @required String? email,
    @required String? userId,
    @required String? name,
  }) async {
    await _collection.doc(userId).set({
      "id": firebaseUserId,
      "email": email,
      "name": name,
      "userId": userId,
    });
    saveStringShare(key: "firebaseUserId", data: firebaseUserId);
  }
}

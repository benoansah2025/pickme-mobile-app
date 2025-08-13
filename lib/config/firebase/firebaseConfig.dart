import 'dart:io';
import 'package:dart_firebase_admin/dart_firebase_admin.dart';
import 'package:dart_firebase_admin/messaging.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class FirebaseConfig {
  late FirebaseAdminApp _admin;
  late Messaging _messaging;

  FirebaseConfig._privateConstructor();

  static final FirebaseConfig _instance = FirebaseConfig._privateConstructor();

  static FirebaseConfig get instance => _instance;

  Future<File> createTempServiceAccountFile(String jsonString) async {
    final directory = await getTemporaryDirectory();
    final path = '${directory.path}/temp_service_account.json';
    final file = File(path);
    return file.writeAsString(jsonString);
  }

  Future<void> initialize() async {
    // Load the service account key from the assets
    final jsonString = await rootBundle.loadString('assets/json/pickme.json');

    // Write the JSON string to a temporary file
    final file = await createTempServiceAccountFile(jsonString);

    // Initialize Firebase Admin SDK
    _admin = FirebaseAdminApp.initializeApp(
      'pickme-f0d3a',
      Credential.fromServiceAccount(file),
    );
    _messaging = Messaging(_admin);
  }

 Messaging getMessaging() => _messaging;
}

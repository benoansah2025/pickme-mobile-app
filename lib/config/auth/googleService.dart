// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';

// // generate debug SHA1 and SHA256
// // keytool -list -v -alias androiddebugkey -keystore %USERPROFILE%\.android\debug.keystore

// // dell home desktop
// // SHA1: 40:50:80:FB:58:AB:75:91:C3:AB:19:9A:3D:03:1E:0B:ED:53:E1:C1
// //  SHA256: 36:D8:32:16:4A:65:AB:F6:E7:FC:AA:07:C2:68:EB:8C:EC:2E:D6:95:C8:14:26:A0:ED:D2:AF:F4:9A:56:8A:16

// class GoogleService {
//   final GoogleSignIn _googleSignIn = GoogleSignIn();
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   Future<User?> googleSignIn() async {
//     googleSignOut();
//     final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
//     final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
//     AuthCredential? credential;
//     try {
//       credential = GoogleAuthProvider.credential(
//         accessToken: googleAuth?.accessToken,
//         idToken: googleAuth?.idToken,
//       );
//     } catch (e) {
//       return null;
//     }

//     final UserCredential authResult = await _auth.signInWithCredential(
//       credential,
//     );
//     User? user = authResult.user;
//     return user;
//   }

//   Future<void> googleSignOut() async {
//     await _googleSignIn.signOut();
//     await _auth.signOut();
//   }
// }

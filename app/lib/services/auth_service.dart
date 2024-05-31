import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  signInWithGoogle() async {
    if (kIsWeb) {
      final GoogleAuthProvider provider = GoogleAuthProvider()
          .setCustomParameters({'prompt': 'select_account'});
      await FirebaseAuth.instance.signInWithPopup(provider);
    } else {
      final GoogleSignInAccount? gUser = await GoogleSignIn(
        scopes: <String>[
          'email',
          'https://www.googleapis.com/auth/userinfo.profile',
        ],
      ).signIn();

      final GoogleSignInAuthentication? gAuth = await gUser?.authentication;

      final credential = GoogleAuthProvider.credential(
          accessToken: gAuth?.accessToken, idToken: gAuth?.idToken);

      return await FirebaseAuth.instance.signInWithCredential(credential);
    }
  }

  signOutWithGoogle() async {
    if (await GoogleSignIn().isSignedIn()) {
      GoogleSignIn().signOut();
    }
  }
}

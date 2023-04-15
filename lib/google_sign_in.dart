import "package:firebase_auth/firebase_auth.dart";
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInProvider extends ChangeNotifier {
  final googleSignIn = GoogleSignIn();

  GoogleSignInAccount? _user;

  GoogleSignInAccount get user => _user!;

  Future googleLogin() async {
    try {
      final googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        return;
      } else {
        _user = googleUser;

        final googleAuth = await googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        UserCredential result =
            await FirebaseAuth.instance.signInWithCredential(credential);

        User? user = result.user;

        notifyListeners();

        return user;
      }
    } catch (e) {
      print('...............................');
      print(e.toString());
      print('...............................');
    }
  }

  Future googleLogout() async {
    await googleSignIn.disconnect();
    FirebaseAuth.instance.signOut();
    notifyListeners();
  }
}

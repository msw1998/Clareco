// ignore_for_file: prefer_const_constructors

import 'package:clareco/dialer.dart';
import 'package:clareco/google_sign_in.dart';
import 'package:clareco/wrapper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  void initState() {
    super.initState();
    // Check if the user is already signed in
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      if (account != null) {
        // User is signed in, navigate to the home page
        Navigator.pushReplacementNamed(context, '/home');
      }
    });
    _googleSignIn.signInSilently();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(32.2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 50),
              ),
              SizedBox(
                width: 200,
                height: 200,
                child: Image.asset(
                  'assets/ClarecoLogo.png',
                  fit: BoxFit.contain,
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Hey, There,\nWelcome Back",
                  style: Theme.of(context).textTheme.headline1,
                ),
              ),
              SizedBox(height: 8.0),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Login to you account to continue",
                  style: Theme.of(context).textTheme.bodyText1,
                ),
              ),
              SizedBox(height: 50.0),
              ElevatedButton(
                onPressed: () async {
                  final provider =
                      Provider.of<GoogleSignInProvider>(context, listen: false);
                  try {
                    dynamic result = await provider.googleLogin();
                    print('////////////////////');
                    print(result);
                    print('///////////////////');
                    if (result == null) {
                    } else {
                      // ignore: use_build_context_synchronously
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) => DialPad()));
                      // setState(() {});
                    }
                  } on FirebaseAuthException catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.blue[800],
                        margin: EdgeInsets.all(20),
                        content: Text(e.message.toString()),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                ),
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Image.asset(
                        'assets/google_icon.png',
                        height: 24.0,
                        width: 24.0,
                      ),
                      SizedBox(width: 16.0),
                      Text(
                        'Sign in with Google',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

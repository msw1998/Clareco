// ignore_for_file: prefer_const_constructors

import 'package:clareco/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clareco/login.dart';
import 'package:clareco/dialer.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text("An Error Has Occured"),
            );
          } else if (snapshot.hasData) {
            print("Inside Snapshot data");
            return DialPad(); // Return an empty container while the page is transitioning

          } else {
            return SignInScreen();
          }
        },
      ),
    );
  }
}

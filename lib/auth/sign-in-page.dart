import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignInPage extends StatefulWidget {
  final GoogleSignIn _googleSignIn = new GoogleSignIn();

  @override
  _SignInPageState createState() => new _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {

  bool isLoading = false;

  Future<Null> _testSignInWithGoogle() async {
    print('Sign In Page starting Google Sign In..');
    GoogleSignInAccount googleUser;

    setState(() {
      isLoading = true;
    });
    try {
      googleUser = await widget._googleSignIn.signIn();
    } catch (e) {
      print('Google Sign In Error: ${e.toString()}');
    }
    if (googleUser != null) {
      print('Sign In Page googleUser=[${googleUser.toString()}]');
      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;
      print('Sign In Page googleAuth=[${googleAuth.toString()}]');
      final FirebaseUser user = await FirebaseAuth.instance.signInWithGoogle(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
//      setState(() {
//        isLoading = false;
//      });
//      print('Sign In Page firebaseUser=[${user.toString()}]');
    }
  }

  @override
  Widget build(BuildContext context) =>
      new MaterialApp(
        theme: new ThemeData(
          primarySwatch: Colors.deepOrange,
          accentColor: Colors.blueAccent,
          brightness: Brightness.dark,
        ),
        home: new Scaffold(
          appBar: new AppBar(
            title: const Text('Sign In'),
          ),
          body: Center(
            child: isLoading ? CircularProgressIndicator() : LoginWidget(onPressed: _testSignInWithGoogle),
          ),
        ),
      );
}

class LoginWidget extends StatelessWidget {
  final VoidCallback onPressed;

  const LoginWidget({this.onPressed});

  @override
  Widget build(BuildContext context) => RaisedButton(
        child: const Text('GOOGLE SIGN-IN'),
        onPressed: onPressed,
        textTheme: ButtonTheme
            .of(context)
            .textTheme,
      );

}
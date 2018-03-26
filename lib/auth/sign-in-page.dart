import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:wpm/data/app_state.dart';

class SignInPage extends StatefulWidget {
  final GoogleSignIn _googleSignIn = new GoogleSignIn();

  @override
  _SignInPageState createState() => new _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  bool signInLoading = false;

  Future<Null> _signInWithGoogle() async {
    print('Sign In Page starting Google Sign In..');
    GoogleSignInAccount googleUser;

    setState(() {
      signInLoading = true;
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
      await FirebaseAuth.instance.signInWithGoogle(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool userLoaded = AppStateProvider.of(context).userLoaded;
    Widget bodyChild;
    if (!userLoaded || signInLoading) {
      bodyChild = new CircularProgressIndicator();
    } else {
      bodyChild = new LoginWidget(onPressed: _signInWithGoogle,);
    }
    return new MaterialApp(
      theme: new ThemeData(
        primarySwatch: Colors.deepOrange,
        accentColor: Colors.blueAccent,
        brightness: Brightness.dark,
      ),
      home: new Scaffold(
        body: new Center(child: bodyChild,),
      ),
    );
  }
}

class LoginWidget extends StatelessWidget {
  final VoidCallback onPressed;

  const LoginWidget({this.onPressed});

  @override
  Widget build(BuildContext context) => new RaisedButton(
        child: const Text('GOOGLE SIGN-IN'),
        onPressed: onPressed,
        textTheme: ButtonTheme.of(context).textTheme,
      );
}

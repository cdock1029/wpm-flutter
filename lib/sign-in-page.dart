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
  Future<Null> _testSignInWithGoogle() async {
    final GoogleSignInAccount googleUser = await widget._googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final FirebaseUser user = await FirebaseAuth.instance.signInWithGoogle(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    /*
    assert(user.email != null);
    assert(user.displayName != null);
    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final FirebaseUser currentUser = await _auth.currentUser();
    assert(user.uid == currentUser.uid);

    return 'signInWithGoogle succeeded: $user';
    */
  }

  @override
  Widget build(BuildContext context) => new MaterialApp(
        theme: new ThemeData(
          primarySwatch: Colors.deepOrange,
          accentColor: Colors.blueAccent,
          // scaffoldBackgroundColor: Colors.grey[200],
        ),
        home: new Scaffold(
          appBar: new AppBar(
            title: const Text('Sign In'),
          ),
          body: new Builder(
            builder: (
              BuildContext context,
            ) =>
                new Center(
                  child: new Container(
                    //margin: const EdgeInsets.all(30.0),
                    //padding: const EdgeInsets.all(10.0),
                    child: new Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new RaisedButton(
                          child: const Text('Google Sign-in'),
                          onPressed: _testSignInWithGoogle,
                          // color: Theme.of(context).accentColor,
                          textTheme: ButtonTheme.of(context).textTheme,
                        ),
                      ],
                    ),
                  ),
                ),
          ),
        ),
      );
}

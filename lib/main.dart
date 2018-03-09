import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wpm/leases/lease_detail.dart';
import 'package:wpm/properties/add_edit_property.dart';
import 'package:wpm/content_shell.dart';
import 'package:wpm/leases/lease_create.dart';
import 'package:wpm/data/models.dart';
import 'package:wpm/app_state.dart';
import 'package:wpm/auth/sign-in-page.dart';
import 'package:wpm/tenants/tenant_add.dart';
import 'package:wpm/tenants/tenant_list.dart';

void main() => runApp(WPMApp());

class WPMApp extends StatefulWidget {
  @override
  WPMAppState createState() => WPMAppState();
}

class WPMAppState extends State<WPMApp> {
  final Stream<List<Property>> _propertiesStream = Firestore.instance
      .collection('properties')
      .snapshots
      .map<List<DocumentSnapshot>>(
          (QuerySnapshot querySnap) => querySnap.documents)
      .map<List<Property>>((List<DocumentSnapshot> docs) => docs
          .map<Property>((DocumentSnapshot doc) => Property.fromSnapshot(doc))
          .toList());

  Company _company;
  Property _selected;
  AppUser _appUser;
  FirebaseUser _user;
  StreamSubscription<FirebaseUser> _authSubscription;

  @override
  void initState() {
    super.initState();

    _authSubscription =
        FirebaseAuth.instance.onAuthStateChanged.listen((FirebaseUser user) {

      print('onAuthStateChanged user=[${user.toString()}]');
      setState(() {
        _user = user;
      });
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  void _selectProperty(Property property) {
    setState(() {
      _selected = property;
    });
  }

  @override
  Widget build(BuildContext context) => StreamBuilder<List<Property>>(
        stream: _propertiesStream,
        initialData: <Property>[],
        builder: (
          BuildContext context,
          AsyncSnapshot<List<Property>> snapshot,
        ) =>
            AppState(
              user: _user,
              properties: snapshot.data,
              selected: _selected,
              selectProperty: _selectProperty,
              child:
                  _user != null ? WPMAppView() : SignInPage(),
            ),
      );
}

class WPMAppView extends StatelessWidget {
  const WPMAppView();

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'WPM',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          accentColor: Colors.tealAccent,
          // scaffoldBackgroundColor: Colors.grey[200],
          brightness: Brightness.dark,
        ),
        home: ContentShell(),
        // home: LeaseDetail(),
        routes: <String, WidgetBuilder>{
          AddEditProperty.routeName: (_) => AddEditProperty(),
          AddTenant.routeName: (_) => AddTenant(),
          TenantList.routeName: (_) => TenantList(),
          CreateLease.routeName: (_) => CreateLease(),
          LeaseDetail.routeName: (_) => LeaseDetail(),
        }
      );
}

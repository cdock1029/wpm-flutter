import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wpm/leases/lease_detail.dart';
import 'package:wpm/properties/add_edit_property.dart';
import 'package:wpm/dashboard.dart';
import 'package:wpm/leases/lease_create.dart';
import 'package:wpm/models.dart';
import 'package:wpm/app_state.dart';
import 'package:wpm/sign-in-page.dart';
import 'package:wpm/tenants/tenant_add.dart';
import 'package:wpm/tenants/tenant_list.dart';

void main() => runApp(new WPMApp());

class WPMApp extends StatefulWidget {
  @override
  WPMAppState createState() => new WPMAppState();
}

class WPMAppState extends State<WPMApp> {
  final Stream<List<Property>> _propertiesStream = Firestore.instance
      .collection('properties')
      .snapshots
      .map<List<DocumentSnapshot>>(
          (QuerySnapshot querySnap) => querySnap.documents)
      .map<List<Property>>((List<DocumentSnapshot> docs) => docs
          .map<Property>(
              (DocumentSnapshot doc) => new Property.fromSnapshot(doc))
          .toList());

  Property _selected;
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

  void _selectProperty(Property property) {
    setState(() {
      _selected = property;
    });
  }

  @override
  Widget build(BuildContext context) => new StreamBuilder<List<Property>>(
        stream: _propertiesStream,
        initialData: <Property>[],
        builder: (
          BuildContext context,
          AsyncSnapshot<List<Property>> snapshot,
        ) =>
            new AppState(
              user: _user,
              properties: snapshot.data,
              selected: _selected,
              selectProperty: _selectProperty,
              child: _user != null ? WPMAppView() : WPMAppView(),// new SignInPage(),
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
        // home: const Dashboard(),
        home: LeaseDetail(),
        routes: <String, WidgetBuilder>{
          AddEditProperty.routeName: (_) => AddEditProperty(),
          AddTenant.routeName: (_) => AddTenant(),
          TenantList.routeName: (_) => TenantList(),
          CreateLease.routeName: (_) => CreateLease(),
          LeaseDetail.routeName: (_) => LeaseDetail(),
        },
      );
}

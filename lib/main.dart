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
  WPMAppState createState() => new WPMAppState();
}

class WPMAppState extends State<WPMApp> {
  @override
  Widget build(BuildContext context) => AppStateProvider(
        userStream: FirebaseAuth.instance.onAuthStateChanged,
        child: WPMAppView(),
      );
}

class WPMAppView extends StatelessWidget {
  const WPMAppView();

  @override
  Widget build(BuildContext context) {
    final AppUser user = AppStateProvider.of(context).user;
    print('WPMAppView user=[${user?.email}]');
    return user != null
        ? MaterialApp(
            title: user.company.name ?? '',
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
              })
        : FutureBuilder<bool>(
            // prevent flash when user initialized to 'null' even though signed in.
            // not sure about 800 but somehow this works pretty good..
            future: Future.delayed(Duration(milliseconds: 800), () => true),
            builder: (
              BuildContext context,
              AsyncSnapshot<bool> snapshot,
            ) => snapshot.hasData ? SignInPage() : Center(child: CircularProgressIndicator()),
          );
  }
}

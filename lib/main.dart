import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wpm/modules/company/company_dashboard.dart';
import 'package:wpm/modules/leases/lease_detail.dart';
import 'package:wpm/modules/properties/add_edit_property.dart';
import 'package:wpm/modules/properties/property_dashboard.dart';
import 'package:wpm/modules/leases/lease_create.dart';
import 'package:wpm/data/models.dart';
import 'package:wpm/data/app_state.dart';
import 'package:wpm/auth/sign-in-page.dart';
import 'package:wpm/modules/tenants/tenant_add.dart';
import 'package:wpm/modules/tenants/tenant_list.dart';

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
    print('building WPMAppView');
    final AppUser user = AppStateProvider.of(context).user;
    return user != null
        ? MaterialApp(
            title: user.company.name ?? '',
            theme: ThemeData(
              primarySwatch: Colors.deepPurple,
              accentColor: Colors.tealAccent,
              brightness: Brightness.dark,
            ),
            home: CompanyDashboard(),
            // home: LeaseDetail(),
            routes: <String, WidgetBuilder>{
                CompanyDashboard.routeName: (_) => CompanyDashboard(),
                PropertyDashboard.routeName: (_) => PropertyDashboard(),
                AddEditProperty.routeName: (_) => AddEditProperty(),
                AddTenant.routeName: (_) => AddTenant(),
                TenantList.routeName: (_) => TenantList(),
                CreateLease.routeName: (_) => CreateLease(),
                LeaseDetail.routeName: (_) => LeaseDetail(),
              })
        : FutureBuilder<bool>(
            // prevent flash when user initialized to 'null' even though signed in.
            // not sure about 800 but somehow this works pretty good..
            // ignore: always_specify_types
            future: Future.delayed(Duration(milliseconds: 800), () => true),
            builder: (
              BuildContext context,
              AsyncSnapshot<bool> snapshot,
            ) => snapshot.hasData ? SignInPage() : Center(child: CircularProgressIndicator()),
          );
  }
}

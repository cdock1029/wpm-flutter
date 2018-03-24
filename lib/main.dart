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
  Widget build(BuildContext context) => new AppStateProvider(
        userStream: FirebaseAuth.instance.onAuthStateChanged,
        child: new WPMAppView(),
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
            home: new CompanyDashboard(),
            // home: LeaseDetail(),
            routes: <String, WidgetBuilder>{
                CompanyDashboard.routeName: (_) => new CompanyDashboard(),
                PropertyDashboard.routeName: (_) => new PropertyDashboard(),
                AddEditProperty.routeName: (_) => new AddEditProperty(),
                AddTenant.routeName: (_) => new AddTenant(),
                TenantList.routeName: (_) => new TenantList(),
                CreateLease.routeName: (_) => new CreateLease(),
                LeaseDetail.routeName: (_) => new LeaseDetail(),
              })
        : new FutureBuilder<bool>(
            // prevent flash when user initialized to 'null' even though signed in.
            // not sure about 800 but somehow this works pretty good..
            // ignore: always_specify_types
            future: Future.delayed(new Duration(milliseconds: 800), () => true),
            builder: (
              BuildContext context,
              AsyncSnapshot<bool> snapshot,
            ) => snapshot.hasData ? new SignInPage() : new Center(child: new CircularProgressIndicator()),
          );
  }
}


import 'package:flutter/material.dart';
import 'package:wpm/modules/company/company_dashboard.dart';
import 'package:wpm/modules/properties/add_edit_property.dart';
import 'package:wpm/modules/properties/property_dashboard.dart';
import 'package:wpm/modules/leases/lease_create.dart';
import 'package:wpm/data/models.dart';
import 'package:wpm/data/app_state.dart';
import 'package:wpm/auth/sign-in-page.dart';
import 'package:wpm/modules/tenants/tenant_add.dart';
import 'package:wpm/modules/tenants/tenant_list.dart';

void main() => runApp(WPMApp());

class WPMApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => new AppStateProvider(child: new WPMAppView());
}

class WPMAppView extends StatelessWidget {
  const WPMAppView();

  @override
  Widget build(BuildContext context) {
    print('building WPMAppView');
    final AppState state = AppStateProvider.of(context);
    final AppUser user = state.user;
    return user != null
        ? MaterialApp(
            title: user?.company?.name ?? '',
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
                // LeaseDetail.routeName: (_) => new LeaseDetail(),
              })
        : new SignInPage();
  }
}

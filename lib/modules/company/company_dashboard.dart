import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wpm/common/wpm_drawer.dart';
import 'package:wpm/data/app_state.dart';
import 'package:wpm/data/models.dart';
import 'package:wpm/modules/properties/property_dashboard.dart';

class CompanyDashboard extends StatelessWidget {
  const CompanyDashboard();

  static const String routeName = 'company_dashboard';

  @override
  Widget build(BuildContext context) {
    final Stream<Property> selectedStream =
        AppStateProvider.of(context).selectedPropertyStream;

    return selectedStream != null
        ? new PropertyDashboard()
        : new Scaffold(
            key: new Key('company_dashboard'),
            appBar: new AppBar(
              title: new Text(AppStateProvider.of(context).user.company.name),
            ),
            drawer: new WPMDrawerLoader(),
            body: new Center(
              child: new Card(
                child: new Padding(
                  padding: new EdgeInsets.all(32.0),
                  child: new Text(
                    'Select Property',
                    style: Theme.of(context).textTheme.headline,
                  ),
                ),
              ),
            ),
          );
  }
}

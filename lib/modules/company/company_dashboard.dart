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
        ? PropertyDashboard()
        : Scaffold(
            key: Key('company_dashboard'),
            appBar: AppBar(
              title: Text(AppStateProvider.of(context).user.company.name),
            ),
            drawer: WPMDrawerLoader(),
            body: Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text(
                    'Select Property',
                    style: Theme.of(context).textTheme.headline,
                  ),
                ),
              ),
            ),
          );
  }
}

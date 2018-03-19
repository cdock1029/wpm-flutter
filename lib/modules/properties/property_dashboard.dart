import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wpm/data/models.dart';
import 'package:wpm/data/app_state.dart';
import 'package:wpm/modules/company/company_dashboard.dart';
import 'package:wpm/modules/properties/add_edit_property.dart';
import 'package:wpm/common/wpm_drawer.dart';
import 'package:wpm/modules/units/units_tab.dart';

class PropertyDashboard extends StatelessWidget {
  const PropertyDashboard();

  static const String routeName = 'property_dashboard';

  @override
  Widget build(BuildContext context) {
    final Stream<Property> selectedStream =
        AppStateProvider.of(context).selectedPropertyStream;
    return StreamBuilder<Property>(
            stream: selectedStream,
            builder: (
              BuildContext context,
              AsyncSnapshot<Property> streamSnap,
            ) {
              if (streamSnap.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }
              final Property selected = streamSnap.data;
              final List<Widget> children = <Widget>[
                UnitsTab(property: selected),
                TenantsTab(selected),
              ];
              return DefaultTabController(
                length: 2,
                child: Scaffold(
                  key: Key('property_detail'),
                  appBar: AppBar(
                    title: Text(selected.name),
                    actions: <Widget>[
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute<Null>(
                                builder: (BuildContext context) =>
                                    AddEditProperty(property: selected),
                              ));
                        },
                      ),
                    ],
                    bottom: TabBar(
                      isScrollable: false,
                      tabs: <Widget>[Tab(text: 'UNITS'), Tab(text: 'TENANTS')],
                    ),
                  ),
                  body: TabBarView(children: children),
                  drawer: WPMDrawerLoader(),
                ),
              );
            },
          );
  }
}

class TenantsTab extends StatelessWidget {
  const TenantsTab(this.property);

  final Property property;

  @override
  Widget build(BuildContext context) => Center(child: Text('tenants todo'));
}

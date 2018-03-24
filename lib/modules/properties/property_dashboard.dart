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
    return new StreamBuilder<Property>(
            stream: selectedStream,
            builder: (
              BuildContext context,
              AsyncSnapshot<Property> streamSnap,
            ) {
              if (streamSnap.connectionState == ConnectionState.waiting) {
                return new CircularProgressIndicator();
              }
              final Property selected = streamSnap.data;
              final List<Widget> children = <Widget>[
                new UnitsTab(property: selected),
                new TenantsTab(selected),
              ];
              return new DefaultTabController(
                length: 2,
                child: new Scaffold(
                  key: new Key('property_detail'),
                  appBar: new AppBar(
                    title: new Text(selected.name),
                    actions: <Widget>[
                      new IconButton(
                        icon: new Icon(Icons.edit),
                        onPressed: () {
                          Navigator.push(
                              context,
                              new MaterialPageRoute<Null>(
                                builder: (BuildContext context) =>
                                    new AddEditProperty(property: selected),
                              ));
                        },
                      ),
                    ],
                    bottom: new TabBar(
                      isScrollable: false,
                      tabs: <Widget>[new Tab(text: 'UNITS'), new Tab(text: 'TENANTS')],
                    ),
                  ),
                  body: new TabBarView(children: children),
                  drawer: new WPMDrawerLoader(),
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
  Widget build(BuildContext context) => new Center(child: new Text('tenants todo'));
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wpm/leases/lease_create.dart';
import 'package:wpm/data/models.dart';
import 'package:wpm/app_state.dart';
import 'package:wpm/properties/add_edit_property.dart';
import 'package:wpm/common/wpm_drawer.dart';
import 'package:wpm/units/unit.dart';

class ContentShell extends StatelessWidget {
  const ContentShell();

  @override
  Widget build(BuildContext context) {
    final Stream<Property> selectedStream =
        AppStateProvider.of(context).selectedPropertyStream;

    return selectedStream == null
        ? SelectPropertyMessage()
        : StreamBuilder<Property>(
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
                UnitsTab(selected),
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
                      tabs: <Widget>[
                        Tab(
                          text: 'UNITS',
                        ),
                        Tab(text: 'TENANTS'),
                      ],
                    ),
                  ),
                  body: TabBarView(
                    children: children,
                  ),
                  drawer: WPMDrawerLoader(),
                  floatingActionButton: FloatingActionButton(
                    child: Center(
                      child: Icon(Icons.add),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, CreateLease.routeName);
                    },
                  ),
                ),
              );
            },
          );
  }
}

class UnitsTab extends StatelessWidget {
  const UnitsTab(this.property);

  final Property property;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Unit count: ${property.unitCount}',
                style: Theme.of(context).textTheme.subhead),
          ),
          Expanded(
            child: UnitListView(
              property: property,
            ),
          ),
        ],
      );
}

class TenantsTab extends StatelessWidget {
  const TenantsTab(this.property);
  final Property property;

  @override
  Widget build(BuildContext context) => Center(child: Text('tenants todo'),);
}


class SelectPropertyMessage extends StatelessWidget {
  const SelectPropertyMessage();

  @override
  Widget build(BuildContext context) => Scaffold(
        key: Key('property_detail'),
        appBar: AppBar(
          title: Text(AppStateProvider.of(context).user.company.name),
        ),
        drawer: WPMDrawerLoader(),
        body: Center(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text(
                'Select Property',
                style: Theme.of(context).textTheme.headline,
              ),
            ),
          ),
        ),
      );
}

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:wpm/leases/lease_create.dart';
import 'package:wpm/data/models.dart';
import 'package:wpm/app_state.dart';
import 'package:wpm/properties/add_edit_property.dart';
import 'package:wpm/common/wpm_drawer.dart';
import 'package:wpm/units/unit.dart';

class ContentShell extends StatelessWidget {
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

class UnitsTab extends StatelessWidget {
  const UnitsTab({@required this.property});

  final Property property;

  @override
  Widget build(BuildContext context) => StreamBuilder<List<Unit>>(
      stream: property.units,
      initialData: <Unit>[],
      builder: (
        BuildContext context,
        AsyncSnapshot<List<Unit>> snap,
      ) {
        final List<Unit> units = snap.data;
        
        // _view = UnitListView(units: units);
        return Column(
          children: <Widget>[
            ListTile(
              dense: true,
              trailing: PopupMenuButton<String>(
                onSelected: (String key) async {
                  switch (key) {
                    case 'add':
                      final Unit newUnit = await showDialog<Unit>(
                        context: context,
                        child: AddUnitDialog(),
                      );
                      if (newUnit != null) {
                        await property.snapshot
                            .reference
                            .getCollection('units')
                            .add(newUnit.data);
                      }
                      break;
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
                  PopupMenuItem<String>(child: Text('ADD UNIT'), value: 'add',),
                ],
              ),
            ),
            Flexible(child: UnitGridView(units: units)),
          ],
        );
      });
}

class TenantsTab extends StatelessWidget {
  const TenantsTab(this.property);

  final Property property;

  @override
  Widget build(BuildContext context) => Center(
        child: Text('tenants todo'),
      );
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

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_stream_friends/flutter_stream_friends.dart';
import 'package:meta/meta.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:wpm/data/models.dart';
import 'package:wpm/modules/units/add_unit.dart';
import 'package:wpm/modules/units/unit_list.dart';

class UnitsTab extends StatefulWidget {
  const UnitsTab({@required this.property});

  final Property property;

  @override
  UnitsTabState createState() => new UnitsTabState();
}

class UnitsTabState extends State<UnitsTab> {
  @override
  Widget build(BuildContext context) => new StreamBuilder<List<Unit>>(
      stream: widget.property.units,
      initialData: <Unit>[],
      builder: (
        BuildContext context,
        AsyncSnapshot<List<Unit>> snap,
      ) {
        final List<Unit> units = snap.data;
        // TODO meh?
        final CollectionReference unitsRef =
            widget.property.ref.getCollection('units');
        final ValueStreamCallback<String> _filterCallback =
            ValueStreamCallback<String>();
        final Stream<String> _searchStream = _filterCallback
            .distinct()
            .transform<String>(debounce(new Duration(milliseconds: 260)));

        /* final Stream<List<Unit>> filteredStream = _searchStream.map((String search) {
        }); */
        return Column(
          children: <Widget>[
            new UnitsTabControlSection(
              unitsRef: unitsRef,
              filterCallback: _filterCallback,
            ),

            new StreamBuilder<String>(
              stream: _searchStream,
              builder: (
                BuildContext context,
                AsyncSnapshot<String> snapshot,
              ) {
                List<Unit> _filteredUnits;
                if (snapshot.hasData && snapshot.data.isNotEmpty) {
                  final String search = snapshot.data.toLowerCase();
                  print('filter search=[$search]');
                  _filteredUnits = units
                      .where((Unit u) {
                        final List<Tenant> tenants = u.currentLease?.loadedTenants ?? <Tenant>[];
                        return u.address.toLowerCase().contains(search) || tenants.where((Tenant t) => t.firstName.toLowerCase().contains(search) || t.lastName.toLowerCase().contains(search)).toList().isNotEmpty;
                      })
                      .toList();
                } else {
                  print('no filter data OR data is empty');
                }
                return new Flexible(
                  // child: new UnitGridView(units: _filteredUnits ?? units),
                  child: new UnitList(units: _filteredUnits ?? units,),
                );
              },
            ),
          ],
        );
      });
}

class UnitsTabControlSection extends StatefulWidget {
  final CollectionReference unitsRef;
  final ValueStreamCallback<String> filterCallback;

  const UnitsTabControlSection({this.unitsRef, this.filterCallback});

  @override
  UnitsTabControlSectionState createState() =>
      new UnitsTabControlSectionState();
}

class UnitsTabControlSectionState extends State<UnitsTabControlSection> {
  @override
  Widget build(BuildContext context) => new Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            new Expanded(
              child: new TextField(
                onChanged: widget.filterCallback,
                decoration: new InputDecoration(
                  icon: new Icon(
                    Icons.search,
                    // color: Theme.of(context).textTheme.subhead.color,
                  ),
                ),
                autocorrect: false,
              ),
            ),
            new PopupMenuButton<String>(
              onSelected: (String key) async {
                switch (key) {
                  case 'add':
                    final Unit unit = await showDialog<Unit>(
                      context: context,
                      builder: (BuildContext context) => new AddUnitDialog(),
                    );
                    if (unit != null) {
                      await widget.unitsRef.add(unit.data);
                      Scaffold.of(context).showSnackBar(
                            new SnackBar(
                              content: new Text('Unit saved'),
                            ),
                          );
                    }
                    break;
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
                    new PopupMenuItem<String>(
                      child: new Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          new Icon(Icons.add),
                          new Container(
                            margin: new EdgeInsets.only(left: 8.0),
                            child: new Text('ADD UNIT'),
                          ),
                        ],
                      ),
                      value: 'add',
                    ),
                  ],
            ),
          ],
        ),
      );
}

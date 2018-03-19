import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_stream_friends/flutter_stream_friends.dart';
import 'package:meta/meta.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:wpm/data/models.dart';
import 'package:wpm/modules/units/add_unit.dart';
import 'package:wpm/modules/units/unit_grid.dart';


class UnitsTab extends StatefulWidget {
  const UnitsTab({@required this.property});

  final Property property;

  @override
  UnitsTabState createState() => new UnitsTabState();
}

class UnitsTabState extends State<UnitsTab> {
  @override
  Widget build(BuildContext context) => StreamBuilder<List<Unit>>(
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
            .transform<String>(debounce(Duration(milliseconds: 260)));
        return Column(
          children: <Widget>[
            UnitsTabControlSection(
              unitsRef: unitsRef,
              filterCallback: _filterCallback,
            ),
            StreamBuilder<String>(
              stream: _searchStream,
              builder: (
                  BuildContext context,
                  AsyncSnapshot<String> snapshot,
                  ) {
                List<Unit> _filteredUnits;
                if (snapshot.hasData && snapshot.data.isNotEmpty) {
                  print('filter data=[${snapshot.data}]');
                  _filteredUnits = units
                      .where((Unit u) => u.address.contains(snapshot.data))
                      .toList();
                } else {
                  print('no filter data OR data is empty');
                }
                return Flexible(
                  child: UnitGridView(units: _filteredUnits ?? units),
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
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Expanded(
          child: TextField(
            onChanged: widget.filterCallback,
            decoration: InputDecoration(
              icon: Icon(
                Icons.search,
                // color: Theme.of(context).textTheme.subhead.color,
              ),
            ),
            autocorrect: false,
          ),
        ),
        PopupMenuButton<String>(
          onSelected: (String key) async {
            switch (key) {
              case 'add':
                final Unit unit = await showDialog<Unit>(
                  context: context,
                  child: AddUnitDialog(),
                );
                if (unit != null) {
                  await widget.unitsRef.add(unit.data);
                  Scaffold.of(context).showSnackBar(SnackBar(
                    content: Text('Unit saved'),
                  ));
                }
                break;
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
            PopupMenuItem<String>(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Icon(Icons.add),
                  Container(
                    margin: EdgeInsets.only(left: 8.0),
                    child: Text('ADD UNIT'),
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
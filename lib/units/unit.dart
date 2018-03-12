import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wpm/common/utilities.dart';
import 'package:wpm/data/models.dart';

class UnitListView extends StatelessWidget {
  const UnitListView({this.units});
  final List<Unit> units;

  @override
  Widget build(BuildContext context) => ListView.builder(
        itemCount: units.length,
        itemBuilder: (BuildContext ctx, int index) {
          final Unit unit = units[index];
          return Card(
            child: ListTile(
              key: new Key(unit.id),
              title: new Text(unit.address),
            ),
          );
        },
      );
}

class AddUnitDialog extends StatefulWidget {
  @override
  _AddUnitDialogState createState() => new _AddUnitDialogState();
}

class _AddUnitDialogState extends State<AddUnitDialog> {
  TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
  }

  @override
  void dispose() {
    _textController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SystemPadding(
        child: AlertDialog(
          title: Text('Add unit'),
          content: TextField(
            autofocus: false,
            controller: _textController,
            autocorrect: false,
            onSubmitted: (String value) {
              Navigator.pop(context, Unit(address: value));
            },
            decoration: InputDecoration(
              hintText: 'Unit address',
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('CANCEL'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            FlatButton(
              child: Text('SAVE'),
              onPressed: () {
                Unit unit;
                if (_textController.text.isNotEmpty) {
                  unit = Unit(address: _textController.text);
                }
                Navigator.pop(context, unit);
              },
            ),
          ],
        ),
      );
}

class UnitGridView extends StatelessWidget {
  const UnitGridView({this.units});
  final List<Unit> units;

  @override
  Widget build(BuildContext context) => GridView.count(
        crossAxisCount: 2,
        childAspectRatio: 2.0,
        children: units
            .map((Unit u) => Card(
                  child: FlatButton(
                    onPressed: () {
                      print('unit pressed');
                    },
                    child: Text(u.address,
                        style: Theme.of(context).textTheme.headline),
                  ),
                ))
            .toList(),
      );
}

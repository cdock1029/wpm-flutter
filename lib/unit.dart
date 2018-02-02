import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wpm/models.dart';

class UnitListView extends StatelessWidget {
  final List<Unit> units;

  const UnitListView({this.units, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) => new ListView(
        children: units
            .map((Unit u) => new ListTile(
                  key: new Key(u.id),
                  title: new Text(u.address),
                ))
            .toList(),
      );
}

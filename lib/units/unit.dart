import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wpm/data/models.dart';

class UnitListView extends StatelessWidget {
  final Stream<List<Unit>> units;
  final Property property;

  UnitListView({this.property, Key key})
      : units = property?.units,
        super(key: key);

  @override
  Widget build(BuildContext context) => new StreamBuilder<List<Unit>>(
        stream: units,
        builder: (
          BuildContext context,
          AsyncSnapshot<List<Unit>> snap,
        ) =>
            new ListView.builder(
              itemCount: snap.data?.length ?? 0,
              itemBuilder: (BuildContext ctx, int index) {
                final Unit unit = snap.data[index];
                return new ListTile(
                  key: new Key(unit.id),
                  title: new Text(unit.address),
                );
              },
            ),
      );
}

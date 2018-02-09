import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wpm/models.dart';

class UnitListView extends StatelessWidget {
  final Stream<QuerySnapshot> stream;
  final Property property;

  const UnitListView({this.property, this.stream, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) => new StreamBuilder<QuerySnapshot>(
        stream: stream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snap) =>
            new ListView.builder(
              itemCount: snap.data?.documents?.length ?? 0,
              itemBuilder: (BuildContext ctx, int index) {
                final DocumentSnapshot doc = snap.data.documents[index];
                final Unit unit = new Unit.fromSnapshot(doc);
                return new ListTile(
                  key: new Key(unit.id),
                  title: new Text(unit.address),
                );
              },
            ),
      );
}

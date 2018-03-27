import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wpm/data/models.dart';

class UnitGridView extends StatelessWidget {
  const UnitGridView({this.units});

  final List<Unit> units;

  @override
  Widget build(BuildContext context) => new GridView.count(
        crossAxisCount: 2,
        childAspectRatio: 3.0,
        children: units
            .map((Unit u) => new Card(
                  key: new Key(u.id),
                  child: new FlatButton(
                    onPressed: () {
                      print('unit pressed');
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new Text(
                          u.address,
                          style: Theme.of(context).textTheme.title,
                        ),
                        new UnitLease(u),
                      ],
                    ),
                  ),
                ))
            .toList(),
      );
}

class UnitLease extends StatelessWidget {
  final Unit unit;
  const UnitLease(this.unit);
  @override
  Widget build(BuildContext context) => new FutureBuilder<List<Tenant>>(
        future: unit.load()?.then((_) => unit.currentLease.tenants),
        // initialData: <Tenant>[],
        builder: (
          BuildContext context,
          AsyncSnapshot<List<Tenant>> snapshot,
        ) {
          if (!snapshot.hasData) {
            return new Container(width: 0.0, height: 0.0,);
          }
          final List<Widget> children = <Widget>[new Text('Tenants:')];
          final List<Tenant> tenants = snapshot.data;
          children.addAll(tenants.map<Widget>((Tenant t) => new Text('${t.lastName}')));
          return new Row(children: children,);
        },
      );
}

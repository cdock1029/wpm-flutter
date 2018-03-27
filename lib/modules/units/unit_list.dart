import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wpm/data/models.dart';

class UnitList extends StatelessWidget {
  const UnitList({this.units});

  final List<Unit> units;

  @override
  Widget build(BuildContext context) => new ListView.builder(
      itemCount: units.length,
      itemBuilder: (
        BuildContext context,
        int index,
      ) {
        final Unit u = units[index];
        return new Card(
          key: new Key(u.id),
          child: new ListTile(
            key: new Key('tile ${u.id}'),
            onTap: () {
              print('unit ${u.address}');
            },
            title: new Text(
              u.address,
              style: Theme.of(context).textTheme.title,
            ),
            trailing: new UnitLease(unit: u, key: new Key(u.id)),
          ),
        );
      });
}

class UnitLease extends StatelessWidget {
  final Unit unit;

  const UnitLease({this.unit, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) => new FutureBuilder<List<Tenant>>(
        future: unit.load()?.then((_) => unit.currentLease.tenants),
        // initialData: <Tenant>[],
        builder: (
          BuildContext context,
          AsyncSnapshot<List<Tenant>> snapshot,
        ) {
          if (!snapshot.hasData) {
            return new Container(
              width: 0.0,
              height: 0.0,
            );
          }
          final List<Tenant> tenants = snapshot.data;
          return new Column(
            children: tenants
                .map<Widget>((Tenant t) => new Text('${t.lastName}'))
                .toList(),
          );
        },
      );
}

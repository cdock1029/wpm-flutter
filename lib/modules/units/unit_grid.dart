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
                  child: new FlatButton(
                    onPressed: () {
                      print('unit pressed');
                    },
                    child: new Text(u.address,
                        style: Theme.of(context).textTheme.title),
                  ),
                ))
            .toList(),
      );
}

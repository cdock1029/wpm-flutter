import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:wpm/models.dart';
import 'package:wpm/unit.dart';


class PropertyDetail extends StatefulWidget {
  const PropertyDetail({@required this.property, @required this.isTablet, @required Key key}) : super(key: key);

  final Property property;
  final bool isTablet;

  @override
  _PropertyDetailState createState() => new _PropertyDetailState();
}

class _PropertyDetailState extends State<PropertyDetail> {
  List<Unit> _units = <Unit>[];
  StreamSubscription<QuerySnapshot> subscription;

  void _updateList(QuerySnapshot snapshot) {
    if (snapshot.documents.isEmpty) {
      setState(() {
        _units = <Unit>[];
      });
    }
    final List<Unit> newUnits = snapshot.documents
        .map((DocumentSnapshot snap) => new Unit.fromSnapshot(snap))
        .toList();
    setState(() {
      _units = <Unit>[]..addAll(newUnits);
    });
  }

  @override
  void initState() {
    // TODO meh
    super.initState();
    print('initState for unit list');
    if (widget.property?.unitsRef != null) {
      subscription = widget.property.unitsRef.snapshots.listen(_updateList);
    }
  }

  @override
  void dispose() {
    super.dispose();
    print('disposing unit list subscription..');
    subscription?.cancel();
  }

  Widget _unitsList() {
    if (widget.property != null && _units.isNotEmpty) {
      print('_units list NOT EMPTY');
      return new UnitListView(units: _units);
    }
    print('_units list is *EMPTY*');
    return new Container();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Widget content = new Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        new Text(
          widget.property?.name ?? 'Select a Property',
          style: textTheme.headline,
        ),
        new Text(
          widget.property?.name != null
              ? 'Unit count: ${_units.length}'
              : '',
          style: textTheme.subhead,
        ),
        new Expanded(
          child: _unitsList(),
        ),
      ],
    );
    return new Scaffold(
      key: const Key('property_detail'),
      appBar: widget.property != null
          ? new AppBar(
        title: new Text(widget.property.name),
      )
          : null,
      body: new Center(
        child: content,
      ),
    );
  }
}
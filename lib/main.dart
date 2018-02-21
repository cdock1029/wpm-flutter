import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wpm/add_property.dart';
import 'package:wpm/dashboard.dart';
import 'package:wpm/lease_create.dart';
import 'package:wpm/models.dart';
import 'package:wpm/property_state.dart';
import 'package:wpm/tenant_add.dart';
import 'package:wpm/tenant_list.dart';

void main() => runApp(new WPMApp());

class WPMApp extends StatefulWidget {
  @override
  WPMAppState createState() => new WPMAppState();
}

class WPMAppState extends State<WPMApp> {
  final Stream<List<Property>> _propertiesStream = Firestore.instance
      .collection('properties')
      .snapshots
      .map<List<DocumentSnapshot>>(
          (QuerySnapshot querySnap) => querySnap.documents)
      .map<List<Property>>((List<DocumentSnapshot> docs) => docs
      .map<Property>(
          (DocumentSnapshot doc) => new Property.fromSnapshot(doc))
      .toList());

  Property _selected;

  void _selectProperty(Property property) {
    setState(() {
      _selected = property;
    });
  }

  @override
  Widget build(BuildContext context) => new StreamBuilder<List<Property>>(
      stream: _propertiesStream,
      initialData: <Property>[],
      builder: (
        BuildContext context,
        AsyncSnapshot<List<Property>> snapshot,
      ) =>
          new AppState(
            snapshot.data,
            _selected,
            _selectProperty,
            new MaterialApp(
              title: 'WPM',
              theme: new ThemeData(
                primarySwatch: Colors.deepPurple,
                accentColor: Colors.deepOrangeAccent,
                scaffoldBackgroundColor: Colors.grey[200],
              ),
              home: const Dashboard(),
              routes: <String, WidgetBuilder>{
                AddProperty.routeName: (_) => const AddProperty(),
                AddTenant.routeName: (_) => const AddTenant(),
                TenantList.routeName: (_) => const TenantList(),
                CreateLease.routeName: (_) => const CreateLease(),
              },
            ),
          ),
    );
}

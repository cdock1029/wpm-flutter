import 'dart:math';

import 'package:flutter/material.dart';
import 'package:wpm/models.dart';
import 'package:wpm/property_detail.dart';
import 'package:wpm/property_list.dart';
import 'package:wpm/wpm_drawer.dart';

void main() => runApp(new WPMApp());

class WPMApp extends StatefulWidget {
  @override
  _WPMAppState createState() => new _WPMAppState();
}

class _WPMAppState extends State<WPMApp> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) => new MaterialApp(
        title: 'Flutter Demo',
        theme: new ThemeData(
          primarySwatch: Colors.deepPurple,
          accentColor: Colors.tealAccent,
        ),
        home: new MasterDetailContainer(),
      );
}

class MasterDetailContainer extends StatefulWidget {
  @override
  _MasterDetailContainerState createState() =>
      new _MasterDetailContainerState();
}

class _MasterDetailContainerState extends State<MasterDetailContainer> {
  Property _selectedProperty;

  static const int kTabletBreakPoint = 650;

  final List<Widget> _drawerWidgets = <Widget>[
    const DrawerHeader(child: const Text('This is the Header')),
    const AboutListTile(
      applicationName: 'WPM Flutter',
      applicationIcon: const Icon(Icons.home),
      applicationVersion: '0.0.1',
    ),
  ];

  void unSelectProperty() {
    print('running in unSelectProperty..');
    setState(() {
      _selectedProperty = null;
    });
  }

  Widget _buildPhoneLayout() {
    print('building Phone layout..');
    return new PropertyListContainer(
      unSelectProperty: unSelectProperty,
      propertySelectedCallback: (Property property) {
        Navigator.push(
          context,
          new MaterialPageRoute<PropertyDetail>(
            builder: (BuildContext context) => new PropertyDetail(
                  key: property != null ? new Key(property.id) : null,
                  property: property,
                  isTablet: false,
                ),
          ),
        );
      },
    );
  }

  Widget _buildTabletLayout() {
    print('building Tablet layout..');
    return new Row(
      children: <Widget>[
        new Flexible(
          child: new PropertyListContainer(
            unSelectProperty: unSelectProperty,
            propertySelectedCallback: (Property property) {
              setState(() {
                _selectedProperty = property;
              });
            },
            selectedProperty: _selectedProperty,
          ),
          flex: 2,
        ),
        new Flexible(
          child: new PropertyDetail(
            key: _selectedProperty?.id != null
                ? new Key(_selectedProperty.id)
                : null,
            property: _selectedProperty,
            isTablet: true,
          ),
          flex: 5,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) => new Scaffold(
        appBar: new AppBar(
          title: const Text('WPM master/detail'),
        ),
        drawer: const WPMDrawerView(),
        body: new LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double minDimension =
                min(constraints.maxWidth, constraints.maxHeight);

            // print('Constraints: maxWidth=[${constraints.maxWidth}], maxHeight=[${constraints.maxHeight}] min=[$minDimension]');

            if (minDimension < kTabletBreakPoint) {
              return _buildPhoneLayout();
            }
            return _buildTabletLayout();
          },
        ),
      );
}



import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
import 'package:wpm/models.dart';

void main() => runApp(new MyApp());

int snapCount = 0;

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
        // counter didn't reset back to zero; the application is not restarted.
        primarySwatch: Colors.deepPurple,
        accentColor: Colors.tealAccent,
      ),
      home: new MasterDetailContainer(),
    );
  }
}

class MasterDetailContainer extends StatefulWidget {
  @override
  _MasterDetailContainerState createState() =>
      new _MasterDetailContainerState();
}

class _MasterDetailContainerState extends State<MasterDetailContainer> {
  Property _selectedProperty;

  static const int kTabletBreakPoint = 650;

  unSelectProperty() {
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
          new MaterialPageRoute(
            builder: (BuildContext context) {
              return new PropertyDetail(
                property: property,
                isTablet: false,
              );
            },
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
            property: _selectedProperty,
            isTablet: true,
          ),
          flex: 5,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('WPM master/detail'),
      ),
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
}

class PropertyList extends StatelessWidget {
  PropertyList(
      {@required this.propertySelectedCallback,
      @required this.unSelectProperty,
      this.selectedProperty});

  final ValueChanged<Property> propertySelectedCallback;
  final Property selectedProperty;
  final VoidCallback unSelectProperty;

  dismissCallbackForProperty(String propertyId) {
    return (DismissDirection direction) {
      Firestore.instance
          .collection('properties')
          .document(propertyId)
          .delete()
          .then((_) {
        print('dismissCallback... unSelecting now..');
        unSelectProperty();
      }).catchError((error) {
        print('Error deleting id=[$propertyId] ==> ' + error.toString());
      });
    };
  }

  @override
  Widget build(BuildContext context) {
    return new StreamBuilder(
      stream:
          Firestore.instance.collection('properties').orderBy('name').snapshots,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) return const Text('Loading...');
        return new ListView(
          children: snapshot.data.documents
              .map((document) => new PropertyListItem(
                    snapShot: document,
                    propertySelectedCallback: propertySelectedCallback,
                    dismissCallback:
                        dismissCallbackForProperty(document.documentID),
                    selected: selectedProperty?.id == document.documentID,
                  ))
              .toList(),
        );
      },
    );
  }
}

class PropertyListItem extends StatelessWidget {
  final Property _property;
  final ValueChanged<Property> propertySelectedCallback;
  final bool _selected;
  final DismissDirectionCallback dismissCallback;

  PropertyListItem(
      {DocumentSnapshot snapShot,
      @required this.propertySelectedCallback,
      @required this.dismissCallback,
      Key key,
      bool selected = false})
      : _property = new Property.fromSnapshot(snapShot),
        _selected = selected,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Dismissible(
      key: new Key(_property.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        dismissCallback(_);
      },
      child: new ListTile(
        title: new Text(_property.name),
        subtitle: new Text("units: ${_property.unitCount}"),
        leading: new CircleAvatar(
          backgroundColor: Theme.of(context).accentColor,
          child: new Text(_property.name.substring(0, 1)),
        ),
        onTap: () => propertySelectedCallback(_property),
        selected: _selected,
      ),
    );
  }
}

class PropertyDetail extends StatelessWidget {
  PropertyDetail({@required this.property, @required this.isTablet});

  final Property property;
  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Widget content = new Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        new Text(
          property?.name ?? 'Select a Property',
          style: textTheme.headline,
        ),
        new Text(
          property?.name != null ? "Unit count: ${property.unitCount}" : '',
          style: textTheme.subhead,
        )
      ],
    );
    return new Scaffold(
      appBar: property != null
          ? new AppBar(
              title: new Text(property.name),
            )
          : null,
      body: new Center(
        child: content,
      ),
    );
  }
}

class AddProperty extends StatefulWidget {
  @override
  _AddPropertyState createState() => new _AddPropertyState();
}

class _AddPropertyState extends State<AddProperty> {
  final TextEditingController _controller = new TextEditingController();

  Future<Null> _addPropertyAsync() async {
    var trimStr = _controller.text.trim();
    if (trimStr.length > 0) {
      Firestore.instance.collection('properties').document().setData(
          <String, String>{'name': trimStr}).then((_) => _controller.clear());
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        new Expanded(
          child: new TextField(
            keyboardType: TextInputType.text,
            controller: _controller,
            onSubmitted: (_) => _addPropertyAsync(),
            decoration: new InputDecoration(hintText: 'Enter property name'),
          ),
        ),
        new RaisedButton(
          onPressed: () => _addPropertyAsync(),
          child: new Text('Add Property'),
        )
      ],
    );
  }
}

class PropertyListContainer extends StatefulWidget {
  PropertyListContainer(
      {Key key,
      this.propertySelectedCallback,
      this.selectedProperty,
      @required this.unSelectProperty})
      : super(key: key);

  final ValueChanged<Property> propertySelectedCallback;
  final Property selectedProperty;
  final VoidCallback unSelectProperty;

  @override
  _PropertyListContainerState createState() =>
      new _PropertyListContainerState();
}

class _PropertyListContainerState extends State<PropertyListContainer> {
  @override
  Widget build(BuildContext context) {
    return new Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        new AddProperty(),
        new Expanded(
          child: new PropertyList(
            unSelectProperty: widget.unSelectProperty,
            propertySelectedCallback: widget.propertySelectedCallback,
            selectedProperty: widget.selectedProperty,
          ),
        ),
      ],
    );
  }
}

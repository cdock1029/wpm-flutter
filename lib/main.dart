import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
import 'package:wpm/models.dart';

void main() => runApp(new MyApp());

int snapCount = 0;

//final routes = <String, WidgetBuilder>{
//  '/new_property': (BuildContext context) {
//    return new ModalRoute(const RouteSettings(name: ''))
//  }
//};

class MyApp extends StatelessWidget {
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

class PropertyList extends StatelessWidget {
  const PropertyList(
      {@required this.propertySelectedCallback,
      @required this.unSelectProperty,
      this.selectedProperty});

  final ValueChanged<Property> propertySelectedCallback;
  final Property selectedProperty;
  final VoidCallback unSelectProperty;
  final Text loading = const Text('Loading...');

  Function dismissCallbackForProperty(String propertyId) =>
      (DismissDirection direction) {
        Firestore.instance
            .collection('properties')
            .document(propertyId)
            .delete()
            .then((_) {
          print('dismissCallback... unSelecting now..');
          unSelectProperty();
        }).catchError((Object error) {
          print('Error deleting id=[$propertyId] ==> ${error.toString()}');
        });
      };

  @override
  Widget build(BuildContext context) => new StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection('properties')
            .orderBy('name')
            .snapshots,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return loading;
          }
          return new ListView(
            children: snapshot.data.documents
                .map((DocumentSnapshot document) => new PropertyListItem(
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

class PropertyListItem extends StatelessWidget {
  final Property _property;
  final ValueChanged<Property> propertySelectedCallback;
  final bool _selected;
  final DismissDirectionCallback dismissCallback;

  PropertyListItem({
    @required this.propertySelectedCallback,
    @required this.dismissCallback,
    DocumentSnapshot snapShot,
    Key key,
    bool selected = false,
  })
      : _property = new Property.fromSnapshot(snapShot),
        _selected = selected,
        super(key: key);

  @override
  Widget build(BuildContext context) => new Dismissible(
        key: new Key(_property.id),
        direction: DismissDirection.endToStart,
        onDismissed: dismissCallback,
        child: new ListTile(
          title: new Text(_property.name),
          subtitle: new Text('units: ${_property.unitCount}'),
          leading: new CircleAvatar(
            backgroundColor: Theme.of(context).accentColor,
            child: new Text(_property.name.substring(0, 1)),
          ),
          onTap: () => propertySelectedCallback(_property),
          selected: _selected,
        ),
      );
}

class PropertyDetail extends StatefulWidget {
  const PropertyDetail({@required this.property, @required this.isTablet});

  final Property property;
  final bool isTablet;

  @override
  _PropertyDetailState createState() => new _PropertyDetailState();
}

class _PropertyDetailState extends State<PropertyDetail> {

  Widget _unitsList(CollectionReference unitsRef) {
    if (unitsRef != null) {
      print('unitsRef is NOT NULL');
      return new StreamBuilder<QuerySnapshot>(
            stream: widget.property.unitsRef.snapshots,
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) {
                return const Text('Loading..');
              }
              return new ListView(
                  children: snapshot.data.documents
                      .map((DocumentSnapshot doc) => new ListTile(
                            key: new Key(doc.documentID),
                            title: new Text(doc['address']),
                          ))
                      .toList());
            }
      );
    }
    print('unitsRef is NULL');
    return const Text('No Units.');
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
              ? 'Unit count: ${widget.property
              .unitCount}'
              : '',
          style: textTheme.subhead,
        ),
        new Expanded(
          child: _unitsList(widget.property?.unitsRef),
        ),
      ],
    );
    return new Scaffold(
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

class AddProperty extends StatefulWidget {
  @override
  _AddPropertyState createState() => new _AddPropertyState();
}

class _AddPropertyState extends State<AddProperty> {
  final TextEditingController _controller = new TextEditingController();

  Future<Null> _addPropertyAsync() async {
    final String trimStr = _controller.text.trim();
    if (trimStr.isNotEmpty) {
      await Firestore.instance
          .collection('properties')
          .document()
          .setData(<String, String>{'name': trimStr});
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) => new Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          new Expanded(
            child: new TextField(
              keyboardType: TextInputType.text,
              controller: _controller,
              onSubmitted: (_) => _addPropertyAsync(),
              decoration:
                  const InputDecoration(hintText: 'Enter property name'),
            ),
          ),
          new RaisedButton(
            onPressed: _addPropertyAsync,
            child: const Text('Add Property'),
          )
        ],
      );
}

class PropertyListContainer extends StatefulWidget {
  const PropertyListContainer({
    @required this.unSelectProperty,
    this.propertySelectedCallback,
    this.selectedProperty,
    Key key,
  })
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
  Widget build(BuildContext context) => new Column(
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

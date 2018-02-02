import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:wpm/models.dart';

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

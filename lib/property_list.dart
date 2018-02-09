import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:wpm/add_property.dart';
import 'package:wpm/app_state.dart';
import 'package:wpm/models.dart';

class PropertyListContainer extends StatefulWidget {
  const PropertyListContainer({
    @required this.model,
    /* @required this.unSelectProperty,
    this.propertySelectedCallback,
    this.selectedProperty, */
    Key key,
  })
      : super(key: key);

  final AppModel model;

  // final ValueChanged<Property> propertySelectedCallback;
  // final Property selectedProperty;
  // final VoidCallback unSelectProperty;

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
              model: widget.model,
              /* unSelectProperty: widget.unSelectProperty,
              propertySelectedCallback: widget.propertySelectedCallback,
              selectedProperty: widget.selectedProperty, */
            ),
          ),
        ],
      );
}

class PropertyListItem extends StatelessWidget {
  final Property property;
  final PropertyStreamCallback propertyStreamCallback;
  final bool _selected;
  final DismissDirectionCallback dismissCallback;

  const PropertyListItem({
    @required this.property,
    @required this.propertyStreamCallback,
    @required this.dismissCallback,
    Key key,
    bool selected = false,
  })
      : _selected = selected,
        super(key: key);

  @override
  Widget build(BuildContext context) => new Dismissible(
        key: new Key(property?.id),
        direction: DismissDirection.endToStart,
        onDismissed: dismissCallback,
        child: new Card(
          child: new ListTile(
            title: new Text(property.name),
            subtitle: new Text('units: ${property.unitCount}'),
            leading: new CircleAvatar(
              backgroundColor: Theme.of(context).accentColor,
              child: new Text(property.name.substring(0, 1)),
            ),
            onTap: () => print('TAPPED!\n\n'),// propertyStreamCallback(property),
            selected: _selected,
          ),
        ),
      );
}

class PropertyList extends StatelessWidget {
  const PropertyList({@required this.model});

  final AppModel model;
  final Text loading = const Text('Loading...');

  Function dismissCallbackForProperty(String propertyId) =>
      (DismissDirection direction) {
        Firestore.instance
            .collection('properties')
            .document(propertyId)
            .delete()
            .then((_) {
          print('dismissCallback... unSelecting now..');
          model.propertyStreamCallback(null);
        }).catchError((Object error) {
          print('Error deleting id=[$propertyId] ==> ${error.toString()}');
        });
      };

  @override
  Widget build(BuildContext context) {
    print('PropertyList model=[\n$model\n]');
    return model.properties.isEmpty
        ? loading
        : new ListView.builder(
            itemCount: model.properties.length,
            itemBuilder: (BuildContext context, int index) =>
                new PropertyListItem(
                  propertyStreamCallback: model.propertyStreamCallback,
                  dismissCallback: (_) => model.propertyStreamCallback(null),
                  property: model.properties.isNotEmpty
                      ? model.properties[index]
                      : null,
                ),
          );
  }
}

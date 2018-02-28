import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wpm/models.dart';

class AddEditProperty extends StatefulWidget {
  final Property property;

  const AddEditProperty({this.property, Key key}) : super(key: key);

  static const String routeName = '/add_edit_property';

  @override
  _AddEditPropertyState createState() => new _AddEditPropertyState();
}

class _AddEditPropertyState extends State<AddEditProperty>
    with TickerProviderStateMixin {
  TextEditingController _propertyNameController;
  TextEditingController _unitAddressController;
  bool _isLoading;
  Property _property;
  int _editUnitIndex;

  @override
  void initState() {
    super.initState();
    _property = widget.property;
    _propertyNameController = new TextEditingController(text: _property?.name);
    _unitAddressController = new TextEditingController();
    _editUnitIndex = -1;
    _isLoading = false;
  }

  @override
  void dispose() {
    _propertyNameController.dispose();
    _unitAddressController.dispose();
    super.dispose();
  }

  void _updateLoading(bool value) {
    setState(() {
      _isLoading = value;
    });
  }

  Future<Null> _addPropertyAsync(BuildContext context) async {
    final String trimStr = _propertyNameController.text.trim();
    if (trimStr.isNotEmpty) {
      final DocumentReference ref =
          Firestore.instance.collection('properties').document(_property?.id);

      final Map<String, String> _data = <String, String>{'name': trimStr};
      if (_property != null) {
        await ref.updateData(_data);
      } else {
        await ref.setData(_data);
      }

      final DocumentSnapshot newPropSnap = await ref.get();

      setState(() {
        _property = new Property.fromSnapshot(newPropSnap);
      });
      //_controller.clear();
    }
    // Navigator.pop(context, prop);
  }

  @override
  Widget build(BuildContext context) => new Scaffold(
        appBar: new AppBar(
            title: new Text(
                widget.property == null ? 'Add Property' : 'Edit Property')),
        body: new Column(
          children: <Widget>[
            new Padding(
              padding: const EdgeInsets.all(16.0),
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  new Expanded(
                    child: new TextField(
                      keyboardType: TextInputType.text,
                      controller: _propertyNameController,
                      onSubmitted: (_) => _addPropertyAsync(context),
                      decoration: const InputDecoration(
                          hintText: 'Enter property name'),
                    ),
                  ),
                ],
              ),
            ),
            _property != null
                ? new Container(
                    padding: const EdgeInsets.all(16.0),
                    child: new TextField(
                      controller: _unitAddressController,
                      decoration: const InputDecoration(
                        labelText: 'Add Unit (address)',
                      ),
                      onSubmitted: (String value) async {
                        _updateLoading(true);
                        await _property.unitsRef
                            .add(<String, dynamic>{'address': value});
                        _updateLoading(false);
                        _unitAddressController.clear();
                      },
                      autofocus: true,
                    ))
                : new Container(
                    width: 0.0,
                    height: 0.0,
                  ),
            _isLoading
                ? const CircularProgressIndicator()
                : new Container(
                    width: 0.0,
                    height: 0.0,
                  ),
            _property != null
                ? new Flexible(
                    child: new StreamBuilder<List<Unit>>(
                      stream: _property.unitsRef
                          .orderBy('ordering')
                          .snapshots
                          .map((QuerySnapshot qSnap) => qSnap.documents)
                          .map((List<DocumentSnapshot> docs) => docs
                              .map((DocumentSnapshot doc) =>
                                  new Unit.fromSnapshot(doc))
                              .toList()),
                      initialData: <Unit>[],
                      builder: (BuildContext context,
                              AsyncSnapshot<List<Unit>> snapshot) =>
                          new ListView.builder(
                            shrinkWrap: true,
                            itemCount: snapshot.data.length,
                            itemBuilder: (BuildContext context, int index) {
                              final Unit unit = snapshot.data[index];

                              final Widget _child = _editUnitIndex != index
                                  ? new ListTile(
                                      dense: true,
                                      key: new Key(unit.id),
                                      title: new Text(
                                        unit.address,
                                        style: Theme
                                            .of(context)
                                            .textTheme
                                            .headline,
                                      ),
                                      onLongPress: () {
                                        setState(() {
                                          _editUnitIndex = index;
                                        });
                                      },
                                    )
                                  : new Form(
                                      child: new Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: new Column(
                                          children: <Widget>[
                                            new Row(
                                              children: <Widget>[
                                                new Flexible(
                                                  child: new TextFormField(
                                                    initialValue: unit.address,
                                                    autocorrect: false,
                                                    decoration:
                                                        const InputDecoration(
                                                      isDense: true,
                                                      icon: const Icon(
                                                          Icons.mail_outline),
                                                      labelText: 'Address',
                                                    ),
                                                    validator: null,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            new Padding(
                                              padding:
                                                  const EdgeInsets.all(16.0),
                                              child: new ButtonBar(
                                                children: <Widget>[
                                                  new FlatButton(
                                                    child: const Text('DELETE'),
                                                    textColor: Colors.red,
                                                    onPressed: () {
                                                      setState(() {
                                                        _editUnitIndex = -1;
                                                      });
                                                      unit.unitRef.delete();
                                                    },
                                                  ),
                                                  new FlatButton(
                                                    child: const Text('UPDATE'),
                                                    onPressed: () {
                                                      print('saved');
                                                      setState(() {
                                                        _editUnitIndex = -1;
                                                      });
                                                    },
                                                  ),
                                                  new FlatButton(
                                                    child: const Text('Cancel'),
                                                    onPressed: () {
                                                      setState(() {
                                                        _editUnitIndex = -1;
                                                      });
                                                    },
                                                    textColor: Colors.black54,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                              return new AnimatedSize(
                                child: _child,
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeInOut,
                                vsync: this,
                              );
                            },
                          ),
                    ),
                  )
                : const Text('Property is empty'),
          ],
        ),
      );
}

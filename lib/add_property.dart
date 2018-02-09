import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wpm/models.dart';

class AddProperty extends StatefulWidget {
  @override
  _AddPropertyState createState() => new _AddPropertyState();
}

class _AddPropertyState extends State<AddProperty> {
  final TextEditingController _controller = new TextEditingController();

  Future<Null> _addPropertyAsync(BuildContext context) async {
    final String trimStr = _controller.text.trim();
    Property prop;
    if (trimStr.isNotEmpty) {

      final DocumentReference ref = Firestore.instance
          .collection('properties')
          .document();

      await ref.setData(<String, String>{'name': trimStr});
      final DocumentSnapshot newPropSnap = await ref.get();

      prop = new Property.fromSnapshot(newPropSnap);

      //TODO does clearing this matter anymore?
      //_controller.clear();
    }
    Navigator.pop(context, prop);
  }

  @override
  Widget build(BuildContext context) => new Scaffold(
        appBar: new AppBar(title: const Text('Add Property')),
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
                      controller: _controller,
                      onSubmitted: (_) => _addPropertyAsync(context),
                      decoration: const InputDecoration(
                          hintText: 'Enter property name'),
                    ),
                  ),
                  /*new Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 4.0, 4.0, 4.0),
                    child: new RaisedButton(
                      color: Theme.of(context).accentColor,
                      onPressed: _addPropertyAsync,
                      child: const Text('Add Property'),
                    ),
                  ),*/
                ],
              ),
            ),
          ],
        ),
      );
}

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

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
  Widget build(BuildContext context) => new Padding(
        padding: const EdgeInsets.all(16.0),
        child: new Row(
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
            new Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 4.0, 4.0, 4.0),
              child: new RaisedButton(
                color: Theme.of(context).accentColor,
                onPressed: _addPropertyAsync,
                child: const Text('Add Property'),
              ),
            ),
          ],
        ),
      );
}

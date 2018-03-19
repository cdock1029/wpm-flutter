import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wpm/common/utilities.dart';
import 'package:wpm/data/models.dart';

class AddUnitDialog extends StatefulWidget {
  const AddUnitDialog({this.unit});
  final Unit unit;

  @override
  _AddUnitDialogState createState() => new _AddUnitDialogState();
}

class _AddUnitDialogState extends State<AddUnitDialog> {
  TextEditingController _textController;
  String _titleText;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.unit?.address);
    _titleText = widget.unit != null ? 'Update unit' : 'Add unit';
  }

  @override
  void dispose() {
    _textController?.dispose();
    super.dispose();
  }

  void _save({String address, BuildContext context}) {
    if (address.isNotEmpty) {
      Unit unitToSave;
      if (widget.unit != null) {
        //update
        unitToSave = Unit.copy(widget.unit, address);
      } else {
        // create new
        unitToSave = Unit(address: address);
      }
      Navigator.pop(context, unitToSave);
    }
  }

  @override
  Widget build(BuildContext context) => SystemPadding(
        child: AlertDialog(
          title: Text(_titleText),
          content: TextField(
            autofocus: false,
            controller: _textController,
            autocorrect: false,
            onSubmitted: (String value) {
              _save(address: value, context: context);
            },
            decoration: InputDecoration(
              hintText: 'Unit address',
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('CANCEL'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            FlatButton(
              child: Text('SAVE'),
              onPressed: () {
                _save(address: _textController.text, context: context);
              },
            ),
          ],
        ),
      );
}

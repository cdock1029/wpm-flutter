import 'package:flutter/material.dart';

//class WPMDrawerContainer extends StatefulWidget {
//  @override
//  _WPMDrawerState createState() => new _WPMDrawerState();
//}
//
//class _WPMDrawerState extends State<WPMDrawerContainer> {
//
//}

class WPMDrawerView extends StatelessWidget {
  static const List<String> _items = const <String>['one', 'two', 'three'];

  const WPMDrawerView({
    Key key,

  }) : super(key: key);

  List<Widget> _children(BuildContext context) => <List<Widget>>[
    <Widget>[
      const DrawerHeader(
        child: const Center(
          child: const Icon(Icons.attach_money),
        ),
      ),
    ],
    ListTile
        .divideTiles(
      context: context,
      tiles: _items
          .map<Widget>((String item) => new ListTile(
        title: new Text(item),
      ))
          .toList(),
    )
        .toList(),
    <Widget>[
      const AboutListTile(
        icon: const Icon(Icons.home),
      ),
    ],
  ].expand((List<Widget> list) => list).toList();

  @override
  Widget build(BuildContext context) => new Drawer(
    child: new ListView(
      children: _children(context),
    ),
  );
}
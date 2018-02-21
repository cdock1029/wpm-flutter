import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wpm/lease_create.dart';
import 'package:wpm/lease_list.dart';
import 'package:wpm/models.dart';
import 'package:wpm/property_state.dart';
import 'package:wpm/wpm_drawer.dart';

class Dashboard extends StatelessWidget {
  const Dashboard();

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final AppState appState = AppState.of(context);
    final Property selected = appState.selected;

    String _titleText, _subTitleText;
    MainAxisAlignment _align;
    if (selected?.name != null) {
      _titleText = selected.name;
      _subTitleText = 'Unit count: ${selected.unitCount}';
      _align = MainAxisAlignment.start;
    } else {
      _titleText = '↑ Select a Property what?';
      _subTitleText = '';
      _align = MainAxisAlignment.center;
    }
    final Text title = new Text(_titleText, style: textTheme.headline);
    final Text subTitle = new Text(_subTitleText, style: textTheme.subhead);

    final List<Widget> _children = <Widget>[
      title,
      subTitle,
    ];
    if (selected != null) {
      print('model.selectedProperty: [$selected]');
      // TODO: use STRING key for now, until refs are supported..
      // final DocumentReference propRef = Firestore.instance.collection('properties').document(model.selectedProperty.id);
      final String propRefSTRING = selected.id;
      _children.add(
        new Expanded(
          child: new LeaseList(
            propertyRef: propRefSTRING,
          ),
        ),
      );
    }

    return new Scaffold(
      key: const Key('property_detail'),
      appBar: new AppBar(
        title: new Text(selected?.name ?? 'WPM'),
      ),
      body: new Column(
        mainAxisAlignment: _align,
        children: _children,
      ),
      drawer: const WPMDrawerView(),
      floatingActionButton: selected != null
          ? new FloatingActionButton(
              child: new Center(
                child: new Icon(Icons.add),
              ),
              onPressed: () {
                Navigator.pushNamed(context, CreateLease.routeName);
              },
            )
          : null,
    );
  }
}

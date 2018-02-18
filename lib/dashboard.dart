import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wpm/app_state.dart';
import 'package:wpm/lease_create.dart';
import 'package:wpm/lease_list.dart';
import 'package:wpm/unit.dart';
import 'package:wpm/wpm_drawer.dart';

class Dashboard extends StatelessWidget {
  final AppState appState;

  const Dashboard(this.appState);

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return new StreamBuilder<AppModel>(
      stream: appState,
      builder: (
        BuildContext context,
        AsyncSnapshot<AppModel> appSnap,
      ) {
        final AppModel model = appSnap.data;

        String _titleText, _subTitleText;
        MainAxisAlignment _align;
        if (model?.selectedProperty?.name != null) {
          _titleText = model?.selectedProperty?.name;
          _subTitleText = 'Unit count: ${model.selectedProperty.unitCount}';
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
        if (model?.selectedProperty != null) {
          print('model.selectedProperty: [${model.selectedProperty}]');
          // TODO: use STRING key for now, until refs are supported..
          // final DocumentReference propRef = Firestore.instance.collection('properties').document(model.selectedProperty.id);
          final String propRefSTRING = model.selectedProperty.id;
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
            title: new Text(model?.selectedProperty?.name ?? 'WPM'),
          ),
          drawer: new WPMDrawerView(appState),
          body: new Column(
            mainAxisAlignment: _align,
            children: _children,
          ),
          floatingActionButton: model?.selectedProperty != null
              ? new FloatingActionButton(
                  child: new Center(child: new Icon(Icons.add),),
                  onPressed: () {
                    Navigator.pushNamed(context, CreateLease.routeName);
                  },
                )
              : null,
        );
      },
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wpm/leases/lease_create.dart';
import 'package:wpm/data/models.dart';
import 'package:wpm/app_state.dart';
import 'package:wpm/properties/add_edit_property.dart';
import 'package:wpm/common/wpm_drawer.dart';
import 'package:wpm/units/unit.dart';

class ContentShell extends StatelessWidget {
  const ContentShell();

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Stream<Property> selectedPropertyStream = AppStateProvider.of(context).selectedPropertyStream;
    // print('ContentShell build => selected=[${selected.toString()}]');

    return StreamBuilder<Property>(
      stream: selectedPropertyStream,
      builder: (
        BuildContext context,
        AsyncSnapshot<Property> streamSnap,
      ) {
        Widget _title;
        String _titleText, _subTitleText;
        MainAxisAlignment _align;
        final Property selected = streamSnap.data;
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
          // print('model.selectedProperty: [$selected]');
          // TODO: use STRING key for now, until refs are supported..
          _children.add(
            new Expanded(
//          child: new LeaseList(
//            propertyRef: propRefSTRING,
//          ),
              child: UnitListView(
                property: selected,
              ),
            ),
          );
        }
        return new Scaffold(
            key: Key('property_detail'),
            appBar: AppBar(
              title: Text(selected?.name ?? AppStateProvider.of(context).user.company.name),
              actions: selected != null
                  ? <Widget>[
                      new IconButton(
                        icon: new Icon(Icons.edit),
                        onPressed: () {
                          Navigator.push(
                              context,
                              new MaterialPageRoute<Null>(
                                builder: (BuildContext context) =>
                                    new AddEditProperty(property: selected),
                              ));
                        },
                      ),
                    ]
                  : null,
            ),
            body: new Column(
              mainAxisAlignment: _align,
              children: _children,
            ),
            drawer: WPMDrawerLoader(),
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
      },
    );
  }
}

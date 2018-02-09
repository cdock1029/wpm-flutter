import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wpm/app_state.dart';
import 'package:wpm/unit.dart';

class PropertyDetail extends StatelessWidget {
  final AppState appState;

  const PropertyDetail({this.appState, Key key}) : super(key: key);

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

        if (model != null) {
          _children.add(
            new Expanded(
                child: new UnitListView(
                    property: model.selectedProperty,
                    stream: model.selectedProperty?.unitsRef?.snapshots)),
          );
        }

        return new Scaffold(
          key: const Key('property_detail'),
          /*appBar: new AppBar(
            key: const Key('property_detail_app_bar'),
          ),*/
          // TODO fix alignment and such..
          body: new Column(mainAxisAlignment: _align, children: _children),
        );
      },
    );
  }
}

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
        Widget content;
        final AppModel model = appSnap.data;
        if (appSnap.data == null) {
          content = new Container();
        } else {
          content = new UnitListView(property: model.selectedProperty, stream: model.selectedProperty.unitsRef?.snapshots);
        }
        final Text headingText = new Text(
          model?.selectedProperty?.name ?? 'Select a Property',
          style: textTheme.headline,
        );
        return new Scaffold(
          key: const Key('property_detail'),
          appBar: new AppBar(
            key: const Key('property_detail_app_bar'),
          ),
          body: new Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              headingText,
              //new RaisedButton(onPressed: () => model.onSelectProperty())
              new Text(
                model?.selectedProperty?.name != null
                    ? 'Unit count: ${model.selectedProperty.unitCount}'
                    : '',
                style: textTheme.subhead,
              ),
              new Expanded(child: content),
            ],
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class PropertyDetail extends StatelessWidget {
  const PropertyDetail();

  @override
  Widget build(BuildContext context) {
    print('unimplemented');
    return Text('unimplemented');
  }
    /*

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
      _children.add(
        new Expanded(
          child: new UnitListView(property: selected),
        ),
      );
    }

    return new Scaffold(
      key: const Key('property_detail'),
      appBar: new AppBar(
        title: new Text(selected?.name ?? 'WPM'),
      ),
      drawer: WPMDrawerLoader(),
      body: new Column(mainAxisAlignment: _align, children: _children),
    );
  }
  */
}

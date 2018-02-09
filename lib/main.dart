
import 'package:flutter/material.dart';
import 'package:wpm/app_state.dart';
import 'package:wpm/property_detail.dart';
import 'package:wpm/property_list.dart';
import 'package:wpm/wpm_drawer.dart';

void main() => runApp(new WPMApp());

class WPMApp extends StatefulWidget {

  @override
  WPMAppState createState() => new WPMAppState();
}

class WPMAppState extends State<WPMApp> {

  ContextGetter contextGetter;
  AppState appState;

  @override
  void initState() {
    super.initState();
    contextGetter = new ContextGetter();
    appState = new AppState(contextGetter);
  }

  @override
  void dispose() {
    super.dispose();
    print('WPMAppState closing stream controller..');
    appState.close();
  }

  @override
  Widget build(BuildContext context) => new StreamBuilder<AppModel>(
      stream: appState,
      builder: (
        BuildContext context,
        AsyncSnapshot<AppModel> snapshot,
      ) {
        print('WPMAppState build. snappshot.data=[${snapshot.data}]');
        final AppModel model = snapshot.data;
        return new MaterialApp(
          title: '* WPM *',
          theme: new ThemeData(
            primarySwatch: Colors.deepPurple,
            accentColor: Colors.tealAccent,
            scaffoldBackgroundColor: Colors.grey[200],
          ),
          home: new Scaffold(
            appBar: new AppBar(
              title: const Text('WPM ??'),
            ),
            drawer: const WPMDrawerView(),
            body: new Builder(
              builder: (BuildContext ctx) {
                contextGetter.context = ctx;
                return new PropertyListContainer(model: model);
              },
            ),
          ),
          routes: <String, WidgetBuilder>{
            '/property_detail': (BuildContext context) =>
                new PropertyDetail(appState: appState),
          },
        );
      });
}

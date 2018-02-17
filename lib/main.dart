
import 'package:flutter/material.dart';
import 'package:wpm/add_property.dart';
import 'package:wpm/app_state.dart';
import 'package:wpm/dashboard.dart';
import 'package:wpm/property_detail.dart';
import 'package:wpm/property_list.dart';
import 'package:wpm/tenant_add.dart';
import 'package:wpm/tenant_list.dart';
import 'package:wpm/wpm_drawer.dart';

void main() => runApp(new WPMApp());

class WPMApp extends StatefulWidget {

  @override
  WPMAppState createState() => new WPMAppState();
}

class WPMAppState extends State<WPMApp> {

  AppState appState;

  @override
  void initState() {
    super.initState();
    // contextGetter = new ContextGetter();
    appState = new AppState();
  }

  @override
  void dispose() {
    super.dispose();
    print('WPMAppState closing stream controller..');
    appState.close();
  }

  @override
  Widget build(BuildContext context) => /*new StreamBuilder<AppModel>(
      stream: appState,
      initialData: new AppModel.initial(),
      builder: (
        BuildContext context,
        AsyncSnapshot<AppModel> snapshot,
      ) {
        final AppModel model = snapshot.data;
        print('WPMAppState build. snappshot.data=[$model]');
        return */ new MaterialApp(
          title: '* WPM *',
          theme: new ThemeData(
            primarySwatch: Colors.deepPurple,
            accentColor: Colors.tealAccent,
            scaffoldBackgroundColor: Colors.grey[200],
          ),
          home: new Dashboard(appState),
          routes: <String, WidgetBuilder>{
            AddProperty.routeName: (_) => const AddProperty(),
            AddTenant.routeName: (_) => const AddTenant(),
            TenantList.routeName: (_) => const TenantList(),
          },
        );
      // });
}

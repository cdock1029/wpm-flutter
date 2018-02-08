import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wpm/app_state.dart';
import 'package:wpm/models.dart';
import 'package:wpm/property_detail.dart';
import 'package:wpm/property_list.dart';
import 'package:wpm/wpm_drawer.dart';
import 'package:flutter_stream_friends/flutter_stream_friends.dart';

void main() => runApp(new WPMApp());

class WPMApp extends StatelessWidget {
  static final ContextGetter _contextGetter = new ContextGetter();
  static final AppModelStream _appModelStream = new AppModelStream(_contextGetter);


  @override
  Widget build(BuildContext context) => new StreamBuilder<AppModel>(
      stream: _appModelStream,
      builder: (
        BuildContext context,
        AsyncSnapshot<AppModel> snapshot,
      ) {
        final AppModel model = snapshot.data ?? new AppModel.initial();
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
                _contextGetter.context = ctx;
                return new PropertyListContainer(model: model);
              },
            ),
          ),
          routes: <String, WidgetBuilder>{
            '/property_detail': (BuildContext context) =>
                new PropertyDetail(appModelStream: _appModelStream),
          },
        );
      });
}

import 'package:flutter/widgets.dart';
import 'package:wpm/models.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppState extends InheritedWidget {

  const AppState({this.user, this.properties, this.selected, this.selectProperty, Widget child}) : super(child: child);

  final List<Property> properties;
  final Property selected;
  final ValueChanged<Property> selectProperty;
  final FirebaseUser user;

  @override
  bool updateShouldNotify(AppState oldWidget) => oldWidget.user != user || oldWidget.properties != properties || oldWidget.selected != selected;

  static AppState of(BuildContext context) => context.inheritFromWidgetOfExactType(AppState);
}
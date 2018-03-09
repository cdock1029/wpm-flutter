import 'package:flutter/widgets.dart';
import 'package:wpm/data/models.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppState extends InheritedWidget {
  const AppState({
    this.user,
    this.company,
    this.properties,
    this.selected,
    this.selectProperty,
    Widget child,
  }) : super(child: child);

  final FirebaseUser user;
  final Company company;
  final List<Property> properties;
  final Property selected;
  final ValueChanged<Property> selectProperty;

  @override
  bool updateShouldNotify(AppState oldWidget) =>
      oldWidget.user != user ||
      oldWidget.company != company ||
      oldWidget.properties != properties ||
      oldWidget.selected != selected;

  static AppState of(BuildContext context) =>
      context.inheritFromWidgetOfExactType(AppState);
}

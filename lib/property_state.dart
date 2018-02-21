import 'package:flutter/widgets.dart';
import 'package:wpm/models.dart';

class AppState extends InheritedWidget {

  const AppState(this.properties, this.selected, this.selectProperty, Widget child) : super(child: child);

  final List<Property> properties;
  final Property selected;
  final ValueChanged<Property> selectProperty;

  @override
  bool updateShouldNotify(AppState oldWidget) => oldWidget.properties != properties || oldWidget.selected != selected;

  static AppState of(BuildContext context) => context.inheritFromWidgetOfExactType(AppState);
}
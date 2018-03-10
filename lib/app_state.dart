import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:wpm/data/models.dart';
import 'package:firebase_auth/firebase_auth.dart';

class _AppState extends InheritedWidget {
  const _AppState({
    this.user,
    this.selectProperty,
    Property selectedProperty,
    Widget child,
  })  : _selectedProperty = selectedProperty,
        super(child: child);

  final AppUser user;
  final ValueChanged<Property> selectProperty;
  final Property _selectedProperty;

  // TODO streams need to generate each time, so when read they yield values...
  // TODO or can somehow use a Subject from rx dart.
  Stream<List<Property>> get propertiesStream => user.company.properties;
  Stream<Property> get selectedPropertyStream => _selectedProperty?.documentReference?.snapshots?.map<Property>((DocumentSnapshot snap) => Property.fromSnapshot(snap));

  @override
  bool updateShouldNotify(_AppState oldWidget) {
    final bool userB = oldWidget.user != user;
    final bool selectedB =
        oldWidget.selectedPropertyStream != selectedPropertyStream;
    final bool shouldNotify = userB || selectedB;

    print(
        'updateShouldNotify? => $shouldNotify (userB=[$userB], selectedB=[$selectedB])');
    print('selected=> old=[${oldWidget.selectedPropertyStream
        .toString()}], new=[${selectedPropertyStream
        .toString()}]');
    return shouldNotify;
  }
}

class AppStateProvider extends StatefulWidget {
  final Stream<FirebaseUser> userStream;
  final Widget child;

  const AppStateProvider({
    this.userStream,
    this.child,
  });

  static _AppState of(BuildContext context) =>
      context.inheritFromWidgetOfExactType(_AppState);

  @override
  _AppStateProviderState createState() => new _AppStateProviderState();
}

class _AppStateProviderState extends State<AppStateProvider> {
  AppUser _user;
  Property _selectedProperty;
  StreamSubscription<AppUser> _appUserSub;

  @override
  void initState() {
    super.initState();
    _appUserSub = widget.userStream
        .asyncMap(AppUser.fromFirebaseUser)
        .listen(_userStreamOnData);
  }

  @override
  void dispose() {
    _appUserSub?.cancel();
    super.dispose();
  }

  void _userStreamOnData(AppUser user) {
    setState(() {
      _user = user;
      if (user == null) {
        _selectedProperty = null;
      }
    });
  }

  void _onPropertySelected(Property property) {
    setState(() {
      _selectedProperty = property;
    });
  }

  @override
  Widget build(BuildContext context) => _AppState(
        user: _user,
        selectedProperty: _selectedProperty,
        selectProperty: _onPropertySelected,
        child: widget.child,
      );
}

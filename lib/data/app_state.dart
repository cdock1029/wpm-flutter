import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:wpm/data/models.dart';
import 'package:firebase_auth/firebase_auth.dart';

class _InheritedState extends InheritedWidget {
  const _InheritedState({
    this.data,
    Widget child,
    Key key,
  }) : super(child: child, key: key);

  final AppState data;

  @override
  bool updateShouldNotify(_InheritedState oldWidget) => true;
}

class AppStateProvider extends StatefulWidget {
  final Widget child;

  const AppStateProvider({this.child});

  static AppState of(BuildContext context) {
    final _InheritedState inherited =
        context.inheritFromWidgetOfExactType(_InheritedState);
    return inherited.data;
  }

  @override
  AppState createState() => new AppState();
}

class AppState extends State<AppStateProvider> {
  AppUser _user;
  bool _userLoaded;
  Property _selectedProperty;
  StreamSubscription<AppUser> _appUserSub;

  Stream<List<Property>> get propertiesStream => _user.company.properties;

  bool get userLoaded => _userLoaded;

  Stream<Property> get selectedPropertyStream => _selectedProperty
      ?.documentReference?.snapshots
      ?.map<Property>((DocumentSnapshot snap) => Property.fromSnapshot(snap));

  Stream<List<Lease>> get leasesForSelectedPropertyStream => _user.company.ref
      .getCollection('leases')
      .where('propertyRef', isEqualTo: _selectedProperty.ref)
      .snapshots
      .map<List<DocumentSnapshot>>((QuerySnapshot q) => q.documents)
      .map<List<Lease>>((List<DocumentSnapshot> docList) => docList
          .map<Lease>((DocumentSnapshot d) => new Lease.fromSnapshot(d))
          .toList());

  AppUser get user => _user;

  ValueChanged<Property> get selectProperty => _onPropertySelected;

  @override
  void initState() {
    super.initState();
    _userLoaded = false;
    _appUserSub = FirebaseAuth.instance.onAuthStateChanged
        .asyncMap(AppUser.fromFirebaseUser)
        .listen(_userStreamOnData);
  }

  @override
  void dispose() {
    _appUserSub?.cancel();
    super.dispose();
  }

  void _userStreamOnData(AppUser user) {
    print('_userStreamOnData, user=[${user.toString()}]');
    setState(() {
      _userLoaded = true;
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
  Widget build(BuildContext context) => new _InheritedState(
        data: this,
        child: widget.child,
      );
}

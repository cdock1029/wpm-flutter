import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:wpm/data/models.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppState extends InheritedWidget {
  const AppState({
    this.user,
    this.userLoaded,
    this.selectProperty,
    Property selectedProperty,
    Widget child,
  })
      : _selectedProperty = selectedProperty,
        super(child: child);

  final AppUser user;
  final bool userLoaded;
  final ValueChanged<Property> selectProperty;
  final Property _selectedProperty;

  Stream<List<Property>> get propertiesStream => user.company.properties;

  Stream<Property> get selectedPropertyStream =>
      _selectedProperty?.documentReference?.snapshots?.map<Property>((
          DocumentSnapshot snap) => Property.fromSnapshot(snap));

  Stream<List<Lease>> get leasesForSelectedPropertyStream =>
      user.company.ref
          .getCollection('leases')
          .where(
          'propertyRef', isEqualTo: _selectedProperty.ref)
          .snapshots
          .map<List<DocumentSnapshot>>((QuerySnapshot q) => q.documents)
          .map<List<Lease>>((List<DocumentSnapshot> docList) => docList.map<Lease>((DocumentSnapshot d) => new Lease.fromSnapshot(d)).toList());

  @override
  bool updateShouldNotify(AppState oldWidget) {
    final bool userB = oldWidget.user != user;
    final bool selectedB =
        oldWidget.selectedPropertyStream != selectedPropertyStream;
    final bool loaded = oldWidget.userLoaded != userLoaded;
    final bool shouldNotify = userB || selectedB || loaded;

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

  static AppState of(BuildContext context) =>
      context.inheritFromWidgetOfExactType(AppState);

  @override
  _AppStateProviderState createState() => new _AppStateProviderState();
}

class _AppStateProviderState extends State<AppStateProvider> {
  AppUser _user;
  bool _userLoaded;
  Property _selectedProperty;
  StreamSubscription<AppUser> _appUserSub;

  @override
  void initState() {
    super.initState();
    _userLoaded = false;
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
  Widget build(BuildContext context) =>
      new AppState(
        user: _user,
        userLoaded: _userLoaded,
        selectedProperty: _selectedProperty,
        selectProperty: _onPropertySelected,
        child: widget.child,
      );
}

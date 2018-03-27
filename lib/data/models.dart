import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';

abstract class Model {

  final DocumentReference ref;

  const Model({this.ref});

  String get id => ref?.documentID;

  String get path => ref?.path;

  CollectionReference get parent => ref?.parent;

  Future<void> updateData(Map<String, dynamic> data) => ref?.updateData(data);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Model && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

class AppUser extends Model {
  final FirebaseUser _firebaseUser;
  final Company company;

  // TODO clean this up..
  AppUser._({
    @required FirebaseUser firebaseUser,
    @required DocumentSnapshot userSnap,
    this.company,
  })
      : _firebaseUser = firebaseUser,
        super(ref: userSnap.reference);

  String get email => _firebaseUser.email;

  String get displayName => _firebaseUser.displayName;

  String get photoUrl => _firebaseUser.photoUrl;

  String get uid => _firebaseUser.uid;

  static Future<AppUser> fromFirebaseUser(FirebaseUser user) async {
    if (user == null) {
      return null;
    }
    final DocumentReference _userDataRef = Firestore.instance.collection(
        'users').document(user.uid);
    final DocumentSnapshot userSnap = await _userDataRef.get();

    final String activeCompany = userSnap['activeCompany'];
    final DocumentSnapshot companySnap = await Firestore.instance
        .collection('companies')
        .document(activeCompany)
        .get();
    final Company company = Company(companySnap);
    print('** Company: dateCreate=${company.dateCreated.toIso8601String()}');

    return AppUser._(firebaseUser: user, userSnap: userSnap, company: company);
  }

  Future<T> getPreference<T>(String key) async {
    final DocumentSnapshot doc = await ref.get();
    final Map<dynamic, dynamic> prefs = doc['preferences'];

    final T result = prefs[key];
    return result;
  }

  // TODO test this updates vs overwrites.
  Future<Null> updatePreference(String key, dynamic value) async {
    final DocumentSnapshot doc = await ref.get();
    final Map<dynamic, dynamic> prefs = doc['preferences'];

    prefs[key] = value;

    final Map<String, dynamic> userUpdate =
    <String, dynamic>{'preferences': prefs};
    // WHY split? type error otherwise..
    await ref.updateData(userUpdate);
    return null;
  }
}

class Company extends Model {
  final String name;
  final DateTime dateCreated;
  final CollectionReference _propertiesRef;
  final CollectionReference _tenantsRef;

  Company(DocumentSnapshot snapshot)
      : name = snapshot['name'],
        dateCreated = snapshot['dateCreated'],
        _propertiesRef = snapshot.reference.getCollection('properties'),
        _tenantsRef = snapshot.reference.getCollection('tenants'),
        super(ref: snapshot.reference);

  Stream<List<Property>> get properties =>
      _propertiesRef.snapshots
          .map<List<DocumentSnapshot>>(
              (QuerySnapshot querySnap) => querySnap.documents)
          .map<List<Property>>((List<DocumentSnapshot> docs) =>
          docs
              .map<Property>((DocumentSnapshot doc) =>
              Property.fromSnapshot(doc))
              .toList());

  Stream<QuerySnapshot> get tenants => _tenantsRef.snapshots;
}

class Property extends Model {
  final String name;
  final int unitCount;
  final DocumentReference documentReference;
  CollectionReference _unitsRef;

  // Property({@required this.name, this.unitCount = 0});

  Property.fromSnapshot(DocumentSnapshot snapshot)
      : name = snapshot['name'],
        unitCount = snapshot['unitCount'] ?? 0,
        _unitsRef = snapshot.reference.getCollection('units'),
        documentReference = snapshot.reference,
        super(ref: snapshot.reference);

  Stream<List<Unit>> get units =>
      _unitsRef.snapshots
          .map<List<DocumentSnapshot>>((QuerySnapshot snap) => snap.documents)
          .map<List<Unit>>((List<DocumentSnapshot> docs) =>
          docs
              .map<Unit>((DocumentSnapshot doc) => Unit.fromSnapshot(doc))
              .toList()).map<List<Unit>>((List<Unit> units) {
        units.sort((Unit a, Unit b) =>
            compareAsciiLowerCaseNatural(a.address, b.address));
        return units;
      });

  Future<DocumentReference> addUnit(Map<String, dynamic> data) =>
      _unitsRef.add(data);

  // Stream<Property> toStream() => documentReference.snapshots.

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Property && other.id == id && other.name == name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;

  @override
  String toString() =>
      'Property(id: $id, name: $name, unitCount: $unitCount, _unitsRef: $_unitsRef)';

}

class Unit extends Model {
  final String address;
  DocumentReference _currentLeaseRef;

  Unit({this.address});

  List<String> _searchFields;
  Lease currentLease;

  Unit.fromSnapshot(DocumentSnapshot snapshot)
      : address = snapshot['address'],
        _currentLeaseRef = snapshot['currentLease'],
        super(ref: snapshot.reference) {
    load();
  }

  Unit.copy(Unit u, [String address])
      : address = address ?? u.address,
        _currentLeaseRef = u._currentLeaseRef,
        super(ref: u.ref);

  // TODO put this in abstract model
  Map<String, dynamic> get data => <String, dynamic>{'address': address};

  // Future<Lease> get currentLease => _currentLeaseRef?.get()?.then((DocumentSnapshot snap) => new Lease.fromSnapshot(snap));
  Future<void> load() =>
      _currentLeaseRef?.get()?.then((DocumentSnapshot snap) {
        currentLease = new Lease.fromSnapshot(snap);
      });
}

class Tenant extends Model {
  final String firstName;
  final String lastName;
  final String displayName;

  // TODO think about Lease queries using name-concatenation w/ tenantId
  // String get normalizedName => '${lastName.toLowerCase()}|${firstName.toLowerCase()}';

  Tenant({this.firstName, this.lastName, this.displayName});

  Tenant.fromSnapshot(DocumentSnapshot snapshot)
      : firstName = snapshot['firstName'],
        lastName = snapshot['lastName'],
        displayName = snapshot['displayName'],
        super(ref: snapshot.reference);

  Tenant.fromMap(Map<dynamic, dynamic> map)
      : firstName = map['firstName'],
        lastName = map['lastName'],
  // ,super(snapshot: snapshot)
        displayName = map['displayName'];

}

class Lease extends Model {
  final DocumentReference propertyRef;
  final int rent;
  final int balance;
  Map<dynamic, dynamic> _tenants;
  Map<dynamic, dynamic> _units;

  List<Tenant> loadedTenants;
  List<Unit> loadedUnits;

  // Lease({this.propertyRef, this.unitRef, this.tenants});

  Lease.fromSnapshot(DocumentSnapshot snapshot)
      : propertyRef = snapshot['propertyRef'],
        rent = snapshot['rent'],
        balance = snapshot['balance'],
        _tenants = snapshot['tenants'],
        _units = snapshot['units'],
        super(ref: snapshot.reference) {
    print('Lease constructor');
    print('_tenants=${_tenants.toString()}');
    print('_units=${_units.toString()}');
    print('propertyRef=${propertyRef.toString()}');
    load();
  }

  Future<List<Tenant>> get tenants =>
      Future.wait<Tenant>(
          _tenants.keys.where(
                  (dynamic tenantKey) => _tenants[tenantKey] == true
          ).map(
                  (dynamic tenKey) =>
                  ref.parent.parent.getCollection('tenants').document(
                      tenKey as String)
          ).map((DocumentReference docRef) => docRef.get()
          ).map((Future<DocumentSnapshot> snap) async =>
          new Tenant.fromSnapshot(await snap)));

  Future<List<Unit>> get units =>
      Future.wait<Unit>(
          _units.keys.where(
                  (dynamic unitKey) => _units[unitKey] == true
          ).map(
                  (dynamic unitKey) =>
                  propertyRef.getCollection('units').document(unitKey as String)
          ).map((DocumentReference docRef) {
            print('unit Ref: ${docRef.toString()}');
            return docRef.get();
          }
          ).map((Future<DocumentSnapshot> snap) async =>
          new Unit.fromSnapshot(await snap)));

  Future<Null> load() async {
    final List<dynamic> loads = await Future.wait<dynamic>(<Future<dynamic>>[tenants, units]);
    loadedTenants = loads[0];
    loadedUnits = loads[1];
    return null;
  }

  @override
  String toString() => '''
    Lease(
      id: $id,
      propertyRef: $propertyRef,
      _tenants: $_tenants,
      _units: $_units,
      rent: $rent,
      parent: ${ref.parent.toString()},
    )
  ''';
}

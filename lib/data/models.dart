import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';

abstract class Model {
  const Model({this.snapshot});

  String get id => snapshot?.documentID;

  final DocumentSnapshot snapshot;

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
  })  : _firebaseUser = firebaseUser,
        super(snapshot: userSnap);

  String get email => _firebaseUser.email;

  String get displayName => _firebaseUser.displayName;

  String get photoUrl => _firebaseUser.photoUrl;

  String get uid => _firebaseUser.uid;

  static Future<AppUser> fromFirebaseUser(FirebaseUser user) async {
    if (user == null) {
      return null;
    }
    final DocumentReference _userDataRef = Firestore.instance.collection('users').document(user.uid);
    final DocumentSnapshot userSnap = await _userDataRef.get();

    final String activeCompany = userSnap['activeCompany'];
    final DocumentSnapshot companySnap = await Firestore.instance
        .collection('companies')
        .document(activeCompany)
        .get();
    final Company company = Company(companySnap);

    return AppUser._(firebaseUser: user, userSnap: userSnap, company: company);
  }

  Future<T> getPreference<T>(String key) async {
    final DocumentSnapshot doc = await snapshot.reference.get();
    final Map<dynamic, dynamic> prefs = doc['preferences'];

    final T result = prefs[key];
    return result;
  }

  // TODO test this updates vs overwrites.
  Future<Null> updatePreference(String key, dynamic value) async {
    final DocumentSnapshot doc = await snapshot.reference.get();
    final Map<dynamic, dynamic> prefs = doc['preferences'];

    prefs[key] = value;

    final Map<String, dynamic> userUpdate = <String, dynamic>{'preferences': prefs};
    // WHY split? type error otherwise..
    await snapshot.reference.updateData(userUpdate);
    return null;
  }
}

class Company extends Model {
  final String name;
  final CollectionReference _propertiesRef;
  final CollectionReference _tenantsRef;

  Company(DocumentSnapshot snapshot)
      : name = snapshot['name'],
        _propertiesRef = snapshot.reference.getCollection('properties'),
        _tenantsRef = snapshot.reference.getCollection('tenants'),
        super(snapshot: snapshot);

  Stream<List<Property>> get properties => _propertiesRef.snapshots
      .map<List<DocumentSnapshot>>(
          (QuerySnapshot querySnap) => querySnap.documents)
      .map<List<Property>>((List<DocumentSnapshot> docs) => docs
          .map<Property>((DocumentSnapshot doc) => Property.fromSnapshot(doc))
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
        super(snapshot: snapshot);

  Stream<List<Unit>> get units => _unitsRef.snapshots
      .map<List<DocumentSnapshot>>((QuerySnapshot snap) => snap.documents)
      .map<List<Unit>>((List<DocumentSnapshot> docs) => docs
          .map<Unit>((DocumentSnapshot doc) => Unit.fromSnapshot(doc))
          .toList()).map<List<Unit>>((List<Unit> units) {
            units.sort((Unit a, Unit b) => compareAsciiLowerCaseNatural(a.address, b.address));
            return units;
          });

  Future<DocumentReference> addUnit(Map<String, dynamic> data) => _unitsRef.add(data);
  // Stream<Property> toStream() => documentReference.snapshots.

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Property && other.id == id && other.name == name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;

  @override
  String toString() =>
      'Property(id: $id, name: $name, unitCount: $unitCount, _unitsRef: $_unitsRef)';

}

class Unit extends Model {
  final String address;
  const Unit({this.address});

  Unit.fromSnapshot(DocumentSnapshot snapshot)
      : address = snapshot['address'],
        super(snapshot: snapshot);

  // TODO put this in abstract model
  Map<String, dynamic> get data => <String, dynamic>{'address': address};
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
        super(snapshot: snapshot);

  Tenant.fromMap(Map<String, dynamic> map)
      : firstName = map['firstName'],
        lastName = map['lastName'], // ,super(snapshot: snapshot)
        displayName = map['displayName'];

}

class Lease extends Model {
  final String propertyRef;
  final String unitRef;
  final String unitPath;
  final int rent;
  List<Tenant> tenants;
  Map<String, dynamic> _tenants;
  String propertyUnit;

  // Lease({this.propertyRef, this.unitRef, this.tenants});

  Lease.fromSnapshot(DocumentSnapshot snapshot)
      : propertyRef = snapshot['propertRef'],
        unitRef = snapshot['unitRef'],
        unitPath = snapshot['unitPath'],
        propertyUnit = snapshot['propertyUnit'],
        rent = snapshot['rent'],
        _tenants = snapshot['tenants'],
        super(snapshot: snapshot);

  @override
  String toString() => '''
    Lease(
      id: $id,
      propertyRef: $propertyRef,
      unitRef: $unitRef,
      _tenants: $_tenants,
    )
  ''';
}

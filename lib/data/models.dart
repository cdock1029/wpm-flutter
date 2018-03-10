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
    final DocumentSnapshot userSnap =
        await Firestore.instance.collection('users').document(user.uid).get();
    final String activeCompany = userSnap['activeCompany'];
    final DocumentSnapshot companySnap = await Firestore.instance
        .collection('companies')
        .document(activeCompany)
        .get();
    final Company company = Company(companySnap);

    return AppUser._(firebaseUser: user, userSnap: userSnap, company: company);
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
  final DocumentReference propertyRef;
  final DocumentReference unitRef;
  final int ordering;

  // Property _property;

  const Unit({this.address, this.propertyRef, this.ordering, this.unitRef});

  Unit.fromSnapshot(DocumentSnapshot snapshot)
      : address = snapshot['address'],
        propertyRef = snapshot['propertyRef'],
        ordering = snapshot['ordering'],
        unitRef = snapshot.reference,
        super(snapshot: snapshot);

}

class Tenant extends Model {
  final String firstName;
  final String lastName;

  // TODO think about Lease queries using name-concatenation w/ tenantId
  // String get normalizedName => '${lastName.toLowerCase()}|${firstName.toLowerCase()}';

  Tenant({this.firstName, this.lastName});

  Tenant.fromSnapshot(DocumentSnapshot snapshot)
      : firstName = snapshot['firstName'],
        lastName = snapshot['lastName'],
        super(snapshot: snapshot);

  Tenant.fromMap(Map<String, dynamic> map)
      : firstName = map['firstName'],
        lastName = map['lastName']; // ,super(snapshot: snapshot)

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

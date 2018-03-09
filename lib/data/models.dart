import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
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

  final FirebaseUser firebaseUser;
  AppUser({this.firebaseUser});

  // Company get company => Firestore.instance.collection('companies').document()
}

class UserData extends Model {
  final FirebaseUser firebaseUser;
  UserData({this.firebaseUser});

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

  Stream<QuerySnapshot> get properties => _propertiesRef.snapshots;
  Stream<QuerySnapshot> get tenants => _tenantsRef.snapshots;

/*
  Company.fromSnapshot(DocumentSnapshot snapshot)
      : name = snapshot['name'],
        super(snapshot: snapshot);

  */
}

class Property extends Model {
  final String name;
  final int unitCount;
  CollectionReference unitsRef;
  List<Unit> _units;

  Property({@required this.name, this.unitCount = 0});

  Property.fromSnapshot(DocumentSnapshot snapshot)
      : name = snapshot['name'],
        unitCount = snapshot['unitCount'] ?? 0,
        unitsRef = snapshot.reference.getCollection('units'),
        super(snapshot: snapshot);

//
//  @override
//  call(DocumentSnapshot snap) => new Property.fromSnapshot(snap);

  @override
  String toString() =>
      'Property(id: $id, name: $name, unitCount: $unitCount, unitsRef: $unitsRef)';

//  Future<List<Unit>> get units async {
//    final List<Unit> updated = await getTypedCollection(
//      _units,
//      unitsRef,
//      this,
//      // (DocumentSnapshot snap) => new Unit.fromSnapshot(snap),
//    );
//    _units = updated;
//    return updated;
//  }

// Property withSnap(DocumentSnapshot snap) => new Property.fromSnapshot(snap);
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

//  @override
//  call(DocumentSnapshot snap) => new Unit.fromSnapshot(snap);

//  Future<Property> get property async {
//    if (_property == null) {
//      final DocumentSnapshot propSnap = await propertyRef.get();
//      _property = new Property.fromSnapshot(propSnap);
//    }
//    return _property;
//  }
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

  @override
  Tenant call(DocumentSnapshot snap) => new Tenant.fromSnapshot(snap);
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
  Lease call(DocumentSnapshot snap) => new Lease.fromSnapshot(snap);

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

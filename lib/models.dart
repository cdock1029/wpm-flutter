import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';

abstract class Model {
  const Model({this.snapshot});

  String get id => snapshot?.documentID;

  final DocumentSnapshot snapshot;

  call(DocumentSnapshot snap);

  Future<List<T>> getTypedCollection<T extends Model>(
    List<T> cached,
    CollectionReference collectionRef,
    T instanceCall,// Function getModelInstance,
  ) async =>
      cached != null
          ? new Future<T>.value(cached)
          : await collectionRef.snapshots
              .map((QuerySnapshot querySnap) => querySnap.documents)
              .expand((List<DocumentSnapshot> docSnapList) =>
                  docSnapList.map((DocumentSnapshot snap) => snap))
              .map((DocumentSnapshot snap) => instanceCall(snap))
              .toList();

  // TODO good enough?
  @override
  bool operator ==(Object other) => identical(this, other) || other is Model && other.id == id;

  @override
  int get hashCode => id.hashCode;

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
        unitsRef = snapshot.reference.getCollection('unitsRef'),
        super(snapshot: snapshot);

  @override
  call(DocumentSnapshot snap) => new Property.fromSnapshot(snap);

  @override
  String toString() => 'Property(id: $id, name: $name, unitCount: $unitCount, unitsRef: $unitsRef)';

  Future<List<Unit>> get units async {
    final List<Unit> updated = await getTypedCollection(
      _units,
      unitsRef,
      this,
      // (DocumentSnapshot snap) => new Unit.fromSnapshot(snap),
    );
    _units = updated;
    return updated;
  }

// Property withSnap(DocumentSnapshot snap) => new Property.fromSnapshot(snap);
}

class Unit extends Model {
  final String address;
  final DocumentReference propertyRef;
  // Property _property;

  const Unit({this.address, this.propertyRef});

  Unit.fromSnapshot(DocumentSnapshot snapshot)
      : address = snapshot['address'],
        propertyRef = snapshot['propertyRef'],
        super(snapshot: snapshot);

  @override
  call(DocumentSnapshot snap) => new Unit.fromSnapshot(snap);

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

  Tenant({this.firstName, this.lastName});

  Tenant.fromSnapshot(DocumentSnapshot snapshot)
    : firstName = snapshot['firstName'],
      lastName = snapshot['lastName'],
      super(snapshot: snapshot);

  @override
  call(DocumentSnapshot snap) => new Tenant.fromSnapshot(snap);
}
















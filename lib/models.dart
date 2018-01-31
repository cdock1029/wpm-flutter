import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

abstract class Model {
  String _id;

  String get id => _id;

  Model({String id}) : _id = id;

  T withId<T extends Model>(String id) {
    _id = id;
    return this as T;
  }
}

class Property extends Model {
  String _name;
  int _unitCount;

  String get name => _name;

  int get unitCount => _unitCount;

  Property.fromSnapshot(DocumentSnapshot snapshot)
      : super(id: snapshot.documentID) {
    _name = snapshot['name'] as String;
    _unitCount = (snapshot['unitCount'] as int) ?? 0;
  }
}

class Unit extends Model {
  String _label;
  DocumentReference _propertyRef;
  Property _property;

  Future<Property> get property async {
    if (_property != null) {
      return new Future<Property>.value(_property);
    }
    DocumentSnapshot propSnap = await _propertyRef.get();
    _property = new Property.fromSnapshot(propSnap);
    return _property;
  }

  Unit.fromSnapshot(DocumentSnapshot snap) : super(id: snap.documentID) {
    _label = snap['label'] as String;
    _propertyRef = snap['property'] as DocumentReference;
  }
}

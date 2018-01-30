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

  Property.fromSnapshot(DocumentSnapshot snapshot) : super(id: snapshot.documentID) {
    _name = snapshot['name'] as String;
    _unitCount = (snapshot['unitCount'] as int) ?? 0;
  }
}

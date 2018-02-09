import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_stream_friends/flutter_stream_friends.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter/material.dart';
import 'package:wpm/models.dart';

class ContextGetter {
  BuildContext context;

  ContextGetter();

  BuildContext call() => context;
}

class AppState extends Stream<AppModel> {
  static final Stream<List<Property>> _propertiesStream = Firestore.instance
      .collection('properties')
      .snapshots
      .map((QuerySnapshot querySnap) => querySnap.documents)
      .map((List<DocumentSnapshot> docList) => docList
          .map((DocumentSnapshot docSnap) => new Property.fromSnapshot(docSnap))
          .toList());

  ContextGetter contextGetter;
  PropertyStreamCallback _propertyStreamCallback;

  Stream<AppModel> _internalStream;
  StreamController<AppModel> _streamController;

  AppState(this.contextGetter) {
    _propertyStreamCallback = new PropertyStreamCallback(contextGetter);
    _internalStream = new CombineLatestStream<AppModel>(
      <Stream<List<Property>>>[
        new Observable<Property>(_propertyStreamCallback)
            .map((Property property) => <Property>[property])
            .startWith(<Property>[null]),
        new Observable<List<Property>>(_propertiesStream)
            .startWith(<Property>[])
      ],
      (List<Property> selected, List<Property> properties) => new AppModel(
          selectedProperty: selected[0],
          properties: properties,
          propertyStreamCallback: _propertyStreamCallback),
    );
    _streamController =
        new BehaviorSubject<AppModel>()//TODO does this work? (seedValue:..)
          ..addStream(_internalStream);
  }

  PropertyStreamCallback get propertyStreamCallback => _propertyStreamCallback;

  @override
  StreamSubscription<AppModel> listen(
    void onData(AppModel event), {
    Function onError,
    void onDone(),
    bool cancelOnError,
  }) =>
      _streamController.stream.listen(
        onData,
        onError: onError,
        onDone: onDone,
        cancelOnError: cancelOnError,
      );

  // TODO when?
  Future<Null> close() => _streamController?.close();
}

class AppModel {
  final Property selectedProperty;
  final List<Property> properties;
  final PropertyStreamCallback propertyStreamCallback;

  const AppModel(
      {this.selectedProperty, this.properties, this.propertyStreamCallback});

  factory AppModel.initial() => const AppModel(properties: const <Property>[]);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppModel &&
          selectedProperty == other.selectedProperty &&
          properties == other.properties &&
          propertyStreamCallback == other.propertyStreamCallback;

  @override
  int get hashCode =>
      selectedProperty.hashCode ^ properties.hashCode ^ propertyStreamCallback.hashCode;

  @override
  String toString() => '''
      AppModel{
        selectedProperty: $selectedProperty,
        properties: $properties,
        propertyStreamCallback: $propertyStreamCallback
      }
      ''';
}

class PropertyStreamCallback extends ValueStreamCallback<Property> {
  final ContextGetter getContext;
  static const String propDetailRoute = '/property_detail';

  PropertyStreamCallback(this.getContext);

  @override
  void call(Property p) {
    streamController.add(p);
    Navigator.pushNamed(getContext(), propDetailRoute).then((_) {
      // streamController.add(p);
    });
    // TODO when hitting back button.. "selected property" is still chosen..
  }
}

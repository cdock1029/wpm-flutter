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

class AppModel {
  final Property selectedProperty;
  final List<Property> properties;
  final ValueChanged<Property> onSelectProperty;
  final String createdWhere;

  const AppModel(
      {this.selectedProperty,
      this.properties,
      this.onSelectProperty,
      this.createdWhere});

  factory AppModel.initial() => const AppModel(properties: const <Property>[]);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppModel &&
          selectedProperty == other.selectedProperty &&
          properties == other.properties &&
          onSelectProperty == other.onSelectProperty;

  @override
  int get hashCode =>
      selectedProperty.hashCode ^
      properties.hashCode ^
      onSelectProperty.hashCode;

  @override
  String toString() => '''
      AppModel{
        createdWhere: $createdWhere,
        selectedProperty: $selectedProperty,
        properties: $properties,
        onSelectProperty: $onSelectProperty
      }
      ''';
}

class AppModelStream extends Stream<AppModel> {
  final Stream<AppModel> _stream;
  final ContextGetter getContext;

  AppModelStream([
    this.getContext,
    ValueStreamCallback<Property> onPropertySelected,
    Property initial,
  ])
      : this._stream = createStream(
          // this is a *callable* class...
          onPropertySelected ?? new PropertyStreamCallback(getContext),
          initial,
        );

  static final Stream<List<Property>> _propertiesStream = Firestore.instance
      .collection('properties')
      .snapshots
      .map((QuerySnapshot querySnap) => querySnap.documents)
      .map((List<DocumentSnapshot> docList) => docList
          .map((DocumentSnapshot docSnap) => new Property.fromSnapshot(docSnap))
          .toList());

  @override
  StreamSubscription<AppModel> listen(
    void onData(AppModel event), {
    Function onError,
    void onDone(),
    bool cancelOnError,
  }) =>
      _stream.listen(onData,
          onError: onError, onDone: onDone, cancelOnError: cancelOnError);

  static Stream<AppModel> createStream(
    PropertyStreamCallback onPropertySelected,
    Property initialValue,
  ) =>
      new CombineLatestStream<AppModel>(
        <Stream<List<Property>>>[
          new Observable<Property>(onPropertySelected)
              .map((Property property) => <Property>[property])
              .startWith(<Property>[initialValue]),
          new Observable<List<Property>>(_propertiesStream)
              .startWith(<Property>[]),
        ],
        // TODO hack to have same stream types?
        (List<Property> selected, List<Property> properties) => new AppModel(
            createdWhere: 'CombineLatestStream CALLBACK',
            selectedProperty: selected[0],
            properties: properties,
            onSelectProperty: onPropertySelected),
      ).asBroadcastStream(onListen: ((StreamSubscription<AppModel> sub) => print('onListen sub=[$sub]')));
}

class PropertyStreamCallback extends ValueStreamCallback<Property> {
  final ContextGetter getContext;
  static const String propDetailRoute = '/property_detail';

  PropertyStreamCallback(this.getContext);

  @override
  void call(Property p) {
    Navigator.pushNamed(getContext(), propDetailRoute);
    streamController.add(p);
  }
}

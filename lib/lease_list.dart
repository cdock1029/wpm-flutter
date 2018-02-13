import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wpm/models.dart';

class LeaseList extends StatelessWidget {
  static const String propertyRefKey = 'propertyRef';
  static const String unitRefKey = 'unitRef';

  final DocumentReference propertyRef;
  final DocumentReference unitRef;
  final Tenant tenant;

  Query leases;

  LeaseList({this.propertyRef, this.unitRef, this.tenant}) {
    /*leases = Firestore.instance.collection('leases');
    if (tenant != null) {
      final String tenantKey = 'tenants.${tenant.id}';
      leases = leases.where(tenantKey, isGreaterThan: 0).orderBy(tenantKey);
    } else {
      if (propertyRef != null) {
        leases = leases.where(propertyRefKey, isEqualTo: propertyRef);
        print('leases=[$leases]');
      }
      if (unitRef != null) {
        leases = leases.where(unitRefKey, isEqualTo: unitRef);
      }
    }*/
  }

  @override
  Widget build(BuildContext context) => new Container(
        padding: const EdgeInsets.all(16.0),
        child: new StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance.collection('leases').snapshots,
          builder: (
            BuildContext context,
            AsyncSnapshot<QuerySnapshot> streamSnap,
          ) {
            if (streamSnap.hasData) {
              final QuerySnapshot querySnap = streamSnap.data;
              final List<DocumentSnapshot> docs = querySnap.documents;
              return new ListView.builder(
                itemCount: docs.length,
                itemBuilder: (BuildContext context, int index) {
                  final DocumentSnapshot lease = docs[index];
                  final String propertyUnit = (lease['propertyUnit'] as String).split('|')[1];
                  return new ListTile(
                    title: new Text('address: ${propertyUnit[1]}'),
                    subtitle: new Text('tenants: ${lease['tenants'].toString()}'),
                  );
                },
              );
            } else if (streamSnap.hasError) {
              return const Text('Error..');
            } else {
              return const Text('Loading or.. Data is null....');
            }
          },
        ),
      );
}

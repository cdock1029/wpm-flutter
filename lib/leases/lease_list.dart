import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wpm/models.dart';

class LeaseList extends StatelessWidget {
  static const String propertyRefKey = 'propertyRef';
  static const String unitRefKey = 'unitRef';

  // TODO: theses are *STRINGS*, temporary hack until DocumentReference is supported..
  final /*DocumentReference*/ String propertyRef;
  final /*DocumentReference*/ String unitRef;
  final Tenant tenant;

  Query leases;

  LeaseList({this.propertyRef, this.unitRef, this.tenant}) {
    leases = Firestore.instance.collection('leases');
    if (tenant != null) {
      final String tenantKey = 'tenants.${tenant.id}';
      leases = leases.where(tenantKey, isGreaterThan: 0).orderBy(tenantKey);
    } else {
      if (propertyRef != null) {
        leases = leases.where(propertyRefKey, isEqualTo: propertyRef);
      }
      if (unitRef != null) {
        leases = leases.where(unitRefKey, isEqualTo: unitRef);
      }
    }
    // print('LeaseList(propertyRef: $propertyRef, unitRef: $unitRef, tenant: $tenant)\nleases=[${leases.buildArguments().toString()}]');
  }

  @override
  Widget build(BuildContext context) => new Container(
        padding: const EdgeInsets.all(16.0),
        child: new StreamBuilder<QuerySnapshot>(
          stream: leases.snapshots,
          builder: (
            BuildContext context,
            AsyncSnapshot<QuerySnapshot> streamSnap,
          ) {
            if (streamSnap.hasData) {
              final List<DocumentSnapshot> docs = streamSnap.data.documents;
              return new ListView.builder(
                itemCount: docs.length + 1,
                itemBuilder: (BuildContext context, int index) {
                  if (index == 0) {
                    return new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        const Text('UNITS'),
                        const Text('TENANTS')
                      ],
                    );
                  }
                  final DocumentSnapshot lease = docs[index - 1];
                  return new LeaseListTile(
                    key: new Key(lease.documentID),
                    lease: lease,
                  );
                },
              );
            } else {
              return const Text('Loading or.. Data is null....');
            }
          },
        ),
      );
}

class LeaseListTile extends StatelessWidget {
  final DocumentSnapshot lease;
  final Map<String, Map<String, String>> tenants;
  Iterable<String> tenantList;

  LeaseListTile({
    this.lease,
    Key key,
  })
      : tenants = lease['tenants'],
        super(key: key) {
    tenantList = tenants.values
        .map<String>((Map<String, String> tenantObj) => tenantObj['name']);
  }

  @override
  Widget build(BuildContext context) {
    final String unit = lease['propertyUnit'].split('|')[1];

    return new Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        new Text(unit),
        new Column(
          children:
              tenantList.map((String tenant) => new Text(tenant)).toList(),
        ),
      ],
    );
  }
}

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wpm/data/models.dart';
import 'package:wpm/modules/tenants/tenant_add.dart';

class TenantList extends StatelessWidget {
  const TenantList({Key key}) : super(key: key);

  static const String routeName = '/tenants';

  @override
  Widget build(BuildContext context) => new StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection('tenants').snapshots,
        builder: (
          BuildContext context,
          AsyncSnapshot<QuerySnapshot> streamSnap,
        ) {
          Widget body;
          if (!streamSnap.hasData) {
            body = const Text('Loading..');
          } else {
            body = new Column(
              children: <Widget>[
                new Container(
                  padding: const EdgeInsets.all(16.0),
                  child: new Text(
                    'Placeholder for filters and such..',
                    style: Theme.of(context).textTheme.headline,
                  ),
                  margin: const EdgeInsets.only(top: 16.0),
                ),
                new Flexible(
                  flex: 1,
                  child: new ListView.builder(
                    itemCount: streamSnap.data.documents.length,
                    itemBuilder: (
                      BuildContext context,
                      int index,
                    ) {
                      final List<DocumentSnapshot> docs =
                          streamSnap.data.documents;
                      final Tenant tenant =
                          new Tenant.fromSnapshot(docs[index]);
                      final ListTile tile = new ListTile(
                        title:
                            new Text('${tenant.lastName}, ${tenant.firstName}'),
                        trailing: new CurrentLeaseSegment(
                          tenantId: tenant.id,
                        ),
                        onLongPress: () {
                          showDialog<Null>(
                            context: context,
                            child: new AlertDialog(
                              content: new Text(
                                  'Delete Tenant "${tenant.lastName}, ${tenant
                                      .firstName}" ?'),
                              actions: <Widget>[
                                new FlatButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('CANCEL'),
                                ),
                                new FlatButton(
                                  onPressed: () async {
                                    await docs[index].reference.delete();
                                    Navigator.pop(context);
                                  },
                                  child: const Text('DELETE'),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                      return tile;
                    },
                  ),
                  fit: FlexFit.loose,
                ),
              ],
            );
          }
          return new Scaffold(
            key: const Key('tenant_scaffold'),
            appBar: new AppBar(
              key: const Key('tenant_app_bar'),
              title: const Text('Tenants'),
            ),
            body: body,
            floatingActionButton: new FloatingActionButton(
              child: new Center(
                child: new Icon(Icons.add),
              ),
              onPressed: () {
                Navigator.pushNamed(context, AddTenant.routeName);
              },
            ),
          );
        },
      );
}

class CurrentLeaseSegment extends StatelessWidget {
  final String tenantId;
  final Stream<Lease> stream;

  CurrentLeaseSegment({this.tenantId})
      : stream = Firestore.instance
            .collection('leases')
            .where('tenants.$tenantId.startTime', isGreaterThan: 0)
            .orderBy('tenants.$tenantId.startTime', descending: true)
            .limit(1)
            .snapshots
            .map<List<Lease>>(_convert)
            .map<Lease>((List<Lease> leases) => leases[0]);

  static List<Lease> _convert(QuerySnapshot querySnap) => querySnap.documents
      .map<Lease>((DocumentSnapshot doc) => new Lease.fromSnapshot(doc))
      .toList();

  @override
  Widget build(BuildContext context) => new StreamBuilder<Lease>(
        stream: stream,
        builder: (
          BuildContext context,
          AsyncSnapshot<Lease> snap,
        ) =>
            new Row(
              children: <Widget>[
                new Text(snap.data?.propertyUnit ?? 'no data')
              ],
            ),
      );
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wpm/models.dart';

class TenantList extends StatelessWidget {

  const TenantList({Key key}) : super(key: key);

  static const String routeName = '/tenants';
  @override
  Widget build(BuildContext context) => new StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection('tenants').snapshots,
        builder:
            (BuildContext context, AsyncSnapshot<QuerySnapshot> streamSnap) {
          Widget body;
          if (!streamSnap.hasData) {
            body = const Text('Loading..');
          } else {
            body = new Column(
              children: <Widget>[
                new Container(
                  color: Colors.tealAccent,
                  padding: const EdgeInsets.all(16.0),
                  child: new Text(
                    'TENANT LIST',
                    style: Theme.of(context).textTheme.headline,
                  ),
                ),
                new Flexible(
                  flex: 1,
                  child: new ListView.builder(
                    itemCount: streamSnap.data.documents.length,
                    itemBuilder: (BuildContext context, int index) {
                      print('ListView builder index=[${index.toString()}]');

                      final List<DocumentSnapshot> docs =
                          streamSnap.data.documents;
                      final Tenant tenant =
                          new Tenant.fromSnapshot(docs[index]);
                      final ListTile tile = new ListTile(
                        title:
                            new Text('${tenant.lastName}, ${tenant.firstName}'),
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
            body: new Center(
              child: new SizedBox(width: 600.0, child: body),
            ),
          );
        },
      );
}

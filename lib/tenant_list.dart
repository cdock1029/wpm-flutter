import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wpm/models.dart';
import 'package:wpm/tenant_add.dart';

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
                        trailing: new FlatButton(
                          onPressed: () {
                            print('pressed ${tenant.id}');
                          },
                          child: const Text('EDIT'),
                        ),
                        onLongPress: () {
                          showDialog(
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

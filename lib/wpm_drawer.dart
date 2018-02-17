import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wpm/add_property.dart';
import 'package:wpm/app_state.dart';
import 'package:wpm/models.dart';
import 'package:wpm/tenant_add.dart';
import 'package:wpm/tenant_list.dart';

//class WPMDrawerContainer extends StatefulWidget {
//  @override
//  _WPMDrawerState createState() => new _WPMDrawerState();
//}
//
//class _WPMDrawerState extends State<WPMDrawerContainer> {
//
//}

class WPMDrawerView extends StatelessWidget {
  /*
  Header
  Add Property
  Add Tenant
  Tenants
  Divider
  Label
  [items]
  */
  static const int extraTileCount = 6;
  final AppState appState;

  // final Widget _header = const DrawerHeader(child: const Text('Drawer Header'));

  const WPMDrawerView(this.appState);

  @override
  Widget build(BuildContext context) => new StreamBuilder<AppModel>(
        stream: appState,
        initialData: new AppModel.initial(),
        builder: (
          BuildContext context,
          AsyncSnapshot<AppModel> snap,
        ) =>
            new Drawer(
              child: new ListView.builder(
                  // gets rid of light-colored top bar..
                  padding: const EdgeInsets.only(top: 0.0),
                  itemCount: snap.data.properties.length + extraTileCount,
                  itemBuilder: (BuildContext ctx, int index) {
                    /* DRAWER HEADER index: 0 */
                    if (index == 0) {
                      return new UserAccountsDrawerHeader(
                        accountName: const Text('Conor Dockry'),
                        accountEmail: const Text('conordockry@gmail.com'),
                        currentAccountPicture: new CircleAvatar(
                          backgroundColor: Theme.of(context).accentColor,
                          child: new Text('cd'.toUpperCase()),
                        ),
                        decoration: new BoxDecoration(
                          gradient: new LinearGradient(
                            colors: <Color>[
                              Theme.of(ctx).primaryColor,
                              Theme.of(ctx).accentColor,
                            ],
                          ),
                        ),
                      );
                    }
                    /* ADD PROPERTY TILE */
                    if (index == 1) {
                      return new ListTile(
                        key: const Key('add_property'),
                        dense: true,
                        leading: const Icon(Icons.add),
                        selected: true,
                        title: const Text('ADD PROPERTY'),
                        onTap: () async {
                          // TODO look into popping values back, when that's better.. (creating here vs in added route..)
                          final Property newProperty =
                              await Navigator.pushNamed(ctx, AddProperty.routeName);
                          if (newProperty != null) {
                            print(
                                'after pop, property is not null: name=[${newProperty
                                .name}]');
                            appState.propertyStreamCallback(newProperty);
                            Navigator.pop(ctx);
                          }
                        },
                      );
                    }
                    if (index == 2) {
                      return new ListTile(
                        key: const Key('add_tenant'),
                        dense: true,
                        leading: const Icon(Icons.add),
                        title: const Text('ADD TENANT'),
                        onTap: () {
                          Navigator.pushNamed(ctx, AddTenant.routeName);
                        }
                      );
                    }
                    if (index == 3) {
                      return new ListTile(
                        key: const Key('tenant_list'),
                        dense: true,
                        leading: const Icon(Icons.people),
                        title: const Text('TENANTS'),
                        onTap: () {
                          Navigator.popAndPushNamed(ctx, TenantList.routeName);
                        },
                      );
                    }
                    /* DIVIDER */
                    if (index == 4) {
                      return const Divider();
                    }
                    /* LABEL */
                    if (index == 5) {
                      return new ListTile(
                        dense: true,
                        key: const Key('properties_label'),
                        title: new Text(
                          'Properties',
                          style: Theme.of(ctx).textTheme.caption,
                        ),
                      );
                    }
                    final Property property = snap.data.properties[index - extraTileCount];
                    return new ListTile(
                      key: new Key(property.id),
                      /*leading: new CircleAvatar(
                        child: new Text(property.name.substring(0, 1)),
                      ),*/
                      selected: snap.data.selectedProperty == property,
                      leading: new Icon(Icons.home),
                      title: new Text(property.name),
                      dense: true,
                      onTap: () {
                        appState.propertyStreamCallback(property);
                        Navigator.pop(ctx);
                      },
                      onLongPress: () async {
                        final bool shouldDelete = await showDialog<bool>(
                          context: context,
                          barrierDismissible: false,
                          child: new AlertDialog(
                            title: const Text('Delete Property'),
                            content: new Text(
                                'Are you sure you want to delete property: "${property
                                .name}"'),
                            actions: <Widget>[
                              new FlatButton(
                                child: const Text('DELETE'),
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                textColor: Colors.white,
                                color: Theme.of(ctx).errorColor,
                              ),
                              new FlatButton(
                                child: const Text('CANCEL'),
                                onPressed: () =>
                                    Navigator.of(ctx).pop(false),
                                textColor: Colors.black45,
                              ),
                            ],
                          ),
                        );
                        //print('Alert Dialog result shouldDelete=[$shouldDelete]');
                        if (shouldDelete) {
                          // TODO use cloud functions to throw error if property has any sub-data..
                          // or refactor to check this on client..
                          // too many steps.. prob easier on server..
                          await Firestore.instance.document('/properties/${property.id}').delete();
                        }
                      },
                    );
                  }),
            ),
      );
}

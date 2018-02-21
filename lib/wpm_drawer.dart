import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wpm/add_property.dart';
import 'package:wpm/models.dart';
import 'package:wpm/property_state.dart';
import 'package:wpm/tenant_list.dart';

class WPMDrawerView extends StatelessWidget {
  /*
  Header
  Tenants
  Divider
  Label / Add Property Button
  [items]
  */
  static const int extraTileCount = 4;

  const WPMDrawerView();

  @override
  Widget build(BuildContext context) {
    final AppState appState = AppState.of(context);

    final List<Property> properties = appState.properties;
    final Property selected = appState.selected;
    final ValueChanged<Property> selectProperty = appState.selectProperty;

    return new Drawer(
              child: new ListView.builder(
                  // gets rid of light-colored top bar..
                  padding: const EdgeInsets.only(top: 0.0),
                  itemCount: properties.length + extraTileCount,
                  itemBuilder: (BuildContext context, int index) {
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
                              Theme.of(context).primaryColor,
                              Theme.of(context).accentColor,
                            ],
                          ),
                        ),
                      );
                    }
                    /* TENANTS Route */
                    if (index == 1) {
                      return new ListTile(
                        key: const Key('tenant_list'),
                        dense: true,
                        leading: const Icon(Icons.people),
                        title: const Text('TENANTS'),
                        onTap: () {
                          Navigator.popAndPushNamed(
                              context, TenantList.routeName);
                        },
                      );
                    }
                    /* DIVIDER */
                    if (index == 2) {
                      return const Divider();
                    }
                    /* LABEL */
                    if (index == 3) {
                      return new ListTile(
                        dense: false,
                        key: const Key('properties_label'),
                        title: new Text(
                          'Properties',
                          style: Theme.of(context).textTheme.caption,
                        ),
                        trailing: new IconButton(
                          icon: const Icon(Icons.create),
                          color: Theme.of(context).accentColor,
                          onPressed: () async {
                            // TODO look into popping values back, when that's better.. (creating here vs in added route..)
                            final Property newProperty = await Navigator
                                .pushNamed(context, AddProperty.routeName);
                            if (newProperty != null) {
                              print(
                                  'after pop, property is not null: name=[${newProperty
                                  .name}]');
                              selectProperty(newProperty);
                              Navigator.pop(context);
                            }
                          },
                        ),
                      );
                    }
                    final Property property =
                        properties[index - extraTileCount];
                    return new ListTile(
                      key: new Key(property.id),
                      /*leading: new CircleAvatar(
                        child: new Text(property.name.substring(0, 1)),
                      ),*/
                      selected: selected == property,
                      leading: new Icon(Icons.home),
                      title: new Text(property.name),
                      dense: true,
                      onTap: () {
                        selectProperty(property);
                        Navigator.pop(context);
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
                                color: Theme.of(context).errorColor,
                              ),
                              new FlatButton(
                                child: const Text('CANCEL'),
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
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
                          await Firestore.instance
                              .document('/properties/${property.id}')
                              .delete();
                        }
                      },
                    );
                  }),
      );
  }
}

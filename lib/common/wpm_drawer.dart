import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:wpm/modules/properties/add_edit_property.dart';
import 'package:wpm/data/models.dart';
import 'package:wpm/data/app_state.dart';
import 'package:wpm/modules/properties/property_dashboard.dart';
import 'package:wpm/modules/tenants/tenant_list.dart';

class WPMDrawerLoader extends StatelessWidget {
  const WPMDrawerLoader();
  @override
  Widget build(BuildContext context) {
    final Stream<List<Property>> propertiesStream = AppStateProvider.of(context).propertiesStream;
    return StreamBuilder<List<Property>>(
      stream: propertiesStream,
      initialData: <Property>[],
      builder: (
        BuildContext context,
        AsyncSnapshot<List<Property>> snapshot,
      ) {
        if (snapshot.hasData) {
          return _WPMDrawerView(snapshot.data);
        } else {
          return Text('why no data?');
        }
      },
    );
  }
}

class _WPMDrawerView extends StatefulWidget {
  /*
  Header
  Tenants
  Divider
  Label / Add Property Button
  [items]
  */
  const _WPMDrawerView(this.properties);
  final List<Property> properties;

  @override
  _WPMDrawerViewState createState() => new _WPMDrawerViewState();
}

class _WPMDrawerViewState extends State<_WPMDrawerView> {
  static const int extraTileCount = 4;
  bool _showSignOut = false;

  void _toggleShowSignOut() {
    setState(() {
      _showSignOut = !_showSignOut;
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppState appState = AppStateProvider.of(context);
    final AppUser user = appState.user;
    final Stream<Property> selectedPropertyStream = appState.selectedPropertyStream;
    final ValueChanged<Property> selectProperty = appState.selectProperty;

    return StreamBuilder<Property>(
      stream: selectedPropertyStream,
      builder: (
        BuildContext context,
        AsyncSnapshot<Property> snapshot,
      ) {
        final Property selectedProperty = snapshot.data;
        return new Drawer(
            child: new ListView.builder(
                // gets rid of light-colored top bar..
                padding: const EdgeInsets.only(top: 0.0),
                itemCount: _showSignOut
                    ? 2
                    : widget.properties.length + extraTileCount,
                itemBuilder: (BuildContext context, int index) {
                  /* DRAWER HEADER index: 0 */
                  if (index == 0) {
                    return DrawerHeader(user: user, toggleShowSignOut: _toggleShowSignOut);
                  }
                  if (_showSignOut) {
                    return SignOutTile();
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
                        onPressed: () {
                          Navigator.pushNamed(
                              context, AddEditProperty.routeName);
                        },
                      ),
                    );
                  }
                  final Property property = widget.properties[index - extraTileCount];
                  print('selectedProperty.id=[${selectedProperty?.id}], property.id=[${property.id}]');
                  return new ListTile(
                    key: new Key(property.id),
                    /*leading: new CircleAvatar(
                          child: new Text(property.name.substring(0, 1)),
                        ),*/
                    selected: selectedProperty?.id == property.id,
                    leading: new Icon(Icons.home),
                    title: new Text(property.name),
                    dense: true,
                    onTap: () async {
                      Navigator.pop(context);
                      // see Drawer kBaseSettleDuration (246 ms), wait for close animation
                      // ignore: strong_mode_implicit_dynamic_type, always_specify_types
                      await Future.delayed(Duration(milliseconds: 255));
                      selectProperty(property);
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
                              onPressed: () => Navigator.of(context).pop(true),
                              textColor: Colors.white,
                              color: Theme.of(context).errorColor,
                            ),
                            new FlatButton(
                              child: const Text('CANCEL'),
                              onPressed: () => Navigator.of(context).pop(false),
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
                            .collection('companies')
                            .document(user.company.id)
                            .getCollection('properties')
                            .document(property.id)
                            .delete();
                      }
                    },
                  );
                }),
          );
      },
    );
  }
}

class DrawerHeader extends StatelessWidget {
  const DrawerHeader({@required this.user, @required this.toggleShowSignOut});

  final AppUser user;
  final VoidCallback toggleShowSignOut;

  @override
  Widget build(BuildContext context) => UserAccountsDrawerHeader(
      accountName: new Text(user.displayName),
      accountEmail: new Text(user.email),
      currentAccountPicture: new CircleAvatar(
        backgroundImage: user.photoUrl != null
            ? new NetworkImage(user.photoUrl)
            : null,
        backgroundColor: Theme.of(context).accentColor,
        child: user.photoUrl == null
            ? new Text(
            user.displayName.substring(0, 1).toUpperCase())
            : null,
      ),
      decoration: new BoxDecoration(
        gradient: new LinearGradient(
          colors: <Color>[
            Theme.of(context).primaryColor,
            Theme.of(context).accentColor,
          ],
        ),
      ),
      onDetailsPressed: toggleShowSignOut,
    );
}

class SignOutTile extends StatelessWidget {
  const SignOutTile();
  @override
  Widget build(BuildContext context) => new ListTile(
      dense: true,
      leading: new Icon(Icons.time_to_leave),
      title: const Text('Sign out'),
      onTap: () async {
        await FirebaseAuth.instance.signOut();
      },
    );
}



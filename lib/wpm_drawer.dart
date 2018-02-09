import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wpm/app_state.dart';
import 'package:wpm/models.dart';

//class WPMDrawerContainer extends StatefulWidget {
//  @override
//  _WPMDrawerState createState() => new _WPMDrawerState();
//}
//
//class _WPMDrawerState extends State<WPMDrawerContainer> {
//
//}

class WPMDrawerView extends StatelessWidget {
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
                  itemCount: snap.data.properties.length + 3, // items + header + Add Property + Divider
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
                        key: const Key('add_new'),
                        dense: true,
                        leading: const Icon(Icons.add),
                        selected: true,
                        title: const Text('ADD PROPERTY'),
                        onTap: () async {
                          // TODO look into popping values back, when that's better.. (creating here vs in added route..)
                          final Property newProperty = await Navigator.popAndPushNamed(ctx, '/add_property');
                          if (newProperty != null) {
                            print('after pop, property is not null: name=[${newProperty.name}]');
                            appState.propertyStreamCallback(newProperty);
                            Navigator.pop(ctx);
                          }
                        },
                      );
                    }
                    /* DIVIDER */
                    if (index == 2) {
                      return const Divider();
                    }
                    final Property property = snap.data.properties[index - 3];
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
                    );
                  }),
            ),
      );
}

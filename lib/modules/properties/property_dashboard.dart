import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wpm/data/models.dart';
import 'package:wpm/data/app_state.dart';
import 'package:wpm/modules/company/company_dashboard.dart';
import 'package:wpm/modules/properties/add_edit_property.dart';
import 'package:wpm/common/wpm_drawer.dart';
import 'package:wpm/modules/units/units_tab.dart';

class PropertyDashboard extends StatelessWidget {
  const PropertyDashboard();

  static const String routeName = 'property_dashboard';

  @override
  Widget build(BuildContext context) {
    final Stream<Property> selectedStream =
        AppStateProvider.of(context).selectedPropertyStream;
    return new StreamBuilder<Property>(
      stream: selectedStream,
      builder: (
        BuildContext context,
        AsyncSnapshot<Property> streamSnap,
      ) {
        if (streamSnap.connectionState == ConnectionState.waiting) {
          return new CircularProgressIndicator();
        }
        final Property selected = streamSnap.data;
        final List<Widget> children = <Widget>[
          new UnitsTab(property: selected),
          new LeasesTab(),
        ];
        return new DefaultTabController(
          length: 2,
          child: new Scaffold(
            key: new Key('property_detail'),
            appBar: new AppBar(
              title: new Text(selected.name),
              actions: <Widget>[
                new IconButton(
                  icon: new Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                        context,
                        new MaterialPageRoute<Null>(
                          builder: (BuildContext context) =>
                              new AddEditProperty(property: selected),
                        ));
                  },
                ),
              ],
              bottom: new TabBar(
                isScrollable: false,
                tabs: <Widget>[new Tab(text: 'UNITS'), new Tab(text: 'LEASES')],
              ),
            ),
            body: new TabBarView(children: children),
            drawer: new WPMDrawerLoader(),
          ),
        );
      },
    );
  }
}

class LeasesTab extends StatelessWidget {
  const LeasesTab();

  @override
  Widget build(BuildContext context) {
    final Stream<List<Lease>> leasesStream =
        AppStateProvider.of(context).leasesForSelectedPropertyStream;
    return new StreamBuilder<List<Lease>>(
      stream: leasesStream,
      builder: (
        BuildContext context,
        AsyncSnapshot<List<Lease>> snapshot,
      ) {
        if (!snapshot.hasData) {
          return new Center(
            child: new CircularProgressIndicator(),
          );
        }
        if (snapshot.data.isEmpty) {
          return new Center(
            child: new Text('Property has no leases.'),
          );
        }
        return ListView.builder(
          itemCount: snapshot.data.length,
          itemBuilder: (
            BuildContext context,
            int index,
          ) {
            final Lease lease = snapshot.data[index];
            return new Column(
              children: <Widget>[
                new FutureBuilder<List<Tenant>>(
                  future: lease.tenants,
                  initialData: <Tenant>[],
                  builder: (
                    BuildContext context,
                    AsyncSnapshot<List<Tenant>> snapshot,
                  ) {
                    final List<Tenant> tenants = snapshot.data;
                    return new Row(children: tenants.map<Widget>((Tenant t) => new Text('${t.lastName}, ${t.firstName}')).toList(),);
                  },
                ),
                new FutureBuilder<List<Unit>>(
                  future: lease.units,
                  initialData: <Unit>[],
                  builder: (
                    BuildContext context,
                    AsyncSnapshot<List<Unit>> snapshot,
                  ) {
                    if (!snapshot.hasData) {
                      return new Row(children: <Widget>[new Text('.. no unit data')],);
                    }
                    final List<Unit> units = snapshot.data;
                    return new Row(children: units.map<Widget>((Unit u) => new Text('${u.address}')).toList(),);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class LeaseTabTile extends StatelessWidget {
  final Lease lease;

  const LeaseTabTile(this.lease);

  @override
  Widget build(BuildContext context) {
//    return new FutureBuilder<List<>(
//      // initialData: <>[],
//      builder: (
//        BuildContext context,
//        AsyncSnapshot<List<List<Model>>> snapshot,
//      ) {
//        //final List<Tenant> tenants = snapshot.data;
//        return new Column(
//          children: <Widget>[
//            new ListTile(title: new Text('Unit:'), subtitle: new Text(),
//            new ListTile(title: new Text('Tenants:'), subtitle: new Text(tenants.map((Tenant t) => t.firstName).join(', ')),),
//          ],
//        );
//      },
//    );
  }
}

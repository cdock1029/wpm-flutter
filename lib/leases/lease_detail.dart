import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

final List<String> _items = <String>[
  'transaction 1',
  'transaction 2',
  'transaction 3',
  'transaction 4',
  'transaction 5',
  'transaction 6',
  'transaction 7',
  'transaction 8',
  'transaction 9',
  'transaction 10',
  'transaction 11',
  'transaction 12',
];

class LeaseDetail extends StatefulWidget {
  const LeaseDetail();

  static const String routeName = '/lease_detail';

  @override
  _LeaseDetailState createState() => new _LeaseDetailState();
}

class _LeaseDetailState extends State<LeaseDetail> {
  @override
  Widget build(BuildContext context) => new Scaffold(
      appBar: new AppBar(
        title: const Text('Unit: A101 Tenant: Smit, John'),
      ),
      body: new Container(
        padding: const EdgeInsets.all(8.0),
        child: new ListView(
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            const LeaseDetailHeader(),
            const ControlSection(),
            new LeaseDetailBottomSection(),

            /*
            const Flexible(
              child: const LeaseDetailHeader(),
              flex: 1,
              fit: FlexFit.loose,
            ),
            const Expanded(
              child: const ControlSection(),
              flex: 4,
              // fit: FlexFit.tight,
            ),
            new Flexible(
              flex: 1,
              fit: FlexFit.loose,
              child: new LeaseDetailBottomSection(),
            ),*/
          ],
        ),
      ));
}

class LeaseDetailBottomSection extends StatefulWidget {
  @override
  _LeaseDetailBottomSectionState createState() =>
      new _LeaseDetailBottomSectionState();
}

class _LeaseDetailBottomSectionState extends State<LeaseDetailBottomSection> {
  @override
  Widget build(BuildContext context) => new ExpansionTile(
    title: const Text('Transactions'),
    children: _items
        .map((String s) => new ListTile(title: new Text(s)))
        .toList(),
  );
}

class LeaseDetailHeader extends StatefulWidget {
  const LeaseDetailHeader();

  @override
  LeaseDetailHeaderState createState() => new LeaseDetailHeaderState();
}

class LeaseDetailHeaderState extends State<LeaseDetailHeader> {
  @override
  Widget build(BuildContext context) => new ExpansionTile(
    title: new Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: new Row(
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        // mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          const Flexible(
            child: const ListTile(
              dense: true,
              leading: const Icon(Icons.home),
              title: const Text('A101'),
              subtitle: const Text('Columbiana Manor'),
            ),
          ),
          const Flexible(
            child: const ListTile(
              dense: true,
              leading: const Icon(Icons.people),
              title: const Text('Smith, John'),
              subtitle: const Text('Smith, Jane'),
            ),
          ),
        ],
      ),
    ),
    children: <Widget>[
      new Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          const Flexible(
            child: const ListTile(
              dense: true,
              leading: const Icon(Icons.calendar_today),
              subtitle: const Text('Start Date'),
              title: const Text('2017-07-04'),
            ),
          ),
          const Flexible(
            child: const ListTile(
              dense: true,
              leading: const Icon(Icons.calendar_today),
              subtitle: const Text('End Date'),
              title: const Text('2018-07-03'),
            ),
          ),
        ],
      ),
      const ListTile(
        dense: true,
        leading: const Icon(Icons.attach_money),
        subtitle: const Text('Rent'),
        title: const Text('550.00'),
      ),
    ],
  );
}

class ControlSection extends StatefulWidget {
  const ControlSection();
  @override
  _ControlSectionState createState() => new _ControlSectionState();
}

class _ControlSectionState extends State<ControlSection> {
  @override
  Widget build(BuildContext context) => new ExpansionTile(
    initiallyExpanded: true,
    leading: const Icon(Icons.edit),
    title: const Text('Actions'),
    children: <Widget>[
        new ListTile(leading: const Text('Balance:'), title: const Text('799.43'),),
        new ListTile(leading: const Text('Balance:'), title: const Text('799.43'),),
        new ListTile(leading: const Text('Balance:'), title: const Text('799.43'),),
        new ListTile(leading: const Text('Balance:'), title: const Text('799.43'),),
        new Container(child: const Text('fill me in'),),
        new Container(child: const Text('fill me in'),),
        new Container(child: const Text('fill me in'),),
        new Container(child: const Text('fill me in'),),
      ],
  );
}


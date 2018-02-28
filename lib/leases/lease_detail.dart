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
  List<bool> _expands = <bool>[false, true, false, false];

  void _onExpanded(int index, bool previous) {
    print('index=[$index], previous=[$previous]');
    final List<bool> _temp = new List<bool>.from(_expands);
    _temp[index] = !previous;
    setState(() {
      _expands = _temp;
    });
  }

  @override
  Widget build(BuildContext context) => new Scaffold(
      appBar: new AppBar(
        title: const Text('A101 Smith, John'),
      ),
      body: new ListView(padding: const EdgeInsets.all(8.0), children: <Widget>[
        // heading
        new Container(
          child: new Text('Details', style: Theme.of(context).textTheme.subhead,),
          margin: const EdgeInsets.fromLTRB(
            4.0,
            12.0,
            0.0,
            8.0,
          ),
        ),

        // simplest, cleanest ?
        new Card(
          child: new Builder(
            builder: (BuildContext context) {
              final Iterable<Widget> tiles = ListTile.divideTiles(
                context: context,
                tiles: _items.map<Widget>((String s) => new ListTile(
                      title: new Text(s),
                    )),
              );
              return new ExpansionTile(
                title: const Text('wowy'),
                children: tiles.toList(),
              );
            },
          ),
        ),

        new Container(
          margin: const EdgeInsets.all(4.0),
          child: new ExpansionPanelList(
            expansionCallback: _onExpanded,
            children: <ExpansionPanel>[
              new ExpansionPanel(
                isExpanded: _expands[0],
                headerBuilder: (BuildContext context, bool isExpanded) =>
                    new ListTile(
                      title: new Text('Add connection'),
                      trailing: new Icon(Icons.arrow_back),
                    ),
                body: new Container(
                  width: 0.0,
                  height: 0.0,
                ),
              ),

              new ExpansionPanel(
                isExpanded: _expands[1],
                headerBuilder: LeaseDetailHeader.headerBuilder,
                body: LeaseDetailHeader.body(),
              ),
              new ExpansionPanel(
                isExpanded: _expands[2],
                headerBuilder: ControlSection.headerBuilder,
                body: ControlSection.body(),
              ),
              new ExpansionPanel(
                isExpanded: _expands[3],
                headerBuilder: LeaseDetailBottomSection.headerBuilder,
                body: LeaseDetailBottomSection.body(),
              ),

              // new LeaseDetailBottomSection(),
            ],
          ),
        ),
      ]));
}

class LeaseDetailHeader extends StatefulWidget {
  const LeaseDetailHeader();

  static Widget headerBuilder(BuildContext context, bool isExpanded) =>
      const ListTile(
        leading: const Icon(Icons.list),
        title: const Text('Details'),
      );

  static Widget body() => const LeaseDetailHeader();

  @override
  LeaseDetailHeaderState createState() => new LeaseDetailHeaderState();
}

class LeaseDetailHeaderState extends State<LeaseDetailHeader> {
  @override
  Widget build(BuildContext context) => new Column(
        children: <Widget>[
          new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
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
          new ListTile(
            dense: true,
            leading: const Icon(Icons.attach_money),
            title: const Text('550.00'),
            subtitle: const Text('Rent'),
          ),
          const Divider(),
          new ButtonBar(
            children: <Widget>[
              new FlatButton(
                onPressed: () {},
                child: const Text('EDIT'),
                textTheme: ButtonTextTheme.accent,
              ),
            ],
          ),
        ],
      );
}

class ControlSection extends StatefulWidget {
  const ControlSection();

  static Widget headerBuilder(BuildContext context, bool isExpanded) =>
      const ListTile(
        leading: const Icon(Icons.edit),
        title: const Text('Actions'),
      );

  static Widget body() => const ControlSection();

  @override
  _ControlSectionState createState() => new _ControlSectionState();
}

class _ControlSectionState extends State<ControlSection> {
  TextEditingController _payController;

  @override
  void initState() {
    super.initState();
    _payController = new TextEditingController(text: '799.43');
  }

  @override
  void dispose() {
    _payController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => new Column(
        children: <Widget>[
          new ListTile(
              title: new Chip(
            label: new Text('Enter payment'),
          )),
          new ListTile(
            leading: const Icon(Icons.attach_money),
            title: const Text(
              'Balance:',
            ),
            trailing: new Text(
              '799.43',
              style: Theme.of(context).textTheme.subhead,
            ),
            /*trailing: new Chip(
              label: new Text('799.43'),
              // TODO abstract background color based on balance
              backgroundColor: Colors.redAccent.withAlpha(75),
            ),*/
          ),
          new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              new Expanded(child: new Container()),
              new Flexible(
                child: new TextField(
                  controller: _payController,
                  textAlign: TextAlign.center,
                  style: Theme
                      .of(context)
                      .textTheme
                      .subhead
                      .copyWith(color: Colors.green),
                  // new TextStyle(color: Theme.of(context).accentColor),
                  decoration: new InputDecoration(
                    icon: const Icon(Icons.attach_money),
                  ),
                ),
              ),
              new ButtonBar(
                children: <Widget>[
//                  new FlatButton(
//                    child: const Text('PAY Other'),
//                    onPressed: () {},
//                    textTheme: ButtonTextTheme.accent,
//                  ),
                  new FlatButton(
                    onPressed: () {},
                    child: const Text('PAY'),
                    textTheme: ButtonTextTheme.primary,
                  ),
                ],
              ),
            ],
          ),
          const Divider(),
          new ListTile(
              title: new Chip(
            label: new Text('Charge late fee'),
          )),
          new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              new Expanded(
                  child: new ListTile(
                title: new Text('Charge late fee'),
              ))
            ],
          ),
//          new Row(
//            children: <Widget>[
//              new ListTile(
//                leading: const Text('Make Payment:'),
//                title: const Text('799.43'),
//              ),
//            ],
//          ),
//          new Row(
//            children: <Widget>[
//              new ListTile(
//                leading: const Text('Apply Charge:'),
//                title: const Text('799.43'),
//              ),
//            ],
//          ),
        ],
      );
}

class LeaseDetailBottomSection extends StatefulWidget {
  const LeaseDetailBottomSection();

  static Widget headerBuilder(BuildContext context, bool isExpanded) =>
      const ListTile(
        leading: const Icon(Icons.dashboard),
        title: const Text('Transactions'),
      );

  static Widget body() => const LeaseDetailBottomSection();

  @override
  _LeaseDetailBottomSectionState createState() =>
      new _LeaseDetailBottomSectionState();
}

class _LeaseDetailBottomSectionState extends State<LeaseDetailBottomSection> {
  @override
  Widget build(BuildContext context) => new Column(
        children:
            _items.map((String s) => new ListTile(title: new Text(s))).toList(),
      );
}

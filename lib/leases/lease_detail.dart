import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wpm/models.dart';
import 'package:intl/intl.dart';

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

final List<Tenant> _tenants = <Tenant>[
  new Tenant(firstName: 'Bill', lastName: 'Brasky'),
  new Tenant(firstName: 'Mickey', lastName: 'Mouse'),
];
final Unit _unit = new Unit(address: 'F555');
final Property _property = new Property(name: 'Raccoon City');

enum ChargeType { rent, late_fee, damage, maintenance, nsf }

class LeaseDetail extends StatefulWidget {
  const LeaseDetail();

  static const String routeName = '/lease_detail';

  @override
  _LeaseDetailState createState() => new _LeaseDetailState();
}

class _LeaseDetailState extends State<LeaseDetail> {
  List<List<bool>> _expands = <List<bool>>[
    // Actions
    // payment, charge
    <bool>[false, false],
    // Details
    <bool>[false],
  ];

  void _onExpanded(int listIndex, int itemIndex, bool previous) {
    print(
        'listIndex=[$listIndex], itemIndex=[$itemIndex], previous=[$previous]');

    final List<List<bool>> _outerTemp = new List<List<bool>>.from(_expands);

    final List<bool> sectionList =
        new List<bool>.filled(_outerTemp[listIndex].length, false);

    sectionList[itemIndex] = !previous;

    _outerTemp[listIndex] = sectionList;

    setState(() {
      _expands = _outerTemp;
    });
  }

  @override
  Widget build(BuildContext context) => new Scaffold(
      appBar: new AppBar(
        title: const Text('A101 Smith, John'),
      ),
      body: new ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          // heading
          new MaterialSection(
            title: 'Details',
            expansionPanelList: new ExpansionPanelList(
              expansionCallback: (int itemIndex, bool previous) =>
                  _onExpanded(1, itemIndex, previous),
              children: <ExpansionPanel>[
                new ExpansionPanel(
                  isExpanded: _expands[1][0],
                  headerBuilder: (_, __) => const ListTile(
                      leading: const Icon(Icons.place),
                      title: const Text('Address')),
                  body: new Column(
                    children: <Widget>[
                      new ListTile(
                        leading: const Icon(Icons.map),
                        title: new Text('Columbiana Manor'),
                        subtitle: new Text('Property'),
                      ),
                      const ListTile(
                        leading: const Icon(Icons.domain),
                        title: const Text('A101'),
                        subtitle: const Text('Unit'),
                      ),
                      const ListTile(
                        leading: const Icon(Icons.merge_type),
                        title: const Text('Type'),
                        subtitle: const Text('Apartment'),
                      ),
                    ],
                  ),
                ),
                // new ExpansionPanel(headerBuilder: (_, __) => const ListTile(title: const Text('Tenants')), body: null),
                // new ExpansionPanel(headerBuilder: (_, __) => const ListTile(title: const Text('Dates')), body: null),
                // new ExpansionPanel(headerBuilder: (_, __) => const ListTile(title: const Text('\$ Amount')), body: null),
              ],
            ),
          ),
          new MaterialSection(
            title: 'Actions',
            expansionPanelList: new ExpansionPanelList(
              expansionCallback: (int itemIndex, bool previous) =>
                  _onExpanded(0, itemIndex, previous),
              children: <ExpansionPanel>[
                new ExpansionPanel(
                  isExpanded: _expands[0][0],
                  headerBuilder: (BuildContext context, bool isExpanded) =>
                      new ListTile(
                          leading: const Icon(
                            Icons.attach_money,
                            color: Colors.green,
                          ),
                          title: new Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              new Text(
                                'Payment',
                                style: isExpanded
                                    ? Theme
                                        .of(context)
                                        .textTheme
                                        .subhead
                                        .copyWith(
                                          // color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.bold,
                                        )
                                    : null,
                              ),
                              new Padding(
                                padding: const EdgeInsets.only(left: 0.0),
                                child: new Column(
                                  children: <Widget>[
                                    new Text(
                                      '799.43',
                                      style:
                                          Theme.of(context).textTheme.subhead,
                                    ),
                                    new Text(
                                      'Balance',
                                      style:
                                          Theme.of(context).textTheme.caption,
                                    )
                                  ],
                                ),
                              )
                            ],
                          )),
                  body: new PaymentActionSection(),
                ),
                new ExpansionPanel(
                  isExpanded: _expands[0][1],
                  headerBuilder: (_, bool isExpanded) => new ListTile(
                        leading: const Icon(
                          Icons.attach_money,
                          color: Colors.red,
                        ),
                        title: new Text(
                                'Charge',
                                style: isExpanded
                                    ? Theme
                                        .of(context)
                                        .textTheme
                                        .subhead
                                        .copyWith(
                                          // color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.bold,
                                        )
                                    : null,
                        ),
                      ),
                  body: new ChargeActionSection(),
                ),
              ],
            ),
          ),

//        new Container(
//          margin: const EdgeInsets.all(4.0),
//          child: new ExpansionPanelList(
//            expansionCallback: _onExpanded,
//            children: <ExpansionPanel>[
//              new ExpansionPanel(
//                isExpanded: _expands[0],
//                headerBuilder: (BuildContext context, bool isExpanded) =>
//                    new ListTile(
//                      title: new Text('Add connection'),
//                      trailing: new Icon(Icons.arrow_back),
//                    ),
//                body: new Container(
//                  width: 0.0,
//                  height: 0.0,
//                ),
//              ),
//
//              new ExpansionPanel(
//                isExpanded: _expands[1],
//                headerBuilder: LeaseDetailHeader.headerBuilder,
//                body: LeaseDetailHeader.body(),
//              ),
//              new ExpansionPanel(
//                isExpanded: _expands[2],
//                headerBuilder: ControlSection.headerBuilder,
//                body: ControlSection.body(),
//              ),
//              new ExpansionPanel(
//                isExpanded: _expands[3],
//                headerBuilder: LeaseDetailBottomSection.headerBuilder,
//                body: LeaseDetailBottomSection.body(),
//              ),
//
//              // new LeaseDetailBottomSection(),
//            ],
//          ),
//        ),
        ],
      ));
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

class MaterialSection extends StatefulWidget {
  final String title;
  final ExpansionPanelList expansionPanelList;
  final bool hideable;

  const MaterialSection(
      {this.title, this.expansionPanelList, this.hideable = false});

  static const double leftMargin = 0.0;
  static const double topMargin = 24.0;
  static const double rightMargin = 0.0;
  static const double bottomMargin = 16.0;

  @override
  _MaterialSectionState createState() => new _MaterialSectionState();
}

class _MaterialSectionState extends State<MaterialSection> {
  @override
  Widget build(BuildContext context) {
    final Widget _titleWidget = new Container(
      child: new Text(
        widget.title,
        style: Theme
            .of(context)
            .textTheme
            .subhead
            .copyWith(fontWeight: FontWeight.bold),
      ),
      margin: const EdgeInsets.fromLTRB(
          MaterialSection.leftMargin,
          MaterialSection.topMargin,
          MaterialSection.rightMargin,
          MaterialSection.bottomMargin),
    );

    return widget.hideable
        ? new ExpansionTile(
            title: _titleWidget, children: <Widget>[widget.expansionPanelList])
        : new Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _titleWidget,
              widget.expansionPanelList,
            ],
          );
  }
}

class MaterialSectionItem extends StatelessWidget {
  final Widget leading;
  final Widget title;
  final List<Widget> children;
  final bool initiallyExpanded;

  const MaterialSectionItem(
      {this.leading,
      this.title,
      this.children,
      this.initiallyExpanded = false});

  @override
  Widget build(BuildContext context) => new ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        leading: leading,
        title: title,
        children: ListTile
            .divideTiles(
              context: context,
              tiles: children
                  .map((Widget child) => new Padding(
                        padding: const EdgeInsets.only(left: 32.0),
                        child: child,
                      ))
                  .toList(),
            )
            .toList(),
      );
}

class PaymentActionSection extends StatefulWidget {
  final DateFormat dateFormat = new DateFormat.yMd();

  @override
  _PaymentActionSectionState createState() => new _PaymentActionSectionState();
}

class _PaymentActionSectionState extends State<PaymentActionSection> {
  DateTime _paymentDate;
  TextEditingController _payController;

  @override
  void initState() {
    _paymentDate = new DateTime.now();
    _payController = new TextEditingController(text: '799.43');
  }

  void _updateDate(DateTime newDate) {
    if (newDate != null) {
      setState(() {
        _paymentDate = newDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) => new Column(
        children: <Widget>[
          new ListTile(
            title: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                // Expanded ? or just Flexible..
                new Expanded(
                  child: new Column(
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      new RaisedButton(
                        child: new Text(widget.dateFormat.format(_paymentDate)),
                        // color: Colors.lightBlue,
                        onPressed: () async {
                          final DateTime newDate = await showDatePicker(
                            context: context,
                            initialDate: _paymentDate,
                            firstDate:
                                new DateTime.fromMicrosecondsSinceEpoch(0),
                            lastDate: new DateTime(3000),
                          );
                          _updateDate(newDate);
                        },
                      ),
                      new Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: new Text(
                          'Payment date',
                          style: Theme.of(context).textTheme.caption,
                        ),
                      ),
                    ],
                  ),
                ),
                new Flexible(
                  child: new TextField(
                    controller: _payController,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.subhead.copyWith(
                        color: Colors.green, fontWeight: FontWeight.bold),
                    // new TextStyle(color: Theme.of(context).accentColor),
                    decoration: new InputDecoration(
                      icon: const Icon(Icons.attach_money),
                      // labelText: 'Amount L',
                      // hintText: 'Amount H',
                      helperText: 'Amount',
                      helperStyle: Theme.of(context).textTheme.caption,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          new ButtonBar(
            children: <Widget>[
              new RaisedButton(
                onPressed: () {},
                child: const Text('SAVE PAYMENT'),
                textTheme: ButtonTextTheme.primary,
                color: Colors.green,
              ),
            ],
          ),
        ],
      );
}

class ChargeActionSection extends StatefulWidget {
  final DateFormat dateFormat = new DateFormat.yMd();

  @override
  _ChargeActionSectionState createState() => new _ChargeActionSectionState();
}

class _ChargeActionSectionState extends State<ChargeActionSection> {
  DateTime _chargeDate;
  TextEditingController _chargeController;
  ChargeType _chargeType;

  @override
  void initState() {
    // TODO think about how to handle currency values.. important!

    final DateTime now = new DateTime.now();
    //final DateTime firstOfThisMonth = new DateTime(now.year, now.month, 1);

    _chargeDate = now;
    // final int difference = now.difference(firstOfThisMonth).inDays;

    _chargeController = new TextEditingController(text: now.day.toString());
    _chargeType = ChargeType.late_fee;
  }

  void _updateDate(DateTime newDate) {
    if (newDate != null) {
      setState(() {
        _chargeDate = newDate;
      });
    }
  }

  void _updateChargeType(ChargeType newType) {
    setState(() {
      _chargeType = newType;
    });
  }

  @override
  Widget build(BuildContext context) => new SingleChildScrollView(
        child: new Column(
          children: <Widget>[
            new ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Date'),
              trailing: new RaisedButton(
                child: new Text(widget.dateFormat.format(_chargeDate)),
                // color: Colors.lightBlue,
                onPressed: () async {
                  final DateTime newDate = await showDatePicker(
                    context: context,
                    initialDate: _chargeDate,
                    firstDate: new DateTime.fromMicrosecondsSinceEpoch(0),
                    lastDate: new DateTime(3000),
                  );
                  _updateDate(newDate);
                },
              ),
            ),
            new ListTile(
                leading: new Container(),
                title: const Text('Type'),
                trailing: new DropdownButton<ChargeType>(
                  value: _chargeType,
                  items: ChargeType.values
                      .map(
                        (ChargeType type) => new DropdownMenuItem<ChargeType>(
                              child: new Text(type
                                  .toString()
                                  .split(r'.')[1]
                                  .splitMapJoin('_', onMatch: (_) => ' ')
                                  .toUpperCase()),
                              value: type,
                            ),
                      )
                      .toList(),
                  onChanged: _updateChargeType,
                )),
            new ListTile(
              leading: new Container(), //const Icon(Icons.monetization_on),
              title: new Row(
                children: <Widget>[
                  const Expanded(
                    child: const Text('Amount'),
                  ),
                  new Flexible(
                    child: new TextField(
                      keyboardType: TextInputType.number,
                      controller: _chargeController,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.subhead.copyWith(
                          color: Colors.red, fontWeight: FontWeight.bold),
                      decoration: const InputDecoration(
                        icon: const Icon(Icons.attach_money),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            new ButtonBar(
              children: <Widget>[
                new RaisedButton(
                  onPressed: () async {
                    final bool result = await showDialog<bool>(
                      context: context,
                      child: new AlertDialog(
                        title: const Text('Confirm charge'),
                        actions: <Widget>[
                          new FlatButton(
                            child: const Text('Cancel'),
                            onPressed: () => Navigator.of(context).pop(false),
                          ),
                          new FlatButton(
                            child: const Text('Save'),
                            onPressed: () => Navigator.of(context).pop(true),
                          )
                        ],
                        content: new Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            new Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                new Text(
                                  'Date',
                                  style: Theme.of(context).textTheme.caption,
                                ),
                                new Text(widget.dateFormat.format(_chargeDate))
                              ],
                              //mainAxisSize: MainAxisSize.min,
                            ),
                            new Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: new Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  new Text(
                                    'Type',
                                    style: Theme.of(context).textTheme.caption,
                                  ),
                                  new Text(_chargeType
                                      .toString()
                                      .split(r'.')[1]
                                      .splitMapJoin('_', onMatch: (_) => ' ')
                                      .toUpperCase()),
                                ],
                                //mainAxisSize: MainAxisSize.min,
                              ),
                            ),
                            new Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                new Text(
                                  'Amount',
                                  style: Theme.of(context).textTheme.caption,
                                ),
                                new Text(_chargeController.text),
                              ],
                              //mainAxisSize: MainAxisSize.min,
                            ),
                          ],
                        ),
                      ),
                    );
                    print('result was: $result');
                  },
                  child: const Text('SAVE CHARGE'),
                  textTheme: ButtonTextTheme.primary,
                  color: Colors.red,
                ),
              ],
            ),
          ],
        ),
      );
}

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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

enum ChargeType { rent, late_fee, damage, maintenance, nsf }

class LeaseDetail extends StatefulWidget {
  const LeaseDetail();

  static const String routeName = '/lease_detail';

  @override
  _LeaseDetailState createState() => _LeaseDetailState();
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

    final List<bool> sectionList = new List<bool>.filled(
      _outerTemp[listIndex].length,
      false,
    );

    sectionList[itemIndex] = !previous;

    _outerTemp[listIndex] = sectionList;

    setState(() {
      _expands = _outerTemp;
    });
  }

  @override
  Widget build(BuildContext context) => DefaultTabController(
        length: 2,
        child: Scaffold(
            appBar: AppBar(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  new Text('A101'),
                  new Text('Smith, John'),
                ],
              ),
              bottom: new TabBar(
                isScrollable: false,
                tabs: <Widget>[
                  new Tab(text: 'ACTIONS'),
                  new Tab(text: 'DETAILS'),
                ],
              ),
            ),
            body: new TabBarView(
              children: <Widget>[
                new ListView(
                  padding: new EdgeInsets.all(16.0),
                  children: <Widget>[
                    new ExpansionPanelList(
                      expansionCallback: (int itemIndex, bool previous) =>
                          _onExpanded(0, itemIndex, previous),
                      children: <ExpansionPanel>[
                        new ExpansionPanel(
                          isExpanded: _expands[0][0],
                          headerBuilder: (
                            BuildContext context,
                            bool isExpanded,
                          ) =>
                              new ListTile(
                                  leading: Icon(
                                    Icons.attach_money,
                                    color: Colors.green,
                                  ),
                                  title: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      new Text(
                                        'Payment',
                                        style: isExpanded
                                            ? Theme
                                                .of(context)
                                                .textTheme
                                                .subhead
                                                .copyWith(
                                                  color: Colors.green,
                                                  fontWeight: FontWeight.bold,
                                                )
                                            : null,
                                      ),
                                      new Padding(
                                        padding: new EdgeInsets.only(left: 0.0),
                                        child: new Column(
                                          children: <Widget>[
                                            new Text(
                                              '799.43',
                                              style: Theme
                                                  .of(context)
                                                  .textTheme
                                                  .subhead,
                                            ),
                                            new Text(
                                              'Balance',
                                              style: Theme
                                                  .of(context)
                                                  .textTheme
                                                  .caption,
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
                          headerBuilder: (
                            BuildContext context,
                            bool isExpanded,
                          ) =>
                              new ListTile(
                                leading: new Icon(
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
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                          )
                                      : null,
                                ),
                              ),
                          body: new ChargeActionSection(),
                        ),
                      ],
                    ),
                  ],
                ),
                new ListView(
                  padding: new EdgeInsets.all(16.0),
                  children: <Widget>[
                    // heading
                    new MaterialSection(
                      title: 'Details',
                      expansionPanelList: new ExpansionPanelList(
                        expansionCallback: (
                          int itemIndex,
                          bool previous,
                        ) =>
                            _onExpanded(1, itemIndex, previous),
                        children: <ExpansionPanel>[
                          new ExpansionPanel(
                            isExpanded: _expands[1][0],
                            headerBuilder: (
                              BuildContext context,
                              bool isExpanded,
                            ) =>
                               new ListTile(
                                  leading: new Icon(Icons.place),
                                  title: new Text('Address'),
                                ),
                            body: Column(
                              children: <Widget>[
                                new ListTile(
                                  leading: new Icon(Icons.map),
                                  title: new Text('Columbiana Manor'),
                                  subtitle: new Text('Property'),
                                ),
                                new ListTile(
                                  leading: new Icon(Icons.domain),
                                  title: new Text('A101'),
                                  subtitle: new Text('Unit'),
                                ),
                                new ListTile(
                                  leading: new Icon(Icons.merge_type),
                                  title: new Text('Apartment'),
                                  subtitle: new Text('Type'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            )),
      );
}

class LeaseDetailHeader extends StatefulWidget {
  const LeaseDetailHeader();

  static Widget headerBuilder({BuildContext context, bool isExpanded}) =>
      ListTile(
        leading: new Icon(Icons.list),
        title: new Text('Details'),
      );

  static Widget body() => new LeaseDetailHeader();

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
              new Flexible(
                child: new ListTile(
                  dense: true,
                  leading: new Icon(Icons.home),
                  title: new Text('A101'),
                  subtitle: new Text('Columbiana Manor'),
                ),
              ),
              new Flexible(
                child: new ListTile(
                  dense: true,
                  leading: new Icon(Icons.people),
                  title: new Text('Smith, John'),
                  subtitle: new Text('Smith, Jane'),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              new Flexible(
                child: new ListTile(
                  dense: true,
                  leading: new Icon(Icons.calendar_today),
                  subtitle: new Text('Start Date'),
                  title: new Text('2017-07-04'),
                ),
              ),
              new Flexible(
                child: new ListTile(
                  dense: true,
                  leading: new Icon(Icons.calendar_today),
                  subtitle: new Text('End Date'),
                  title: new Text('2018-07-03'),
                ),
              ),
            ],
          ),
          new ListTile(
            dense: true,
            leading: new Icon(Icons.attach_money),
            title: new Text('550.00'),
            subtitle: new Text('Rent'),
          ),
          new Divider(),
          new ButtonBar(
            children: <Widget>[
              new FlatButton(
                onPressed: () {},
                child: new Text('EDIT'),
                textTheme: ButtonTextTheme.accent,
              ),
            ],
          ),
        ],
      );
}

class ControlSection extends StatefulWidget {
  const ControlSection();

  static Widget headerBuilder({BuildContext context, bool isExpanded}) =>
      new ListTile(
        leading: Icon(Icons.edit),
        title: Text('Actions'),
      );

  static Widget body() => ControlSection();

  @override
  _ControlSectionState createState() => _ControlSectionState();
}

class _ControlSectionState extends State<ControlSection> {
  TextEditingController _payController;

  @override
  void initState() {
    super.initState();
    _payController = TextEditingController(text: '799.43');
  }

  @override
  void dispose() {
    _payController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
        children: <Widget>[
          ListTile(
              title: Chip(
            label: Text('Enter payment'),
          )),
          ListTile(
            leading: Icon(Icons.attach_money),
            title: Text(
              'Balance:',
            ),
            trailing: Text(
              '799.43',
              style: Theme.of(context).textTheme.subhead,
            ),
            /*trailing: Chip(
              label: Text('799.43'),
              // TODO abstract background color based on balance
              backgroundColor: Colors.redAccent.withAlpha(75),
            ),*/
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(child: Container()),
              Flexible(
                child: TextField(
                  controller: _payController,
                  textAlign: TextAlign.center,
                  style: Theme
                      .of(context)
                      .textTheme
                      .subhead
                      .copyWith(color: Colors.green),
                  // TextStyle(color: Theme.of(context).accentColor),
                  decoration: InputDecoration(
                    icon: Icon(Icons.attach_money),
                  ),
                ),
              ),
              ButtonBar(
                children: <Widget>[
//                  FlatButton(
//                    child: Text('PAY Other'),
//                    onPressed: () {},
//                    textTheme: ButtonTextTheme.accent,
//                  ),
                  FlatButton(
                    onPressed: () {},
                    child: Text('PAY'),
                    textTheme: ButtonTextTheme.primary,
                  ),
                ],
              ),
            ],
          ),
          Divider(),
          ListTile(
              title: Chip(
            label: Text('Charge late fee'),
          )),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                  child: ListTile(
                title: Text('Charge late fee'),
              ))
            ],
          ),
        ],
      );
}

class LeaseDetailBottomSection extends StatefulWidget {
  const LeaseDetailBottomSection();

  static Widget headerBuilder({BuildContext context, bool isExpanded}) =>
      ListTile(
        leading: Icon(Icons.dashboard),
        title: Text('Transactions'),
      );

  static Widget body() => LeaseDetailBottomSection();

  @override
  _LeaseDetailBottomSectionState createState() =>
      _LeaseDetailBottomSectionState();
}

class _LeaseDetailBottomSectionState extends State<LeaseDetailBottomSection> {
  @override
  Widget build(BuildContext context) => Column(
        children: _items.map((String s) => ListTile(title: Text(s))).toList(),
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
  _MaterialSectionState createState() => _MaterialSectionState();
}

class _MaterialSectionState extends State<MaterialSection> {
  @override
  Widget build(BuildContext context) {
    final Widget _titleWidget = Container(
      child: Text(
        widget.title,
        style: Theme
            .of(context)
            .textTheme
            .subhead
            .copyWith(fontWeight: FontWeight.bold),
      ),
      margin: EdgeInsets.fromLTRB(
          MaterialSection.leftMargin,
          MaterialSection.topMargin,
          MaterialSection.rightMargin,
          MaterialSection.bottomMargin),
    );

    return widget.hideable
        ? ExpansionTile(
            title: _titleWidget, children: <Widget>[widget.expansionPanelList])
        : Column(
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
  Widget build(BuildContext context) => ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        leading: leading,
        title: title,
        children: ListTile
            .divideTiles(
              context: context,
              tiles: children
                  .map((Widget child) => Padding(
                        padding: EdgeInsets.only(left: 32.0),
                        child: child,
                      ))
                  .toList(),
            )
            .toList(),
      );
}

class PaymentActionSection extends StatefulWidget {
  final DateFormat dateFormat = DateFormat.yMd();

  @override
  _PaymentActionSectionState createState() => _PaymentActionSectionState();
}

class _PaymentActionSectionState extends State<PaymentActionSection> {
  DateTime _paymentDate;
  TextEditingController _payController;

  @override
  void initState() {
    super.initState();
    _paymentDate = DateTime.now();
    _payController = TextEditingController(text: '799.43');
  }

  @override
  void dispose() {
    _payController?.dispose();
    super.dispose();
  }

  void _updateDate(DateTime newDate) {
    if (newDate != null) {
      setState(() {
        _paymentDate = newDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) => Column(
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.calendar_today),
            title: Text('Date'),
            trailing: FlatButton(
              child: Text(
                widget.dateFormat.format(_paymentDate),
              ),
              textTheme: ButtonTextTheme.accent,
              // color: Colors.lightBlue,
              onPressed: () async {
                final DateTime newDate = await showDatePicker(
                  context: context,
                  initialDate: _paymentDate,
                  firstDate: DateTime.fromMicrosecondsSinceEpoch(0),
                  lastDate: DateTime(3000),
                );
                _updateDate(newDate);
              },
            ),
          ),
          ListTile(
            leading: Icon(Icons.attach_money),
            title: Row(
              children: <Widget>[
                Expanded(child: Text('Amount')),
                Flexible(
                  child: TextField(
                    controller: _payController,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.subhead.copyWith(
                        color: Theme.of(context).accentColor,
                        fontWeight: FontWeight.bold),
                    // TextStyle(color: Theme.of(context).accentColor),
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.attach_money,
                        color: Theme.of(context).iconTheme.color,
                      ),
                      // labelText: 'Amount L',
                      // hintText: 'Amount H',
                      helperText: 'Amount',
                      helperStyle: Theme.of(context).textTheme.caption,
                    ),
                  ),
                )
              ],
            ),
          ),
          Divider(),
          ButtonBar(
            children: <Widget>[
              RaisedButton(
                onPressed: () {},
                child: Text('SAVE PAYMENT'),
                textTheme: ButtonTextTheme.primary,
                // color: Colors.green,
              ),
            ],
          ),
        ],
      );
}

class ChargeActionSection extends StatefulWidget {
  final DateFormat dateFormat = DateFormat.yMMMEd();

  @override
  _ChargeActionSectionState createState() => _ChargeActionSectionState();
}

class _ChargeActionSectionState extends State<ChargeActionSection> {
  DateTime _chargeDate;
  TextEditingController _chargeController;
  ChargeType _chargeType;

  @override
  void initState() {
    super.initState();
    // TODO think about how to handle currency values.. important!

    final DateTime now = DateTime.now();
    //final DateTime firstOfThisMonth = DateTime(now.year, now.month, 1);

    _chargeDate = now;
    // final int difference = now.difference(firstOfThisMonth).inDays;

    _chargeController = TextEditingController(text: now.day.toString());
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
  Widget build(BuildContext context) => SingleChildScrollView(
        child: Column(
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.calendar_today),
              title: Text('Date'),
              trailing: FlatButton(
                child: Text(
                  widget.dateFormat.format(_chargeDate),
                ),
                // color: Colors.lightBlue,
                onPressed: () async {
                  final DateTime newDate = await showDatePicker(
                    context: context,
                    initialDate: _chargeDate,
                    firstDate: DateTime.fromMicrosecondsSinceEpoch(0),
                    lastDate: DateTime(3000),
                  );
                  _updateDate(newDate);
                },
                // color: Theme.of(context).accentColor,
                textTheme: ButtonTextTheme.accent,
              ),
            ),
            ListTile(
              leading: Container(),
              title: Text('Type'),
              trailing: DropdownButton<ChargeType>(
                // style: Theme.of(context).textTheme.subhead.copyWith(color: Theme.of(context).accentColor),
                value: _chargeType,
                items: ChargeType.values
                    .map(
                      (ChargeType type) => DropdownMenuItem<ChargeType>(
                            child: Text(type
                                .toString()
                                .split(r'.')[1]
                                .splitMapJoin('_', onMatch: (_) => ' ')
                                .toUpperCase()),
                            value: type,
                          ),
                    )
                    .toList(),
                onChanged: _updateChargeType,
              ),
            ),
            ListTile(
              leading: Container(), //Icon(Icons.monetization_on),
              title: new Row(
                children: <Widget>[
                  new Expanded(
                    child: new Text('Amount'),
                  ),
                  new Flexible(
                    child: new TextField(
                      keyboardType: TextInputType.number,
                      controller: _chargeController,
                      textAlign: TextAlign.center,
                      /* style: Theme.of(context).textTheme.subhead.copyWith(
                            color: Theme.of(context).accentColor,
                            fontWeight: FontWeight.bold,
                          ), */
                      decoration: new InputDecoration(
                        // icon: Icon(Icons.attach_money),
                        prefixIcon: new Icon(
                          Icons.attach_money,
                          color: Theme.of(context).iconTheme.color,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(),
            ButtonBar(
              children: <Widget>[
                RaisedButton(
                  onPressed: () async {
                    final bool result = await showDialog<bool>(
                      context: context,
                      builder: (BuildContext context) => new AlertDialog(
                          title: new Text('Confirm charge'),
                          actions: <Widget>[
                            new FlatButton(
                              child: new Text('CANCEL'),
                              onPressed: () => Navigator.of(context).pop(false),
                            ),
                            new FlatButton(
                              child: new Text('SAVE'),
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
                                padding: new EdgeInsets.symmetric(vertical: 8.0),
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
                              Row(
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
                  child: new Text('SAVE CHARGE'),
                  textTheme: ButtonTextTheme.primary,
                  // color: Colors.redAccent,
                ),
              ],
            ),
          ],
        ),
      );
}

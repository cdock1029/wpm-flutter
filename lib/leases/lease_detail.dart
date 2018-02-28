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

        new MaterialSection(
          title: 'Details',
          hideable: true,
          sectionItems: <MaterialSectionItem>[
            new MaterialSectionItem(
              leading: const Icon(Icons.home),
              title: const Text('Address'),
              children: <Widget>[
                new ListTile(
                  leading: const Icon(Icons.do_not_disturb),
                  title: new Text('A101'),
                  subtitle: new Text('Unit'),
                ),
                new ListTile(
                  leading: const Icon(Icons.map),
                  title: new Text('Columbiana Manor'),
                  subtitle: new Text('Property'),
                ),
              ],
            ),
            new MaterialSectionItem(
              leading: const Icon(Icons.people),
              title: new Text('Tenants'),
              children: <Widget>[
                new ListTile(
                  leading: const Icon(Icons.person),
                  title: new Text('Smith, John'),
                  subtitle: new Text('Primary'),
                ),
                new ListTile(
                  leading: const Icon(Icons.person),
                  title: new Text('Smith, Jane'),
                  subtitle: new Text('Co-sign'),
                ),
              ],
            ),
            new MaterialSectionItem(
              title: new Text('Dates'),
              leading: const Icon(Icons.calendar_today),
              children: <Widget>[
                new ListTile(
                  title: new Text('2018-10-09'),
                  subtitle: new Text('Start'),
                  trailing: const Icon(Icons.edit),
                ),
                new ListTile(
                  title: new Text('2017-10-10'),
                  subtitle: new Text('End'),
                ),
              ],
            )
          ],
        ),

        new MaterialSection(
          title: 'Actions',
          sectionItems: <MaterialSectionItem>[
            new MaterialSectionItem(
              title: new Text('Payment'),
              children: <Widget>[
                // const ListTile(title: const Text('799.43'), subtitle: const Text('Balance'),),
                new Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    new Flexible(
                        child: new Column(
                      children: <Widget>[
                        new Text(
                          '799.43',
                          style: Theme.of(context).textTheme.subhead,
                        ),
                        new Text(
                          'Balance',
                          style: Theme.of(context).textTheme.caption,
                        )
                      ],
                    )),
                    new Flexible(
                      child: new TextField(
                        // controller: _payController,
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
              ],
              initiallyExpanded: true,
            ),
            new MaterialSectionItem(
              title: new Text('Charge'),
              children: <Widget>[
                new ListTile(title: new Text('Late Fee:')),
              ],
            ),
          ],
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
  final List<MaterialSectionItem> sectionItems;
  final bool hideable;

  const MaterialSection({this.title, this.sectionItems, this.hideable = false});

  static const double leftMargin = 4.0;
  static const double topMargin = 12.0;
  static const double rightMargin = 0.0;
  static const double bottomMargin = 8.0;

  @override
  _MaterialSectionState createState() => new _MaterialSectionState();
}

class _MaterialSectionState extends State<MaterialSection> {
  @override
  Widget build(BuildContext context) {
    final Widget _titleWidget = new Container(
      child: new Text(
        widget.title,
        style: Theme.of(context).textTheme.subhead,
      ),
      margin: const EdgeInsets.fromLTRB(
          MaterialSection.leftMargin,
          MaterialSection.topMargin,
          MaterialSection.rightMargin,
          MaterialSection.bottomMargin),
    );

    final Widget _sectionItemsWidget = new Card(
      child: new Column(
        children: widget.sectionItems,
      ),
    );

    final List<Widget> _outerColumnChildren = <Widget>[
      _titleWidget,
      // holds the card-backed items.. white background
      _sectionItemsWidget,
    ];

    //..addAll(widget.sectionItems);

    return widget.hideable
        ? new ExpansionTile(title: _titleWidget, children: <Widget>[_sectionItemsWidget])
        : new Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _outerColumnChildren,
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

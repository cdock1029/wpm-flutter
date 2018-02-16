import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

class AddTenant extends StatefulWidget {
  static const String routeName = '/add_tenant';

  const AddTenant({Key key}) : super(key: key);

  @override
  AddTenantState createState() => new AddTenantState();
}

class AddTenantState extends State<AddTenant> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  final RegExp _nameExp = new RegExp(r'^[A-Za-z0-9 ]+$');
  final RegExp _phoneExp = new RegExp(r'^[0-9]{10}$');

  TenantData tenant = new TenantData();

  String _validateName(String name) {
    if (name.isEmpty) {
      return 'Name value is required.';
    }
    if (!_nameExp.hasMatch(name)) {
      return 'Only use letters or numbers.';
    }
    return null;
  }

  String _validatePhone(String phone) {
    if (phone.isEmpty) {
      return 'Phone number is required.';
    }
    if (!_phoneExp.hasMatch(phone)) {
      return 'Enter 10 digit phone number';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    print('');
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(title: const Text('New Tenant')),
      body: new SafeArea(
        top: false,
        bottom: false,
        child: new Form(
          key: _formKey,
          autovalidate: true,
          child: new ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            children: <Widget>[
              new Container(
                child: new Text(
                  '* indicates required field.',
                  style: Theme.of(context).textTheme.caption,
                ),
                padding: const EdgeInsets.symmetric(vertical: 16.0),
              ),
              new TextFormField(
                autocorrect: false,
                decoration: const InputDecoration(
                  isDense: true,
                  icon: const Icon(Icons.person),
                  labelText: 'First name *',
                ),
                validator: _validateName,
              ),
              new TextFormField(
                autocorrect: false,
                decoration: const InputDecoration(
                  isDense: true,
                  icon: const Icon(Icons.person),
                  labelText: 'Last name *',
                ),
                validator: _validateName,
              ),
              new TextFormField(
                autocorrect: false,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  isDense: true,
                  icon: const Icon(Icons.phone),
                  labelText: 'Phone *',
                ),
                validator: _validatePhone,
                inputFormatters: <TextInputFormatter>[
                  WhitelistingTextInputFormatter.digitsOnly,
                ],
              ),
              new TextFormField(
                autocorrect: false,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  isDense: true,
                  icon: const Icon(Icons.email),
                  labelText: 'Email *',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TenantData {
  String firstName = '';
  String lastName = '';
  String email = '';
  String phone = '';
}

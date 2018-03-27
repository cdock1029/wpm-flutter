import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

class AddTenant extends StatefulWidget {
  static const String routeName = '/add_tenant';
  static const String cloudFunctionsAuthority =
      'us-central1-wpmfirebaseproject.cloudfunctions.net';
  static const String validateEmailPath = 'validateEmail';
  static const String emailParam = 'email';

  const AddTenant({Key key}) : super(key: key);

  @override
  AddTenantState createState() => new AddTenantState();
}

class AddTenantState extends State<AddTenant> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final HttpClient _httpClient = new HttpClient();

  final RegExp _nameExp = new RegExp(r'^[A-Za-z0-9 ]+$');
  final RegExp _phoneExp = new RegExp(r'^[0-9]{10}$');

  TenantData tenant = new TenantData();

  bool _formWasEdited = false;
  bool _autovalidate = false;

  String _validateName(String name) {
    _formWasEdited = true;
    if (name.isEmpty) {
      return 'Name value is required.';
    }
    if (!_nameExp.hasMatch(name)) {
      return 'Only use letters or numbers.';
    }
    return null;
  }

  String _validatePhone(String phone) {
    _formWasEdited = true;
    if (phone.isEmpty) {
      return 'Phone number is required.';
    }
    if (!_phoneExp.hasMatch(phone)) {
      return 'Enter 10 digit phone number';
    }
    return null;
  }

  Future<bool> _validateEmail(String email) async {
    final Uri validateEmailUri = new Uri.https(
      AddTenant.cloudFunctionsAuthority,
      AddTenant.validateEmailPath,
      <String, String>{
        AddTenant.emailParam: email,
      },
    );
    final HttpClientRequest request = await _httpClient.getUrl(validateEmailUri);
    final HttpClientResponse response = await request.close();
    final String body = await response.transform(utf8.decoder).join();
    final Map<String, dynamic> _json = await json.decode(body);
    final bool isEmailValid = _json['isEmail'];
    return isEmailValid;
  }

  Future<Null> _save() async {
    _formKey.currentState.save();
    if (_formKey.currentState.validate()) {

      final bool isEmailValid = await _validateEmail(tenant.email);

      if (!isEmailValid) {
        tenant.emailValid = false;
        _scaffoldKey.currentState.showSnackBar(
          const SnackBar(content: const Text('Email failed validation..')));
      } else {
        _autovalidate = false;
        await Firestore.instance
            .collection('tenants')
            .document()
            .setData(tenant.data);
        _formKey.currentState.reset();
        _scaffoldKey.currentState
            .showSnackBar(const SnackBar(content: const Text('Tenant saved.')));
      }
    } else {
      _autovalidate = true;
      _scaffoldKey.currentState.showSnackBar(
          const SnackBar(content: const Text('Fix errors before saving.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    print('formwasedited=[$_formWasEdited]');
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(title: const Text('New Tenant')),
      body: new SafeArea(
        top: false,
        bottom: false,
        child: new Form(
          key: _formKey,
          autovalidate: _autovalidate,
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
                onSaved: (String value) {
                  tenant.firstName = value;
                },
              ),
              new TextFormField(
                autocorrect: false,
                decoration: const InputDecoration(
                  isDense: true,
                  icon: const Icon(Icons.person),
                  labelText: 'Last name *',
                ),
                validator: _validateName,
                onSaved: (String value) {
                  tenant.lastName = value;
                },
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
                onSaved: (String value) {
                  tenant.phone = value;
                },
              ),
              new TextFormField(
                autocorrect: false,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  isDense: true,
                  icon: const Icon(Icons.email),
                  labelText: 'Email *',
                ),
                validator: (String value) {
                  String result;
                  if (!tenant.emailValid) {
                    result = 'Email must be VALID';
                    tenant.emailValid = true;
                  }
                  return result;
                },
                onSaved: (String value) {
                  tenant
                    ..email = value
                    ..emailValid = true;
                },
              ),
              new Container(
                padding: const EdgeInsets.all(30.0),
                alignment: Alignment.center,
                child: new RaisedButton(
                  child: const Text('SAVE'),
                  onPressed: _save,
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
  bool emailValid = true;

  Map<String, String> get data => <String, String>{
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phone': phone,
      };
}

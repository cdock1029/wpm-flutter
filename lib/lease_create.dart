import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_stream_friends/flutter_stream_friends.dart';
import 'package:rxdart/rxdart.dart';
import 'package:wpm/models.dart';

class CreateLease extends StatefulWidget {
  static const String routeName = '/create_lease';

  const CreateLease({Key key}) : super(key: key);

  @override
  CreateLeaseState createState() => new CreateLeaseState();
}

class CreateLeaseState extends State<CreateLease> {
  final TextEditingController _searchController = new TextEditingController();

  final VoidStreamCallback vscb = new VoidStreamCallback();

  Observable<List<Tenant>> ob;

  Observable<List<Tenant>> _postAlgolia(String query) {
    final Map<String, String> data = <String, String>{'params': 'query=$query'};
    final String jsonData = JSON.encode(data);

    print('json query: $jsonData');
    final HttpClient client = new HttpClient();
    final Uri algUrl =
        new Uri.https('21MICXERPS-dsn.algolia.net', '1/indexes/tenants/query');

    print('algUrl=[${algUrl.toString()}]');
    final Future<HttpClientRequest> futureRequest = client.postUrl(algUrl);
    return new Observable<HttpClientRequest>.fromFuture(futureRequest)
        .map<HttpClientResponse>((HttpClientRequest request) {
      request.headers
          .add('X-Algolia-API-Key', '0596a34b3766181185a29c9bff3d1256');
      request.headers.add('X-Algolia-Application-Id', '21MICXERPS');
      request.headers.add('Content-Type', 'application/json');
      request.headers.add('Accept', 'application/json');

      request.write(jsonData);
      return request.close();
    }).map<String>((HttpClientResponse response) {
      final Stream<String> str = response.transform<String>(UTF8.decoder);
      final Future<String> jn = str.join();
      return jn;
    }).map<Map<String, dynamic>>((String body) {
      print('response body');
      return JSON.decode(body);
    }).map<List<Tenant>>((Map<String, dynamic> json) {
      print('response data: ${json.toString()}');
      final List<Map<String, dynamic>> hits = json['hits'];
      return hits
          .map((Map<String, dynamic> hit) => new Tenant.fromSnapshot(hit))
          .toList();
    });

    /*
    final HttpClientResponse response = await request.close();

    final String body = await response.transform(UTF8.decoder).join();
    final Map<String, dynamic> json = await JSON.decode(body);

    final List<Map<String, dynamic>> hits = json['hits'];

    final  hits.map((Map<String, dynamic> hit) => new Tenant.fromSnapshot(hit)).toList();
    */
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(vscb);

    ob = new Observable<void>(vscb)
        .map<String>((_) => _searchController.text)
        .distinct()
        // .where((String text) => text.length > 2)
        .debounce(new Duration(milliseconds: 450))
        .flatMapLatest<List<Tenant>>(_postAlgolia);
  }

  @override
  void dispose() {
    super.dispose();
    _searchController?.removeListener(vscb);
    _searchController?.dispose();
  }

  @override
  Widget build(BuildContext context) => new Scaffold(
        appBar: new AppBar(
          title: const Text('New Lease'),
        ),
        body: new SafeArea(
          // TODO: what is this thing for???
          top: false,
          bottom: false,
          child: new Form(
            child: new ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: <Widget>[
                new TextFormField(
                  autocorrect: false,
                  controller: _searchController,
                  decoration: new InputDecoration(
                    isDense: true,
                    labelText: 'Tenant',
                    icon: new Icon(Icons.person),
                  ),
                ),
                new Container(
                  padding: const EdgeInsets.all(16.0),
                  child: new SizedBox(
                    height: 100.0,
                    child: new Card(
                      child: new StreamBuilder<List<Tenant>>(
                        stream: ob,
                        builder: (
                          BuildContext context,
                          AsyncSnapshot<List<Tenant>> snap,
                        ) {
                          if (!snap.hasData) {
                            return const Text('NO Data');
                          }
                          return new ListView.builder(
                            itemCount: snap.data.length,
                            itemBuilder: (BuildContext context, int index) {
                              final Tenant tenant = snap.data[index];
                              return new Text(
                                  '${tenant.lastName}, ${tenant.firstName}');
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),
                new TextFormField(
                  decoration: new InputDecoration(
                    isDense: true,
                    labelText: 'Rent *',
                    icon: new Icon(Icons.confirmation_number),
                  ),
                )
              ],
            ),
          ),
        ),
      );
}

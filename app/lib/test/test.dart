import 'package:flutter/material.dart';
import 'dart:developer';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../picturesListView.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../location/location.dart';
import '../location/provider.dart';
import 'package:provider/provider.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  Future<List>? data;
  final LocationProvider locationProvider = LocationProvider();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Test'),
        ),
        body: Column(
          children: [
            Text("http://${dotenv.get('API_IP')}/api/plant"),
            FutureBuilder(
              future: fetchTest(),
              builder: (context, snapshot) => snapshot.hasData
                  ? ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data?.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(snapshot.data?[index]["name"]),
                          subtitle: Text(snapshot.data?[index]["url"]),
                        );
                      },
                    )
                  : Center(child: CircularProgressIndicator()),
            ),
            MultiProvider(
                providers: [
                  ChangeNotifierProvider<LocationProvider>(
                    create: (context) => LocationProvider(),
                  ),
                ],
                child: locationProvider.position == null
                    ? Text("しばらくお待ちください")
                    : Text(locationProvider.position.toString())),
          ],
        ));
  }

  Future<List> fetchTest() async {
    final response =
        await http.get(Uri.parse("http://${dotenv.get('API_IP')}/api/plant"));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load test');
    }
  }

  @override
  void initState() {
    super.initState();
    data = fetchTest();
  }
}
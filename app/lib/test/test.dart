import 'package:app/notification/notification.dart';
import 'package:flutter/material.dart';
import 'dart:developer';
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import '../picturesListView.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../location/location.dart';
import '../location/provider.dart';
import 'package:provider/provider.dart';
import 'package:http/io_client.dart' as http;

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
    call_periodic_notification();
    return Scaffold(
        appBar: AppBar(
          title: Text('Test'),
        ),
        body: Column(
          children: [
            Text("http://${dotenv.get('API_IP')}/api/plant"),
            FutureBuilder(
              future: fetchTest().then((value) => value, onError: (e) {
                print(e);
              }),
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
            OutlinedButton(onPressed: () => notifyNow(), child: Text("今すぐ通知")),
            // OutlinedButton(onPressed: () => notifyLater(), child: Text("後で通知")),
          ],
        ));
  }

  Future<List<dynamic>> fetchTest() async {
    late List data = [];
    try {
      final response = await http.get(
          Uri.parse("http://${dotenv.get('API_IP')}/api/plant"),
          headers: {"Content-Type": "application/json"});
      if (response.statusCode == 200) {
        data = json.decode(response.body);
      } else {
        throw Exception('Failed to load data');
      }
    } catch (err) {
      print(err);
    }
    return data;
  }

  @override
  void initState() {
    super.initState();
    data = fetchTest();
  }
}

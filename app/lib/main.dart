import 'package:flutter/material.dart';
import 'dart:developer';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'picturesListView.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'location/location.dart';

Future main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<List>? data;

  @override
  Widget build(BuildContext context) {
    fetchTest();
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
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
            FutureBuilder(
              future: determinePosition(),
              builder: (context, snapshot) => snapshot.hasData
                  ? Text(snapshot.data.toString())
                  : Center(child: CircularProgressIndicator()),
            )
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

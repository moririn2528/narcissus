import 'package:app/notification/notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../location/provider.dart';
import 'package:provider/provider.dart';
import '../handle_api/handle.dart';
import '../util/picturesListView.dart';

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
            OutlinedButton(onPressed: () => notifyLater(), child: Text("後で通知")),
            OutlinedButton(
                onPressed: () => notifyPlant(locationProvider.position),
                child: Text("近くの植物を探す")),
            AssetPicturesListView(imageDatas: [
              ["images/a.png", "つくし"],
              ["images/b.png", "もみじ", "とても綺麗"],
              ["images/c.png", "おはな"]
            ])
          ],
        ));
  }

  @override
  void initState() {
    super.initState();
    data = fetchTest();
  }
}

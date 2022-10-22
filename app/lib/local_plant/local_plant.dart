import 'package:app/notification/notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../location/provider.dart';
import 'package:provider/provider.dart';
import '../handle_api/handle.dart';
import '../util/picturesListView.dart';
import '../location/location.dart';

class LocalPlantPage extends StatefulWidget {
  LocalPlantPage({Key? key}) : super(key: key);
  @override
  State<LocalPlantPage> createState() => LocalPlantPageState();
}

class LocalPlantPageState extends State<LocalPlantPage> {
  List plants = [];
  late LocationProvider locationProvider = LocationProvider();
  @override
  Widget build(BuildContext context) {
    locationProvider = Provider.of<LocationProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Local Plant'),
      ),
      body: Center(
          child: plants.isEmpty
              ? const Text('植物が見つかりません')
              : NetworkPicturesListView(imageUrls: plants)),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          update_list();
        },
        child: Icon(Icons.update),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    update_list();
  }

  void update_list() async {
    locationProvider.updatePosition();
    getNearPlant(await determinePosition()).then((value) {
      setState(() {
        plants = value;
      });
    });
  }
}

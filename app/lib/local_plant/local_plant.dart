import 'package:app/notification/notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../handle_api/handle.dart';
import '../util/picturesListView.dart';
import 'package:location/location.dart';
import 'package:app/local_plant/plants.dart';
import '../location_state/location_state.dart';
import 'dart:async';

class LocalPlantPage extends StatefulWidget {
  final LocationState locationState;
  LocalPlantPage({required this.locationState});
  @override
  State<LocalPlantPage> createState() => LocalPlantPageState();
}

class LocalPlantPageState extends State<LocalPlantPage> {
  Plants plants = Plants(plants_list: []);
  Location location = Location();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Local Plant'),
      ),
      body: Center(
          child: plants.plants_list.isEmpty
              ? const Text('植物が見つかりません')
              : NetworkPicturesListView(imageUrls: plants)),
      floatingActionButton: FloatingActionButton(
        heroTag: "local",
        onPressed: () {
          update_list();
        },
        child: Icon(Icons.update),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }

  @override
  void initState() {
    super.initState();
    // periodically update
    Timer.periodic(Duration(seconds: 10), (timer) {
      update_list();
    });
  }

  void update_list() {
    setState(() {
      plants.update_plants(widget.locationState.position);
    });
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../location_state/location_state.dart';
import 'package:app/local_plant/plants.dart';
import 'map.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPage extends StatefulWidget {
  final LocationState locationState;
  MapPage({required this.locationState});
  @override
  State<MapPage> createState() => MapPageState();
}

class MapPageState extends State<MapPage> {
  Plants plants = Plants(plants_list: []);
  late LatLng _center;
  late GoogleMapController _controller;
  var _isLoading = true;
  late Set<Marker> _markers;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map'),
      ),
      body: Stack(
        children: [
          _isLoading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : GoogleMap(
                  onMapCreated: (controller) {
                    _controller = controller;
                  },
                  initialCameraPosition: CameraPosition(
                    target: _center,
                    zoom: 15.0,
                  ),
                  markers: _markers,
                  myLocationButtonEnabled: true,
                  myLocationEnabled: true,
                ),
          // show your latitude and longitude
          Positioned(
            child: Container(
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("latitude: ${widget.locationState.position.latitude}, "),
                  Text("longitude: ${widget.locationState.position.longitude}"),
                ],
              ),
            ),
          ),
          // 左上に設定画面を開くボタンを設置
          Positioned(
            top: 50,
            left: 10,
            child: FloatingActionButton(
              onPressed: () async {
                await openAppSettings();
              },
              child: Icon(Icons.settings),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "map",
        onPressed: () {
          update_list();
        },
        child: Icon(Icons.update),
        // set position of button
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }

  @override
  void initState() {
    update_list();
    plants.update_plants(widget.locationState.position);
    Timer.periodic(const Duration(seconds: 5), (timer) {
      update_list();
    });
    Future.delayed(const Duration(seconds: 7), () {
      setState(() {
        _center = LatLng(widget.locationState.position.latitude!,
            widget.locationState.position.longitude!);
        _isLoading = false;
      });
    });
  }

  void update_list() async {
    setState(() {
      plants.update_plants(widget.locationState.position);
      _markers = plants.plants2markers(context);
      print("map plants updated");
    });
  }
}

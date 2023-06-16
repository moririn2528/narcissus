import 'package:app/location_state/location_state.dart';
import 'package:app/model.dart';
import 'package:flutter/material.dart';
import 'package:app/location_state/location_state.dart';
import 'package:app/local_plant/plants.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';

// 地図と、投稿位置にピンを表示するWidget
// latitude, longitudeと、UploadPosts(植物名,緯度,経度,画像URL)のリストを渡すと
// latitude, longitudeを中心としてUploadPostsの位置に対してピンを打った地図が表示される
// ピンをタップすると詳細(写真)が表示される

class MapandPosts extends StatefulWidget {
  final LocationState locationState;
  final Plants uploadPlants;
  const MapandPosts(
      {Key? key, required this.locationState, required this.uploadPlants})
      : super(key: key);

  @override
  State<MapandPosts> createState() => _MapandPostsState();
}

class _MapandPostsState extends State<MapandPosts> {
  late GoogleMapController _controller;
  late Set<Marker> _markers;
  late LatLng _center;
  late Plants _uploadPlants;
  late UploadPost _selectedPost;
  var _isLoading = true;

  @override
  void initState() {
    super.initState();
    _markers = Set<Marker>();
    setState(() {
      _center = LatLng(widget.locationState.position.latitude!,
          widget.locationState.position.longitude!);
    });
    _uploadPlants = widget.uploadPlants;
    Timer.periodic(const Duration(seconds: 3), (timer) {
      setState(() {
        _markers = _uploadPlants.plants2markers(context);
        _center = LatLng(widget.locationState.position.latitude!,
            widget.locationState.position.longitude!);
      });
    });
    Future.delayed(const Duration(seconds: 7), () {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
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
    ]);
  }

  void updateCameraPosition(LatLng newPosition) {
    if (_controller != null) {
      _controller.animateCamera(
        CameraUpdate.newLatLng(newPosition),
      );
    }
  }
}

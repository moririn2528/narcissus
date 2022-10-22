import 'package:app/model.dart';
import 'package:app/notification/notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../location/provider.dart';
import 'package:provider/provider.dart';
import '../handle_api/handle.dart';
import '../util/picturesListView.dart';
import '../location/location.dart';
import 'map.dart';

class MapPage extends StatefulWidget {
  MapPage({Key? key}) : super(key: key);
  @override
  State<MapPage> createState() => MapPageState();
}

class MapPageState extends State<MapPage> {
  List<UploadPost> plants = [];
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
              ? const Text('近くに植物がありません')
              : MapAndPosts(
                  latitude: locationProvider.position.latitude,
                  longitude: locationProvider.position.longitude,
                  uploadPosts: plants,
                )),
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
    await getNearPlant(locationProvider.position).then((value) {
      // TODO
      // plants = value; とってきた情報をMapAndPostsに渡す形に変える
      List<UploadPost> posts = [];
      for (var v in value) {
        posts.add(UploadPost(
            name: v["name"],
            url: v["url"],
            latitude: v["latitude"],
            longitude: v["longitude"],
            detail: v["detail"]));
      }
      plants = posts;
    });
  }
}

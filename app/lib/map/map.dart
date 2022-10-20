import 'package:app/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// 表示のサンプル
Future main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MapSamplePage());
}

class MapSamplePage extends StatefulWidget {
  const MapSamplePage({super.key});

  @override
  State<MapSamplePage> createState() => _MapSamplePageState();
}

class _MapSamplePageState extends State<MapSamplePage> {
  //テスト用データ 百万遍付近
  final List<UploadPost> testPosts = [
    UploadPost(
      name: "お花1",
      latitude: 35.02527355160815,
      longitude: 135.77870285267127,
      url: "https://upload.wikimedia.org/wikipedia/commons/e/e3/Cherry_blossoms_%282004%29.jpg"
    ),
    UploadPost(
      name: "お花2",
      latitude: 35.02498254430388,
      longitude: 135.77890210637494,
      url: "https://upload.wikimedia.org/wikipedia/commons/3/30/Houttuynia_cordata4.jpg"
    ),
  ];
  final double originLatitude = 35.0251;
  final double originLongitude = 135.7788;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home:Scaffold(
      appBar: AppBar(
        title: const Text('Map'),
      ),
      body: MapAndPosts(
        latitude: originLatitude,
        longitude: originLongitude,
        uploadPosts: testPosts
      )
    ));
  }
}

// 地図と、投稿位置にピンを表示するWidget
// latitude, longitudeと、UploadPosts(植物名,緯度,経度,画像URL)のリストを渡すと
// latitude, longitudeを中心としてUploadPostsの位置に対してピンを打った地図が表示される
// ピンをタップすると詳細(写真)が表示される
class MapAndPosts extends StatelessWidget {
  MapAndPosts({
    Key? key,
    required this.latitude,
    required this.longitude ,
    required this.uploadPosts
  }) : super(key: key);

  late GoogleMapController mapController;
  final double latitude;
  final double longitude;
  final List<UploadPost> uploadPosts;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Set<Marker> _createMaker(BuildContext context , List<UploadPost> uploadPosts){
    Set<Marker> markers = {};
    for(int i = 0; i < uploadPosts.length; i++){
      markers.add(Marker(
          markerId: MarkerId(i.toString()),
          position: LatLng(uploadPosts[i].latitude, uploadPosts[i].longitude),
          infoWindow: InfoWindow(title: uploadPosts[i].name),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          onTap: (){
            _showDialog(context, uploadPosts[i]);
          }
      ));
    }
    return markers;
  }

  Future<void> _showDialog(BuildContext context, UploadPost uploadPost) async {
    final String name = uploadPost.name;
    //final String detail = "";
    final Widget image = Image.network(uploadPost.url);
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(name),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                image,
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('閉じる'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      onMapCreated: _onMapCreated,
      initialCameraPosition: CameraPosition(
        target: LatLng(latitude, longitude),
        zoom: 17.0,
      ),
      markers: _createMaker(context, uploadPosts),
    );
  }
}

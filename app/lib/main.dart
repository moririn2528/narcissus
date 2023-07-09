import 'package:app/local_plant/local_plant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'search/search.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import '../map/map_page.dart';
import 'package:app/location_state/location_state.dart';
import 'package:geolocator/geolocator.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:app/notification/notification.dart';
import 'package:app/upload/upload.dart';
import 'dart:async';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationController.init_notification();
  await dotenv.load(fileName: ".env").then((value) {
    Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key, required this.title});
  final String title;
  final LocationState locationState = LocationState();
  final NotificationController notificationController =
      NotificationController();
  int _idx = 0;
  Color _selectedIconColor = Colors.green;
  Color _unselectedIconColor = Colors.grey;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    final List<Widget> _screens = [
      LocalPlantPage(locationState: widget.locationState),
      MapPage(locationState: widget.locationState),
      SearchPage(),
      UploadPage(locationState: widget.locationState),
    ];
    return Scaffold(
      body: IndexedStack(
        index: widget._idx,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          setState(() {
            widget._idx = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home,
                color: widget._idx == 0
                    ? widget._selectedIconColor
                    : widget._unselectedIconColor),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map,
                color: widget._idx == 1
                    ? widget._selectedIconColor
                    : widget._unselectedIconColor),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search,
                color: widget._idx == 2
                    ? widget._selectedIconColor
                    : widget._unselectedIconColor),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.upload,
                color: widget._idx == 3
                    ? widget._selectedIconColor
                    : widget._unselectedIconColor),
            label: 'Upload',
          ),
        ],
        currentIndex: widget._idx,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    widget.locationState.set_permission();
    if (widget.locationState.permissionStatus == LocationPermission.always) {
      widget.locationState.set_background_mode();
    }
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: NotificationController.onActionReceivedMethod,
    );
    Timer.periodic(Duration(seconds: 5), (timer) {
      widget.locationState.updatePosition();
      widget.notificationController
          .notifyPlant(widget.locationState.position, DateTime.now());
    });
  }
}

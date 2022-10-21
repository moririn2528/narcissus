import 'package:app/local_plant/local_plant.dart';
import 'package:app/notification/notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'search/search.dart';
import 'test/test.dart';
import 'upload/upload.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import '../location/provider.dart';
import 'package:provider/provider.dart';
import '../map/map_page.dart';

Future main() async {
  await dotenv.load(fileName: ".env").then((value) {
    Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    WidgetsFlutterBinding.ensureInitialized();
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  final LocationProvider locationProvider = LocationProvider();
  MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider<LocationProvider>(
            create: (context) => locationProvider,
          ),
        ],
        child: const MyHomePage(title: 'Flutter Demo Home Page'),
      ),
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
  PageController _pageController = PageController();
  int _page = 0;

// メニューのリスト
  List<BottomNavigationBarItem> BottomNavItems() {
    return [
      BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: 'Home',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: '一覧',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.map),
        label: 'マップ',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.add),
        label: 'アップロード',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.search),
        label: '検索',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) => setState(() => _page = index),
          // ページのリスト
          children: <Widget>[
            TestPage(),
            LocalPlantPage(),
            MapPage(),
            UploadPage(),
            SearchPage(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.white,
          backgroundColor: Color.fromARGB(255, 81, 180, 85),
          items: BottomNavItems(),
          // メニュータップ時の処理
          onTap: (index) {
            setState(() {
              _page = index;
              _pageController.animateToPage(index,
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut);
            });
          },
          currentIndex: _page,
        ));
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: _page,
    );
  }
}

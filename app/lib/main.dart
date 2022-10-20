import 'package:app/notification/notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'search/search.dart';
import 'test/test.dart';
import 'upload/upload.dart';

Future main() async {
  await dotenv.load(fileName: ".env").then((value) {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(const MyApp());
  });
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
        icon: Icon(Icons.search),
        label: 'Search',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.add),
        label: 'Upload',
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
            SearchPage(),
            UploadPage(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
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

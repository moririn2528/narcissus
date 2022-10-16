import 'package:flutter/material.dart';
import 'dart:developer';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'picturesListView.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'location/location.dart';
import 'search/search.dart';
import 'test/test.dart';

Future main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
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
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) => setState(() => _page = index),
          children: <Widget>[
            TestPage(),
            SearchPage(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: BottomNavItems(),
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

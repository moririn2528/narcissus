import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'provider.dart';

void main() {
  runApp(const SearchPage());
}

// メイン関数として実行するための外枠
class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Builder(
        builder: (context) => MaterialApp(
              title: 'Flutter Demo',
              theme: ThemeData(
                primarySwatch: Colors.blue,
              ),
              home: Scaffold(
                appBar: AppBar(
                  title: const Text('Search'),
                ),
                body: const SearchGroup(),
              ),
            ));
  }
}

// 検索機能にかかわる部分,検索バー、タグの提案、タグの保持からなる
class SearchGroup extends StatefulWidget {
  const SearchGroup({super.key});

  @override
  State<SearchGroup> createState() => _SearchGroupState();
}

class _SearchGroupState extends State<SearchGroup> {
  final SearchProvider searchProvider = SearchProvider();

  @override
  void initState() {
    super.initState();
    // searchProvider.fetchtags();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<SearchProvider>(
            create: (context) => SearchProvider(),
          ),
        ],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Flexible(child: SearchBar(), flex: 1),
            Expanded(
                child: Suggestions(), flex: SearchProvider().isopened() * 2),
            Flexible(child: Keep(), flex: 1),
          ],
        ));
  }
}

// 検索バー
class SearchBar extends StatelessWidget {
  SearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    final Screenwidth = MediaQuery.of(context).size.width;
    final Screenheight = MediaQuery.of(context).size.height;
    final SearchProvider searchProvider = Provider.of<SearchProvider>(context);
    final TextEditingController fieldController =
        Provider.of<SearchProvider>(context).fieldController;
    return Container(
        margin: EdgeInsets.only(top: Screenheight * 0.05),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.search, color: Colors.grey, size: 30.0),
            SizedBox(
              height: 30.0,
              width: Screenwidth * 0.9,
              child: Scaffold(
                body: TextField(
                  controller: fieldController,
                  textInputAction: TextInputAction.search,
                  // 検索ボタンの挙動を指定する関数
                  onSubmitted: (value) {
                    print("searching");
                  },
                  // 入力が変わった際に実行される関数
                  onChanged: (value) {
                    searchProvider.suggestion();
                  },
                  decoration: InputDecoration(
                    hintText: 'タグ名を入力',
                  ),
                ),
              ),
            )
          ],
        ));
  }
}

// タグ候補の提案
class Suggestions extends StatelessWidget {
  const Suggestions({super.key});

  @override
  Widget build(BuildContext context) {
    final Screenwidth = MediaQuery.of(context).size.width;
    final Screenheight = MediaQuery.of(context).size.height;
    final SearchProvider searchProvider = Provider.of<SearchProvider>(context);
    TextEditingController fieldController =
        Provider.of<SearchProvider>(context).fieldController;
    return ListView.builder(
      shrinkWrap: true,
      itemCount: searchProvider.suggested_tags!.length,
      itemBuilder: (context, index) {
        // 各タグの表示
        return Card(
            child: ListTile(
          title: Text(searchProvider.suggested_tags![index]),
          // タグをタップした際の挙動
          onTap: () {
            searchProvider.addtag(searchProvider.suggested_tags![index]);
            searchProvider.suggested_tags = [];
            fieldController.clear();
          },
        ));
      },
    );
  }
}

// 選ばれたタグの表示
class Keep extends StatelessWidget {
  const Keep({super.key});

  @override
  Widget build(BuildContext context) {
    final SearchProvider searchProvider = Provider.of<SearchProvider>(context);
    return SizedBox(
      height: 50.0,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: searchProvider.keep_tags!.length,
        itemBuilder: (context, index) {
          // 　各タグの表示
          return Card(
              elevation: 5.0,
              shadowColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Container(
                  margin: EdgeInsets.only(left: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(searchProvider.keep_tags![index]),
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          size: 20.0,
                        ),
                        // 削除ボタンを押した際の挙動
                        onPressed: () {
                          searchProvider
                              .removetag(searchProvider.keep_tags![index]);
                        },
                      ),
                    ],
                  )));
        },
      ),
    );
  }
}

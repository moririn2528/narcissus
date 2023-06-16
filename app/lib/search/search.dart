import 'package:app/handle_api/handle.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'result.dart';
import 'dart:developer';

Future main() async {
  await dotenv.load(fileName: ".env");
  runApp(const SearchPage());
}

// 検索機能にかかわる部分,検索バー、タグの提案、タグの保持からなる
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final SearchProvider searchProvider = SearchProvider();
    return Scaffold(
        appBar: AppBar(
          title: const Text('Search'),
        ),
        body: SearchGroup(
          searchProvider: searchProvider,
        ));
  }
}

class SearchGroup extends StatelessWidget {
  final SearchProvider searchProvider;
  const SearchGroup({super.key, required this.searchProvider});

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
            LimitedBox(
              child: Suggestions(),
              maxHeight: 200,
            ),
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 1,
              child: Icon(
                Icons.search,
                color: Colors.grey,
                size: 30.0,
              ),
            ),
            Expanded(
              flex: 8,
              child: SizedBox(
                height: 30.0,
                child: Scaffold(
                  body: TextField(
                    controller: fieldController,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (value) {
                      search_post(
                        searchProvider.keep_tags,
                        context,
                        searchProvider,
                      );
                    },
                    onChanged: (value) {
                      searchProvider.suggestion();
                    },
                    decoration: InputDecoration(
                      hintText: 'タグ名を入力',
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: IconButton(
                icon: Icon(
                  Icons.send,
                  size: 30.0,
                  color: Colors.green,
                ),
                onPressed: () {
                  search_post(
                    searchProvider.keep_tags,
                    context,
                    searchProvider,
                  );
                },
              ),
            ),
          ],
        ));
  }
}

void search_post(
    List<dynamic> ids, BuildContext context, SearchProvider searchProvider) {
  final List<int> ids = [];
  for (var i = 0; i < searchProvider.keep_tags.length; i++) {
    ids.add(searchProvider.keep_tags[i]["id"]);
  }
  searchPlant(ids).then((value) {
    Navigator.push(
        context,
        MaterialPageRoute(
            // ナビゲートして検索結果を表示する
            builder: (context) => ResultPage(imageUrls: value)));
  }, onError: (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('検索に失敗しました'),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {
            // Some code to undo the change.
          },
        ),
      ),
    );
  });
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
      itemCount: searchProvider.suggested_tags.length,
      itemBuilder: (context, index) {
        // 各タグの表示
        return Card(
            child: ListTile(
          title: Text(searchProvider.suggested_tags[index]["name"]),
          // タグをタップした際の挙動
          onTap: () {
            searchProvider.addtag(searchProvider.suggested_tags[index]);
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
        itemCount: searchProvider.keep_tags.length,
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
                      Text(searchProvider.keep_tags[index]['name']),
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          size: 20.0,
                        ),
                        // 削除ボタンを押した際の挙動
                        onPressed: () {
                          searchProvider.removetag(index);
                        },
                      ),
                    ],
                  )));
        },
      ),
    );
  }
}

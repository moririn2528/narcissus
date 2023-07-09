import 'dart:async';
import 'dart:io';
import 'package:app/location_state/location_state.dart';
import 'package:flutter/material.dart';
import 'package:app/upload/upload_util.dart';
import 'package:location/location.dart';
import 'package:app/util/snackbar.dart';
import 'package:app/handle_api/gcs_api.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:app/util/circle.dart';

class CheckimagePage extends StatefulWidget {
  final File image;
  UploadInfo info = UploadInfo(
      id: 0, name: '', hash: '', latitude: 0, longitude: 0, tags: []);
  List<String> candidate_tags = [];
  List<String> tags = [];
  List<String> suggestions = [];
  List<String> candidate_names = [];
  LocationState locationState = LocationState();
  CheckimagePage(
      {required this.image,
      required this.candidate_tags,
      required this.candidate_names,
      required this.locationState});
  @override
  State<CheckimagePage> createState() => CheckimagePageState();
}

class CheckimagePageState extends State<CheckimagePage> {
  @override
  void initState() {
    LocationData? position = widget.locationState.position;
    if (position != null) {
      widget.info.latitude = position.latitude!;
      widget.info.longitude = position.longitude!;
    }
    widget.info.hash = DateTime.now().millisecondsSinceEpoch.toString();
    widget.info.id = widget.info.hash.hashCode;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
            appBar: AppBar(
              title: const Text('Check Image'),
            ),
            body: SingleChildScrollView(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.file(
                      widget.image,
                      width: 200,
                      height: 200,
                    ),
                    // select location with map and show selected location marker
                    Container(
                      height: 200,
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: LatLng(
                              widget.info.latitude, widget.info.longitude),
                          zoom: 15,
                        ),
                        markers: {
                          Marker(
                            markerId: MarkerId('selected'),
                            position: LatLng(
                                widget.info.latitude, widget.info.longitude),
                          )
                        },
                        onTap: (LatLng pos) {
                          setState(() {
                            widget.info.latitude = pos.latitude;
                            widget.info.longitude = pos.longitude;
                          });
                        },
                      ),
                    ),
                    // input image name
                    TextField(
                      decoration: InputDecoration(
                        hintText: '画像の名前を入力',
                      ),
                      onChanged: (input) {
                        widget.info.name = input;
                      },
                    ),
                    // show candidate names with horizontal list
                    Container(
                      height: 50,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.candidate_names.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                            title: Text(widget.candidate_names[index]),
                            onTap: () {
                              setState(() {
                                widget.info.name =
                                    widget.candidate_names[index];
                              });
                            },
                          );
                        },
                      ),
                    ),
                    Container(
                      child: Column(
                        children: [
                          Text('タグを追加'),
                          TextField(
                            decoration: InputDecoration(
                              hintText: 'タグを入力',
                            ),
                            onChanged: (input) {
                              // show candidate tag match with input
                              suggest_tags(input);
                            },
                          ),
                          // show suggestion list
                          Container(
                            height: 200,
                            child: ListView.builder(
                              itemCount: widget.suggestions.length,
                              itemBuilder: (BuildContext context, int index) {
                                return ListTile(
                                  title: Text(widget.suggestions[index]),
                                  onTap: () {
                                    // add tag to tags
                                    setState(() {
                                      widget.tags
                                          .add(widget.suggestions[index]);
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                          Wrap(
                            spacing: 8, // タグ間のスペースを設定
                            children: widget.tags.map((tag) {
                              return Chip(
                                label: Text(tag),
                                deleteIcon: Icon(Icons.delete),
                                onDeleted: () {
                                  // delete tag from tags
                                  setState(() {
                                    widget.tags.remove(tag);
                                  });
                                },
                              );
                            }).toList(),
                          )
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        // upload image to gcs
                        try {
                          if (!validate()) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              redsnackbar('名前を入力してください'),
                            );
                          } else {
                            showWaitingDialog(context);
                            await uploadImage(widget.image, widget.info.hash);
                            // upload post to api
                            widget.info.tags = widget.tags;
                            await upload_post(widget.info);
                            Navigator.pop(context);
                            // show snackbar
                            ScaffoldMessenger.of(context).showSnackBar(
                              greensnackbar('投稿が完了しました'),
                            );
                            // go back to home
                            Timer(const Duration(seconds: 1), () {
                              Navigator.pop(context);
                            });
                          }
                        } catch (e) {
                          delete_post(widget.info.hash);
                          Navigator.pop(context);
                          // show snackbar
                          ScaffoldMessenger.of(context).showSnackBar(
                            redsnackbar('投稿に失敗しました'),
                          );
                        }
                      },
                      child: const Text('投稿する'),
                    ),
                  ],
                ),
              ),
            )),
        onWillPop: () async {
          delete_from_gcs(widget.info.hash);
          Navigator.pop(context);
          return true;
        });
  }

  void suggest_tags(String input) {
    widget.suggestions = [];
    for (String tag in widget.candidate_tags) {
      if (tag.contains(input)) {
        setState(() {
          widget.suggestions.add(tag);
        });
      }
    }
  }

  bool validate() {
    if (widget.info.hash == '') {
      return false;
    }
    if (widget.info.latitude == 0 || widget.info.longitude == 0) {
      return false;
    }
    if (widget.info.name == '') {
      return false;
    }
    return true;
  }
}

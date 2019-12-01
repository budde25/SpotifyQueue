import 'package:cloud_firestore/cloud_firestore.dart' as prefix0;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spotify_queue/queue.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'spotifyApi.dart';
import 'platform.dart';


class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

String token;

class Song {
  String name;
  String artist;
  String track;

  Song(String name, String artist, String track) {
    this.name = name;
    this.artist = artist;
    this.track = track;
  }
}

class _SearchState extends State<Search> {

  TextEditingController search = new TextEditingController();
  List<Song> results = new List();
  String lastSearch;

  @override
  void initState() {
    _loadToken();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Search for songs'
              ),
              onSubmitted: _update(search.text),
              controller: search,
              autocorrect: true,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: results.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Text (results[index].name),
                      subtitle: Text (results[index].artist),
                      onTap: () { _addSong(results[index].name, results[index].artist, results[index].track);
                        // songs.add(results[index]);
                        },
                    );
                  }),
            )
          ],
        ),
      )
    );
  }

  _update(String text) {
    _search(text);
  }

  Future<void> _search(String query) async {
    if (query == null || query == '' || query == lastSearch)
      return;

    lastSearch = query;
    results = new List();

    Map search = await getSearchResults(query, token);
    List list = search['items'];

    setState(() {
      for (int i = 0; i < list.length; i++) {
        String name = list[i]['name'];
        String artist = list[i]['artists'][0]['name'];
        String uri = list[i]['uri'];

        results.add(new Song(name, artist, uri));
      }
    });

  }
  
  Future<String> _getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  void _loadToken() async {
    token = await getToken();
  }

  _addSong(String name, String artist, String track) {
    prefix0.Firestore.instance.collection(queueId).document(track);
    Firestore.instance.collection(queueId).document(track)
        .setData({ 'name': name, 'artist': artist, 'track': track });
  }


}
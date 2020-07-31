import 'dart:async';
import 'dart:convert';

import 'package:chrona_1/UserInfo/state.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:http/http.dart' as http;

import 'model/news.dart';
import 'news_details.dart';

class NewsListPage extends StatefulWidget {
  final String title;
  final String newsType;

  NewsListPage(this.title, this.newsType);

  @override
  _NewsListPageState createState() => _NewsListPageState();
}

class _NewsListPageState extends State<NewsListPage> {
  FirebaseDatabase firebaseDatabase;
  DatabaseReference databaseReferencelike,databaseReferencedislike;
  @override
  void initState() {
    String s=StaticState.user.email;
    s=s.substring(0,s.indexOf("@"));
    firebaseDatabase=FirebaseDatabase.instance;
    databaseReferencelike=firebaseDatabase.reference().child("Users").child(s).child("News").child("Likes");
    databaseReferencedislike=firebaseDatabase.reference().child("Users").child(s).child("News").child("Dislikes");
    super.initState();
  }

  var size;
  Future<List<Article>> getData(String newsType) async {
    List<Article> list;
    String link;
    if (newsType == "top_news") {
      link =
          "https://newsapi.org/v2/top-headlines?country=in&apiKey=36bbc55c610e417e8b80512b6ea9e7c5";
    }
    else if(newsType == "global") {
      link=
      "https://newsapi.org/v2/everything?domains=bbc.com,foxnews.com,cnn.com&sortBy=popularity&apiKey=36bbc55c610e417e8b80512b6ea9e7c5";
    }
    else if(newsType == "gaming") {
      link=
      "https://newsapi.org/v2/everything?domains=ign.com&sortBy=popularity&apiKey=36bbc55c610e417e8b80512b6ea9e7c5";
    }
    else if(newsType == "automobiles") {
      link=
      "https://newsapi.org/v2/everything?domains=autonews.com,thedrive.com,autocarindia.com&sortBy=popularity&apiKey=36bbc55c610e417e8b80512b6ea9e7c5";
    }
     else {
      link =
          "https://newsapi.org/v2/top-headlines?country=in&category=$newsType&apiKey=36bbc55c610e417e8b80512b6ea9e7c5";
    }
    print(link);
    var res = await http
        .get(Uri.encodeFull(link), headers: {"Accept": "application/json"});
    if (res.statusCode == 200) {
      var data = json.decode(res.body);
      var rest = data["articles"] as List;
      list = rest.map<Article>((json) => Article.fromJson(json)).toList();
    }
    return list;
  }

  Widget listViewWidget(List<Article> article) {
    return Container(
        child: ListView.builder(
            itemCount: article.length,
            padding: const EdgeInsets.all(2.0),
            itemBuilder: (context, position) {
              return Slidable(
                actionPane: SlidableDrawerActionPane(),
                actionExtentRatio: 0.20,
                child: Card(
                  child: Container(
                    height: 120.0,
                    width: 120.0,
                    child: Center(
                      child: ListTile(
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 5.0),
                          child: Text(
                            '${article[position].source.name}',
                          ),
                        ),
                        title: Text(
                          '${article[position].title}',
                          style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                        ),
                        leading: Container(
                          height: 100.0,
                          width: 100.0,
                          child: article[position].urlToImage == null
                              ? Image.asset(
                                  'images/no_image_available.png',
                                  height: 70,
                                  width: 70,
                                )
                              : Image.network(
                                  '${article[position].urlToImage}',
                                  height: 70,
                                  width: 70,
                                ),
                        ),
                        onTap: () => _onTapItem(context, article[position]),
                      ),
                    ),
                  ),
                ),
                secondaryActions: <Widget>[
                  IconSlideAction(
                    caption: 'Like',
                    color: Colors.blue,
                    icon: Icons.check,
                    onTap: () => Like(article[position]),
                  ),
                  IconSlideAction(
                    caption: 'Dislike',
                    color: Colors.red,
                    icon: Icons.clear,
                     onTap: () => Dislike(article[position]),
                  ),
                ],
              );
            }));
  }

  void _onTapItem(BuildContext context, Article article) {
    Navigator.push(context, MaterialPageRoute(builder: (context)=>NewsDetails(article, widget.title)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text(widget.title),
          backgroundColor: Colors.black,
        ),
        body: new Stack(children: <Widget>[
          new Image.asset(
            'images/b1.jpg',
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.cover,
          ),
          FutureBuilder(
              future: getData(widget.newsType),
              builder: (context, snapshot) {
                return snapshot.data != null
                    ? listViewWidget(snapshot.data)
                    : Center(child: CircularProgressIndicator());
              }),
        ]));
  }

  Like(Article article) {
    databaseReferencelike.push().set(article.toJson());
  }

  Dislike(Article article) {
    databaseReferencedislike.push().set({"title":article.title,"url":article.url,"source":article.source.name});
  }
}

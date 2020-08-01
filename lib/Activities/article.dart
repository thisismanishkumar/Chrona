import 'package:chrona_1/Activities/add_article.dart';
import 'package:chrona_1/Activities/article_component.dart';
import 'package:chrona_1/Activities/question.dart';
import 'package:chrona_1/UserInfo/state.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';

import 'account.dart';
import 'main.dart';

class Article extends StatefulWidget {
  @override
  _ArticleState createState() => _ArticleState();
}

class _ArticleState extends State<Article> {
  int selectedIndex = 2;
  FirebaseDatabase firebaseDatabase = FirebaseDatabase.instance;
  DatabaseReference databaseReferenceArticle,databaseReferenceUser;

  @override
  void setState(VoidCallback fn) {}
  
  @override
  void initState() {
    
    super.initState();
    databaseReferenceArticle = firebaseDatabase.reference().child("Article");
    databaseReferenceUser=firebaseDatabase.reference().child("Users");
  }

  TextEditingController headerController = new TextEditingController();
  TextEditingController bodyController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: new Text("Articles"),
          actions: <Widget>[
            IconButton(
              icon: CircleAvatar(
                radius: 18.0,
                backgroundImage: NetworkImage(StaticState.user.photoUrl),
                backgroundColor: Colors.transparent,
              ),
            )
          ],
          backgroundColor: Colors.black,
        ),
        body: new Column(
          children: <Widget>[
            new Flexible(
              child: new FirebaseAnimatedList(
                  query: databaseReferenceArticle
                      .orderByChild("verify")
                      .equalTo(true),
                  padding: new EdgeInsets.all(8.0),
                  reverse: false,
                  itemBuilder: (_, DataSnapshot snapshot,
                      Animation<double> animation, int x) {
                        return ArticleComponent(snapshot:snapshot);
                    // print(snapshot.value);
                  //  debugPrint(snapshot.value["user"]+"  0  "+StaticState.user.email);
                    
                  }),
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          elevation: 5.0,
          onPressed: addArticle,
          backgroundColor: Colors.redAccent,
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              title: new Text("Home"),
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.question_answer),
                title: new Text("Q/A"),
                backgroundColor: Colors.black),
            BottomNavigationBarItem(
                icon: Icon(Icons.description),
                title: new Text("Article"),
                backgroundColor: Colors.black),
            BottomNavigationBarItem(
                icon: Icon(Icons.account_circle), title: new Text("Account"))
          ],
          currentIndex: selectedIndex,
          selectedItemColor: Colors.red,
          onTap: _ontappeditem,
        ));
  }

  void addArticle() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => AddArticle()));
  }

  


  void _ontappeditem(int value) {
    if (value == 0) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => NewsMain()));
      // selectedIndex=0;
    }
    if (value == 1) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => Question_Route()));
    }
    if (value == 3) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => Account()));
      //selectedIndex=2;
    }
  }
  
}

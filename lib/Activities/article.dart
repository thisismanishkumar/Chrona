import 'package:chrona_1/Activities/add_article.dart';
import 'package:chrona_1/Activities/question.dart';
import 'package:chrona_1/UserInfo/state.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'account.dart';
import 'main.dart';

class Article extends StatefulWidget {
  @override
  _ArticleState createState() => _ArticleState();
}

class _ArticleState extends State<Article> {
  int selectedIndex = 2;
  FirebaseDatabase firebaseDatabase = FirebaseDatabase.instance;
  DatabaseReference databaseReferenceArticle;

  @override
  void setState(VoidCallback fn) {}
  static bool OnChanged;
  @override
  void initState() {
    OnChanged = false;
    super.initState();
    databaseReferenceArticle = firebaseDatabase.reference().child("Article");
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
                    headerController.text = snapshot.value["header"];
                    bodyController.text = snapshot.value["body"];
                    print(snapshot.value);
                    debugPrint(snapshot.value["user"]+"  0  "+StaticState.user.email);
                    return Slidable(
                      actionPane: SlidableDrawerActionPane(),
                      actionExtentRatio: 0.20,
                      child: new Card(
                        elevation: 5.0,
                        child: Column(
                          children: <Widget>[
                            Padding(padding: EdgeInsets.all(5.0)),
                            TextFormField(
                              readOnly: snapshot.value["user"].toString() ==
                                      StaticState.user.email.toString()
                                  ? false
                                  : true,
                              //initialValue: snapshot.value['header'].toString(),
                              onEditingComplete: () => OnChanged = true,
                              autocorrect: true,
                              autofocus: false,
                              controller: headerController,
                              maxLength: 128,
                              maxLines: null,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                              keyboardType: TextInputType.multiline,
                              decoration: InputDecoration(
                                  labelText: "Heading",
                                  hintText: 'Enter Heading ',
                                  prefixIcon: Icon(Icons.view_headline),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  )),
                            ),
                            Text(
                              "Questioner is ${snapshot.value["username"]}",
                              textAlign: TextAlign.left,
                            ),
                            Padding(padding: EdgeInsets.all(4.0)),
                            TextFormField(
                              readOnly: snapshot.value["user"].toString() ==
                                      StaticState.user.email.toString()
                                  ? false
                                  : true,
                              // initialValue: snapshot.value['body'].toString(),
                              onEditingComplete: () => OnChanged = true,
                              autocorrect: true,
                              autofocus: false,
                              controller: bodyController,
                              maxLength: 1024,
                              maxLines: null,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                              keyboardType: TextInputType.multiline,
                              decoration: InputDecoration(
                                  labelText: "Body",
                                  hintText: 'Enter Body ',
                                  prefixIcon: Icon(Icons.description),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  )),
                            ),
                            Row(
                              children: <Widget>[
                                Icon(Icons.check),
                                Text(
                                  " " + snapshot.value["likes"].toString(),
                                  style: TextStyle(color: Colors.indigo),
                                ),
                                Padding(
                                    padding:
                                        EdgeInsetsDirectional.only(start: 5.0)),
                                Icon(Icons.clear),
                                Text(
                                  " " + snapshot.value["dislikes"].toString(),
                                  style: TextStyle(color: Colors.red),
                                ),
                                Padding(padding: EdgeInsets.only(left: 190.0)),

                                RaisedButton(

                                  child: Text("UPDATE"),
                                  onPressed: snapshot.value["user"].toString() ==
                                              StaticState.user.email.toString()
                                          ? ()=>update(snapshot.key)
                                          : null,
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      secondaryActions: <Widget>[
                        IconSlideAction(
                          caption: 'Like',
                          color: Colors.blue,
                          icon: Icons.check,
                          onTap: () => Like(snapshot.key),
                        ),
                        IconSlideAction(
                          caption: 'Dislike',
                          color: Colors.red,
                          icon: Icons.clear,
                          onTap: () => Dislike(snapshot.key),
                        ),
                      ],
                    );
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

  Like(String key) {
    databaseReferenceArticle.child(key).once().then((DataSnapshot snapshot) {
      int likes = snapshot.value["likes"];
      print("likes are ${likes}");
      databaseReferenceArticle.child(key).child("likes").set(likes + 1);
    });
  }

  Dislike(String key) {
    databaseReferenceArticle.child(key).once().then((DataSnapshot snapshot) {
      int dislikes = snapshot.value["dislikes"];
      print("likes are ${dislikes}");
      databaseReferenceArticle.child(key).child("dislikes").set(dislikes + 1);
    });
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

  update(String key) {
    databaseReferenceArticle
        .child(key)
        .child("header")
        .set(headerController.text);
    databaseReferenceArticle.child(key).child("body").set(bodyController.text);
  }
}

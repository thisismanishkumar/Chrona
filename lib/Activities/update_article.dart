import 'package:chrona_1/Activities/question.dart';
import 'package:chrona_1/UserInfo/state.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'account.dart';
import 'article.dart';
import 'main.dart';
class UpdateArticle extends StatefulWidget {
  String KEY,head,body;
  UpdateArticle(this.KEY, this.head, this.body);

  @override
  _UpdateArticleState createState() => _UpdateArticleState(KEY,head,body);
}

class _UpdateArticleState extends State<UpdateArticle> {
  int selectedIndex=2;
  String KEY,head,body;
  _UpdateArticleState(this.KEY, this.head, this.body);
  FirebaseDatabase firebaseDatabase;
  DatabaseReference databaseReference;
  TextEditingController header= TextEditingController();
  TextEditingController BODY=TextEditingController();


  @override
  void initState() {
    firebaseDatabase=FirebaseDatabase.instance;
    databaseReference=firebaseDatabase.reference().child("Article");
  }



  @override
  Widget build(BuildContext context) {
    header.text=head;
    BODY.text=body;

    return Scaffold(
        appBar: AppBar(
          title: new Text("Update Article"),
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
            Card(
              elevation: 5.0,
              child: Column(
                children: <Widget>[
                  Padding(padding: EdgeInsets.all(5.0)),
                  TextFormField(
                    readOnly: false,
                    autocorrect: true,
                    autofocus: false,
                    controller: header,
                    maxLength: 256,
                    maxLines: null,
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                        labelText: "Header",
                        prefixIcon: Icon(Icons.view_headline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        )),
                  ),
                  Padding(padding: EdgeInsets.all(10.0)),
                  TextFormField(
                    readOnly: false,
                    autocorrect: true,
                    autofocus: false,
                    controller: BODY,
                    maxLength: 512,
                    maxLines: null,
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                        labelText: "Body",
                        prefixIcon: Icon(Icons.description),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        )),
                  ),
                  RaisedButton(
                    onPressed: update,
                    child: Text("Submit"),)
                ],
              ),
            ),
          ],
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
                icon: Icon(Icons.description), title: new Text("Article"),backgroundColor: Colors.black),
            BottomNavigationBarItem(
                icon: Icon(Icons.account_circle), title: new Text("Account"))
          ],
          currentIndex: selectedIndex,
          selectedItemColor: Colors.red,
          onTap: _ontappeditem,
        ));
  }

  update() {
    databaseReference.child(KEY).child("header").set(header.text);
    databaseReference.child(KEY).child("body").set(BODY.text);
    databaseReference.child(KEY).child("verify").set(false);
    databaseReference.child(KEY).child("likeCount").set(0);
    databaseReference.child(KEY).child("dislikeCount").set(0);
    databaseReference.child(KEY).child("likes").set([]);
    databaseReference.child(KEY).child("dislikes").set([]);

    Navigator.pop(context);
  }

  void _ontappeditem(int value) {
    if (value == 0) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => NewsMain()));
      // selectedIndex=0;
    }
    if(value==1)
      {
        Navigator.push(context, MaterialPageRoute(builder: (context)=>Question_Route()));
      }
    if (value == 2) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => Article()));
    }
    if (value == 3) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => Account()));
    }
  }
}

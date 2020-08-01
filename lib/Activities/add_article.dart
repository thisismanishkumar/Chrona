import 'dart:convert';

import 'package:chrona_1/Activities/article.dart';
import 'package:chrona_1/Activities/question.dart';
import 'package:chrona_1/UserInfo/state.dart';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';

import 'account.dart';
import 'main.dart';

class AddArticle extends StatefulWidget {
  @override
  _AddArticleState createState() => _AddArticleState();
}

class _AddArticleState extends State<AddArticle> {
  FirebaseDatabase firebaseDatabase = FirebaseDatabase.instance;
  DatabaseReference databaseReferenceArticle, databaseReferenceUser;

  @override
  void initState() {
    databaseReferenceArticle = firebaseDatabase.reference().child("Article");
    databaseReferenceUser = firebaseDatabase.reference().child("Users");
  }

  final TextEditingController headerController = new TextEditingController();
  final TextEditingController bodyController = new TextEditingController();
  int selectedIndex = 2;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: new Text("Add Article"),
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
        body: new Container(
          padding: EdgeInsets.all(6.0),
          child: new ListView(
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(padding: EdgeInsetsDirectional.only(start: 5.0)),
                  TextField(
                      autocorrect: true,
                      autofocus: true,
                      controller: headerController,
                      maxLength: 256,
                      maxLines: 8,
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                          labelText: "Header you want to display!!!",
                          hintText: 'Write Intutive Header ',
                          prefixIcon: Icon(Icons.view_headline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ))),
                  Padding(
                    padding: EdgeInsetsDirectional.only(top: 10.0),
                  ),
                  TextField(
                      autocorrect: true,
                      autofocus: true,
                      controller: bodyController,
                      maxLength: 1024,
                      maxLines: 18,
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                          labelText: "Body you want to show",
                          hintText: 'Write your Article here',
                          prefixIcon: Icon(Icons.grade),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ))),
                  Padding(
                    padding: EdgeInsetsDirectional.only(top: 10.0),
                  ),
                  RaisedButton(
                    onPressed: () => submit(context),
                    child: Text("Submit"),
                    elevation: 5.0,
                  )
                ],
              ),
            ],
          ),
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

  void submit(BuildContext context) {
    if (headerController.text.isEmpty || headerController.text.isEmpty) {
      Flushbar(
        padding: EdgeInsets.all(10.0),
        borderRadius: 8,
        backgroundGradient: LinearGradient(
          colors: [Colors.amber.shade500, Colors.orange.shade500],
          stops: [0.5, 1],
        ),
        boxShadows: [
          BoxShadow(
            color: Colors.black45,
            offset: Offset(3, 3),
            blurRadius: 3,
          ),
        ],
        dismissDirection: FlushbarDismissDirection.HORIZONTAL,
        forwardAnimationCurve: Curves.fastLinearToSlowEaseIn,
        title: 'Something Missing!!!',
        message: 'Check whether above two fields are filled or not.',
        duration: Duration(seconds: 4),
      )..show(context);
    } else {
      var firstChunk = utf8.encode(headerController.text);
      var secondChunk = utf8.encode(bodyController.text);

      var output = new AccumulatorSink<Digest>();
      var input = sha1.startChunkedConversion(output);
      input.add(firstChunk);
      input.add(secondChunk); // call `add` for every chunk of input data
      input.close();
      var digest = output.events.single;
      databaseReferenceArticle
          .child(digest.toString())
          .once()
          .then((DataSnapshot data) {
        if (data.value != null) {
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text("This Question already exists !!"),
          ));
        } else {
          var firstChunk = utf8.encode(headerController.text);
          var secondChunk = utf8.encode(bodyController.text);

          var output = new AccumulatorSink<Digest>();
          var input = sha1.startChunkedConversion(output);
          input.add(firstChunk);
          input.add(secondChunk); // call `add` for every chunk of input data
          input.close();
          var digest = output.events.single;
          databaseReferenceArticle.child(digest.toString()).set({
            "header": headerController.text,
            "body": bodyController.text,
            "verify": false,
            "user": StaticState.user.email.toString(),
            "username": StaticState.user.displayName.toString(),
            "likes": [],
            "likeCount":0,
            "dislikes": [],
            "dislikeCount":0,
          });
          String s = StaticState.user.email;
          s = s.substring(0, s.indexOf("@"));
          databaseReferenceUser
              .child(s)
              .child("article")
              .push()
              .set({"qid": digest.toString(), "verify": false});
          Navigator.pop(context);
        }
      });
    }
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
    if (value == 2) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => Article()));
    }
    if (value == 3) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => Account()));
      //selectedIndex=2;
    }
  }
}

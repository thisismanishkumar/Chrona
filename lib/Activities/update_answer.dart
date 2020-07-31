import 'package:chrona_1/Activities/answer.dart';
import 'package:chrona_1/UserInfo/state.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'account.dart';
import 'article.dart';
import 'main.dart';

class UpdateAnswer extends StatefulWidget {
  String ansId,ans,qid;
  UpdateAnswer(this.qid,this.ansId, this.ans);

  @override
  _UpdateAnswerState createState() => _UpdateAnswerState(qid,ansId,ans);
}

class _UpdateAnswerState extends State<UpdateAnswer> {
  FirebaseDatabase firebaseDatabase;
  String ansId,ans,qid;
  int selectedIndex = 1;

  _UpdateAnswerState(this.qid,this.ansId, this.ans);

  DatabaseReference databaseReference;
  @override
  void initState() {
    firebaseDatabase = FirebaseDatabase.instance;
    databaseReference = firebaseDatabase.reference().child("Question").child(qid).child("Answer");

  }

  TextEditingController answer = new TextEditingController();


  @override
  Widget build(BuildContext context) {
    answer.text=ans;
    return Scaffold(
        appBar: AppBar(
          title: new Text("Update Answer"),
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
                    controller: answer,
                    maxLength: 256,
                    maxLines: null,
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                        labelText: "Answer",
                        prefixIcon: Icon(Icons.question_answer),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        )),
                  ),
                  Padding(padding: EdgeInsets.all(10.0)),
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
                icon: Icon(Icons.description), title: new Text("Article")),
            BottomNavigationBarItem(
                icon: Icon(Icons.account_circle), title: new Text("Account"))
          ],
          currentIndex: selectedIndex,
          selectedItemColor: Colors.red,
          onTap: _ontappeditem,
        ));
  }

  update() {
    databaseReference.child(ansId).child("answer").set(answer.text);
    databaseReference.child(ansId).child("likeCount").set(0);
    databaseReference.child(ansId).child("dislikeCount").set(0);
    databaseReference.child(ansId).child("likes").set([]);
    databaseReference.child(ansId).child("dislikes").set([]);
    Navigator.pop(context);
  }

  void _ontappeditem(int value) {
    if (value == 0) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => NewsMain()));
      // selectedIndex=0;
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

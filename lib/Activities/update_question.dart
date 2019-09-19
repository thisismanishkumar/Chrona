import 'package:chrona_1/Activities/question.dart';
import 'package:chrona_1/UserInfo/state.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'account.dart';
import 'article.dart';
import 'main.dart';

class UpdateQuestion extends StatefulWidget {
  String qid, value;
  UpdateQuestion(this.qid, this.value);

  @override
  _UpdateQuestionState createState() => _UpdateQuestionState(qid, value);
}

class _UpdateQuestionState extends State<UpdateQuestion> {
  FirebaseDatabase firebaseDatabase;
  String qid, value;
  int selectedIndex = 1;
  _UpdateQuestionState(this.qid, this.value);
  DatabaseReference databaseReference;
  @override
  void initState() {
    firebaseDatabase = FirebaseDatabase.instance;
    databaseReference = firebaseDatabase.reference().child("Question");
  }

  TextEditingController question = new TextEditingController();


  @override
  Widget build(BuildContext context) {
    question.text=value;
    return Scaffold(
        appBar: AppBar(
          title: new Text("Update Question"),
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
                    controller: question,
                    maxLength: 256,
                    maxLines: null,
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                        labelText: "Question",
                        hintText: 'Enter Question ',
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
    databaseReference.child(qid).child("question").set(question.text);
    databaseReference.child(qid).child("verify").set(false);

    Navigator.push(context, MaterialPageRoute(builder: (context)=>Question_Route()));
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

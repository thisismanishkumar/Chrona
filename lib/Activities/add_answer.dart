import 'dart:convert';

import 'package:chrona_1/Activities/question.dart';
import 'package:chrona_1/UserInfo/state.dart';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'account.dart';
import 'article.dart';
import 'main.dart';

class AddAnswer extends StatefulWidget {
  String ques;
  String KEY;
  AddAnswer(this.ques, this.KEY);

  @override
  _AddAnswerState createState() => _AddAnswerState(ques, KEY);
}

class _AddAnswerState extends State<AddAnswer> {
  int selectedIndex = 1;
  DatabaseReference databaseReference;
  FirebaseDatabase firebaseDatabase;
  String ques, KEY;

  _AddAnswerState(this.ques, this.KEY);

  @override
  void initState() {
    firebaseDatabase = FirebaseDatabase.instance;
    databaseReference = firebaseDatabase.reference().child("Question");
  }

  TextEditingController answer = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: new Text("Add Answer"),
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
            Padding(
              padding: EdgeInsets.all(8.0),
            ),
            TextFormField(
              readOnly: true,
              autocorrect: true,
              autofocus: false,
              initialValue: ques,
              maxLength: 256,
              maxLines: null,
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                  labelText: "Question",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  )),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
            ),
            TextField(
                autocorrect: true,
                autofocus: true,
                controller: answer,
                maxLength: 512,
                maxLines: null,
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                    labelText: "Answer",
                    hintText: 'Write Your answer here  ',
                    prefixIcon: Icon(Icons.description),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ))),
            Padding(
              padding: EdgeInsets.all(8.0),
            ),
            RaisedButton(
              onPressed: () => submit(context),
              child: Text("Submit"),
              elevation: 5.0,
            )
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

  void _ontappeditem(int value) {
    if (value == 0) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => NewsMain()));
      // selectedIndex=0;
    }
    if (value == 1) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => Question_Route()));
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

  void submit(BuildContext context) {
    if (answer.text.isEmpty) {
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
        message: 'Check whether you have written your answer or not.',
        duration: Duration(seconds: 4),
      )..show(context);
    } else {
      var firstChunk = utf8.encode(answer.text);
      var secondChunk = utf8.encode(StaticState.user.email);

      var output = new AccumulatorSink<Digest>();
      var input = sha1.startChunkedConversion(output);
      input.add(firstChunk);
      input.add(secondChunk); // call `add` for every chunk of input data
      input.close();
      var digest = output.events.single;
      databaseReference.child(KEY).child("Answer").child(digest.toString()).set({
        "answer": answer.text,
        "user": StaticState.user.email.toString(),
        "username": StaticState.user.displayName.toString(),
        "likes": 0,
        "dislikes": 0
      });
      Navigator.pop(context);
    }
  }
}

import 'package:chrona_1/Activities/add_answer.dart';
import 'package:chrona_1/Activities/answer_component.dart';
import 'package:chrona_1/UserInfo/state.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';


import 'account.dart';
import 'article.dart';
import 'main.dart';

class Answer extends StatefulWidget {
  String Id;
  String KEY;
  Answer(this.Id, this.KEY);

  @override
  _AnswerState createState() => _AnswerState(Id, KEY);
}

class _AnswerState extends State<Answer> {
  String Ques;
  String KEY;

  _AnswerState(this.Ques, this.KEY);

  int selectedIndex = 1;
  DatabaseReference databaseReference;
  FirebaseDatabase firebaseDatabase;

  @override
  void initState() {
    firebaseDatabase = FirebaseDatabase.instance;
    databaseReference =
        firebaseDatabase.reference().child("Question").child(KEY);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: new Text("Answer"),
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
              initialValue: Ques,
              maxLength: 256,
              maxLines: null,
              style:
                  TextStyle(fontWeight: FontWeight.bold),
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                  labelText: "Question",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  )),
            ),
            new Flexible(
              child: new FirebaseAnimatedList(
                  query: databaseReference.child("Answer"),
                  padding: new EdgeInsets.all(8.0),
                  reverse: false,
                  itemBuilder: (_, DataSnapshot snapshot,
                      Animation<double> animation, int x) {
                    // tags.text=snapshot.value["tags"];
                    //print(snapshot.value);
                    return AnswerComponent(
                        snapshot: snapshot, questionKey: KEY);
                  }),
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          elevation: 5.0,
          onPressed: () => addanswer(Ques, KEY),
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
    if (value == 2) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => Article()));
    }
    if (value == 3) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => Account()));
    }
  }

  void addanswer(String id, String key) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => AddAnswer(id, key)));
  }
}

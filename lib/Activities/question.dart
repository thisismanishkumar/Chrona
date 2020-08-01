import 'package:chrona_1/Activities/account.dart';
import 'package:chrona_1/Activities/add_question.dart';
import 'package:chrona_1/Activities/article.dart';
import 'package:chrona_1/Activities/main.dart';
import 'package:chrona_1/Activities/question_component.dart';
import 'package:chrona_1/UserInfo/state.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class Question_Route extends StatefulWidget {
  @override
  _Question_RouteState createState() => _Question_RouteState();
}

class _Question_RouteState extends State<Question_Route> {
  int selectedIndex = 1;
  DatabaseReference databaseReference;
  FirebaseDatabase firebaseDatabase;
  Query query;
  List<bool> liked,disliked;
  @override
  void initState() {
    firebaseDatabase = FirebaseDatabase.instance;
    databaseReference = firebaseDatabase.reference().child("Question");
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: new Text("Question"),
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
                  query: databaseReference.orderByChild("verify").equalTo(true),
                  padding: new EdgeInsets.all(8.0),
                  reverse: false,
                  itemBuilder: (_, DataSnapshot snapshot,
                      Animation<double> animation, int x) {
                        return QuestionComponent(snapshot: snapshot);
                    //Question component
                  }),
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          elevation: 5.0,
          onPressed: addquestion,
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

  void addquestion() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => AddQuestion()));
  }
  
}





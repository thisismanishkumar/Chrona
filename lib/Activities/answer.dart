import 'package:chrona_1/Activities/add_answer.dart';
import 'package:chrona_1/Activities/update_answer.dart';
import 'package:chrona_1/UserInfo/state.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'account.dart';
import 'article.dart';
import 'main.dart';

class Answer extends StatefulWidget {
  String Id;
  String KEY;
  Answer(this.Id, this.KEY);

  @override
  _AnswerState createState() => _AnswerState(Id,KEY);
}

class _AnswerState extends State<Answer> {
  String Ques;
  String KEY;

  _AnswerState(this.Ques,  this.KEY);

  int selectedIndex = 1;
  DatabaseReference databaseReference;
  FirebaseDatabase firebaseDatabase;

  @override
  void initState() {
    firebaseDatabase = FirebaseDatabase.instance;
    databaseReference = firebaseDatabase.reference().child("Question").child(KEY);
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
            Padding(padding: EdgeInsets.all(8.0),),
            TextFormField(
              readOnly: true,
              autocorrect: true,
              autofocus: false,
              initialValue: Ques,
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
            new Flexible(
              child: new FirebaseAnimatedList(
                  query: databaseReference.child("Answer"),
                  padding: new EdgeInsets.all(8.0),
                  reverse: false,
                  itemBuilder: (_, DataSnapshot snapshot,
                      Animation<double> animation, int x) {

                    TextEditingController answer = new TextEditingController();
                    answer.text=snapshot.value["answer"];

                    // tags.text=snapshot.value["tags"];
                    //print(snapshot.value);
                    return Slidable(


                      actionPane: SlidableDrawerActionPane(),
                      actionExtentRatio: 0.20,
                      child: new Card(
                        elevation: 5.0,
                        child: Column(
                          children: <Widget>[
                            Padding(padding: EdgeInsets.all(5.0)),

                            TextFormField(
                              readOnly: true,
                              autocorrect: true,
                              autofocus: false,
                              controller: answer,
                              //initialValue: snapshot.value["answer"],
                              maxLength: 256,
                              maxLines: null,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                              keyboardType: TextInputType.multiline,
                              decoration: InputDecoration(
                                  labelText: "Answer",
                                  hintText: 'Enter Answer ',
                                  prefixIcon: Icon(Icons.question_answer),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  )),
                            ),
                            Text(
                              "Answer is uploaded by ${snapshot.value["username"]}",
                              textAlign: TextAlign.left,
                            ),
                            Padding(padding: EdgeInsets.all(4.0)),

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
                                Padding(padding: EdgeInsets.only(left: 50.0)),

                                Padding(padding: EdgeInsets.only(left: 50.0)),
                                RaisedButton(
                                  child: Text("UPDATE"),
                                  onPressed:
                                      snapshot.value["user"].toString() ==
                                              StaticState.user.email.toString()
                                          ? () => update(KEY,snapshot.key,snapshot.value["answer"])
                                          : null,
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        IconSlideAction(
                          caption: 'Delete',
                          color: Colors.red,
                          icon: Icons.delete,
                          onTap:    snapshot.value["user"].toString() ==
                              StaticState.user.email.toString()
                              ? () => databaseReference.child("Answer").child(snapshot.key).remove()
                              : null,
                        )
                      ],
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
          onPressed: ()=>addanswer(Ques,KEY),
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
        context, MaterialPageRoute(builder: (context) => AddAnswer(id,key)));
  }

  Like(String key) {
    databaseReference.child("Answer").child(key).once().then((DataSnapshot snapshot) {
      int likes = snapshot.value["likes"];
      print("likes are ${likes}");
      databaseReference.child("Answer").child(key).child("likes").set(likes + 1);
    });
  }

  Dislike(String key) {
    databaseReference.child("Answer").child(key).once().then((DataSnapshot snapshot) {
      int dislikes = snapshot.value["dislikes"];
      print("likes are ${dislikes}");
      databaseReference.child("Answer").child(key).child("dislikes").set(dislikes + 1);
    });
  }

  update(String qid, ansId, ans) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context)=>UpdateAnswer(qid,ansId,ans)));

  }
}

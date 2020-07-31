import 'dart:collection';
import 'dart:collection' as prefix0;

import 'package:chrona_1/Activities/account.dart';
import 'package:chrona_1/Activities/add_question.dart';
import 'package:chrona_1/Activities/answer.dart';
import 'package:chrona_1/Activities/article.dart';
import 'package:chrona_1/Activities/main.dart';
import 'package:chrona_1/Activities/update_question.dart';
import 'package:chrona_1/UserInfo/state.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class Question_Route extends StatefulWidget {
  @override
  _Question_RouteState createState() => _Question_RouteState();
}

class _Question_RouteState extends State<Question_Route> {
  int selectedIndex = 1;
  DatabaseReference databaseReference;
  FirebaseDatabase firebaseDatabase;
  Query query;
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
                              initialValue: snapshot.value["question"],
                              maxLength: 256,
                              maxLines: 6,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                              keyboardType: TextInputType.multiline,
                              decoration: InputDecoration(
                                  labelText: "Question",
                                  hintText: 'Enter Question ',
                                  prefixIcon: Icon(Icons.question_answer),
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
                              readOnly: true,
                              autocorrect: true,
                              autofocus: false,
                              initialValue: snapshot.value["tags"].toString(),
                              maxLength: 256,
                              maxLines: null,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                              keyboardType: TextInputType.multiline,
                              decoration: InputDecoration(
                                  labelText: "Tags",
                                  hintText: 'Enter Tags ',
                                  prefixIcon: Icon(Icons.grade),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  )),
                            ),
                            Row(
                              children: <Widget>[
                                Icon(Icons.thumb_up,
//                                color: isLiked(snapshot.key),
                                ),
                                Text(
                                  snapshot.value["likeCount"].toString(),
                                  style: TextStyle(color: Colors.indigo),
                                ),
                                Padding(
                                    padding:
                                        EdgeInsetsDirectional.only(start: 5.0)),
                                Icon(Icons.thumb_down),
                                Text(
                                  " " + snapshot.value["dislikeCount"].toString(),
                                  style: TextStyle(color: Colors.red),
                                ),
                                Padding(padding: EdgeInsets.only(left: 50.0)),
                                RaisedButton(
                                  onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Answer(
                                              snapshot.value["question"],
                                              snapshot.key))),
                                  child: Text("View"),
                                ),
                                Padding(padding: EdgeInsets.only(left: 50.0)),
                                RaisedButton(
                                  child: Text("UPDATE"),
                                  onPressed: snapshot.value["user"]
                                              .toString() ==
                                          StaticState.user.email.toString()
                                      ? () => update(snapshot.key,
                                          snapshot.value["question"].toString())
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
                          onTap: snapshot.value["user"]
                              .toString() ==
                              StaticState.user.email.toString()
                              ? () => databaseReference.child(snapshot.key).remove()
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
   Future<Colors> isLiked(String key) {
    databaseReference.child(key).child("likes").child(StaticState.user.email.substring(0,StaticState.user.email.indexOf("@"))).once().then((DataSnapshot snapshot) {
      if (snapshot.value != null && snapshot.value["flag"]) {
        return Colors.blueAccent;
      }
      else{
        return Colors.black12;
      }
    });
  }

  Like(String key) {
    bool flag=false;
    databaseReference.child(key).child("likes").child(StaticState.user.email.substring(0,StaticState.user.email.indexOf("@"))).once().then((DataSnapshot snapshot){
      if(snapshot.value==null){
        flag=true;
        databaseReference.child(key).child("likes").child(StaticState.user.email.substring(0,StaticState.user.email.indexOf("@"))).set({"flag":true});
        databaseReference.child(key).once().then((DataSnapshot snapshot) {
          int likes = snapshot.value["likeCount"];
          databaseReference.child(key).child("likeCount").set(likes+1);
        });
      }
      else{
        flag=snapshot.value["flag"];
        if(flag==true) {
          flag = false;
          databaseReference.child(key).once().then((DataSnapshot snapshot) {
          int likes = snapshot.value["likeCount"];
            databaseReference.child(key).child("likeCount").set(likes-1);
          });
        }
        else{
          flag = true;
          print("%%");
          databaseReference.child(key).once().then((DataSnapshot snapshot) {
            int likes = snapshot.value["likeCount"];
            databaseReference.child(key).child("likeCount").set(likes+1);
          });
        }
        databaseReference.child(key).child("likes").child(StaticState.user.email.substring(0,StaticState.user.email.indexOf("@"))).set({"flag":flag});
      }
      checkDislike(flag,key);
    });
  }
  checkDislike(bool flag, String key){
    if(flag==true) {
      databaseReference.child(key).child("dislikes").child(
          StaticState.user.email.substring(
              0, StaticState.user.email.indexOf("@"))).once().then((
          DataSnapshot snapshot) {
        if (snapshot.value != null) {
          bool flag1 = snapshot.value["flag"];
          if (flag1 == true) {
            flag1 = false;
            databaseReference.child(key).once().then((DataSnapshot snapshot) {
              int dislikes = snapshot.value["dislikeCount"];
              databaseReference.child(key).child("dislikeCount").set(
                  dislikes - 1);
            });
          }
          databaseReference.child(key).child("dislikes").child(
              StaticState.user.email.substring(
                  0, StaticState.user.email.indexOf("@"))).set({"flag": flag1});
        }
      });
    }
  }


  Dislike(String key) {
    bool flag;
    databaseReference.child(key).child("dislikes").child(StaticState.user.email.substring(0,StaticState.user.email.indexOf("@"))).once().then((DataSnapshot snapshot){
      if(snapshot.value==null){
        flag = true;
        databaseReference.child(key).child("dislikes").child(StaticState.user.email.substring(0,StaticState.user.email.indexOf("@"))).set({"flag":true});
        databaseReference.child(key).once().then((DataSnapshot snapshot) {
          int dislikes = snapshot.value["dislikeCount"];
          databaseReference.child(key).child("dislikeCount").set(dislikes+1);
        });
      }
      else{
        flag=snapshot.value["flag"];
        if(flag==true) {
          flag = false;
          databaseReference.child(key).once().then((DataSnapshot snapshot) {
            int dislikes = snapshot.value["dislikeCount"];
            databaseReference.child(key).child("dislikeCount").set(dislikes-1);
          });
        }
        else{
          flag=true;
          databaseReference.child(key).once().then((DataSnapshot snapshot) {
            int dislikes = snapshot.value["dislikeCount"];
            databaseReference.child(key).child("dislikeCount").set(dislikes+1);
          });
        }
        databaseReference.child(key).child("dislikes").child(StaticState.user.email.substring(0,StaticState.user.email.indexOf("@"))).set({"flag":flag});
      }
      checkLike(flag,key);
    });

  }
  checkLike(bool flag, String key){
    if(flag==true) {
      databaseReference.child(key).child("likes").child(
          StaticState.user.email.substring(
              0, StaticState.user.email.indexOf("@"))).once().then((
          DataSnapshot snapshot) {
        if (snapshot.value != null) {
          bool flag1 = snapshot.value["flag"];
          if (flag1 == true) {
            flag1 = false;
            databaseReference.child(key).once().then((DataSnapshot snapshot) {
              int dislikes = snapshot.value["likeCount"];
              databaseReference.child(key).child("likeCount").set(
                  dislikes - 1);
            });
          }
          databaseReference.child(key).child("likes").child(
              StaticState.user.email.substring(
                  0, StaticState.user.email.indexOf("@"))).set({"flag": flag1});
        }
      });
    }
  }

  update(String key, value) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => UpdateQuestion(key, value)));
  }
}



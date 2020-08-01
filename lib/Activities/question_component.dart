import 'package:chrona_1/Activities/update_question.dart';
import 'package:chrona_1/UserInfo/state.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flushbar/flushbar.dart';
import 'answer.dart';

class QuestionComponent extends StatefulWidget {
  final DataSnapshot snapshot;

  const QuestionComponent({Key key, this.snapshot}) : super(key: key);
  @override
  _QuestionComponentState createState() => _QuestionComponentState();
}

class _QuestionComponentState extends State<QuestionComponent> {
  DatabaseReference databaseReference;
  FirebaseDatabase firebaseDatabase;
  bool isLiked, isDisliked, isLoading;
  @override
  void initState() {
    firebaseDatabase = FirebaseDatabase.instance;
    databaseReference = firebaseDatabase.reference().child("Question");
    isLiked = false;
    isDisliked = false;
    isLoading = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DataSnapshot snapshot = widget.snapshot;
    loadLikeData(snapshot.key);
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.20,
      child: new Card(
        elevation: 5.0,
        child: isLoading
            ? Column(children: <Widget>[
                Padding(padding: EdgeInsets.all(5.0)),
                Center(child: CircularProgressIndicator()),
                Padding(padding: EdgeInsets.all(5.0)),
              ])
            : Column(
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
                        color: Colors.black, fontWeight: FontWeight.bold),
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
                      Icon(
                        Icons.thumb_up,
                        color: isLiked ? Colors.blueAccent : Colors.black45,
                      ),
                      Text(
                        snapshot.value["likeCount"].toString(),
                        style: TextStyle(color: Colors.indigo),
                      ),
                      Padding(padding: EdgeInsetsDirectional.only(start: 5.0)),
                      Icon(
                        Icons.thumb_down,
                        color: isDisliked ? Colors.redAccent : Colors.black45,
                      ),
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
                                    snapshot.value["question"], snapshot.key))),
                        child: Text("View"),
                      ),
                      Padding(padding: EdgeInsets.only(left: 50.0)),
                      RaisedButton(
                        child: Text("UPDATE"),
                        onPressed: snapshot.value["user"].toString() ==
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
          onTap: ()=>checkForDelete(context, snapshot.key, snapshot.value["user"])
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
  }

  void loadLikeData(String key) {
    bool liked, disliked;
    databaseReference
        .child(key)
        .child("likes")
        .child(StaticState.user.email
            .substring(0, StaticState.user.email.indexOf("@")))
        .once()
        .then((snapshot) {
      if (snapshot.value != null && snapshot.value["flag"]) {
        liked = true;
      } else {
        liked = false;
      }
      databaseReference
          .child(key)
          .child("dislikes")
          .child(StaticState.user.email
              .substring(0, StaticState.user.email.indexOf("@")))
          .once()
          .then((snapshot) {
        if (snapshot.value != null && snapshot.value["flag"]) {
          disliked = true;
        } else {
          disliked = false;
        }
        setState(() {
          isLiked = liked;
          isDisliked = disliked;
          isLoading = false;
        });
      });
    });
  }

  Like(String key) {
    bool flag = false;
    databaseReference
        .child(key)
        .child("likes")
        .child(StaticState.user.email
            .substring(0, StaticState.user.email.indexOf("@")))
        .once()
        .then((DataSnapshot snapshot) {
      if (snapshot.value == null) {
        flag = true;
        databaseReference
            .child(key)
            .child("likes")
            .child(StaticState.user.email
                .substring(0, StaticState.user.email.indexOf("@")))
            .set({"flag": true});
        databaseReference.child(key).once().then((DataSnapshot snapshot) {
          int likes = snapshot.value["likeCount"];
          databaseReference.child(key).child("likeCount").set(likes + 1);
        });
      } else {
        flag = snapshot.value["flag"];
        if (flag == true) {
          flag = false;
          databaseReference.child(key).once().then((DataSnapshot snapshot) {
            int likes = snapshot.value["likeCount"];
            databaseReference.child(key).child("likeCount").set(likes - 1);
          });
        } else {
          flag = true;
          print("%%");
          databaseReference.child(key).once().then((DataSnapshot snapshot) {
            int likes = snapshot.value["likeCount"];
            databaseReference.child(key).child("likeCount").set(likes + 1);
          });
        }
        databaseReference
            .child(key)
            .child("likes")
            .child(StaticState.user.email
                .substring(0, StaticState.user.email.indexOf("@")))
            .set({"flag": flag});
      }
      checkDislike(flag, key);
    });
  }

  checkDislike(bool flag, String key) {
    if (flag == true) {
      databaseReference
          .child(key)
          .child("dislikes")
          .child(StaticState.user.email
              .substring(0, StaticState.user.email.indexOf("@")))
          .once()
          .then((DataSnapshot snapshot) {
        if (snapshot.value != null) {
          bool flag1 = snapshot.value["flag"];
          if (flag1 == true) {
            flag1 = false;
            databaseReference.child(key).once().then((DataSnapshot snapshot) {
              int dislikes = snapshot.value["dislikeCount"];
              databaseReference
                  .child(key)
                  .child("dislikeCount")
                  .set(dislikes - 1);
            });
          }
          databaseReference
              .child(key)
              .child("dislikes")
              .child(StaticState.user.email
                  .substring(0, StaticState.user.email.indexOf("@")))
              .set({"flag": flag1});
        }
      });
    }
  }

  Dislike(String key) {
    bool flag;
    databaseReference
        .child(key)
        .child("dislikes")
        .child(StaticState.user.email
            .substring(0, StaticState.user.email.indexOf("@")))
        .once()
        .then((DataSnapshot snapshot) {
      if (snapshot.value == null) {
        flag = true;
        databaseReference
            .child(key)
            .child("dislikes")
            .child(StaticState.user.email
                .substring(0, StaticState.user.email.indexOf("@")))
            .set({"flag": true});
        databaseReference.child(key).once().then((DataSnapshot snapshot) {
          int dislikes = snapshot.value["dislikeCount"];
          databaseReference.child(key).child("dislikeCount").set(dislikes + 1);
        });
      } else {
        flag = snapshot.value["flag"];
        if (flag == true) {
          flag = false;
          databaseReference.child(key).once().then((DataSnapshot snapshot) {
            int dislikes = snapshot.value["dislikeCount"];
            databaseReference
                .child(key)
                .child("dislikeCount")
                .set(dislikes - 1);
          });
        } else {
          flag = true;
          databaseReference.child(key).once().then((DataSnapshot snapshot) {
            int dislikes = snapshot.value["dislikeCount"];
            databaseReference
                .child(key)
                .child("dislikeCount")
                .set(dislikes + 1);
          });
        }
        databaseReference
            .child(key)
            .child("dislikes")
            .child(StaticState.user.email
                .substring(0, StaticState.user.email.indexOf("@")))
            .set({"flag": flag});
      }
      checkLike(flag, key);
    });
  }

  checkLike(bool flag, String key) {
    if (flag == true) {
      databaseReference
          .child(key)
          .child("likes")
          .child(StaticState.user.email
              .substring(0, StaticState.user.email.indexOf("@")))
          .once()
          .then((DataSnapshot snapshot) {
        if (snapshot.value != null) {
          bool flag1 = snapshot.value["flag"];
          if (flag1 == true) {
            flag1 = false;
            databaseReference.child(key).once().then((DataSnapshot snapshot) {
              int dislikes = snapshot.value["likeCount"];
              databaseReference.child(key).child("likeCount").set(dislikes - 1);
            });
          }
          databaseReference
              .child(key)
              .child("likes")
              .child(StaticState.user.email
                  .substring(0, StaticState.user.email.indexOf("@")))
              .set({"flag": flag1});
        }
      });
    }
  }
  checkForDelete(BuildContext context, String key, String user) {
    if (user == StaticState.user.email.toString()) {
      databaseReference.child(key).remove();
      Flushbar(
        padding: EdgeInsets.all(10.0),
        borderRadius: 8,
        backgroundGradient: LinearGradient(
          colors: [Colors.green, Colors.lightGreen],
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
        title: 'Successful!',
        message: 'Your Question has been deleted successfully!!!',
        duration: Duration(seconds: 4),
      )..show(context);
    } else {
      Flushbar(
        padding: EdgeInsets.all(10.0),
        borderRadius: 8,
        backgroundGradient: LinearGradient(
          colors: [Colors.deepOrange, Colors.deepOrangeAccent],
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
        title: 'Failure!',
        message: 'You cannot delete other user Question',
        duration: Duration(seconds: 4),
      )..show(context);
    }
  }

  update(String key, value) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => UpdateQuestion(key, value)));
  }
}

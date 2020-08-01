import 'package:chrona_1/Activities/update_answer.dart';
import 'package:chrona_1/UserInfo/state.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class AnswerComponent extends StatefulWidget {
  final DataSnapshot snapshot;
  final String questionKey;
  const AnswerComponent({Key key, this.snapshot, this.questionKey})
      : super(key: key);
  @override
  _AnswerComponentState createState() => _AnswerComponentState();
}

class _AnswerComponentState extends State<AnswerComponent> {
  DatabaseReference databaseReference, databaseReferenceAnswer;
  FirebaseDatabase firebaseDatabase;
  bool isLiked, isDisliked, isLoading;
  @override
  void initState() {
    firebaseDatabase = FirebaseDatabase.instance;
    databaseReference = firebaseDatabase
        .reference()
        .child("Question")
        .child(widget.questionKey);
    databaseReferenceAnswer = databaseReference.child("Answer");
    isLiked = false;
    isDisliked = false;
    isLoading = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DataSnapshot snapshot = widget.snapshot;
    loadLikeData(snapshot.key);
    TextEditingController answer = new TextEditingController();
    answer.text = snapshot.value["answer"];
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
                    controller: answer,
                    //initialValue: snapshot.value["answer"],
                    maxLength: 256,
                    maxLines: null,
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
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
                      Icon(
                        Icons.thumb_up,
                        color: isLiked ? Colors.blueAccent : Colors.black45,
                      ),
                      Text(
                        " " + snapshot.value["likeCount"].toString(),
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
                      Padding(padding: EdgeInsets.only(left: 50.0)),
                      RaisedButton(
                        child: Text("UPDATE"),
                        onPressed: snapshot.value["user"].toString() ==
                                StaticState.user.email.toString()
                            ? () => update(widget.questionKey, snapshot.key,
                                snapshot.value["answer"])
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
          onTap: () =>
              checkForDelete(context, snapshot.key, snapshot.value["user"]),
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
    databaseReferenceAnswer
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
      databaseReferenceAnswer
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
    databaseReferenceAnswer
        .child(key)
        .child("likes")
        .child(StaticState.user.email
            .substring(0, StaticState.user.email.indexOf("@")))
        .once()
        .then((DataSnapshot snapshot) {
      if (snapshot.value == null) {
        flag = true;
        databaseReferenceAnswer
            .child(key)
            .child("likes")
            .child(StaticState.user.email
                .substring(0, StaticState.user.email.indexOf("@")))
            .set({"flag": true});
        databaseReferenceAnswer.child(key).once().then((DataSnapshot snapshot) {
          int likes = snapshot.value["likeCount"];
          databaseReferenceAnswer.child(key).child("likeCount").set(likes + 1);
        });
      } else {
        flag = snapshot.value["flag"];
        if (flag == true) {
          flag = false;
          databaseReferenceAnswer
              .child(key)
              .once()
              .then((DataSnapshot snapshot) {
            int likes = snapshot.value["likeCount"];
            databaseReferenceAnswer
                .child(key)
                .child("likeCount")
                .set(likes - 1);
          });
        } else {
          flag = true;
          print("%%");
          databaseReferenceAnswer
              .child(key)
              .once()
              .then((DataSnapshot snapshot) {
            int likes = snapshot.value["likeCount"];
            databaseReferenceAnswer
                .child(key)
                .child("likeCount")
                .set(likes + 1);
          });
        }
        databaseReferenceAnswer
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
      databaseReferenceAnswer
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
            databaseReferenceAnswer
                .child(key)
                .once()
                .then((DataSnapshot snapshot) {
              int dislikes = snapshot.value["dislikeCount"];
              databaseReferenceAnswer
                  .child(key)
                  .child("dislikeCount")
                  .set(dislikes - 1);
            });
          }
          databaseReferenceAnswer
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
    databaseReferenceAnswer
        .child(key)
        .child("dislikes")
        .child(StaticState.user.email
            .substring(0, StaticState.user.email.indexOf("@")))
        .once()
        .then((DataSnapshot snapshot) {
      if (snapshot.value == null) {
        flag = true;
        databaseReferenceAnswer
            .child(key)
            .child("dislikes")
            .child(StaticState.user.email
                .substring(0, StaticState.user.email.indexOf("@")))
            .set({"flag": true});
        databaseReferenceAnswer.child(key).once().then((DataSnapshot snapshot) {
          int dislikes = snapshot.value["dislikeCount"];
          databaseReferenceAnswer
              .child(key)
              .child("dislikeCount")
              .set(dislikes + 1);
        });
      } else {
        flag = snapshot.value["flag"];
        if (flag == true) {
          flag = false;
          databaseReferenceAnswer
              .child(key)
              .once()
              .then((DataSnapshot snapshot) {
            int dislikes = snapshot.value["dislikeCount"];
            databaseReferenceAnswer
                .child(key)
                .child("dislikeCount")
                .set(dislikes - 1);
          });
        } else {
          flag = true;
          databaseReferenceAnswer
              .child(key)
              .once()
              .then((DataSnapshot snapshot) {
            int dislikes = snapshot.value["dislikeCount"];
            databaseReferenceAnswer
                .child(key)
                .child("dislikeCount")
                .set(dislikes + 1);
          });
        }
        databaseReferenceAnswer
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
      databaseReferenceAnswer
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
            databaseReferenceAnswer
                .child(key)
                .once()
                .then((DataSnapshot snapshot) {
              int dislikes = snapshot.value["likeCount"];
              databaseReferenceAnswer
                  .child(key)
                  .child("likeCount")
                  .set(dislikes - 1);
            });
          }
          databaseReferenceAnswer
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
      databaseReference.child("Answer").child(key).remove();
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
        message: 'Your Answer has been deleted successfully!!!',
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
        message: 'You cannot delete other user Answer',
        duration: Duration(seconds: 4),
      )..show(context);
    }
  }

  update(String qid, ansId, ans) {
    Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => UpdateAnswer(qid, ansId, ans)));
  }
}

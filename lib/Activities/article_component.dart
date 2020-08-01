import 'package:chrona_1/Activities/update_article.dart';
import 'package:chrona_1/UserInfo/state.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class ArticleComponent extends StatefulWidget {
  final DataSnapshot snapshot;

  const ArticleComponent({Key key, this.snapshot}) : super(key: key);
  @override
  _ArticleComponentState createState() => _ArticleComponentState();
}

class _ArticleComponentState extends State<ArticleComponent> {
  DatabaseReference databaseReferenceArticle, databaseReferenceUser;
  FirebaseDatabase firebaseDatabase;
  bool isLiked, isDisliked, isLoading;
  static bool OnChanged;
  @override
  void initState() {
    OnChanged = false;
    firebaseDatabase = FirebaseDatabase.instance;
    databaseReferenceArticle = firebaseDatabase.reference().child("Article");
    databaseReferenceUser = firebaseDatabase.reference().child("Users");
    isLiked = false;
    isDisliked = false;
    isLoading = true;
    super.initState();
  }

  TextEditingController headerController = new TextEditingController();
  TextEditingController bodyController = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    DataSnapshot snapshot = widget.snapshot;
    loadLikeData(snapshot.key);
    headerController.text = snapshot.value["header"];
    bodyController.text = snapshot.value["body"];
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
                    readOnly: snapshot.value["user"].toString() ==
                            StaticState.user.email.toString()
                        ? false
                        : true,
                    //initialValue: snapshot.value['header'].toString(),
                    onEditingComplete: () => OnChanged = true,
                    autocorrect: true,
                    autofocus: false,
                    initialValue: snapshot.value["header"],
                    maxLength: 128,
                    maxLines: null,
                    style: TextStyle(
                         fontWeight: FontWeight.bold),
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                        labelText: "Heading",
                        hintText: 'Enter Heading ',
                        prefixIcon: Icon(Icons.view_headline),
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
                    readOnly: snapshot.value["user"].toString() ==
                            StaticState.user.email.toString()
                        ? false
                        : true,
                    // initialValue: snapshot.value['body'].toString(),
                    onEditingComplete: () => OnChanged = true,
                    autocorrect: true,
                    autofocus: false,
                    initialValue: snapshot.value["body"],
                    maxLength: 1024,
                    maxLines: null,
                    style: TextStyle(
                        fontWeight: FontWeight.bold),
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                        labelText: "Body",
                        hintText: 'Enter Body ',
                        prefixIcon: Icon(Icons.description),
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
                      Padding(padding: EdgeInsets.only(left: 190.0)),
                      RaisedButton(
                        child: Text("UPDATE"),
                        onPressed: snapshot.value["user"].toString() ==
                                StaticState.user.email.toString()
                            ? () => update(
                                snapshot.key,
                                snapshot.value["header"],
                                snapshot.value["body"])
                            : null,
                      ),
                    ],
                  )
                ],
              ),
      ),
      actions: <Widget>[
        IconSlideAction(
          caption: 'Bookmark',
          color: Colors.blue,
          icon: Icons.bookmark,
          onTap: () =>
              Bookmark(snapshot.value["header"], snapshot.value["body"]),
        ),
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
    databaseReferenceArticle
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
      databaseReferenceArticle
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
    databaseReferenceArticle
        .child(key)
        .child("likes")
        .child(StaticState.user.email
            .substring(0, StaticState.user.email.indexOf("@")))
        .once()
        .then((DataSnapshot snapshot) {
      if (snapshot.value == null) {
        flag = true;
        databaseReferenceArticle
            .child(key)
            .child("likes")
            .child(StaticState.user.email
                .substring(0, StaticState.user.email.indexOf("@")))
            .set({"flag": true});
        databaseReferenceArticle
            .child(key)
            .once()
            .then((DataSnapshot snapshot) {
          int likes = snapshot.value["likeCount"];
          databaseReferenceArticle.child(key).child("likeCount").set(likes + 1);
        });
      } else {
        flag = snapshot.value["flag"];
        if (flag == true) {
          flag = false;
          databaseReferenceArticle
              .child(key)
              .once()
              .then((DataSnapshot snapshot) {
            int likes = snapshot.value["likeCount"];
            databaseReferenceArticle
                .child(key)
                .child("likeCount")
                .set(likes - 1);
          });
        } else {
          flag = true;
          print("%%");
          databaseReferenceArticle
              .child(key)
              .once()
              .then((DataSnapshot snapshot) {
            int likes = snapshot.value["likeCount"];
            databaseReferenceArticle
                .child(key)
                .child("likeCount")
                .set(likes + 1);
          });
        }
        databaseReferenceArticle
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
      databaseReferenceArticle
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
            databaseReferenceArticle
                .child(key)
                .once()
                .then((DataSnapshot snapshot) {
              int dislikes = snapshot.value["dislikeCount"];
              databaseReferenceArticle
                  .child(key)
                  .child("dislikeCount")
                  .set(dislikes - 1);
            });
          }
          databaseReferenceArticle
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
    databaseReferenceArticle
        .child(key)
        .child("dislikes")
        .child(StaticState.user.email
            .substring(0, StaticState.user.email.indexOf("@")))
        .once()
        .then((DataSnapshot snapshot) {
      if (snapshot.value == null) {
        flag = true;
        databaseReferenceArticle
            .child(key)
            .child("dislikes")
            .child(StaticState.user.email
                .substring(0, StaticState.user.email.indexOf("@")))
            .set({"flag": true});
        databaseReferenceArticle
            .child(key)
            .once()
            .then((DataSnapshot snapshot) {
          int dislikes = snapshot.value["dislikeCount"];
          databaseReferenceArticle
              .child(key)
              .child("dislikeCount")
              .set(dislikes + 1);
        });
      } else {
        flag = snapshot.value["flag"];
        if (flag == true) {
          flag = false;
          databaseReferenceArticle
              .child(key)
              .once()
              .then((DataSnapshot snapshot) {
            int dislikes = snapshot.value["dislikeCount"];
            databaseReferenceArticle
                .child(key)
                .child("dislikeCount")
                .set(dislikes - 1);
          });
        } else {
          flag = true;
          databaseReferenceArticle
              .child(key)
              .once()
              .then((DataSnapshot snapshot) {
            int dislikes = snapshot.value["dislikeCount"];
            databaseReferenceArticle
                .child(key)
                .child("dislikeCount")
                .set(dislikes + 1);
          });
        }
        databaseReferenceArticle
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
      databaseReferenceArticle
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
            databaseReferenceArticle
                .child(key)
                .once()
                .then((DataSnapshot snapshot) {
              int dislikes = snapshot.value["likeCount"];
              databaseReferenceArticle
                  .child(key)
                  .child("likeCount")
                  .set(dislikes - 1);
            });
          }
          databaseReferenceArticle
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
      databaseReferenceArticle.child(key).remove();
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
        message: 'Your Article has been deleted successfully!!!',
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
        message: 'You cannot delete other user Article',
        duration: Duration(seconds: 4),
      )..show(context);
    }
  }

  update(String key, head, body) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => UpdateArticle(key, head, body)));
  }

  Bookmark(String key, value) {
    String s = StaticState.user.email;
    s = s.substring(0, s.indexOf("@"));
    databaseReferenceUser
        .child(s)
        .child("bookmark")
        .push()
        .set({"header": key, "body": value});
  }
}

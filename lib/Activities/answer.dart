import 'package:chrona_1/Activities/add_answer.dart';
import 'package:chrona_1/Activities/update_answer.dart';
import 'package:chrona_1/UserInfo/state.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:flushbar/flushbar.dart';

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
  DatabaseReference databaseReference, databaseReferenceAnswer;
  FirebaseDatabase firebaseDatabase;

  @override
  void initState() {
    firebaseDatabase = FirebaseDatabase.instance;
    databaseReference = firebaseDatabase.reference().child("Question").child(KEY);
    databaseReferenceAnswer = databaseReference.child("Answer");
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
                                Icon(Icons.thumb_up),
                                Text(
                                  " " + snapshot.value["likeCount"].toString(),
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
                          onTap:()=>checkForDelete(context,snapshot.key,snapshot.value["user"]),
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
    bool flag=false;
    databaseReferenceAnswer.child(key).child("likes").child(StaticState.user.email.substring(0,StaticState.user.email.indexOf("@"))).once().then((DataSnapshot snapshot){
      if(snapshot.value==null){
        flag=true;
        databaseReferenceAnswer.child(key).child("likes").child(StaticState.user.email.substring(0,StaticState.user.email.indexOf("@"))).set({"flag":true});
        databaseReferenceAnswer.child(key).once().then((DataSnapshot snapshot) {
          int likes = snapshot.value["likeCount"];
          databaseReferenceAnswer.child(key).child("likeCount").set(likes+1);
        });
      }
      else{
        flag=snapshot.value["flag"];
        if(flag==true) {
          flag = false;
          databaseReferenceAnswer.child(key).once().then((DataSnapshot snapshot) {
            int likes = snapshot.value["likeCount"];
            databaseReferenceAnswer.child(key).child("likeCount").set(likes-1);
          });
        }
        else{
          flag = true;
          print("%%");
          databaseReferenceAnswer.child(key).once().then((DataSnapshot snapshot) {
            int likes = snapshot.value["likeCount"];
            databaseReferenceAnswer.child(key).child("likeCount").set(likes+1);
          });
        }
        databaseReferenceAnswer.child(key).child("likes").child(StaticState.user.email.substring(0,StaticState.user.email.indexOf("@"))).set({"flag":flag});
      }
      checkDislike(flag,key);
    });
  }
  checkDislike(bool flag, String key){
    if(flag==true) {
      databaseReferenceAnswer.child(key).child("dislikes").child(
          StaticState.user.email.substring(
              0, StaticState.user.email.indexOf("@"))).once().then((
          DataSnapshot snapshot) {
        if (snapshot.value != null) {
          bool flag1 = snapshot.value["flag"];
          if (flag1 == true) {
            flag1 = false;
            databaseReferenceAnswer.child(key).once().then((DataSnapshot snapshot) {
              int dislikes = snapshot.value["dislikeCount"];
              databaseReferenceAnswer.child(key).child("dislikeCount").set(
                  dislikes - 1);
            });
          }
          databaseReferenceAnswer.child(key).child("dislikes").child(
              StaticState.user.email.substring(
                  0, StaticState.user.email.indexOf("@"))).set({"flag": flag1});
        }
      });
    }
  }


  Dislike(String key) {
    bool flag;
    databaseReferenceAnswer.child(key).child("dislikes").child(StaticState.user.email.substring(0,StaticState.user.email.indexOf("@"))).once().then((DataSnapshot snapshot){
      if(snapshot.value==null){
        flag = true;
        databaseReferenceAnswer.child(key).child("dislikes").child(StaticState.user.email.substring(0,StaticState.user.email.indexOf("@"))).set({"flag":true});
        databaseReferenceAnswer.child(key).once().then((DataSnapshot snapshot) {
          int dislikes = snapshot.value["dislikeCount"];
          databaseReferenceAnswer.child(key).child("dislikeCount").set(dislikes+1);
        });
      }
      else{
        flag=snapshot.value["flag"];
        if(flag==true) {
          flag = false;
          databaseReferenceAnswer.child(key).once().then((DataSnapshot snapshot) {
            int dislikes = snapshot.value["dislikeCount"];
            databaseReferenceAnswer.child(key).child("dislikeCount").set(dislikes-1);
          });
        }
        else{
          flag=true;
          databaseReferenceAnswer.child(key).once().then((DataSnapshot snapshot) {
            int dislikes = snapshot.value["dislikeCount"];
            databaseReferenceAnswer.child(key).child("dislikeCount").set(dislikes+1);
          });
        }
        databaseReferenceAnswer.child(key).child("dislikes").child(StaticState.user.email.substring(0,StaticState.user.email.indexOf("@"))).set({"flag":flag});
      }
      checkLike(flag,key);
    });

  }
  checkLike(bool flag, String key){
    if(flag==true) {
      databaseReferenceAnswer.child(key).child("likes").child(
          StaticState.user.email.substring(
              0, StaticState.user.email.indexOf("@"))).once().then((
          DataSnapshot snapshot) {
        if (snapshot.value != null) {
          bool flag1 = snapshot.value["flag"];
          if (flag1 == true) {
            flag1 = false;
            databaseReferenceAnswer.child(key).once().then((DataSnapshot snapshot) {
              int dislikes = snapshot.value["likeCount"];
              databaseReferenceAnswer.child(key).child("likeCount").set(
                  dislikes - 1);
            });
          }
          databaseReferenceAnswer.child(key).child("likes").child(
              StaticState.user.email.substring(
                  0, StaticState.user.email.indexOf("@"))).set({"flag": flag1});
        }
      });
    }
  }

  checkForDelete(BuildContext context, String key, String user) {
    if(user == StaticState.user.email.toString()){
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
    }
    else{
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
    Navigator.of(context).push(MaterialPageRoute(builder: (context)=>UpdateAnswer(qid,ansId,ans)));
  }
}

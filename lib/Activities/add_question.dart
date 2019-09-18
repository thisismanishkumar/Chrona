import 'package:chrona_1/Activities/question.dart';
import 'package:chrona_1/UserInfo/state.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'account.dart';
import 'main.dart';

class AddQuestion extends StatefulWidget {
  @override
  _AddQuestionState createState() => _AddQuestionState();
}

class _AddQuestionState extends State<AddQuestion> {
  final FirebaseDatabase database = FirebaseDatabase.instance;
  DatabaseReference databaseReferenceQues, databaseReferenceUser;
  final TextEditingController questionText = new TextEditingController();
  final TextEditingController tagcontroller = new TextEditingController();
  int selectedIndex = 1;
  @override
  void initState() {
    databaseReferenceQues = database.reference().child("Question");
    databaseReferenceUser = database.reference().child("Users");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: new Text("Add Question"),
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
        body: new Container(
          padding: EdgeInsets.all(6.0),
          child: new ListView(
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(padding: EdgeInsetsDirectional.only(start: 5.0)),
                  TextField(
                      autocorrect: true,
                      autofocus: true,
                      controller: questionText,
                      maxLength: 256,
                      maxLines: null,
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                          labelText: "Question us anything!!!",
                          hintText: 'Write question here ',
                          prefixIcon: Icon(Icons.question_answer),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ))),
                  Padding(
                    padding: EdgeInsetsDirectional.only(top: 10.0),
                  ),
                  TextField(
                      autocorrect: true,
                      autofocus: true,
                      controller: tagcontroller,
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
                          ))),
                  Padding(
                    padding: EdgeInsetsDirectional.only(top: 10.0),
                  ),
                  RaisedButton(
                    onPressed: ()=>submit(context),
                    child: Text("Submit"),
                    elevation: 5.0,
                  )
                ],
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
                icon: Icon(Icons.home), title: new Text("Home")),
            BottomNavigationBarItem(
                icon: Icon(Icons.question_answer), title: new Text("Q/A")),
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
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => NewsMain()));
      // selectedIndex=0;
    }
    if (value == 1) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => Question_Route()));
    }
    if (value == 2) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => Account()));
      //selectedIndex=2;
    }
  }

  void submit(BuildContext context) {
    if(questionText.text.isEmpty || tagcontroller.text.isEmpty)
      {
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
          message: 'Check whether above two fields are filled or not.',
          duration: Duration(seconds: 4),
        )..show(context);
      }
    else{

      List<String> tags = tagcontroller.text.split(";");

      var firstChunk = utf8.encode(questionText.text);
      var secondChunk = utf8.encode(tagcontroller.text);

      var output = new AccumulatorSink<Digest>();
      var input = sha1.startChunkedConversion(output);
      input.add(firstChunk);
      input.add(secondChunk); // call `add` for every chunk of input data
      input.close();
      var digest = output.events.single;
      databaseReferenceQues.child(digest.toString()).once().then((DataSnapshot data) {
        if (data.value != null) {
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text("This Question already exists !!"),
          ));
        } else {
          databaseReferenceQues
              .child(digest.toString())
              .set({"question": questionText.text, "tags": tags,"verify":false,"user":StaticState.user.email.toString(),"username":StaticState.user.displayName.toString(),"likes":0,"dislikes":0});
          String s=StaticState.user.email;
          s=s.substring(0,s.indexOf("@"));
          databaseReferenceUser.child(s).child("question").push().set({"qid":digest.toString(),"verify":false});
        }
      });
      print(questionText.text.toString() + '\n' + tagcontroller.text.toString());

    }
  }
  
}

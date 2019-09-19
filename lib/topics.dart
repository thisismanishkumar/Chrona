import 'package:chrona_1/RealTimeDatabase/users_to_push.dart';
import 'package:chrona_1/RealTimeDatabase/users_to_push.dart' show User;
import 'package:chrona_1/SharedPreferences/shared_preferences.dart';
import 'package:chrona_1/UserInfo/state.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:grouped_buttons/grouped_buttons.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Activities/main.dart';

class TopicRoute extends StatefulWidget {
  @override
  _TopicRouteState createState() => _TopicRouteState();
}

class _TopicRouteState extends State<TopicRoute> {
  List<String> topic = new List();

  //List<User> userDatabase = List();

  // User user= new User(appState.user);
  final FirebaseDatabase database = FirebaseDatabase.instance;
//  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  DatabaseReference databaseReference;

  @override
  void initState() {

    print("4554");
    super.initState();

    databaseReference = database.reference().child("Users");
//    databaseReference.onChildAdded.listen(_onEntryAdded);
//    databaseReference.onChildChanged.listen(_onEntryChanged);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: new AppBar(
        title: new Text("Topics of Interests"),
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
      body: ListView(
        children: <Widget>[
          new Padding(padding: EdgeInsets.all(20.0)),
          CheckboxGroup(
            orientation: GroupedButtonsOrientation.VERTICAL,
            margin: const EdgeInsets.only(left: 12.0),
            labels: <String>[
              "Politics",
              "Technology",
              "Global",
              "Science",
              "Sports",
              "Business",
              "Gaming",
              "Entertainment",
              "Automobile",
            ],
              onSelected: (List<String> checked){
              print(checked.toString());
              topic=checked;
              print(topic.toString());
              }
          ),
          Padding(
            padding: EdgeInsets.all(30.0),
          ),
          Text(
            "Click clear if you want to clear list or Submit to Save your interests",
            style: TextStyle(fontSize: 20.0, fontStyle: FontStyle.italic),
          ),
          RaisedButton(
            onPressed: () {

              print("123");
              topic.clear();
            },
            child: Text(
              "CLEAR",
              style: TextStyle(fontSize: 25.0),
            ),
          ),
          RaisedButton(
            onPressed: () => handleSubmit(context),
            child: Text(
              "SUBMIT",
              style: TextStyle(fontSize: 25.0),
            ),
          ),
        ],
      ),
    );
  }

   handleSubmit(BuildContext context) async {
    print("hello");
    if(topic.length==0)
      {
        Flushbar(
          padding: EdgeInsets.all(10.0),
          borderRadius: 8,
          backgroundGradient: LinearGradient(
            colors: [Colors.red.shade500, Colors.orange.shade500],
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
          message: 'You have not selected anything atleast choose one',
          duration: Duration(seconds: 4),
        )..show(context);

      }
    debugPrint(StaticState.user.email.toString());
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(StaticState.user.email.toString(), 1);
    debugPrint(StaticState.user.email.toString());
    String s=StaticState.user.email;
    s=s.substring(0,s.indexOf("@"));
    databaseReference.child(s).child("topicsofinterest").set({"toi":topic});

    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => NewsMain()));

  }
}

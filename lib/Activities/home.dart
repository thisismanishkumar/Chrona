
import 'package:chrona_1/Activities/main.dart';
import 'package:chrona_1/SignIn/app.dart';
import 'package:chrona_1/main.dart';
import 'package:chrona_1/topics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../UserInfo/state.dart';
import '../SignIn/state_widget.dart';
import '../SignIn/login.dart';
import '../topics.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  StateModel appState;

  Widget _buildStories({Widget body}) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: Text('Chrona'),
      ),
      body: Container(
        child: Center(
            child: Column(
//              mainAxisAlignment: MainAxisAlignment.center,
//              crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Container(
                alignment: Alignment.center,
                padding: EdgeInsets.all(30.0),
                height: 150.0,
                width: 150.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    fit: BoxFit.fill,
                    image: NetworkImage(appState.user.photoUrl.toString()),
                  ),
                )),
            new Text(
              'Hello, ' '${appState.user.displayName}' '!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black, fontSize: 25),
            ),
            new Padding(padding: EdgeInsets.all(10.0)),
            new Text(
              "Welcome To Our Learning App",
              style: new TextStyle(fontSize: 20.0),
            ), new Padding(padding: EdgeInsets.all(10.0)),
            new RaisedButton(
              onPressed: check,
              child: new Text(
                "Lets Get Started",
                style:
                    new TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
            ), new Padding(padding: EdgeInsets.all(10.0)),
            new RaisedButton(
              onPressed: topic,
              child: new Text(
                "Change topic of interest",
                style:
                new TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
            ),
            new Padding(padding: EdgeInsets.all(10.0)),
            new RaisedButton(
                onPressed: signOut,
              child: new Text(
                "Sign Out",
                style:new TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),

              )
            )
          ],
        )),
      ),
    );
  }

  Widget _buildContent() {
    if (appState.isLoading) {
      return _buildLoadingIndicator();
    } else if (!appState.isLoading && appState.user == null) {
      return new LoginScreen();
    } else {
      return _buildStories();
    }
  }

  Scaffold _buildLoadingIndicator() {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(color: Colors.redAccent),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 50.0,
                        child: Icon(
                          Icons.developer_mode,
                          color: Colors.greenAccent,
                          size: 50.0,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 10.0),
                      ),
                      Text(
                        "Chrona",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 24.0),
                      )
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "Loading...Please wait",
                      softWrap: true,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                          color: Colors.white),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 20.0),
                    ),
                    CircularProgressIndicator(),
                    Padding(
                      padding: EdgeInsets.only(top: 20.0),
                    ),
                    Text(
                      "Get the information you need. Anytime. Anywhere.",
                      softWrap: true,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                          color: Colors.white),
                    )
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Build the content depending on the state:
    appState = StateWidget.of(context).state;
    StaticState.user = appState.user;
    return _buildContent();
  }

  void check() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int counter = (prefs.getInt(appState.user.email) ?? 0);
    if (counter == 0)
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => TopicRoute()));
    else {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => NewsMain()));
    }
  }

  void topic() {
    Navigator.push(context, MaterialPageRoute(builder: (context)=>TopicRoute()));
  }

  void signOut() async{
    final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
    await _auth.signOut();
    await _googleSignIn.signOut();
    StaticState.user=null;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoginScreen()));
  }
}

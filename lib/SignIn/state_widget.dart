import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../UserInfo/state.dart';
import 'auth.dart';

class StateWidget extends StatefulWidget {
  final StateModel state;
  final Widget child;

  StateWidget({
    @required this.child,
    this.state,
  });

  // Returns data of the nearest widget _StateDataWidget
  // in the widget tree.
  static _StateWidgetState of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(_StateDataWidget)
    as _StateDataWidget)
        .data;
  }

  @override
  _StateWidgetState createState() => new _StateWidgetState();
}

class _StateWidgetState extends State<StateWidget> {
  StateModel state;
  GoogleSignInAccount googleAccount;
  final FirebaseDatabase database = FirebaseDatabase.instance;
//  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  DatabaseReference databaseReference;

  final GoogleSignIn googleSignIn = new GoogleSignIn();

  @override
  void initState() {
    super.initState();
    if (widget.state != null)
    {
      StateModel.set(false, state.user);
      state = widget.state;
      StaticState.user=widget.state.user;
      StaticState.loading=false;
    }
    else
      {
      state = new StateModel(isLoading: true);
      StateModel.set(true,null );
      initUser();
    }

    databaseReference = database.reference().child("Users");
  }

  Future<Null> initUser() async {
    googleAccount = await getSignedInAccount(googleSignIn);
    if (googleAccount == null) {
      setState(() {
        StaticState.loading=false;
        state.isLoading = false;
      });
    } else {
      await signInWithGoogle();
    }
  }


  Future<Null> signInWithGoogle() async {
    if (googleAccount == null) {
      // Start the sign-in process:
      googleAccount = await googleSignIn.signIn();
    }
    FirebaseUser firebaseUser = await signIntoFirebase(googleAccount);
    state.user = firebaseUser;
    // new
    StaticState.user=firebaseUser;
    String s=StaticState.user.email;
    s=s.substring(0,s.indexOf("@"));
    databaseReference.child(s).child("info").set({"name":firebaseUser.displayName,"emailId":firebaseUser.email});
    setState(() {
      StaticState.user=firebaseUser;
      state.isLoading = false;
      state.user = firebaseUser;
      StaticState.loading=false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new _StateDataWidget(
      data: this,
      child: widget.child,
    );
  }
}

class _StateDataWidget extends InheritedWidget {
  final _StateWidgetState data;

  _StateDataWidget({
    Key key,
    @required Widget child,
    @required this.data,
  }) : super(key: key, child: child);

  // Rebuild the widgets that inherit from this widget
  // on every rebuild of _StateDataWidget:
  @override
  bool updateShouldNotify(_StateDataWidget old) => true;
}
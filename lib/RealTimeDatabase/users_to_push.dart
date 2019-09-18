import 'package:chrona_1/UserInfo/state.dart';
import 'package:chrona_1/SignIn/state_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class User {
  String key = "";

  Map<dynamic, dynamic> answered;
  Map<dynamic, dynamic> questioned;
  Map<dynamic, dynamic> bookmark;
  List<String> topicsOfInterest;

  //User.topic(this.topicsOfInterest);
  User(this.topicsOfInterest);

  toJson() {
    print("sddsf"+topicsOfInterest.toString());
    return {
      "emailId": StaticState.user.email,
      "name": StaticState.user.displayName,
      "topicsofinterest": topicsOfInterest
    };
  }
}

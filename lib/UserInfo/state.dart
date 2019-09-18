import 'package:firebase_auth/firebase_auth.dart';

class StateModel {
  bool isLoading;
  FirebaseUser user;
  StateModel({
    this.isLoading = false,
    this.user,
  });
  factory StateModel.set(bool val,FirebaseUser firebaseUser)
  {
    return StateModel(
      isLoading: val,
      user: firebaseUser
    );
  }

}
class StaticState
{
  static FirebaseUser user;
  static bool loading=false;
}
import 'package:chrona_1/UserInfo/state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesTest {

  final String verification = "hello";//StaticState.user.email.toString();


  Future<bool> getverification() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getBool(verification) ;
  }

  Future<bool> setVerification(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();


    return prefs.setBool(verification, value);
  }

}
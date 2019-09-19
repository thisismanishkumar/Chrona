import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'login.dart';

Future<GoogleSignInAccount> getSignedInAccount(
    GoogleSignIn googleSignIn) async {
  GoogleSignInAccount account = googleSignIn.currentUser;
  if (account == null) {
    account = await googleSignIn.signInSilently();
  }
  return account;
}

Future<FirebaseUser> signIntoFirebase(
    GoogleSignInAccount googleSignInAccount) async {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
  final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

  final AuthCredential credential = GoogleAuthProvider.getCredential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );

  final FirebaseUser user = (await _auth.signInWithCredential(credential)).user;
  print("signed in " + user.displayName);
  return user;
}

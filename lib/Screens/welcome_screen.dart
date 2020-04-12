import 'package:flutter/material.dart';
import 'package:notesapp/Components/RoundedButton.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:notesapp/Screens/notes_screen.dart';
import 'package:notesapp/global.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as JSON;

import 'package:notesapp/utils/authentication.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _isLoggedIn = false;
  Map userProfile;
  final facebookLogin = FacebookLogin();

  // _loginWithFB() async {
  //   final result = await facebookLogin.logIn(['email']);

  //   switch (result.status) {
  //     case FacebookLoginStatus.loggedIn:
  //       final token = result.accessToken.token;
  //       final graphResponse = await http.get(
  //           'https://graph.facebook.com/v2.12/me?fields=name,picture,email&access_token=${token}');
  //       final profile = JSON.jsonDecode(graphResponse.body);
  //       print(profile);
  //       setState(() {
  //         userProfile = profile;
  //         Global.photoUrl = userProfile["picture"]["data"]["url"];
  //         _isLoggedIn = true;
  //       });
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //           builder: (context) => NotesScreen(),
  //         ),
  //       );
  //       break;

  //     case FacebookLoginStatus.cancelledByUser:
  //       setState(() => _isLoggedIn = false);
  //       break;
  //     case FacebookLoginStatus.error:
  //       setState(() => _isLoggedIn = false);
  //       break;
  //   }
  // }

  // final FirebaseAuth _auth = FirebaseAuth.instance;
  // final GoogleSignIn googleSignIn = new GoogleSignIn();

  // Future<FirebaseUser> _loginWithGoogle() async {
  //   GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
  //   GoogleSignInAuthentication gSA = await googleSignInAccount.authentication;

  //   final AuthCredential credential = GoogleAuthProvider.getCredential(
  //     idToken: gSA.idToken,
  //     accessToken: gSA.accessToken,
  //   );
  //   final FirebaseUser user =
  //       (await _auth.signInWithCredential(credential)).user;

  //   print("User Name : ${user.photoUrl}");
  //   Global.photoUrl = user.photoUrl;
  //   return user;
  // }

  // void _signOut() {
  //   googleSignIn.signOut();
  //   print("User Signed out");
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Builder(
        builder: (context) => SafeArea(
          child: SingleChildScrollView(child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 22.0),
                  child: Text(
                    'Welcome',
                    style: TextStyle(
                      fontSize: 40.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Image.asset('images/welcome_art2.png'),
                Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Text(
                    'Brood helps you keep track of special thoughts that comes to your mind, and then remind you of them. So for the app to work properly notifications need to be turned on. ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 18.0, color: Colors.grey, height: 1.4),
                  ),
                ),
                RoundedButton(
                  color: Color(0xff64B6C0),
                  buttonTitle: 'Continue with Google',
                  onPressed: () {
                    signInWithGoogle();
                  },
                ),
                RoundedButton(
                  color: Color(0xff269FBF),
                  buttonTitle: 'Continue with Facebook',
                  onPressed: () {
                    signInWithFacebook();
                  },
                ),
              ],
            ),
          ),
        )),
      ),
    );
  }

  void signInWithGoogle() async {
    BaseAuth auth = new Auth();
    String uid = await auth.signInWithGoogle();
    Navigator.pushReplacement(
        context, new MaterialPageRoute(builder: (context) => NotesScreen(uid)));
  }

  void signInWithFacebook() async {
    BaseAuth auth = new Auth();
    String uid = await auth.signInWithFacebook();
    print('facebook uid: ' + uid);
    if (uid != 'canceled' && uid != 'error' && uid != null) {
      Navigator.pushReplacement(
          context, new MaterialPageRoute(builder: (context) => NotesScreen(uid)));
    }
  }
}

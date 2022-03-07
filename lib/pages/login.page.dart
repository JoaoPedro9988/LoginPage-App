import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:login_page/pages/home.page.dart';
import 'package:provider/provider.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            padding: EdgeInsets.only(top: 60, left: 40, right: 40),
            color: Colors.white,
            child: ListView(
              children: <Widget>[
                SizedBox(height: 30),
                SizedBox(
                    width: 150,
                    height: 150,
                    child: Image.asset("assets/logo.png")
                ),
                SizedBox(height: 60),
                _Button(
                  image: AssetImage('assets/google_button.png'),
                  onPressed: () {
                    final provider =
                    Provider.of<GoogleSignInProvider>(context, listen: false);
                    provider.googleLogin();
                  },
                ),
                _Button(
                  image: AssetImage('assets/facebook_button.png'),
                  onPressed: () {},
                ),
              ],
            ),
        )
    );
  }
}

// Botões
class _Button extends StatelessWidget {
  final ImageProvider image;
  final VoidCallback onPressed;

  _Button({
    required this.image,
    required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 0.0, left: 15.0, right: 15.0),
      child: GestureDetector(
        onTap: () {
          onPressed();
        },
        child: Container(
            height: 75,
            padding: EdgeInsets.all(5),
            child: Row(
                children: [
                  const SizedBox(width: 10),
                  Image(
                    image: image,
                    height: 275,
                    width: 275,
                  ),
                ],
            ),
          ),
        ),
      );
  }
}

// GoogleLogin
class GoogleSignInProvider extends ChangeNotifier {
  final googleSignIn = GoogleSignIn();

  GoogleSignInAccount? _user;

  GoogleSignInAccount get user => _user!;

  Future googleLogin() async {
    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) return;
    _user = googleUser;

    final googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    await FirebaseAuth.instance.signInWithCredential(credential);

    notifyListeners();
  }
}

//Background
class Background extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/background.png'),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
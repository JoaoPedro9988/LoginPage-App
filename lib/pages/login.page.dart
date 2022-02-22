import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<LoginPage> {

  var loading = false;

  void _logInWithFacebook() async {
    setState(() { loading = true; });

    try {
      final facebookLoginResult = await FacebookAuth.instance.login();
      final userData = await FacebookAuth.instance.getUserData();

      final facebookAuthCredential = FacebookAuthProvider.credential(facebookLoginResult.accessToken!.token);
      await FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);

      await FirebaseFirestore.instance.collection('users').add({
        'email': userData['email'],
        'imageUrl': userData['picture']['data']['url'],
        'name': userData['name'],
      });

      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => LoginPage()),
              (route) => false);

    } on FirebaseAuthException catch (e) {
      var content = '';
      switch (e.code) {
        case "account-exists-with-diferrent-credential":
          content = 'Essa conta existe com um provedor de login diferente';
          break;
        case 'invalid-credential':
          content = "Um erro desconhecido ocorreu";
          break;
        case 'operation-not-allowed':
          content = 'Essa operação não é permitida';
          break;
        case 'user-not-found':
          content = 'O usuário não foi encontrado';
          break;

      }

      showDialog(context: context, builder: (context) => AlertDialog(
        title: Text('O Log in com o facebook falhou'),
        content: Text(content),
        actions: [TextButton(onPressed: () {
          Navigator.of(context).pop();

        }, child: Text('Ok'))],
      ));

    } finally {
      setState(() { loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }
}

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
                  Provider.of<GoogleSignInProvider>(context, listen:false);
                provider.googleLogin();
              },
            ),
            _Button(
              image: AssetImage('assets/facebook_button.png'),
              onPressed: () {
                _logInWithFacebook();
              },
            ),
          ],
        ),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/background.png"),
          fit: BoxFit.cover,
          ),
        )
      )
    );
  }

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
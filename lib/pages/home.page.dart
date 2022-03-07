import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

  class HomePage extends StatelessWidget {
    const HomePage({Key? key}) : super(key: key);

    @override
    Widget build(BuildContext context) => Scaffold(
      drawer: NavigationDrawer(),
    );
  }

  class NavigationDrawer extends StatelessWidget {
    @override
    Widget build(BuildContext context) =>
        Drawer(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                FutureBuilder(
                    future: Provider
                        .of(context)
                        .auth
                        .getCurrentUser(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return displayUserInformation(context, snapshot);
                      } else {
                        return CircularProgressIndicator();
                      }
                    }
                ),
              ],
            ),
          ),
        );

    Widget displayUserInformation(context, snapshot) {
      final user = snapshot.data;

      return Column(
        children: <Widget>[
          CircleAvatar(
            maxRadius: 25,
            backgroundImage: NetworkImage(user.photoURL),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              user.displayName,
              style: TextStyle(fontSize: 20),),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              user.email,
              style: TextStyle(fontSize: 20),),
          ),
        ],
      );
    }
  }
import 'package:flutter/material.dart';
import 'package:joincompany/pages/LoginPage.dart';
import 'package:joincompany/pages/app.dart';
import 'package:joincompany/pages/home/taskHome.dart';

void main() async {
  runApp(MyApp());
}

const PrimaryColor = const Color(0xff80d8ff);


class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        "/Login": (context) =>LoginPage(),
        "/vistap": (context) =>taskHomePage(),
      },
      theme: ThemeData(
        primaryColor: PrimaryColor,
        accentColor: PrimaryColor,
        textTheme: TextTheme(
            headline: TextStyle(fontSize: 72.0, fontWeight: FontWeight.w900),
            title: TextStyle(fontSize: 14.0, fontFamily: 'RobotoMono'),
            button: TextStyle(fontSize: 14.0, fontFamily: 'RobotoMono')
        )
      ),
      debugShowCheckedModeBanner: false,
      title: 'Join',
      home: App(),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:joincompany/pages/app.dart';

void main() async {
  runApp(MyApp());
}

const PrimaryColor = const Color(0xff80d8ff);

var routes = <String, WidgetBuilder>{
  "/App": (BuildContext context) =>App(),
};

class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
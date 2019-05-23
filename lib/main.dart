import 'package:flutter/material.dart';
import 'package:joincompany/pages/FirmTouch.dart';
import 'package:joincompany/pages/LoginPage.dart';
import 'package:joincompany/pages/app.dart';
import 'package:joincompany/Menu/clientes.dart';
import 'package:joincompany/pages/home/taskHome.dart';
import 'package:joincompany/widgets/FormTaskNew.dart';

import 'pages/BuscarRuta/BuscarDireccion.dart';

void main() async {
  runApp(MyApp());
}

const PrimaryColor = const Color(0xff29a0c7);
const SecondaryColor = const Color(0xff29a0c7);
const hostApi = 'webapp.getkem.com';
const versionApi = '/api/v1';
const kGoogleApiKey = "AIzaSyDCs8ksRMNY73LlWa_VEyLzzDS24qKaaMw";


class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        "/Login": (context) =>LoginPage(),
        "/vistap": (context) =>TaskHomePage(),
        "/formularioTareas": (context) =>FormTask(),
        "/cliente": (context) =>Cliente(),
        "/firma": (context) =>FirmTouch(),
      },
      theme: ThemeData(
        primaryColor: PrimaryColor,
        accentColor: PrimaryColor,
        textTheme: TextTheme(
            headline: TextStyle(fontSize: 72.0, fontWeight: FontWeight.w900),
            title: TextStyle(fontSize: 14.0, fontFamily: 'Roboto'),
            button: TextStyle(fontSize: 14.0, fontFamily: 'Roboto')
        ),
        fontFamily: 'Roboto'
      ),
      debugShowCheckedModeBanner: false,
      title: 'Join',
      home: App(),
    );
  }
}
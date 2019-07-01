import 'package:flutter/material.dart';
import 'package:joincompany/Menu/formContac.dart';
import 'package:joincompany/Menu/formBusiness.dart';
import 'package:joincompany/pages/FirmTouch.dart';
import 'package:joincompany/pages/FormTaskNew.dart';
import 'package:joincompany/pages/LoginPage.dart';
import 'package:joincompany/pages/app.dart';
import 'package:joincompany/Menu/clientes.dart';
import 'package:joincompany/pages/home/taskHome.dart';
import 'package:joincompany/blocs/blocCheckConnectivity.dart';
import 'Menu/businesList.dart';
import 'Menu/configCli.dart';
import 'Menu/contactView.dart';

void main() async {
  ConnectionStatusSingleton connectionStatus = ConnectionStatusSingleton.getInstance();
  connectionStatus.initialize();
  runApp(MyApp());
}

const PrimaryColor = const Color(0xff29a0c7);
const SecondaryColor = const Color(0xff29a0c7);
const hostApi = 'webapp.getkem.com';
const versionApi = '/api/v1';
const kGoogleApiKey = "AIzaSyAiN5XM-jcaGfIeqXRweANSdhvaZluolbI";

class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        "/Login": (context) =>LoginPage(),
        "/vistap": (context) =>TaskHomePage(),
        "/formularioTareas": (context) =>FormTask(),
        "/cliente": (context) =>Client(statusPage: STATUS_PAGE_CLIENT.full),
        "/firma": (context) =>FirmTouch(),
        "/contactos": (context) =>ContactView(STATUS_PAGE.full),
        "/negocios": (context) =>BusinessList(STATUS_PAGE.full),
        "/configuracion": (context) =>ConfigCli(),
        "/App": (context) =>App(),
        "/addcontact": (context) =>AddContact(null),
        "/FormBusiness": (context) =>FormBusiness(),
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
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:joincompany/Sqlite/database_helper.dart';
import 'package:joincompany/models/UserDataBase.dart';
import 'package:joincompany/pages/LoginPage.dart';
import 'package:joincompany/pages/home/taskHome.dart';

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {

  Widget ValidarUsrPrimeraVez()  {
    Future<UserDataBase> userActiv = getUser();
    if(userActiv != null){
      return LoginPage();
    }else{
      Navigator.pushReplacementNamed(context, '/vistap');
    }
    return Text('ha ocurrido un error');
  }

  Future<UserDataBase> getUser() async {
    UserDataBase userActiv = await ClientDatabaseProvider.db.getCodeId('1');
    return userActiv;
  }


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: Stack(
            children: <Widget>[
              LoginPage(),
            ]
        )
    );
  }
}

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

  Future<UserDataBase> getUser() async {
    UserDataBase userActiv = await ClientDatabaseProvider.db.getCodeId('1');
    return userActiv;
  }

  bool TextViewVisible = true;
  bool AgregarUser = true;
  String companyEstable = '';
  bool salirMail = false;

  ValidarUsrPrimeraVez() async {
    UserDataBase UserActiv = await getUser();
    if(UserActiv != null){
      setState(() {
        TextViewVisible = false;
        AgregarUser = false;
        companyEstable = UserActiv.company;
      });
    }
    salirMail = true;
    setState(() {
      salirMail;
    });

  }

  @override
  void initState() {
    ValidarUsrPrimeraVez();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: Stack(
            children: <Widget>[
//              salirMail ?
//              LoginPage(TextViewVisiblewidget: TextViewVisible,AgregarUserwidget: AgregarUser,companyEstablewidget: companyEstable)
//              : Center(
//                child: CircularProgressIndicator(),
//              ),
            ]
        )
    );
  }
}
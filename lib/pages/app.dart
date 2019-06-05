import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:joincompany/Sqlite/database_helper.dart';
import 'package:joincompany/async_database/Database.dart';
import 'package:joincompany/models/UserDataBase.dart';
import 'package:joincompany/models/UserModel.dart';
import 'package:joincompany/pages/LoginPage.dart';
import 'package:joincompany/pages/home/taskHome.dart';

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {

  Future<UserModel> getUser() async => 
    await DatabaseProvider.db.RetrieveLastLoggedUser();

  bool TextViewVisible = true;
  bool AgregarUser = true;
  String companyEstable = '';
  bool salirMail = false;

  ValidarUsrPrimeraVez() async {
    UserModel lastActiveUser = await getUser();
    if(lastActiveUser != null){
      setState(() {
        TextViewVisible = false;
        AgregarUser = false;
        companyEstable = lastActiveUser.company;
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
              salirMail ?
              LoginPage(TextViewVisiblewidget: TextViewVisible,AgregarUserwidget: AgregarUser,companyEstablewidget: companyEstable)
              : Center(
                child: CircularProgressIndicator(),
              ),
            ]
        )
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:joincompany/Sqlite/database_helper.dart';
import 'package:joincompany/models/UserDataBase.dart';
import 'package:joincompany/pages/LoginPage.dart';

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {

  Future<UserDataBase> getUser() async {
    UserDataBase userActiv = await ClientDatabaseProvider.db.getCodeId('1');
    return userActiv;
  }

  bool textViewVisible = true;
  bool addUser = true;
  String companyEstable = '';
  bool salirMail = false;

  validateUserForFirstV() async {
    UserDataBase userActivity = await getUser();
    if(userActivity != null){
      setState(() {
        textViewVisible = false;
        addUser = false;
        companyEstable = userActivity.company;
      });
    }

    setState(() {
      salirMail = true;
    });

  }

  @override
  void initState() {
    validateUserForFirstV();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: Stack(
            children: <Widget>[
              salirMail ?
              LoginPage(textViewVisibleWidget: textViewVisible,addUserWidget: addUser,companyEstableWidget: companyEstable)
              : Center(
                child: CircularProgressIndicator(),
              ),
            ]
        )
    );
  }
}
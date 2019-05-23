import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:joincompany/Sqlite/database_helper.dart';
import 'package:joincompany/models/UserDataBase.dart';
import 'package:joincompany/models/UserModel.dart';
import 'package:joincompany/services/UserService.dart';

enum type{
  NAME,
  CODE,
  DEFAULT,
  TITLE,
  TLF_F,
  TLF_M,
  EMAIL,
  NOTE,
  PASSWORD,
}

class ConfigCli extends StatefulWidget {
  @override
  _ConfigCliState createState() => _ConfigCliState();
}

class _ConfigCliState extends State<ConfigCli> {

  //Const
  static const int linesInputsBasic = 1;
  static const int linesInputsTextAreaBasic = 4;

  TextEditingController name,code,defaults,title,tlfF,tlfM,email,note,password;

  void setDataForm(String data, type t){
      //TODO
  }

  void initController(){
    name = TextEditingController();
    code = TextEditingController();
    defaults = TextEditingController();
    title = TextEditingController();
    tlfF = TextEditingController();
    tlfM = TextEditingController();
    email = TextEditingController();
    note = TextEditingController();
    password = TextEditingController();
  }

  void disposeController(){
    name.dispose();
    code.dispose();
    defaults.dispose();
    title.dispose();
    tlfF.dispose();
    tlfM.dispose();
    email.dispose();
    note.dispose();
    password.dispose();
  }

  void getConfig() async {
    UserDataBase userAct = await ClientDatabaseProvider.db.getCodeId('1');
    var getUserResponse = await getUser(userAct.company, userAct.token);
    UserModel user = UserModel.fromJson(getUserResponse.body);

    name.text = user.name;
    code.text =  user.code;
    defaults.text =  user.profile;//TODO
    title.text =  user.title;
    tlfF.text =  user.phone;
    tlfM.text =  user.phone;
    email.text =  user.email;
    note.text =  user.details;
    password.text = "";

  }

  @override
  void initState() {
    //TODO
    initController();
    getConfig();
    super.initState();
  }

  @override
  void dispose() {
    //TODO
    disposeController();
    super.dispose();
  }

  Widget customTextField(String title, type t, int maxLines){
    return Container(
      margin: EdgeInsets.all(12.0),
      color: Colors.grey.shade300,
      child: TextFormField(
        maxLines: maxLines,
        textInputAction: TextInputAction.next,
        validator: (value){
          //TODO
        },
        onSaved: (value){
          setDataForm(value, t);
        },
        decoration: InputDecoration(
          hintText: title,
          border: InputBorder.none
        ),
        controller: getController(t),
      ),
    );
  }

  TextEditingController getController(type t){
    switch (t){
      case type.NAME:{
        return name;
      }
      case type.CODE:{
        return code;
      }
      case type.DEFAULT:{
        return defaults;
      }
      case type.TITLE:{
        return title;
      }
      case type.TLF_F:{
        return tlfF;
      }
      case type.TLF_M:{
        return tlfM;
      }
      case type.EMAIL:{
        return email;
      }
      case type.NOTE:{
        return note;
      }
      case type.PASSWORD:{
        return password;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Configuracion"),
        automaticallyImplyLeading: true,
      ),
      body:SingleChildScrollView(
          child: Column(
            children: <Widget>[
              customTextField("Nombre",type.NAME,linesInputsBasic),
              customTextField("Codigo",type.CODE,linesInputsBasic),
              customTextField("profile",type.DEFAULT,linesInputsBasic),
              customTextField("titulo",type.TITLE,linesInputsBasic),
              customTextField("Telefono fijo",type.TLF_F,linesInputsBasic),
              customTextField("Telefono movil",type.TLF_M,linesInputsBasic),
              customTextField("Emails",type.EMAIL,linesInputsBasic),
              customTextField("Notas",type.NOTE,linesInputsTextAreaBasic),
              customTextField("Contraseña",type.PASSWORD,linesInputsBasic),
              customTextField("Repetir Contraseña",type.PASSWORD,linesInputsBasic),
            ],
          ),
        ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:joincompany/Sqlite/database_helper.dart';
import 'package:joincompany/main.dart';
import 'package:joincompany/models/UserDataBase.dart';
import 'package:joincompany/models/UserModel.dart';
import 'package:joincompany/services/UserService.dart';

import 'contactView.dart';

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
  PASSWORD1
}

class ConfigCli extends StatefulWidget {
  @override
  _ConfigCliState createState() => _ConfigCliState();
}

class _ConfigCliState extends State<ConfigCli> {

  //Const
  static const int linesInputsBasic = 1;
  static const int linesInputsTextAreaBasic = 4;

  TextEditingController name,code,defaults,title,tlfF,tlfM,email,note,password,password1;

  String nameUser = '';
  String emailUser = '';

  @override
  void initState() {
    //TODO
    initController();
    getConfig();
    setUser();
    super.initState();
  }

  @override
  void dispose() {
    //TODO
    disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: buildDrawer(),
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
            customTextField("Repetir Contraseña",type.PASSWORD1,linesInputsBasic),
          ],
        ),
      ),
    );
  }

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
    password1 = TextEditingController();
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
    password1.dispose();
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

  Widget customTextField(String title, type t, int maxLines){
    return Container(
      margin: EdgeInsets.all(12.0),
      //color: Colors.grey.shade300,
      decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10)),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black12,
                blurRadius: 5
            )
          ]
      ),
      child: TextFormField(
        obscureText: (t == type.PASSWORD) || t == (type.PASSWORD1) ? true:false,
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
          contentPadding: EdgeInsets.all(12.0),
          border: InputBorder.none,
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
      case type.PASSWORD1:{
        return password1;
      }
    }
    return null;
  }

  bool drawerCustomer = true;
  Drawer buildDrawer() {
    return Drawer(
      elevation: 12,
      child: new ListView(
        children: <Widget>[
          new UserAccountsDrawerHeader(
            decoration: new BoxDecoration(color: SecondaryColor),
            margin: EdgeInsets.only(bottom: 0),
            accountName: new Text(nameUser,style: TextStyle(color: Colors.white,fontSize: 16,),),
            accountEmail : Text(emailUser,style: TextStyle(color: Colors.white,fontSize: 15,),),
            currentAccountPicture: CircleAvatar(
              radius: 1,
              backgroundColor: Colors.white,
              backgroundImage: new AssetImage('assets/images/user.png'),
            ),
          ),
          Container(
              child: ListTile(
                trailing: new Icon(Icons.assignment),
                title: new Text('Tareas'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              )
          ),
          Container(
            child: ListTile(
              title: new Text("Clientes"),
              trailing: new Icon(Icons.business),
              onTap: () {
                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.pushNamed(context, '/cliente');
              },
            ),
          ),
          Container(
            child: new ListTile(
              title: new Text("Contactos"),
              trailing: new Icon(Icons.contacts),
              onTap: () {
                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.pushNamed(context, '/contactos');
              },
            ),
          ),
          Container(
            color: drawerCustomer ? Colors.grey[200] :  null,
            child: new ListTile(
              title: new Text("Negocios"),
              trailing: new Icon(Icons.account_balance),
              onTap: () {
                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.pushNamed(context, '/negocios');
              },
            ),
          ),
          Divider(
            height: 30.0,
          ),
          Container(
            color: drawerCustomer ? Colors.grey[200] :  null,
            child: new ListTile(
              title: new Text("Configuración"),
              trailing: new Icon(Icons.filter_vintage),
              onTap: () {
                // Navigator.pushReplacementNamed(context, "/intro");
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    );
  }
  setUser() async {
    UserDataBase userAct = await ClientDatabaseProvider.db.getCodeId('1');
    var getUserResponse = await getUser(userAct.company, userAct.token);
    UserModel user = UserModel.fromJson(getUserResponse.body);

    setState(() {
      nameUser = user.name;
      emailUser = user.email;
    });
  }

}
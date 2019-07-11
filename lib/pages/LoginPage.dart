
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:joincompany/async_database/Database.dart';
import 'package:joincompany/async_operations/AddressChannel.dart';
import 'package:joincompany/async_operations/BusinessChannel.dart';
import 'package:joincompany/async_operations/ContactChannel.dart';
import 'package:joincompany/async_operations/CustomerAddressesChannel.dart';
import 'package:joincompany/async_operations/CustomerChannel.dart';
import 'package:joincompany/async_operations/CustomerContactsChannel.dart';
import 'package:joincompany/async_operations/FormChannel.dart';
import 'package:joincompany/async_operations/TaskChannel.dart';
import 'package:joincompany/blocs/blocCheckConnectivity.dart';
import 'package:flutter/services.dart';
import 'package:joincompany/blocs/BlocValidators.dart';
import 'package:joincompany/main.dart';
import 'package:joincompany/models/AddressModel.dart';
import 'package:joincompany/models/AddressesModel.dart';
import 'package:joincompany/models/AuthModel.dart';
import 'package:joincompany/models/BusinessesModel.dart';
import 'package:joincompany/models/ContactsModel.dart';
import 'package:joincompany/models/CustomerModel.dart';
import 'package:joincompany/models/CustomersModel.dart';
import 'package:joincompany/models/FormModel.dart';
import 'package:joincompany/models/FormsModel.dart';
import 'package:joincompany/models/ResponseModel.dart';
import 'package:joincompany/models/TaskModel.dart';
import 'package:joincompany/models/TasksModel.dart';
import 'package:joincompany/models/UserModel.dart';
import 'package:joincompany/services/AuthService.dart';
import 'package:joincompany/services/BusinessService.dart';
import 'package:joincompany/services/ContactService.dart';
import 'package:joincompany/services/CustomerService.dart';
import 'package:joincompany/services/FormService.dart';
import 'package:joincompany/services/TaskService.dart';
import 'package:joincompany/services/UserService.dart';

//import 'package:joincompany/models/ValidatorSms.dart';



class LoginPage extends StatefulWidget {

  LoginPage({this.AgregarUserwidget,this.companyEstablewidget,this.TextViewVisiblewidget});
  final bool TextViewVisiblewidget;
  final bool AgregarUserwidget;
  final String companyEstablewidget;
  @override
  State<StatefulWidget> createState() {
    return _LoginPageState();
  }
}
class _LoginPageState extends State<LoginPage> {

  //singleton
  StreamSubscription _connectionChangeStream;
  bool isOnline = false;

  final companyController = TextEditingController(text : 'factochile');
  final nameController = TextEditingController(text : 'cbarrios@factochile.cl');
  final passwordController = TextEditingController(text: '123');


//  final nameController = TextEditingController();
//  final companyController = TextEditingController();
//  final passwordController = TextEditingController();

  bool TextViewVisible;
  bool AgregarUser;
  String companyEstable;
  bool ErrorTextFieldEmail = false;
  bool ErrorTextFieldpsd = false;
  bool ErrorTextFieldcompany = false;
  String ErrorTextFieldTextemail = '';
  String ErrorTextFieldTextpwd = '';
  String ErrorTextFieldTextcompany = '';
  bool Circuleprogress = false;
  bool ori = false;

  @override
  void initState() {
    ConnectionStatusSingleton connectionStatus = ConnectionStatusSingleton.getInstance();
    _connectionChangeStream = connectionStatus.connectionChange.listen(connectionChanged);
    setState(() {
      isOnline = connectionStatus.connectionStatus;
    });
    TextViewVisible = widget.TextViewVisiblewidget;
    AgregarUser = widget.AgregarUserwidget;
    companyEstable = widget.companyEstablewidget;
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

  }

  void connectionChanged(dynamic hasConnection) {
    setState(() {
      isOnline = hasConnection;
    });
  }
  @override
  void dispose() {
  passwordController.dispose();
  nameController.dispose();
  companyController.dispose();
  _connectionChangeStream.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context);
    if (mediaQueryData.orientation == Orientation.portrait) {
      ori = true;
    }
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: Stack(
        children: <Widget>[
          ListViewPrincipal(),
          Center(
            child: Circuleprogress ? CircularProgressIndicator() : null,
          ),
        ],
      )
    );
  }

  ListViewPrincipal(){
    return ListView(
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.30,
          child: Image.asset('assets/images/final-logo.png',height: MediaQuery.of(context).size.height*0.30,),

        ),
        containerInColumn(),
      ],
    );
  }

  containerInColumn(){
    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.only(top: 62),
      child: Column(
        children: <Widget>[
          Container(
              width: MediaQuery.of(context).size.width/1.2,
              height: MediaQuery.of(context).size.height * 0.08,
              padding: EdgeInsets.only(
                  top: 4,left: 16, right: 16, bottom: 4
              ),
              decoration: BoxDecoration(
                color: Colors.transparent,
              ),
              child: StreamBuilder(
                stream: blocValidators.email,
                builder: (context,snapshot){
                  return TextField(
                    onChanged: blocValidators.changeEmail,
                    controller: nameController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      icon: Icon(Icons.email,
                        color: Colors.black,
                      ),
                      errorText: ErrorTextFieldEmail ? ErrorTextFieldTextemail : null,
                      hintText: 'Usuario',
                    ),
                  );
                },
              )
          ),
          Container(
            width: MediaQuery.of(context).size.width/1.2,
            height: MediaQuery.of(context).size.height * 0.08,
            margin: EdgeInsets.only(top: 32),
            padding: EdgeInsets.only(
                top: 4,left: 16, right: 16, bottom: 4
            ),
            decoration: BoxDecoration(
              color: Colors.transparent,
            ),
            child: StreamBuilder(
              stream: blocValidators.password,
              builder: (context,snapshot){
                return TextField(
                  onChanged: blocValidators.changePassword,
                  obscureText: true,
                  controller: passwordController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    icon: Icon(Icons.vpn_key,
                      color: Colors.black,
                    ),
                    hintText: 'Password',
                    errorText: ErrorTextFieldpsd ? ErrorTextFieldTextpwd : null,
                  ),
                );
              },
            ),
          ),
          TextViewVisible ?
          Container(
            width: MediaQuery.of(context).size.width/1.2,
            height: MediaQuery.of(context).size.height * 0.08,
            margin: EdgeInsets.only(top: 32),
            padding: EdgeInsets.only(
                top: 4,left: 16, right: 16, bottom: 4
            ),
            decoration: BoxDecoration(
              color: Colors.transparent,
            ),
            child: TextField(
              controller: companyController,
              decoration: InputDecoration(
                border: InputBorder.none,
                icon: Icon(Icons.business,
                  color: Colors.black,
                ),
                errorText: ErrorTextFieldcompany ? ErrorTextFieldTextcompany : null,
                hintText: 'Empresa',
              ),
            ) ,
          ) : Container(),
          Container(
            height: MediaQuery.of(context).size.height * 0.08,
            width: MediaQuery.of(context).size.width/1.2,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xff80d8ff),
                    Color(0xff80d8ff)
                  ],
                ),
                borderRadius: BorderRadius.all(
                    Radius.circular(50)
                )
            ),
            child: RaisedButton(
              padding: const EdgeInsets.all(10.0),
              color: PrimaryColor,
              elevation: 15.0,
              textColor: Colors.white,
              splashColor: Colors.white10,

              onPressed: () async {
                ValidarDatos_DB(nameController.text,passwordController.text,companyController.text);
              },
              child: Center(
                  child: Center(
                      child: Text('Ingresar'.toUpperCase(),)
                  )
              ),
            ),
          ),
        ],
      ),
    );
  }

  void ValidateEmail(String email) {
    if (email.isEmpty) {
      ErrorTextFieldEmail = true;
      ErrorTextFieldTextemail = 'Campo requerido';
      setState(() {
        ErrorTextFieldEmail;
        ErrorTextFieldTextemail;
      });
    } else
      ErrorTextFieldEmail = false;
  }

  void ValidatePassword(String password) {
    if (password.isEmpty) {
      ErrorTextFieldpsd = true;
      ErrorTextFieldTextpwd = 'Campo requerido';
      setState(() {
        ErrorTextFieldpsd;
        ErrorTextFieldTextpwd;
      });
    } else
      ErrorTextFieldpsd = false;
  }

  void ValidateCompany(String company) {
    if (company.isEmpty) {
      ErrorTextFieldcompany = true;
      ErrorTextFieldTextcompany = 'Campo requerido';
      setState(() {
        ErrorTextFieldcompany;
        ErrorTextFieldTextcompany;
      });
    } else
      ErrorTextFieldcompany = false;
  }

  bool EvalValidations() {
    return (!ErrorTextFieldpsd && !ErrorTextFieldcompany && !ErrorTextFieldcompany);
  }

  void HandleUnsuccessfulResponse(Response loginResponse) {
    if (loginResponse.statusCode == 401) {
      ErrorTextFieldEmail = true;
      ErrorTextFieldpsd = true;
      ErrorTextFieldcompany = true;
      ErrorTextFieldTextemail = ErrorTextFieldTextpwd =
          ErrorTextFieldTextcompany = 'Datos incorrectos';
      setState(() {
        ErrorTextFieldEmail;
        ErrorTextFieldpsd;
        ErrorTextFieldcompany;
        ErrorTextFieldTextemail;
        ErrorTextFieldTextpwd;
        ErrorTextFieldTextcompany;
      });
      Circuleprogress = false;
      setState(() => Circuleprogress);
    } else if (loginResponse.statusCode == 500) {
      ErrorTextFieldEmail = true;
      ErrorTextFieldpsd = true;
      ErrorTextFieldcompany = true;
      ErrorTextFieldTextemail = ErrorTextFieldTextpwd =
          ErrorTextFieldTextcompany = 'Error en conexion';
      setState(() {
        ErrorTextFieldEmail;
        ErrorTextFieldpsd;
        ErrorTextFieldcompany;
        ErrorTextFieldTextemail;
        ErrorTextFieldTextpwd;
        ErrorTextFieldTextcompany;
      });
      Circuleprogress = false;
      setState(() => Circuleprogress);
    }
  }

  ValidarDatos_DB(String email, String password, String company) async {

    Circuleprogress = true;
    setState(() => Circuleprogress);

    String companyLocal = companyEstable;
    if (AgregarUser)
      companyLocal = company;

    ValidateEmail(email);
    ValidatePassword(password);
    ValidateCompany(companyLocal);

    if (isOnline) {
      if (EvalValidations()) {
        // Query by email:
        UserModel query = UserModel(email: email);
        List<UserModel> usersFromDatabaseByEmail = await DatabaseProvider.db.QueryUser(query);
        UserModel lastUserLogged = await DatabaseProvider.db.RetrieveLastLoggedUser();

        // If there is any user with that email in the db request login from server.
        if (usersFromDatabaseByEmail.isNotEmpty) {
          // Set user so that you don't have to dereference it by the first getter.
          // (You will use it whether or not there is internet connection).
          UserModel user = usersFromDatabaseByEmail.first;

          // Send login request to the server.
          Response loginResponse = await login(email, password, companyLocal);
          if (loginResponse != null) {
            // Validate the http response (Is or isn't 200 the status code?)
            if (loginResponse.statusCode != 200) {
              HandleUnsuccessfulResponse(loginResponse);
            } else {
              // If it was successful, then it SHOULD have a valid token and the like
              // so that it can be just stored in a authModel in order for us to use it.
              AuthModel authFromResponse = AuthModel.fromJson(loginResponse.body);
              // Update the local user's access token.
              user.rememberToken = authFromResponse.accessToken;
              user.password = md5.convert(utf8.encode(password)).toString();
              user.company = companyLocal;
              user.loggedAt = DateTime.now().toString();

              await DatabaseProvider.db.UpdateUser(
                  user.id,
                  user,
                  SyncState.synchronized
              );

              if(user.id != lastUserLogged.id){
                setState(()=>Circuleprogress = false);
                await syncDialog();
              }

              Navigator.pushReplacementNamed(context, '/vistap');
            }
          } else {
            ErrorTextFieldEmail = true;
            ErrorTextFieldpsd = true;
            ErrorTextFieldcompany = true;
            ErrorTextFieldTextemail = ErrorTextFieldTextpwd =
                ErrorTextFieldTextcompany = 'Error en conexion';
            setState(() {
              ErrorTextFieldEmail;
              ErrorTextFieldpsd;
              ErrorTextFieldcompany;
              ErrorTextFieldTextemail;
              ErrorTextFieldTextpwd;
              ErrorTextFieldTextcompany;
            });
            Circuleprogress = false;
            setState(() => Circuleprogress);
          }
        } else
          /* A.K.A* the case in which there is no user with that email in the local db */ {
          // If there is no user with that email in the db request login and store a new user in the local db...
          // Send login request to the server.
          var loginResponse = await login(email, password, companyLocal);
          // The response has arrived!
          if (loginResponse != null) {
            // The login didn't success...
            if (loginResponse.statusCode != 200) {
              HandleUnsuccessfulResponse(loginResponse);
            } else {
              // The login successed!
              var authFromResponse = AuthModel.fromJson(loginResponse.body);
              // Now get an user based on the given token from the server...
              var userFromServerResponse = await getUser(
                  companyLocal, authFromResponse.accessToken);
              // Validate it!
              if (userFromServerResponse != null) {
                UserModel userFromServer = UserModel.fromJson(
                    userFromServerResponse.body);

                userFromServer.rememberToken = authFromResponse.accessToken;
                userFromServer.password = md5.convert(utf8.encode(password)).toString();
                userFromServer.company = companyLocal;
                setState(() {

                });
                await DatabaseProvider.db.CreateUser(userFromServer, SyncState.synchronized);

                setState(()=>Circuleprogress = false);
                await syncDialog();
                Navigator.pushReplacementNamed(context, '/vistap');
              }
            }
          } else {
            // If response is null, do this...
            ErrorTextFieldEmail = true;
            ErrorTextFieldpsd = true;
            ErrorTextFieldcompany = true;
            ErrorTextFieldTextemail = ErrorTextFieldTextpwd =
                ErrorTextFieldTextcompany = 'Error en conexion';
            setState(() {
              ErrorTextFieldEmail;
              ErrorTextFieldpsd;
              ErrorTextFieldcompany;
              ErrorTextFieldTextemail;
              ErrorTextFieldTextpwd;
              ErrorTextFieldTextcompany;
            });
            Circuleprogress = false;
            setState(() => Circuleprogress);
          }
        }
      }
    } else {
      if ((await DatabaseProvider.db.RetrieveLastLoggedUser()) == null) {
        ErrorTextFieldEmail = true;
        ErrorTextFieldpsd = true;
        ErrorTextFieldcompany = true;
        ErrorTextFieldTextemail = ErrorTextFieldTextpwd = ErrorTextFieldTextcompany ='Error en conexion';
        setState(() {
          ErrorTextFieldEmail;
          ErrorTextFieldpsd;
          ErrorTextFieldcompany;
          ErrorTextFieldTextemail;
          ErrorTextFieldTextpwd;
          ErrorTextFieldTextcompany;
        });
        Circuleprogress = false;
        setState(() => Circuleprogress);
      } else {
        UserModel query = UserModel(email: email);
        List<UserModel> usersFromDatabaseByEmail = await DatabaseProvider.db.QueryUser(query);
        if (usersFromDatabaseByEmail.isEmpty) {
          ErrorTextFieldEmail = true;
          ErrorTextFieldTextemail = "No se ha encontrado ningun usuario con este correo.";
          setState(() {
            ErrorTextFieldEmail;
            ErrorTextFieldTextemail;
          });
        } else if (usersFromDatabaseByEmail.first.id != (await DatabaseProvider.db.RetrieveLastLoggedUser()).id) {
          ErrorTextFieldEmail = true;
          ErrorTextFieldTextemail = "Se necesita conexión a internet para sincronizar los datos de este usuario.";
          setState(() {
            ErrorTextFieldEmail;
            ErrorTextFieldTextemail;
          });
        } else {
          UserModel user = usersFromDatabaseByEmail.first;
          password = md5.convert(utf8.encode(password)).toString();
          if (user.password == password) {
            user.loggedAt = DateTime.now().toString();
            await DatabaseProvider.db.UpdateUser(
                user.id,
                user,
                SyncState.synchronized
            );
            Navigator.pushReplacementNamed(context, '/vistap');
          } else {
            ErrorTextFieldpsd = true;
            ErrorTextFieldTextpwd = "Las contraseñas no coinciden.";
            setState(() {
              ErrorTextFieldpsd;
              ErrorTextFieldTextpwd;
            });
          }
        }
      }
    }
  }


  Future syncDialog(){
    return showDialog(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return SyncApp();
      },
    );
  }

}

class SyncApp extends StatefulWidget {
  @override
  _SyncAppState createState() => _SyncAppState();
}

class _SyncAppState extends State<SyncApp> {

  Widget title;
  bool flag = true;

  syncAll() async{
    setState((){title = Text("Sincronizando Datos 1/8");});
    await AddressChannel.syncEverything();
    setState((){title = Text("Sincronizando Datos 2/8");});
    await CustomerChannel.syncEverything();
    setState((){title = Text("Sincronizando Datos 3/8");});
    await CustomerAddressesChannel.syncEverything();
    setState((){title = Text("Sincronizando Datos 4/8");});
    await ContactChannel.syncEverything();
    setState((){title = Text("Sincronizando Datos 5/8");});
    await CustomerContactsChannel.syncEverything();
    setState((){title = Text("Sincronizando Datos 6/8");});
    await BusinessChannel.syncEverything();
    setState((){title = Text("Sincronizando Datos 7/8");});
    await FormChannel.syncEverything();
    setState((){title = Text("Sincronizando Datos 8/8");});
    await TaskChannel.syncEverything();
    Navigator.pop(context);
  }


  @override
  Widget build(BuildContext context) {
    if (flag) {
      syncAll();
      flag = false;
    }

    return AlertDialog(
        title: title,
        content:SizedBox(
          height: 100.0,
          width: 100.0,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        )
    );;
  }
}


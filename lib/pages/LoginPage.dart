import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:joincompany/async_database/Database.dart';
import 'package:joincompany/async_operations/AddressChannel.dart';
import 'package:joincompany/async_operations/CustomerAddressesChannel.dart';
import 'package:joincompany/async_operations/CustomerChannel.dart';
import 'package:joincompany/async_operations/FormChannel.dart';
import 'package:joincompany/blocs/blocCheckConnectivity.dart';
import 'package:joincompany/blocs/BlocValidators.dart';
import 'package:joincompany/main.dart';
import 'package:joincompany/models/AddressModel.dart';
import 'package:joincompany/models/AddressesModel.dart';
import 'package:joincompany/models/AuthModel.dart';
import 'package:joincompany/models/CustomerModel.dart';
import 'package:joincompany/models/CustomersModel.dart';
import 'package:joincompany/models/FormModel.dart';
import 'package:joincompany/models/FormsModel.dart';
import 'package:joincompany/models/TaskModel.dart';
import 'package:joincompany/models/TasksModel.dart';
import 'package:joincompany/models/UserModel.dart';
import 'package:joincompany/services/AuthService.dart';
import 'package:joincompany/services/CustomerService.dart';
import 'package:joincompany/services/FormService.dart';
import 'package:joincompany/services/TaskService.dart';
import 'package:joincompany/services/UserService.dart';

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

  // final nameController = TextEditingController(text : 'eibanez@duperu.com');
  // final companyController = TextEditingController(text : 'duperu');
 final nameController = TextEditingController(text : 'jgarcia@getkem.com');
 final companyController = TextEditingController(text : 'getkem');
  final passwordController = TextEditingController(text : '123');

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
  }

  void connectionChanged(dynamic hasConnection) {
    setState(() {
      isOnline = !hasConnection;
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
          child: Column(
            children: <Widget>[
              Spacer(),
              Align(
                alignment: Alignment.center,
                child: Container(
                  child: Image.asset('assets/images/final-logo.png'),
                )
              ),
            ],
          ),
        ),
        ContainerDentroColum(),
      ],
    );
  }

  ContainerDentroColum(){
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
                // testApi();
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
        List<UserModel> usersFromDatabaseByEmail = await DatabaseProvider.db.QueryUser(
            query);

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
              await DatabaseProvider.db.UpdateUser(
                  user.id,
                  user,
                  SyncState.synchronized
              );

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

                await DatabaseProvider.db.CreateUser(userFromServer, SyncState.synchronized);                

                await AddressChannel.syncEverything();
                await CustomerChannel.syncEverything();
                await CustomerAddressesChannel.syncEverything();
                await FormChannel.syncEverything();
                
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
        } else {
          UserModel user = usersFromDatabaseByEmail.first;
          password = md5.convert(utf8.encode(password)).toString();
          if (user.password == password) {
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

  getFormsRaw() {
    return '{ "current_page": 1, "data": [ { "id": 3, "created_at": "2018-10-21 20:06:29", "updated_at": "2018-10-21 20:06:31", "deleted_at": null, "created_by_id": 1, "updated_by_id": 1, "deleted_by_id": null, "name": "Enrolamiento eHuapi 3", "with_checkinout": true, "active": true }, { "id": 1, "created_at": "2018-07-18 17:48:04", "updated_at": "2018-07-18 17:48:04", "deleted_at": null, "created_by_id": 1, "updated_by_id": 1, "deleted_by_id": null, "name": "Notas", "with_checkinout": false, "active": true }, { "id": 2, "created_at": "2018-07-18 17:50:19", "updated_at": "2018-07-18 17:50:19", "deleted_at": null, "created_by_id": 1, "updated_by_id": 1, "deleted_by_id": null, "name": "Visitas", "with_checkinout": true, "active": true } ], "first_page_url": "https://webapp.getkem.com/api/v1/forms?page=1", "from": 1, "last_page": 1, "last_page_url": "https://webapp.getkem.com/api/v1/forms?page=1", "next_page_url": null, "path": "https://webapp.getkem.com/api/v1/forms", "per_page": 20, "prev_page_url": null, "to": 3, "total": 3 } ';
    // return '{ "current_page": 1, "data": [ { "id": 1, "created_at": "2018-07-18 17:48:04", "updated_at": "2018-07-18 17:48:04", "deleted_at": null, "created_by_id": 1, "updated_by_id": 1, "deleted_by_id": null, "name": "Notas", "with_checkinout": false, "active": true }, { "id": 2, "created_at": "2018-07-18 17:50:19", "updated_at": "2018-07-18 17:50:19", "deleted_at": null, "created_by_id": 1, "updated_by_id": 1, "deleted_by_id": null, "name": "Visitas", "with_checkinout": true, "active": true } ], "first_page_url": "https://webapp.getkem.com/api/v1/forms?page=1", "from": 1, "last_page": 1, "last_page_url": "https://webapp.getkem.com/api/v1/forms?page=1", "next_page_url": null, "path": "https://webapp.getkem.com/api/v1/forms", "per_page": 20, "prev_page_url": null, "to": 3, "total": 3 } ';
  }

  getFormRaw(int id) {
    if(id==1){
      return ' { "id": 1, "created_at": "2018-07-18 17:48:04", "updated_at": "2018-07-21 17:48:04", "deleted_at": null, "created_by_id": 1, "updated_by_id": 1, "deleted_by_id": null, "name": "Notas", "with_checkinout": false, "active": true, "sections": [ { "id": 1, "created_at": "2018-07-18 17:48:57", "updated_at": "2018-07-18 17:48:57", "deleted_at": null, "created_by_id": 1, "updated_by_id": 1, "deleted_by_id": null, "section_id": null, "entity_type": "Form", "entity_id": 1, "type": "section", "name": "Datos de la Nota", "code": "SECTION_1", "subtitle": null, "position": 1, "field_default_value": null, "field_type": null, "field_placeholder": null, "field_options": [], "field_collection": null, "field_required": false, "field_width": 3, "fields": [ { "id": 2, "created_at": "2018-07-18 17:50:03", "updated_at": "2018-07-18 17:50:03", "deleted_at": null, "created_by_id": 1, "updated_by_id": 1, "deleted_by_id": null, "section_id": 1, "entity_type": "Form", "entity_id": 1, "type": "field", "name": "Comentarios", "code": "FIELD_2", "subtitle": null, "position": 1, "field_default_value": null, "field_type": "TextArea", "field_placeholder": null, "field_options": [], "field_collection": null, "field_required": false, "field_width": 3 } ] } ] } '; 
      //actualizado
      // return ' { "id": 1, "created_at": "2018-07-18 17:48:04", "updated_at": "2018-07-21 17:48:04", "deleted_at": null, "created_by_id": 1, "updated_by_id": 1, "deleted_by_id": null, "name": "Notas", "with_checkinout": false, "active": true, "sections": [ { "id": 1, "created_at": "2018-07-18 17:48:57", "updated_at": "2018-07-18 17:48:57", "deleted_at": null, "created_by_id": 1, "updated_by_id": 1, "deleted_by_id": null, "section_id": null, "entity_type": "Form", "entity_id": 1, "type": "section", "name": "Datos de la Nota", "code": "SECTION_1", "subtitle": null, "position": 1, "field_default_value": null, "field_type": null, "field_placeholder": null, "field_options": [], "field_collection": null, "field_required": false, "field_width": 3, "fields": [ { "id": 2, "created_at": "2018-07-18 17:50:03", "updated_at": "2019-07-18 17:50:03", "deleted_at": null, "created_by_id": 1, "updated_by_id": 1, "deleted_by_id": null, "section_id": 1, "entity_type": "Form", "entity_id": 1, "type": "field", "name": "Comentarios test", "code": "FIELD_2", "subtitle": null, "position": 1, "field_default_value": null, "field_type": "TextArea", "field_placeholder": null, "field_options": [], "field_collection": null, "field_required": false, "field_width": 3 } ] } ] } '; 
    }

    if(id==2){
      return ' { "id": 2, "created_at": "2018-07-18 17:50:19", "updated_at": "2018-07-18 17:50:19", "deleted_at": null, "created_by_id": 1, "updated_by_id": 1, "deleted_by_id": null, "name": "Visitas", "with_checkinout": true, "active": true, "sections": [ { "id": 3, "created_at": "2018-07-18 17:48:57", "updated_at": "2018-07-18 17:48:57", "deleted_at": null, "created_by_id": 1, "updated_by_id": 1, "deleted_by_id": null, "section_id": null, "entity_type": "Form", "entity_id": 2, "type": "section", "name": "Datos de Visita", "code": "SECTION_3", "subtitle": null, "position": 1, "field_default_value": null, "field_type": null, "field_placeholder": null, "field_options": [], "field_collection": null, "field_required": false, "field_width": 3, "fields": [ { "id": 4, "created_at": "2018-07-18 17:50:03", "updated_at": "2018-07-18 17:50:03", "deleted_at": null, "created_by_id": 1, "updated_by_id": 1, "deleted_by_id": null, "section_id": 3, "entity_type": "Form", "entity_id": 2, "type": "field", "name": "Comentarios", "code": "FIELD_4", "subtitle": null, "position": 1, "field_default_value": null, "field_type": "TextArea", "field_placeholder": null, "field_options": [], "field_collection": null, "field_required": false, "field_width": 3 }, { "id": 37, "created_at": null, "updated_at": null, "deleted_at": null, "created_by_id": null, "updated_by_id": null, "deleted_by_id": null, "section_id": 3, "entity_type": "Form", "entity_id": 2, "type": "field", "name": "Checkin", "code": "FIELD_35", "subtitle": null, "position": 1, "field_default_value": null, "field_type": "Button", "field_placeholder": null, "field_options": [], "field_collection": null, "field_required": false, "field_width": 3 }, { "id": 38, "created_at": null, "updated_at": null, "deleted_at": null, "created_by_id": null, "updated_by_id": null, "deleted_by_id": null, "section_id": 3, "entity_type": "Form", "entity_id": 2, "type": "field", "name": "ComboSearch", "code": "FIELD_36", "subtitle": null, "position": 1, "field_default_value": null, "field_type": "ComboSearch", "field_placeholder": null, "field_options": [ { "value": 56, "name": "Item1" }, { "value": 57, "name": "Item2" } ], "field_collection": "ComboSearch", "field_required": false, "field_width": 3 }, { "id": 39, "created_at": null, "updated_at": null, "deleted_at": null, "created_by_id": null, "updated_by_id": null, "deleted_by_id": null, "section_id": 3, "entity_type": "Form", "entity_id": 2, "type": "field", "name": "Table", "code": "FIELD_37", "subtitle": null, "position": 1, "field_default_value": "Columna 1*columna 2* columna 3;**;**", "field_type": "Table", "field_placeholder": null, "field_options": [ { "value": 58, "name": "Item1x1" }, { "value": 59, "name": "Item1x2" }, { "value": 60, "name": "Item2x1" }, { "value": 61, "name": "Item2x2" } ], "field_collection": "Table", "field_required": false, "field_width": 3 }, { "id": 40, "created_at": null, "updated_at": null, "deleted_at": null, "created_by_id": null, "updated_by_id": null, "deleted_by_id": null, "section_id": 3, "entity_type": "Form", "entity_id": 2, "type": "field", "name": "Texto", "code": "FIELD_38", "subtitle": null, "position": 1, "field_default_value": null, "field_type": "Text", "field_placeholder": null, "field_options": [], "field_collection": null, "field_required": false, "field_width": 3 }, { "id": 5, "created_at": "2018-07-18 17:50:03", "updated_at": "2018-07-18 17:50:03", "deleted_at": null, "created_by_id": 1, "updated_by_id": 1, "deleted_by_id": null, "section_id": 3, "entity_type": "Form", "entity_id": 2, "type": "field", "name": "Fotografía", "code": "FIELD_5", "subtitle": null, "position": 2, "field_default_value": null, "field_type": "Photo", "field_placeholder": null, "field_options": [], "field_collection": null, "field_required": false, "field_width": 3 }, { "id": 6, "created_at": "2018-07-18 17:50:03", "updated_at": "2018-07-18 17:50:03", "deleted_at": null, "created_by_id": 1, "updated_by_id": 1, "deleted_by_id": null, "section_id": 3, "entity_type": "Form", "entity_id": 2, "type": "field", "name": "Tipo de vista (Seleccionador)", "code": "FIELD_6", "subtitle": null, "position": 3, "field_default_value": null, "field_type": "Combo", "field_placeholder": null, "field_options": [ { "value": 1, "name": "Venta" }, { "value": 2, "name": "Fidelización" }, { "value": 3, "name": "Retención" } ], "field_collection": "TipoVisitas", "field_required": false, "field_width": 3 }, { "id": 7, "created_at": "2018-07-18 17:53:38", "updated_at": "2018-07-18 17:53:38", "deleted_at": null, "created_by_id": 1, "updated_by_id": 1, "deleted_by_id": null, "section_id": 3, "entity_type": "Form", "entity_id": 2, "type": "field", "name": "Prioritario (Checklist)", "code": "FIELD_7", "subtitle": null, "position": 4, "field_default_value": null, "field_type": "Boolean", "field_placeholder": null, "field_options": [], "field_collection": null, "field_required": false, "field_width": 3 }, { "id": 9, "created_at": "2018-09-11 16:47:46", "updated_at": "2018-09-11 16:47:49", "deleted_at": null, "created_by_id": 1, "updated_by_id": 1, "deleted_by_id": null, "section_id": 3, "entity_type": "Form", "entity_id": 2, "type": "field", "name": "Firma cliente (Firma conformidad)", "code": "FIELD_8", "subtitle": null, "position": 5, "field_default_value": null, "field_type": "CanvanSignature", "field_placeholder": null, "field_options": [], "field_collection": null, "field_required": false, "field_width": 3 }, { "id": 11, "created_at": "2018-09-11 16:49:57", "updated_at": "2018-09-11 16:50:00", "deleted_at": null, "created_by_id": 1, "updated_by_id": 1, "deleted_by_id": null, "section_id": 3, "entity_type": "Form", "entity_id": 2, "type": "field", "name": "Indicador sobre imagen (Dibujo sobre imagen)", "code": "FIELD_9", "subtitle": null, "position": 6, "field_default_value": "https://previews.123rf.com/images/pandavector/pandavector1612/pandavector161200463/69448631-icono-de-ri%C3%B1ones-humanos-en-el-estilo-de-contorno-aislado-en-el-fondo-blanco-%C3%B3rganos-humanos-ilustraci%C3%B3n-s%C3%ADmbol.jpg", "field_type": "CanvanImage", "field_placeholder": null, "field_options": [], "field_collection": null, "field_required": false, "field_width": 3 }, { "id": 12, "created_at": "2018-09-11 16:51:55", "updated_at": "2018-09-11 16:51:58", "deleted_at": null, "created_by_id": 1, "updated_by_id": 1, "deleted_by_id": null, "section_id": 3, "entity_type": "Form", "entity_id": 2, "type": "field", "name": "Nota (Texto predefinido)", "code": "FIELD_10", "subtitle": null, "position": 7, "field_default_value": "Esto es un label", "field_type": "Label", "field_placeholder": null, "field_options": [], "field_collection": null, "field_required": false, "field_width": 3 }, { "id": 13, "created_at": "2018-09-11 16:53:16", "updated_at": "2018-09-11 16:53:19", "deleted_at": null, "created_by_id": 1, "updated_by_id": 1, "deleted_by_id": null, "section_id": 3, "entity_type": "Form", "entity_id": 2, "type": "field", "name": "Logo imagen (Imagen predefinida)", "code": "FIELD_11", "subtitle": null, "position": 8, "field_default_value": "http://www.brandemia.org/wp-content/uploads/2012/10/logo_principal.jpg", "field_type": "Image", "field_placeholder": null, "field_options": [], "field_collection": null, "field_required": false, "field_width": 3 }, { "id": 14, "created_at": "2018-09-11 16:54:31", "updated_at": "2018-09-11 16:54:34", "deleted_at": null, "created_by_id": 1, "updated_by_id": 1, "deleted_by_id": null, "section_id": 3, "entity_type": "Form", "entity_id": 2, "type": "field", "name": "Fecha", "code": "FIELD_12", "subtitle": null, "position": 9, "field_default_value": null, "field_type": "Date", "field_placeholder": null, "field_options": [], "field_collection": null, "field_required": false, "field_width": 3 }, { "id": 15, "created_at": "2018-09-11 16:55:25", "updated_at": "2018-09-11 16:55:29", "deleted_at": null, "created_by_id": 1, "updated_by_id": 1, "deleted_by_id": null, "section_id": 3, "entity_type": "Form", "entity_id": 2, "type": "field", "name": "Hora", "code": "FIELD_13", "subtitle": null, "position": 10, "field_default_value": null, "field_type": "Time", "field_placeholder": null, "field_options": [], "field_collection": null, "field_required": false, "field_width": 3 }, { "id": 16, "created_at": "2018-09-11 16:56:19", "updated_at": "2018-09-11 16:56:26", "deleted_at": null, "created_by_id": 1, "updated_by_id": 1, "deleted_by_id": null, "section_id": 3, "entity_type": "Form", "entity_id": 2, "type": "field", "name": "Fecha y hora", "code": "FIELD_14", "subtitle": null, "position": 11, "field_default_value": null, "field_type": "DateTime", "field_placeholder": null, "field_options": [], "field_collection": null, "field_required": false, "field_width": 3 } ] } ] } ';
    }

    if(id==3){
      return ' { "id": 3, "created_at": "2018-07-18 17:50:19", "updated_at": "2018-07-18 17:50:19", "deleted_at": null, "created_by_id": 1, "updated_by_id": 1, "deleted_by_id": 14, "name": "Enrolamiento eHuapi 3", "with_checkinout": true, "active": true, "sections": [ { "id": 17, "created_at": "2018-07-18 17:50:19", "updated_at": "2018-07-18 17:48:57", "deleted_at": null, "created_by_id": 1, "updated_by_id": 1, "deleted_by_id": 1, "section_id": 1, "entity_type": "Form", "entity_id": 3, "type": "section", "name": "Datos persona que atiende", "code": "SECTION_15", "subtitle": "test", "position": 12, "field_default_value": "test", "field_type": "", "field_placeholder": "test", "field_options": [], "field_collection": "test", "field_required": false, "field_width": 3, "fields": [ { "id": 35, "created_at": "2018-07-18 17:50:19", "updated_at": "2018-07-18 17:48:57", "deleted_at": null, "created_by_id": 1, "updated_by_id": 1, "deleted_by_id": 1, "section_id": 26, "entity_type": "Form", "entity_id": 3, "type": "field", "name": "Giro", "code": "FIELD_33", "subtitle": "test", "position": 30, "field_default_value": "test", "field_type": "Combo", "field_placeholder": "test", "field_options": [ { "value": 16, "name": "Botillería" }, { "value": 17, "name": "Roticería" }, { "value": 18, "name": "Minimarket" }, { "value": 19, "name": "Carnicería" }, { "value": 20, "name": "Otro" } ], "field_collection": "Giro", "field_required": false, "field_width": 3 } ] } ] }';
    }
  }

  testApi() async{

    try {
      print("---------------- Inicia test. ----------------------------");

      String email = 'jgarcia@getkem.com';
      // String email = 'jgarcia@getkem.com';
      String password = '123';
      String customer = 'getkem';

      // login
      // var loginResponse = await login(email, password, customer);
      // AuthModel auth = AuthModel.fromJson(loginResponse.body);
      // String authorization = auth.accessToken;
      // print(auth.accessToken);
      // print(auth.accessToken.length);
      // print(loginResponse.headers['content-type']);

      // var logoutResponse = await logout(customer, authorization);
      // print(logoutResponse.body);

      // var refreshResponse = await refreshToken(customer, authorization);
      // print(refreshResponse.body);

      // Customer Get
      // var getCustomerResponse = await getCustomer('387', customer, authorization);
      // CustomerModel customerObj = getCustomerResponse.body;
      // print(customerObj.name);
      // print(getCustomerResponse.body);

      // Customer Update
      // customerObj.name += ' rr';
      // var updateCustomerResponse = await updateCustomer('2', customerObj, customer, authorization);
      // print(updateCustomerResponse.body);

      // Customer Create
      // CustomerModel customerObjNew = CustomerModel(
      //   name : '123Test test test', 
      //   code : '1132154654', 
      //   email : "test12@test.com", 
      //   phone : "79879812", 
      //   contactName : "name12 conact", 
      //   details : "nota 12" 
      // );
      // var createCustomerResponse = await createCustomer(customerObjNew, customer, authorization);
      // print(createCustomerResponse.request);
      // print(createCustomerResponse.statusCode);
      // print(createCustomerResponse.body);

      // Customer Delete
      // var deleteCustomerResponse = await deleteCustomer('411', customer, authorization);
      // print(deleteCustomerResponse.body);
      // bool eliminado = deleteCustomerResponse.body == '1' ? true : false;
      // print(eliminado);

      // Customer All
      // var getAllCustomersResponse = await getAllCustomers(customer, authorization);
      // CustomersModel customers = CustomersModel.fromJson(getAllCustomersResponse.body);
      // print(customers.data[0].name);
      // print(getAllCustomersResponse.body);

      // Customers With Address
      // var getAllCustomersWithAddressResponse = await getAllCustomersWithAddress(customer, authorization);
      // CustomersWithAddressModel customersWithAddres = getAllCustomersWithAddressResponse.body;
      // print(customersWithAddres.data[0].name);
      // print(customersWithAddres.data[0].latitude);
      // print(getAllCustomersWithAddressResponse.body);

      // Customer Addresses
      // var getCustomerAddressesResponse = await getCustomerAddresses('387', customer, authorization);
      // List<AddressModel> customerAddresses = new List<AddressModel>.from(json.decode(getCustomerAddressesResponse.body).map((x) => AddressModel.fromMap(x)));
      // print(customerAddresses.length);
      // print(customerAddresses[0].address);

      // Customer Address Relate
      // var relateCustomerAddressResponse = await relateCustomerAddress('417', '345', customer, authorization);
      // print(relateCustomerAddressResponse.statusCode);
      // print(relateCustomerAddressResponse.body);

      // Customer Address Unrelate
      // var unrelateCustomerAddressResponse = await unrelateCustomerAddress('417', '345', customer, authorization);
      // print(unrelateCustomerAddressResponse.request);
      // print(unrelateCustomerAddressResponse.statusCode);
      // print(unrelateCustomerAddressResponse.body);
      // Task Create
      // TaskModel taskNew = new TaskModel(
      //   name: 'Enrolamiento eHuapi',
      //   formId: 3,
      //   responsibleId: 3,
      //   customerId: 408,
      //   addressId: 345,
      //   customValuesMap: {"18": "test", "20": "valor test"}
      // );
      // var createTaskResponse = await createTask(taskNew, customer, authorization);
      // var body = createTaskResponse.body;
      // print(createTaskResponse.request);
      // print(createTaskResponse.statusCode);
      // print(createTaskResponse.body);

      // Task Get
      // var getTaskResponse = await getTask('2427', customer, authorization);
      // TaskModel task = TaskModel.fromJson(getTaskResponse.body);
      // print(task.name);
      // print(task.responsibleId);
      // print(task.checkinLatitude);

      // Task All
      // var getAllTasksResponse = await getAllTasks(customer, authorization);
      // TasksModel tasks = TasksModel.fromJson(getAllTasksResponse.body);
      // print(getAllTasksResponse.request);
      // print(getAllTasksResponse.body);
      // print(tasks.data.length);
      // print(tasks.data[0].responsibleId);

      // CheckIn Task
      // var checkInTaskResponse = await checkInTask('2933', customer, authorization, '-33.4544217', '-70.6308317', '678', date: '2019-05-21 11:38:49');
      // TaskModel taskCheckIn = TaskModel.fromJson(checkInTaskResponse.body);
      // print(taskCheckIn.status);


      // CheckOut Task
      // var checkOutTaskResponse = await checkOutTask('2527', customer, authorization, '-12.0949443', '-76.8862068', '');
      // TaskModel taskCheckOut = TaskModel.fromJson(checkOutTaskResponse.body);
      // print(taskCheckOut.status);

      // Form Get
      // var getFormResponse = await getForm('4', customer, authorization);
      // FormModel form = FormModel.fromJson(getFormResponse.body);
      // getFormResponse.body.split(' ').forEach((word) => print(" " + word));

      // Form All
      // var getAllFormsResponse = await getAllForms(customer, authorization);
      // FormsModel forms = FormsModel.fromJson(getAllFormsResponse.body);
      // print(forms.data[1].name);

      // Address Get
      // var getAddressResponse = await getAddress('559', customer, authorization);
      // AddressModel address = AddressModel.fromJson(getAddressResponse.body);
      // print(address.address);
      // print(address.googlePlaceId);
      // print(address.latitude);
      // print(address.longitude);

      // Address All
      // var getAllAddressesResponse = await getAllAddresses(customer, authorization);
      // AddressesModel addresses = AddressesModel.fromJson(getAllAddressesResponse.body);
      // print(addresses.data.length);
      // print(addresses.data[0].address);
      // print(addresses.data[0].googlePlaceId);
      // print(addresses.data[0].latitude);
      // print(addresses.data[0].longitude);

      // User Get
      // var getUserResponse = await getUser(customer, authorization);
      // UserModel user = UserModel.fromJson(getUserResponse.body);
      // print(user.name);
      // print(user.email);
      // print(user.profile);

      // LocalityModel locality = new LocalityModel(id: 1, name: "Locality Manuel");
      // AddressModel address = new AddressModel(id: 355, address: "Manuel Gonzalez Olachea", locality: locality);
      // var res = await DatabaseProvider.db.CreateAddress(address, SyncState.synchronized);
      // print(res);
      // var data = await DatabaseProvider.db.QueryCustomerAddress(null, null, null, null, null, null, null, null);
      // print(data.toString());


      // var data = await DatabaseProvider.db.QueryAddress(AddressModel());
      // print(data.toString());

      // var a1 = await DatabaseProvider.db.ListAddresses();
      // await AddressChannel.syncEverything();
      // var a2 = await DatabaseProvider.db.ListAddresses();

      // var c1 = await DatabaseProvider.db.ListCustomers();
      // await CustomerChannel.syncEverything();
      // var c2 = await DatabaseProvider.db.ListCustomers();

      // var ca1 = await DatabaseProvider.db.ListCustomerAddresses();
      // await CustomerAddressesChannel.syncEverything();
      // var ca2 = await DatabaseProvider.db.ListCustomerAddresses();

      // var fcs = await DatabaseProvider.db.ListForms();
      // await FormChannel.syncEverything();
      // var fce = await DatabaseProvider.db.ListForms();

      // var response = await getAllForms(customer, "");
      // print(response.body);

      // await FormChannel.syncEverything();

      // var formsRaw = getFormsRaw();
      // FormsModel formsServer = FormsModel.fromJson(formsRaw);
      // print(formsServer);

      // for (var i = 0; i < formsServer.data.length; i++) {
      //   var getFormResponse = await getFormRaw(formsServer.data[i].id);
      //   FormModel formServer = FormModel.fromJson(getFormResponse);
      //   FormModel formLocal = await DatabaseProvider.db.ReadFormById(formServer.id);
      //   if (formLocal != null) {
          
      //     DateTime updateDateLocal  = DateTime.parse(formLocal.updatedAt); 
      //     DateTime updateDateServer = DateTime.parse(formServer.updatedAt);
      //     int  diffInMilliseconds = updateDateLocal.difference(updateDateServer).inMilliseconds;
      //     print(diffInMilliseconds);
      //     if ( diffInMilliseconds < 0 ) { // Actualizar Local
      //       await DatabaseProvider.db.UpdateForm(formServer.id, formServer, SyncState.synchronized);
      //     }
      //   } 
      // }

      //var formsResponse = await getAllForms(customer, "");
      //var forms = await formsResponse.body;
      //print(forms);

      var sections = await DatabaseProvider.db.ListSections();
      print(sections);

      // Create Server To Local
    // var formsServerResponse = await getFormsRaw();
    // FormsModel formsServer = FormsModel.fromJson(formsServerResponse);

    // Set idsFormsServer = new Set();
    // await Future.forEach(formsServer.data, (formServer) async {
    //   idsFormsServer.add(formServer.id);
    // });

    // Set idsFormsLocal = new Set.from(await DatabaseProvider.db.RetrieveAllFormIds()); //método de albert

    // Set idsToCreate = idsFormsServer.difference(idsFormsLocal);

    // await Future.forEach(formsServer.data, (formServer) async {
    //   if (idsToCreate.contains(formServer.id)) {
    //     // Cambiar el SyncState Local
    //     var getFormResponse = await getFormRaw(formServer.id);
    //     FormModel form = FormModel.fromJson(getFormResponse);

    //     print("Se va a crear: " + form.name);

    //     await DatabaseProvider.db.CreateForm(form, SyncState.synchronized);
    //   }
    // });



    // Delete
    // var formsServerResponse = await getFormsRaw();
    // FormsModel formsServer = FormsModel.fromJson(formsServerResponse);

    // Set idsFormsServer = new Set();
    // await Future.forEach(formsServer.data, (formServer) async {
    //   idsFormsServer.add(formServer.id);
    // });

    // Set idsFormsLocal = new Set.from( await DatabaseProvider.db.RetrieveAllFormIds() ); //método de albert

    // Set idsToDelete = idsFormsLocal.difference(idsFormsServer);

    // await Future.forEach(idsToDelete, (idToDelete) async{
    //   print("Delete... $idsToDelete" );
    //   await DatabaseProvider.db.DeleteFormById(idToDelete);
    // });




      print("---------------- Fin test. ----------------------------");
    }catch(error, stackTrace){
      print(error);
      print(stackTrace);
    }

  }
}
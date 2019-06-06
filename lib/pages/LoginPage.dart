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
import 'package:joincompany/models/TaskModel.dart';
import 'package:joincompany/models/TasksModel.dart';
import 'package:joincompany/models/UserModel.dart';
import 'package:joincompany/services/AuthService.dart';
import 'package:joincompany/services/CustomerService.dart';
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
              user.loggedAt = DateTime.now().toString();
              user.password = md5.convert(utf8.encode(password)).toString();
              user.company = companyLocal;
              DatabaseProvider.db.UpdateUser(
                  user.id,
                  user,
                  SyncState.synchronized
              );
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
                userFromServer.loggedAt = DateTime.now().toString();
                userFromServer.password =
                    md5.convert(utf8.encode(password)).toString();
                userFromServer.company = companyLocal;
                await DatabaseProvider.db.CreateUser(
                    userFromServer, SyncState.synchronized);
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

  testApi() async{

    try {
      print("---------------- Inicia test. ----------------------------");

      String email = 'jgarcia@getkem.com';
      // String email = 'jgarcia@getkem.com';
      String password = '123';
      String customer = 'getkem';

      // login
      var loginResponse = await login(email, password, customer);
      AuthModel auth = AuthModel.fromJson(loginResponse.body);
      String authorization = auth.accessToken;
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

      // await AddressChannel.syncEverything();
      // await CustomerChannel.syncEverything();
      // await CustomerAddressesChannel.syncEverything();
      // await FormChannel.syncEverything();

      print("---------------- Fin test. ----------------------------");
    }catch(error, stackTrace){

    }

  }
}
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

import 'package:http/http.dart' as http;
import 'dart:async';
//import 'package:joincompany/models/ValidatorSms.dart';



class LoginPage extends StatefulWidget {

  LoginPage({this.addUserWidget,this.companyEstableWidget,this.textViewVisibleWidget});
  final bool textViewVisibleWidget;
  final bool addUserWidget;
  final String companyEstableWidget;
  @override
  State<StatefulWidget> createState() {
    return _LoginPageState();
  }
}
class _LoginPageState extends State<LoginPage> {

  //singleton
  StreamSubscription _connectionChangeStream;
  bool isOnline = false;

//  final nameController = TextEditingController(text : 'eibanez@duperu.com');
//     final companyController = TextEditingController(text : 'duperu');
    final nameController = TextEditingController(text: 'cbarrios@factochile.cl');
     final companyController = TextEditingController(text: 'factochile');
  final passwordController = TextEditingController(text: '123');

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

    TextViewVisible = widget.textViewVisibleWidget;
    AgregarUser = widget.addUserWidget;
    companyEstable = widget.companyEstableWidget;
    super.initState();
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
                await ContactChannel.syncEverything();
                await BusinessChannel.syncEverything();
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

      print("------------------------------- Inicia Test ----------------------------");

      // String email = 'jgarcia@getkem.com';
      String email = 'cbarrios@factochile.cl';
      String password = '123';
      String customer = 'factochile';

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

      // var formsResponse = await getAllForms(customer, "");
      // var forms = await formsResponse.body;
      // print(forms);

      // var sections = await DatabaseProvider.db.ListSections();
      // print(sections);

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

    // Contact All
    // var getAllContactsResponse = await getAllContacts(customer, authorization);
    // ContactsModel contacts = ContactsModel.fromJson(getAllContactsResponse.body);
    // print(getAllContactsResponse.request);
    // print(getAllContactsResponse.body);
    // print(contacts.data.length);
    // print(contacts.data[0].name);

    // Contact Get
    // var getContactResponse = await getContact("5", customer, authorization);
    // ContactModel contact = ContactModel.fromJson(getContactResponse.body);
    // print(getContactResponse.body);
    // print(contact.id);
    // print(contact.name);

    // Contact Create
    // ContactModel contactObjNew = new ContactModel(
    //   customerId: 467,
    //   name: "Nombre Contacto",
    //   phone: "0414-123456",
    //   email: "contacto@contacto.com",
    //   details: "Nota de Contacto"
    // );
    // var createContactResponse = await createContact(contactObjNew, customer, authorization);
    // print(createContactResponse.statusCode);
    // print(createContactResponse.body);
    // ContactModel contactCreated = ContactModel.fromJson(createContactResponse.body);
    // print(contactCreated.name);

    // Contact Update
    // contact.name = 'Nombre Actualizado';
    // var updateContactResponse = await updateContact('5', contact, customer, authorization);
    // print(updateContactResponse.request);
    // print(updateContactResponse.statusCode);
    // print(updateContactResponse.body);

    // Contact Delete
    // var deleteContactResponse = await deleteContact('6', customer, authorization);
    // print(deleteContactResponse.request);
    // print(deleteContactResponse.body);
    // bool eliminado = deleteContactResponse.body == '1' ? true : false;
    // print(eliminado);

    // Business All
    // var getAllBusinessesResponse = await getAllBusinesses(customer, authorization);
    // BusinessesModel businesses = BusinessesModel.fromJson(getAllBusinessesResponse.body);
    // print(getAllBusinessesResponse.request);
    // print(getAllBusinessesResponse.body);
    // print(businesses.data.length);
    // print(businesses.data[0].name);

    // Business Get
    // var getBusinessResponse = await getBusiness("4", customer, authorization);
    // BusinessModel business = BusinessModel.fromJson(getBusinessResponse.body);
    // print(getBusinessResponse.body);
    // print(business.id);
    // print(business.name);

    // Business Create
    // BusinessModel businessObjNew = new BusinessModel(
    //   customerId: 467,
    //   name: "Nombre Business",
    //   stage: "Nueva Etapa",
    //   date: "2019-06-19",
    //   amount: "0"
    // );
    // var createBusinessResponse = await createBusiness(businessObjNew, customer, authorization);
    // print(createBusinessResponse.statusCode);
    // print(createBusinessResponse.body);
    // BusinessModel businessCreated = BusinessModel.fromJson(createBusinessResponse.body);
    // print(businessCreated.name);

    // Business Update
    // business.name = 'Nombre Actualizado 33';
    // var updateBusinessResponse = await updateBusiness('4', business, customer, authorization);
    // print(updateBusinessResponse.request);
    // print(updateBusinessResponse.statusCode);
    // print(updateBusinessResponse.body);

    // Business Delete
    // var deleteBusinessResponse = await deleteBusiness('3', customer, authorization);
    // print(deleteBusinessResponse.request);
    // print(deleteBusinessResponse.body);
    // bool eliminado = deleteBusinessResponse.body == '1' ? true : false;
    // print(eliminado);

    // Customer Contacts All
    // var getCustomerContactsResponse = await getCustomerContacts('467', customer, authorization);
    // ContactsModel customerContacts = ContactsModel.fromJson(getCustomerContactsResponse.body);
    // print(getCustomerContactsResponse.request);
    // print(getCustomerContactsResponse.body);
    // print(customerContacts.data.length);
    // print(customerContacts.data[0].name);

    // Customer Contact Relate
    // var relateCustomerContactResponse = await relateCustomerContact('472', '5', customer, authorization);
    // print(relateCustomerContactResponse.statusCode);
    // print(relateCustomerContactResponse.body);

    // Customer Contact Unrelate
    // var unrelateCustomerContactResponse = await unrelateCustomerContact('40', '5', customer, authorization);
    // print(unrelateCustomerContactResponse.request);
    // print(unrelateCustomerContactResponse.statusCode);
    // print(unrelateCustomerContactResponse.body);

    // Customer Businesess All
    // var getCustomerBusinesessResponse = await getCustomerBusinesses('21', customer, authorization);
    // BusinessesModel customerBusinesess = BusinessesModel.fromJson(getCustomerBusinesessResponse.body);
    // print(getCustomerBusinesessResponse.request);
    // print(getCustomerBusinesessResponse.body);
    // print(customerBusinesess.data.length);
    // print(customerBusinesess.data[0].name);

    // Customer Business Relate
    // var relateCustomerBusinessResponse = await relateCustomerBusiness('21', '2', customer, authorization);
    // print(relateCustomerBusinessResponse.statusCode);
    // print(relateCustomerBusinessResponse.body);

    // await ContactChannel.syncEverything();

      // UserModel user = await DatabaseProvider.db.RetrieveLastLoggedUser();

      // ResponseModel a = await getAllContacts(user.company, user.rememberToken);
      // ContactsModel b = a.body;
      // print(b.data.length);



      print("---------------- Fin test. ----------------------------");
    }catch(error, stackTrace){
      print(error);
      print(stackTrace);
    }

  }
}
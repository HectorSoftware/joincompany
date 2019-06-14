
import 'package:flutter/material.dart';
import 'package:joincompany/blocs/BlocValidators.dart';
import 'package:joincompany/main.dart';
import 'package:joincompany/models/AuthModel.dart';
import 'package:joincompany/models/UserDataBase.dart';
import 'package:joincompany/Sqlite/database_helper.dart';
import 'package:joincompany/models/UserModel.dart';
import 'package:joincompany/services/AuthService.dart';
import 'package:joincompany/services/UserService.dart';
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

  UserDataBase saveUser;
  UserDataBase userVe;

//  final nameController = TextEditingController(/*text : 'eibanez@duperu.com'*/);
//     final companyController = TextEditingController(/*text : 'duperu'*/);
//  final nameController = TextEditingController(text : 'jgarcia@getkem.com');
//  final companyController = TextEditingController(text : 'getkem');
  final nameController = TextEditingController(text : 'jcurihual@factochile.cl');
  final companyController = TextEditingController(text : 'factochile');
  final passwordController = TextEditingController(text : '123');

  bool textViewVisible;
  bool addUser;
  String companyEstable;
  bool errorTextFieldEmail = false;
  bool errorTextFieldPsd = false;
  bool errorTextFieldCompany = false;
  String errorTextFieldTextEmail = '';
  String errorTextFieldTextPassword = '';
  String errorTextFieldTextCompany = '';
  bool circularProgress = false;
  bool ori = false;

  @override
  void initState() {
    textViewVisible = widget.textViewVisibleWidget;
    addUser = widget.addUserWidget;
    companyEstable = widget.companyEstableWidget;
    super.initState();
  }
@override
  void dispose() {
  passwordController.dispose();
  nameController.dispose();
  companyController.dispose();
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
          listViewMain(),
          Center(
            child: circularProgress ? CircularProgressIndicator() : null,
          ),
        ],
      )
    );
  }

  listViewMain(){
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
                      errorText: errorTextFieldEmail ? errorTextFieldTextEmail : null,
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
                    errorText: errorTextFieldPsd ? errorTextFieldTextPassword : null,
                  ),
                );
              },
            ),
          ),
          textViewVisible ?
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
                errorText: errorTextFieldCompany ? errorTextFieldTextCompany : null,
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
                validateData(nameController.text,passwordController.text,companyController.text);
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

  validateData(String user, String pwd, String company) async {


    setState(() {
      circularProgress = true;
    });

    String companyLocal = companyEstable;
    if(addUser){
      companyLocal = company;
    }

    if(user == ''){
    setState(() {
      errorTextFieldEmail = true; errorTextFieldTextEmail = 'Campo requerido';
    });

    }else{
      errorTextFieldEmail = false;
    }
    if(pwd == ''){
    setState(() {
      errorTextFieldPsd = true; errorTextFieldTextPassword = 'Campo requerido';
    });
    }else{
      errorTextFieldPsd = false;
    }
    if(companyLocal == ''){
    setState(() {
      errorTextFieldCompany = true; errorTextFieldTextCompany = 'Campo requerido';
    });
    }else{errorTextFieldCompany = false;}

    if((!errorTextFieldPsd)&&(!errorTextFieldCompany)&&(!errorTextFieldCompany)){
      var loginResponse;
      try{
        loginResponse = await login(user, pwd, companyLocal);
      }catch(e){ }

      if(loginResponse != null){
        if(loginResponse.statusCode == 401){
          setState(() {
            errorTextFieldEmail = true;errorTextFieldPsd = true;errorTextFieldCompany = true;
            errorTextFieldTextEmail = errorTextFieldTextPassword = errorTextFieldTextCompany = 'Datos incorrectos';
            circularProgress = false;
          });
        }
        if(loginResponse.statusCode == 500){
          setState(() {
            errorTextFieldEmail = true;errorTextFieldPsd = true;errorTextFieldCompany = true;
            errorTextFieldTextEmail = errorTextFieldTextPassword = errorTextFieldTextCompany ='Error en conexion';
            circularProgress = false;
          });
        }
        if(loginResponse.statusCode == 200){
          AuthModel auth = AuthModel.fromJson(loginResponse.body);

          var getUserResponseid = await getUser(companyLocal,auth.accessToken);
          if(getUserResponseid != null){
            if(addUser){
              UserModel userIdLogueado = UserModel.fromJson(getUserResponseid.body);
              UserDataBase newuser = UserDataBase(name: user,idUserCompany: userIdLogueado.id, idTable: 1,password: pwd,company: companyLocal, token: auth.accessToken);
              await ClientDatabaseProvider.db.saveUser(newuser);
            }else{
             // int res = await ClientDatabaseProvider.db.updatetoken(auth.accessToken);
            }
            Navigator.pushReplacementNamed(context, '/vistap');
          }else{

            setState(() {
              errorTextFieldEmail = true;errorTextFieldPsd = true;errorTextFieldCompany = true;
              errorTextFieldTextEmail = errorTextFieldTextPassword = errorTextFieldTextCompany ='Error en conexion';
              circularProgress = false;
            });

          }
        }
      }else{
        setState(() {
          errorTextFieldEmail = true;errorTextFieldPsd = true;errorTextFieldCompany = true;
          errorTextFieldTextEmail = errorTextFieldTextPassword = errorTextFieldTextCompany ='Error en conexion';
          circularProgress = false;
        });
      }
    }

    /*

    var loginResponse = await login(Usr, pwd, companylocal);
    if(loginResponse.statusCode == 200){
      Navigator.pushReplacementNamed(context, '/vistap');
    }else{

    }*/
  }

//  testApi() async{
//
//    try {
//
//      String email = 'jgarcia@getkem.com';
//      // String email = 'jgarcia@getkem.com';
//      String password = '123';
//      String customer = 'getkem';

      // login
   //   var loginResponse = await login(email, password, customer);
     // AuthModel auth = AuthModel.fromJson(loginResponse.body);
      //String authorization = auth.accessToken;
      // print(auth.accessToken);
      // print(auth.accessToken.length);
      // print(loginResponse.headers['content-type']);

      // var logoutResponse = await logout(customer, authorization);
      // print(logoutResponse.body);

      // var refreshResponse = await refreshToken(customer, authorization);
      // print(refreshResponse.body);

      // Customer Get
      // var getCustomerResponse = await getCustomer('387', customer, authorization);
      // CustomerModel customerObj = CustomerModel.fromJson(getCustomerResponse.body);
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
      // CustomersWithAddressModel customersWithAddres = CustomersWithAddressModel.fromJson(getAllCustomersWithAddressResponse.body);
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
        // name: 'Enrolamiento eHuapi',
        // formId: 3,
        // responsibleId: 3,
        // customerId: 408,
        // addressId: 345,
        // customValuesMap: {"18": "test", "20": "valor test"}
      // );
      // var createTaskResponse = await createTask(taskNew, customer, authorization);
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

//    }catch(error){
//
//    }
//
//  }
}
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:joincompany/blocs/BlocValidators.dart';
import 'package:joincompany/main.dart';
import 'package:joincompany/models/AuthModel.dart';
import 'package:joincompany/models/CustomerModel.dart';
import 'package:joincompany/models/CustomersModel.dart';
import 'package:joincompany/models/FormModel.dart';
import 'package:joincompany/models/FormsModel.dart';
import 'package:joincompany/models/TaskModel.dart';
import 'package:joincompany/models/TasksModel.dart';
import 'package:joincompany/models/UserDataBase.dart';
import 'package:joincompany/pages/home/taskHome.dart';
import 'package:joincompany/Sqlite/database_helper.dart';
import 'package:joincompany/services/AuthService.dart';
import 'package:joincompany/services/CustomerService.dart';
import 'package:joincompany/services/FormService.dart';
import 'package:joincompany/services/TaskService.dart';
import 'package:sentry/sentry.dart' as sentryr;
class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {


  UserDataBase saveUser;
  UserDataBase userVe;
  final nameController = TextEditingController(text : 'eibanez@duperu.com');
  final passwordController = TextEditingController(text : '123');
  final companyController = TextEditingController(text : '');
  bool TextViewVisible = true;
  bool AgregarUser = true;
  String companyEstable = '';
  bool ErrorTextFieldEmail = false;
  bool ErrorTextFieldpsd = false;
  bool ErrorTextFieldcompany = false;
  String ErrorTextFieldTextemail = '';
  String ErrorTextFieldTextpwd = '';
  String ErrorTextFieldTextcompany = '';
  bool Circuleprogress = false;

  @override
  void initState() {
    ValidarUsrPrimeraVez();
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
          height: MediaQuery.of(context).size.height * 0.25,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xff29a0c7),
                  Color(0xff29a0c7)
                ],
              ),
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(90)
              )
          ),
          child: Column(
            children: <Widget>[
              Spacer(),
              Align(
                alignment: Alignment.center,
                child: Icon(Icons.person,
                  size: 90,
                  color: Colors.black,
                ),
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
            child: TextViewVisible ? TextField(
              controller: companyController,
              decoration: InputDecoration(
                border: InputBorder.none,
                icon: Icon(Icons.business,
                  color: Colors.black,
                ),
                errorText: ErrorTextFieldcompany ? ErrorTextFieldTextcompany : null,
                hintText: 'Empresa',
              ),
            ) : Container(),
          ),
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
                ValidarDatos(nameController.text,passwordController.text,companyController.text);
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

  ValidarDatos(String Usr, String pwd, String compy) async {

    Circuleprogress = true;
    setState(() {
      Circuleprogress;
    });

    String companylocal = companyEstable;
    if(AgregarUser){
      companylocal = compy;
    }

    if(Usr == ''){ErrorTextFieldEmail = true; ErrorTextFieldTextemail = 'Campo requerido';
    setState(() {ErrorTextFieldEmail;ErrorTextFieldTextemail;
    });
    }else{ErrorTextFieldEmail = false;}
    if(pwd == ''){ErrorTextFieldpsd = true; ErrorTextFieldTextpwd = 'Campo requerido';
    setState(() {ErrorTextFieldpsd;ErrorTextFieldTextpwd;
    });
    }else{ErrorTextFieldpsd = false;}
    if(companylocal == ''){ErrorTextFieldcompany = true; ErrorTextFieldTextcompany = 'Campo requerido';
    setState(() {ErrorTextFieldcompany;ErrorTextFieldTextcompany;
    });
    }else{ErrorTextFieldcompany = false;}

    if((!ErrorTextFieldpsd)&&(!ErrorTextFieldcompany)&&(!ErrorTextFieldcompany)){
      var loginResponse;
      try{
        loginResponse = await login(Usr, pwd, companylocal);
      }catch(e){ }

      if(loginResponse != null){
        if(loginResponse.statusCode == 401){
          ErrorTextFieldEmail = true;ErrorTextFieldpsd = true;ErrorTextFieldcompany = true;
          ErrorTextFieldTextemail = ErrorTextFieldTextpwd = ErrorTextFieldTextcompany = 'Datos incorrectos';
          setState(() {
            ErrorTextFieldEmail;ErrorTextFieldpsd;ErrorTextFieldcompany;ErrorTextFieldTextemail;ErrorTextFieldTextpwd;ErrorTextFieldTextcompany;
          });
          Circuleprogress = false; setState(() {
            Circuleprogress;
          });
        }
        if(loginResponse.statusCode == 500){
          ErrorTextFieldEmail = true;ErrorTextFieldpsd = true;ErrorTextFieldcompany = true;
          ErrorTextFieldTextemail = ErrorTextFieldTextpwd = ErrorTextFieldTextcompany ='Error en conexion';
          setState(() {
            ErrorTextFieldEmail;ErrorTextFieldpsd;ErrorTextFieldcompany;ErrorTextFieldTextemail;ErrorTextFieldTextpwd;ErrorTextFieldTextcompany;
          });
          Circuleprogress = false; setState(() {
            Circuleprogress;
          });
        }
        if(loginResponse.statusCode == 200){

          AuthModel auth = AuthModel.fromJson(loginResponse.body);
          if(AgregarUser){
            UserDataBase newuser = UserDataBase(name: Usr,idTable: 1,password: pwd,company: companylocal, token: auth.accessToken);
            int res = await ClientDatabaseProvider.db.saveUser(newuser);
          }else{
            int res = await ClientDatabaseProvider.db.updatetoken(auth.accessToken);
          }

          Navigator.pushReplacementNamed(context, '/vistap');
        }
      }else{
        ErrorTextFieldEmail = true;ErrorTextFieldpsd = true;ErrorTextFieldcompany = true;
        ErrorTextFieldTextemail = ErrorTextFieldTextpwd = ErrorTextFieldTextcompany ='Error en conexion';
        setState(() {
          ErrorTextFieldEmail;ErrorTextFieldpsd;ErrorTextFieldcompany;ErrorTextFieldTextemail;ErrorTextFieldTextpwd;ErrorTextFieldTextcompany;
        });
        Circuleprogress = false; setState(() {
          Circuleprogress;
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

  ValidarUsrPrimeraVez() async {
    UserDataBase UserActiv = await ClientDatabaseProvider.db.getCodeId('1');
    if(UserActiv != null){
      TextViewVisible = false;
      AgregarUser = false;
      companyEstable = UserActiv.company;
      setState(() {
        TextViewVisible;AgregarUser;companyEstable;
      });
    }
  }

  testApi() async{

    try {
      print("---------------- Inicia test. ----------------------------");

      String email = 'eibanez@duperu.com';
      // String email = 'jgarcia@getkem.com';
      String password = '123';
      String customer = 'duperu';

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
      // var getCustomerResponse = await getCustomer('2', customer, authorization);
      // CustomerModel customerObj = CustomerModel.fromJson(getCustomerResponse.body);
      // print(customerObj.name);
      // print(getCustomerResponse.body);

      // Customer Update
      // customerObj.name += ' rr';
      // var updateCustomerResponse = await updateCustomer('2', customerObj, customer, authorization);
      // print(updateCustomerResponse.body);

      // Customer Create
      // customerObj.name = 'TestTest Test';
      // customerObj.code = '987654321';
      // var createCustomerResponse = await createCustomer(customerObj, customer, authorization);
      // print(createCustomerResponse.body);

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

      // Form Get
      // var getFormResponse = await getForm('4', customer, authorization);
      // FormModel form = FormModel.fromJson(getFormResponse.body);
      // getFormResponse.body.split(' ').forEach((word) => print(" " + word));

      // Form All
      // var getAllFormsResponse = await getAllForms(customer, authorization);
      // FormsModel forms = FormsModel.fromJson(getAllFormsResponse.body);
      // print(forms.data[1].name);

      // CheckIn Task
      //lat -12.0949443
      //long -76.8862068
      // var checkInTaskResponse = await checkInTask('2527', customer, authorization, '-12.0949443', '-76.8862068', '', date: '2019-05-09 08:30:00');
      // TaskModel taskCheckIn = TaskModel.fromJson(checkInTaskResponse.body);
      // print(taskCheckIn.status);


      // CheckOut Task
      // var checkOutTaskResponse = await checkOutTask('2527', customer, authorization, '-12.0949443', '-76.8862068', '');
      // TaskModel taskCheckOut = TaskModel.fromJson(checkOutTaskResponse.body);
      // print(taskCheckOut.status);

      print("---------------- Fin test. ----------------------------");
    }catch(error, stackTrace){
      print(error);
      print(stackTrace);
    }

  }
}
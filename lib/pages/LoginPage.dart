import 'package:flutter/material.dart';
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
  final nameController = TextEditingController();
  final passwordController = TextEditingController();
  final companyController = TextEditingController();

  @override
  void initState() {

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
      body: Container(
        child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height/2.5,
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
                  Spacer(),

                  Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          bottom: 32,
                          right: 32
                      ),
                      child: Text('Login',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                            color: Colors.black,
                            fontSize: 18
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Container(
              height: MediaQuery.of(context).size.height/2,
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.only(top: 62),
              child: Column(
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width/1.2,
                    height: 45,
                    padding: EdgeInsets.only(
                        top: 4,left: 16, right: 16, bottom: 4
                    ),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                            Radius.circular(50)
                        ),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black12,
                              blurRadius: 5
                          )
                        ]
                    ),
                    child: TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        icon: Icon(Icons.email,
                          color: Colors.black,
                        ),
                        hintText: 'Usuario',
                      ),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width/1.2,
                    height: 45,
                    margin: EdgeInsets.only(top: 32),
                    padding: EdgeInsets.only(
                        top: 4,left: 16, right: 16, bottom: 4
                    ),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                            Radius.circular(50)
                        ),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black12,
                              blurRadius: 5
                          )
                        ]
                    ),
                    child: TextField(
                      obscureText: true,
                      controller: passwordController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        icon: Icon(Icons.vpn_key,
                          color: Colors.black,
                        ),
                        hintText: 'Password',
                      ),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width/1.2,
                    height: 45,
                    margin: EdgeInsets.only(top: 32),
                    padding: EdgeInsets.only(
                        top: 4,left: 16, right: 16, bottom: 4
                    ),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                            Radius.circular(50)
                        ),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black12,
                              blurRadius: 5
                          )
                        ]
                    ),
                    child: TextField(
                      controller: companyController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        icon: Icon(Icons.business,
                          color: Colors.black,
                        ),
                        hintText: 'Empresa',
                      ),
                    ),
                  ),


                  Spacer(),

                  Container(
                    height: 40,
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
                      textColor: Colors.black,
                      splashColor: Colors.white,


                      onPressed: () async {

                      /*final sentryr.SentryClient sentry = new sentryr.SentryClient(dsn: 'https://3b62a478921e4919a71cdeebe4f8f2fc@sentry.io/1445102');
                       try{
                         /*String empresa = 'getkem';
                         //var v = await login('eibanez@duperu.com','123',empresa);
                         var v = await login('jgarcia@getkem.com','123',empresa);
                         Auth aur = authFromJson(v.body);
                         //var tokken = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwczpcL1wvd2ViYXBwLmdldGtlbS5jb21cL2FwaVwvdjFcL2F1dGhcL2xvZ2luIiwiaWF0IjoxNTU3ODM3NjA0LCJleHAiOjE1NTc5MjQwMDQsIm5iZiI6MTU1NzgzNzYwNCwianRpIjoiQTdSWFZKRjJXdjJYVmZJaiIsInN1YiI6NCwicHJ2IjoiOGIwYjQ2ZmU0M2U1YWNjMmU1NzFkYmRlNWIwODFiYzFiMjA1MGNmMiJ9.gMtVV-lu_bo9RLiVgik4o0AmcDzxS-I_FJEdfaW55pU';
                         var tokken = aur.accessToken;
                         print('-----------elwe--------');
                        //LLAMAR CLIENTE
                         var b =   await  getCustomer('2',empresa,tokken);
                         print(b.body);
                         Customer c = customerFromJson(b.body);
                         //TODOS LOS CLIENTES
                         var muchosresponse = await getAllCustomers(empresa,tokken);
                         Customers muchos = customersFromJson(muchosresponse.body);
                         //ACTUALIZAR CLIENTES
                         c.name += '   rn';
                         var actualizarRespose = await updateCustomer(c.id.toString(), c,empresa, tokken);
                         print(actualizarRespose.statusCode);
                         muchos = customersFromJson(muchosresponse.body);
                         print(muchos.data[1].name);
                         //CREAR NUEVO
                         Customer nuevo = Customer(id: null, name: 'cl',code: '456',contactName: 'kn',createdAt: 'jn',createdById: null,deletedAt: 'p',deletedById: null,details: 'juhoji', email: '@g',phone: '5464', pivot: null, updatedAt: 'npk',updatedById: null);
                         var nuevoResponse = await createCustomer(nuevo,empresa,tokken);
                         print(nuevoResponse.statusCode);*/
                       }catch(error, stackTrace){
                         await sentry.captureException(
                           exception: error,
                           stackTrace: stackTrace,
                         );
                       }*/
                      testApi();
                      //Navigator.pushReplacementNamed(context, '/vistap');
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
            )
          ],
        ),
      ),
      ),
    );


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
      print(auth.tokenType);
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
      // var getFormResponse = await getForm('1', customer, authorization);
      // FormModel form = FormModel.fromJson(getFormResponse.body);
      // print(form.name);

      // Form All
      // var getAllFormsResponse = await getAllForms(customer, authorization);
      // FormsModel forms = FormsModel.fromJson(getAllFormsResponse.body);
      // print(forms.data[1].name);
      






      print("---------------- Fin test. ----------------------------");
    }catch(e, s){
      print("----------------- Error ----------------");
      print(e.toString());
      print(s);
    }

  }
}
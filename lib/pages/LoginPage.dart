import 'package:flutter/material.dart';
import 'package:joincompany/main.dart';
import 'package:joincompany/models/AuthModel.dart';
import 'package:joincompany/models/CustomerModel.dart';
import 'package:joincompany/models/CustomersModel.dart';
import 'package:joincompany/models/TaskModel.dart';
import 'package:joincompany/models/TasksModel.dart';
import 'package:joincompany/models/UserDataBase.dart';
import 'package:joincompany/pages/home/taskHome.dart';
import 'package:joincompany/Sqlite/database_helper.dart';
import 'package:joincompany/services/AuthService.dart';
import 'package:joincompany/services/CustomerService.dart';
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


                      testApi();
                      //Navigator.pushReplacementNamed(context, '/vistap');
                     Navigator.pushReplacementNamed(context, '/vistap');
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
      String password = '123';
      String customer = 'duperu';

      // login
      var loginResponse = await login(email, password, customer);
      Auth auth = Auth.fromJson(loginResponse.body);
      String authorization = auth.accessToken;
      print(auth.tokenType);

      // Customer Get
      // var getCustomerResponse = await getCustomer('2', customer, authorization);
      // Customer customerObj = Customer.fromJson(getCustomerResponse.body);
      // print(customerObj.name);

      // Customer Update
      // customerObj.name += ' rr';
      // var updateCustomerResponse = await updateCustomer('2', customerObj, customer, authorization);
      // print(updateCustomerResponse.body);

      // Customer Create
      // customerObj.name = 'Test';
      // customerObj.code = '123456789';
      // var createCustomerResponse = await createCustomer(customerObj, customer, authorization);
      // print(createCustomerResponse.body);

      // Customer All
      // var getAllCustomersResponse = await getAllCustomers(customer, authorization);
      // Customers customers = Customers.fromJson(getAllCustomersResponse.body);
      // print(customers.data[1].name);

      // Task Get
      // var getTaskResponse = await getTask('2427', customer, authorization);
      // Task task = Task.fromJson(getTaskResponse.body);
      // print(task.name);
      // print(task.responsibleId);
      // print(task.checkinLatitude);

      // Task All
      // var getAllTasksResponse = await getAllTasks(customer, authorization);
      // Tasks tasks = Tasks.fromJson(getAllTasksResponse.body);
      // print(tasks.data[0].name);
      // print(tasks.data[0].responsibleId);






      print("---------------- Fin test. ----------------------------");
    }catch(e, s){
      print("----------------- Error ----------------");
      print(e.toString());
      print(s);
    }

  }
}
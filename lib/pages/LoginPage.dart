import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:joincompany/blocs/BlocValidators.dart';
import 'package:joincompany/main.dart';
import 'package:joincompany/models/AuthModel.dart';
import 'package:joincompany/models/CustomerModel.dart';
import 'package:joincompany/models/CustomersModel.dart';
import 'package:joincompany/models/UserDataBase.dart';
import 'package:joincompany/pages/home/taskHome.dart';
import 'package:joincompany/Sqlite/database_helper.dart';
import 'package:joincompany/services/AuthService.dart';
import 'package:joincompany/services/CustomerService.dart';
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
  bool TextViewVisible = true;
  bool AgregarUser = true;
  String companyEstable = '';
  bool ErrorTextFieldEmail = false;
  bool ErrorTextFieldpsd = false;
  bool ErrorTextFieldcompany = false;
  String ErrorTextFieldTextemail = '';
  String ErrorTextFieldTextpwd = '';
  String ErrorTextFieldTextcompany = '';

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
//
//                  Align(
//                    alignment: Alignment.bottomRight,
//                    child: Padding(
//                      padding: const EdgeInsets.only(
//                          bottom: 32,
//                          right: 32
//                      ),
//                      child: Text('Login',
//                        style: TextStyle(
//                          fontStyle: FontStyle.italic,
//                            color: Colors.black,
//                            fontSize: 18
//                        ),
//                      ),
//                    ),
//                  ),
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
                    height: 45,
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
                    height: 45,
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
            )
          ],
        ),
      ),
      ),
    );


  }

  ValidarDatos(String Usr, String pwd, String compy) async {

    String companylocal = companyEstable;

    if(AgregarUser){
      UserDataBase newuser = UserDataBase(name: Usr,idTable: 1,password: pwd,company: compy);
      int res = await ClientDatabaseProvider.db.saveUser(newuser);
      companylocal = compy;
    }

    if(Usr == ''){ErrorTextFieldEmail = true; ErrorTextFieldTextemail = 'Es necesario insertar datos';
    setState(() {ErrorTextFieldEmail;ErrorTextFieldTextemail;
    });
    }else{ErrorTextFieldEmail = false;}
    if(pwd == ''){ErrorTextFieldpsd = true; ErrorTextFieldTextpwd = 'Es necesario insertar datos';
    setState(() {ErrorTextFieldpsd;ErrorTextFieldTextpwd;
    });
    }else{ErrorTextFieldpsd = false;}
    if(companylocal == ''){ErrorTextFieldcompany = true; ErrorTextFieldTextcompany = 'Es necesario insertar datos';
    setState(() {ErrorTextFieldcompany;ErrorTextFieldTextcompany;
    });
    }else{ErrorTextFieldcompany = false;}

    if((!ErrorTextFieldpsd)&&(!ErrorTextFieldcompany)&&(!ErrorTextFieldcompany)){
      var loginResponse;
      try{
        loginResponse = await login(Usr, pwd, companylocal);
      }catch(e){
        print('*************');
        print(e.toString());
      }

      if(loginResponse != null){
        if(loginResponse.statusCode == 401){
          ErrorTextFieldEmail = true;ErrorTextFieldpsd = true;ErrorTextFieldcompany = true;
          ErrorTextFieldTextemail = ErrorTextFieldTextpwd = ErrorTextFieldTextcompany = 'Datos incorrectos';
          setState(() {
            ErrorTextFieldEmail;ErrorTextFieldpsd;ErrorTextFieldcompany;ErrorTextFieldTextemail;ErrorTextFieldTextpwd;ErrorTextFieldTextcompany;
          });
        }
        if(loginResponse.statusCode == 500){
          ErrorTextFieldEmail = true;ErrorTextFieldpsd = true;ErrorTextFieldcompany = true;
          ErrorTextFieldTextemail = ErrorTextFieldTextpwd = ErrorTextFieldTextcompany ='Error en conexion';
          setState(() {
            ErrorTextFieldEmail;ErrorTextFieldpsd;ErrorTextFieldcompany;ErrorTextFieldTextemail;ErrorTextFieldTextpwd;ErrorTextFieldTextcompany;
          });
        }
        if(loginResponse.statusCode == 200){
          Navigator.pushReplacementNamed(context, '/vistap');
        }
      }else{
        ErrorTextFieldEmail = true;ErrorTextFieldpsd = true;ErrorTextFieldcompany = true;
        ErrorTextFieldTextemail = ErrorTextFieldTextpwd = ErrorTextFieldTextcompany ='Error en conexion';
        setState(() {
          ErrorTextFieldEmail;ErrorTextFieldpsd;ErrorTextFieldcompany;ErrorTextFieldTextemail;ErrorTextFieldTextpwd;ErrorTextFieldTextcompany;
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

    try{
      print("---------------- Inicia test. ----------------------------");

      String email = 'eibanez@duperu.com';
      String password = '123';
      String customer = 'duperu';

      // login
      var loginResponse = await login(email, password, customer);
      Auth auth = Auth.fromJson(loginResponse.body);
      String authorization = auth.accessToken;
//      print(auth.accessToken);

      // Customer Get
      var getCustomerResponse = await getCustomer('2', customer, authorization);
      Customer customerObj = Customer.fromJson(getCustomerResponse.body);
//      print(customerObj.name);

      // Customer Update
//      customerObj.name += ' rr';
//      var updateCustomerResponse = await updateCustomer('2', customerObj, customer, authorization);
//      print(updateCustomerResponse.body);

      // Customer Create
//      customerObj.name = 'Test';
//      customerObj.code = '123456789';
//      var createCustomerResponse = await createCustomer(customerObj, customer, authorization);
//      print(createCustomerResponse.body);

      // Customer All
      var getAllCustomerResponse = await getAllCustomers(customer, authorization);
      Customers customers = Customers.fromJson(getAllCustomerResponse.body);
//      print(customers.data[1].name);






      print("---------------- Fin test. ----------------------------");
    }catch(e, s){
      print("----------------- Error ----------------");
      print(e.toString());
      print(s);
    }

  }
}
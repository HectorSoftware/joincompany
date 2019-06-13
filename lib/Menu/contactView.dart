import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:joincompany/Menu/addContact.dart';
import 'package:joincompany/Sqlite/database_helper.dart';
import 'package:joincompany/main.dart';
import 'package:joincompany/models/CustomersModel.dart';
import 'package:joincompany/models/UserDataBase.dart';
import 'package:joincompany/models/UserModel.dart';
import 'package:joincompany/services/UserService.dart';

// ignore: must_be_immutable
class ContactView extends StatefulWidget {
  bool vista;

  ContactView(vista){
    this.vista = vista;
  }

  @override
  _ContactViewState createState() => _ContactViewState();
}

class _ContactViewState extends State<ContactView> {

  String nameUser = '';
  String emailUser = '';

  @override
  void initState() {
    extraerUser();
    super.initState();
  }

  @override
  void dispose(){
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: widget.vista ? null : buildDrawer(),
      appBar: AppBar(
        title: Text("Contactos"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            contactCard("Contacto 1"),
            contactCard("Contacto 2"),
            contactCard("Contacto 3"),
            contactCard("Contacto 4"),
            contactCard("Contacto 5"),
            contactCard("Contacto 6"),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).pop();
          Navigator.push(
              context,
              new MaterialPageRoute(
                  builder: (BuildContext context) => new AddContact()));
        },
      ),
    );
  }

  Future<List<CustomersModel>> data() {
    //TODO
    //CustomerService.getAllCustomers();
    return null;
  }

  Widget contactCard(String dataContacts) {
    //TODO: change String for Contacts
    return Card(
      child: ListTile(
        title: Text(dataContacts),
        subtitle: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Align(alignment: Alignment.centerLeft, child: Text("empresa"),),
            Align(alignment: Alignment.centerLeft,
              child: Row(
                children: <Widget>[
                  IconButton(
                    icon: Icon(
                      Icons.mail,
                      size: 20,
                    ),
                    onPressed: () {},
                  ),

                  IconButton(
                    icon: Icon(
                      Icons.call,
                      size: 20,
                    ),
                    onPressed: () {},
                  )
                ],
              ),
            ),
          ],
        ),
        onTap: widget.vista ? () {
          Navigator.of(context).pop(dataContacts);
        } : null,
      ),
    );
  }

  //drawer
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
            color: drawerCustomer ? Colors.grey[200] : null,
            child: new ListTile(
              title: new Text("Contactos"),
              trailing: new Icon(Icons.contacts),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ),
          Container(
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
            child: new ListTile(
              title: new Text("Configuración"),
              trailing: new Icon(Icons.filter_vintage),
              onTap: () {
                // Navigator.pushReplacementNamed(context, "/intro");
                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.pushNamed(context, '/configuracion');
              },
            ),
          ),
          Container(
            child: new ListTile(
              title: new Text("Salir"),
              trailing: new Icon(Icons.directions_run),
              onTap: () {
                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context,'/App');
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<UserDataBase> deletetUser() async {
    UserDataBase userActiv = await ClientDatabaseProvider.db.getCodeId('1');
    return userActiv;
  }

  extraerUser() async {
    UserDataBase userAct = await ClientDatabaseProvider.db.getCodeId('1');
    var getUserResponse = await getUser(userAct.company, userAct.token);
    UserModel user = UserModel.fromJson(getUserResponse.body);

    setState(() {
      nameUser = user.name;
      emailUser = user.email;
    });
  }

}

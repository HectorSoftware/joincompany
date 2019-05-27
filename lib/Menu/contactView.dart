import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:joincompany/Menu/addContact.dart';
import 'package:joincompany/Sqlite/database_helper.dart';
import 'package:joincompany/models/CustomersModel.dart';
import 'package:joincompany/models/UserDataBase.dart';
import 'package:joincompany/models/UserModel.dart';
import 'package:joincompany/services/UserService.dart';

import '../main.dart';
import 'configCli.dart';
class ContactView extends StatefulWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: buildDrawer(),
      appBar: AppBar(
        title: Text(""),
      ),
//      body: FutureBuilder<List<String>>(//TODO: change String for Contacts
//        future: null, //TODO: getAllContacts()
//        builder: (BuildContext contex, AsyncSnapshot<List<String>> snapshot){//TODO: change String for Contacts
//          if (snapshot.hasData) {
//            return ListView.builder(
//                itemCount: snapshot.data.length,
//                itemBuilder: (BuildContext contex, int index){
//                  String item = snapshot.data[index]; //TODO: change String for Contacts
//                  return contactCard(item);
//                }
//            );
//          }else{
//            return Center(child: CircularProgressIndicator());
//          }
//        },
//      ),
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
        onPressed:(){
          Navigator.of(context).pop();
          Navigator.push(
              context,
              new MaterialPageRoute(
                  builder: (BuildContext context) => new  AddContact()));
        },
      ),
    );
  }


  Future<List<CustomersModel>> data(){ //TODO
    //CustomerService.getAllCustomers();
    return null;
  }

  Widget contactCard(String dataContacts) {//TODO: change String for Contacts
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,

        children: <Widget>[
          Container(
            margin: EdgeInsets.all(12.0),
            child: Align(alignment: Alignment.centerLeft,child: Text(dataContacts, style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold
            ),),),
          ),
          Container(
            margin: EdgeInsets.all(12.0),
            child: Align(alignment: Alignment.centerLeft,child: Text("empresa"),),
          ),
          Row(
            children: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.mail
                ),
                onPressed: (){},
              ),

              IconButton(
                icon: Icon(
                    Icons.call
                ),
                onPressed: (){},
              )
            ],
          ),
        ],
      ),
    );
  }


  bool drawerCustomer = true;
  Drawer buildDrawer() {
    return Drawer(
      elevation: 12,
      child: new ListView(
        children: <Widget>[
          new UserAccountsDrawerHeader(
            decoration: new BoxDecoration(color: SecondaryColor,
            ),
            accountName: new Text(nameUser,
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
            accountEmail : Text(emailUser,
              style: TextStyle(
                color: Colors.black,
                fontSize: 15,
              ),
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
            color: drawerCustomer ? Colors.grey[200] :  null,
            child: new ListTile(
              title: new Text("Contactos"),
              trailing: new Icon(Icons.contacts),
              onTap: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          /*new ListTile(
            title: new Text("Negocios"),
            trailing: new Icon(Icons.poll),
            onTap: () {
              Navigator.of(context).pop();
            },
          ),*/
          Divider(
            height: 30.0,
          ),
          Container(
            child: new ListTile(
              title: new Text("Configuración"),
              trailing: new Icon(Icons.filter_vintage),
              onTap: () {
                // Navigator.pushReplacementNamed(context, "/intro");
                Navigator.of(context).pop();
                Navigator.pop(context);
                Navigator.push(
                    context,
                    new MaterialPageRoute(
                        builder: (BuildContext context) => new  ConfigCli()));
              },
            ),
          ),
        ],
      ),
    );
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

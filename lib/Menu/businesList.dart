import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:joincompany/Sqlite/database_helper.dart';
import 'package:joincompany/main.dart';
import 'package:joincompany/models/BusinessModel.dart';
import 'package:joincompany/models/BusinessesModel.dart';
import 'package:joincompany/models/ContactModel.dart';
import 'package:joincompany/models/CustomerModel.dart';
import 'package:joincompany/models/UserDataBase.dart';
import 'package:joincompany/models/UserModel.dart';
import 'package:joincompany/models/WidgetsList.dart';
import 'package:joincompany/services/BusinessService.dart';
import 'package:joincompany/services/UserService.dart';
import 'formBusiness.dart';


// ignore: must_be_immutable
class BusinessList extends StatefulWidget {
  bool vista;
  BusinessList(bool vista){
    this.vista = vista;
  }
  @override
  _BusinessListState createState() => _BusinessListState();
}

class _BusinessListState extends State<BusinessList> {
  ListWidgets ls = ListWidgets();

  String nameUser = '';
  String emailUser = '';
  BusinessesModel businessGlobal = BusinessesModel();
  List<BusinessModel> listBusiness = List<BusinessModel>();

  bool getData = false;
  @override
  void initState() {
    getAll();

    extraerUser();
    super.initState();
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
//                Navigator.pushNamed(context, '/cliente');
//              Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context) => new  Cliente()));
              },
            ),
          ),
          Container(
            child: new ListTile(
              title: new Text("Contactos"),
              trailing: new Icon(Icons.contacts),
              onTap: () {
                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.pushNamed(context, '/contactos');
              },
            ),
          ),
          Container(
            color: drawerCustomer ? Colors.grey[200] :  null,
            child: new ListTile(
              title: new Text("Negocios"),
              trailing: new Icon(Icons.account_balance),
              onTap: () {
                Navigator.pop(context);
                //Navigator.pop(context);
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
                Navigator.of(context).pop();
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

  @override
  void dispose(){
    super.dispose();
  }



  getAll()async{
    UserDataBase user = await ClientDatabaseProvider.db.getCodeId('1');
    var getAllBusinessesResponse = await getAllBusinesses(user.company,user.token);
       BusinessesModel busisness = BusinessesModel.fromJson(getAllBusinessesResponse.body);
       listBusiness = busisness.data;
       getData = true;
  }
  //search
  Icon _searchIcon = new Icon(Icons.search);
  Widget _appBarTitle = new Text('Negocios');
  String textFilter='';
  final TextEditingController _filter = new TextEditingController();

  void _searchPressed() {
    setState(() {
      if (this._searchIcon.icon == Icons.search) {
        this._searchIcon = new Icon(Icons.close);
        this._appBarTitle = new TextField(
          controller: _filter,
          decoration: new InputDecoration(
              prefixIcon: new Icon(Icons.search),
              hintText: 'Buscar'
          ),
          onChanged: (value){
            setState(() {
              textFilter = value.toString();
            });
          },
        );
      } else {
        this._searchIcon = new Icon(Icons.search);
        this._appBarTitle = new Text('Negocios');
        setState(() {
          textFilter='';
        });
        _filter.clear();
      }
    });
  }

//  Widget cardBusiness(){
//    var padding = 16.0;
//    double por = 0.1;
//    if (MediaQuery.of(context).orientation == Orientation.portrait) {
//      por = 0.07;
//    }
//
//    return Card(
//      child: Column(
//        children: <Widget>[
//          Container(
//            padding: EdgeInsets.only(left: padding,right: 0,top: padding, bottom: 0),
//            width: MediaQuery.of(context).size.width,
//            height: MediaQuery.of(context).size.height * por,
//            color: PrimaryColor,
//            child: Text("Primer contacto", style: TextStyle(
//                fontSize: 16, color: Colors.white)),
//          ),
//          Card(
//            child: ListTile(
//              title: Text("Posicionamiento - Cliente B"),
//              subtitle: Text("Primer Contacto"),
//              trailing: Text("29-02-2019"),
//              onTap: (){
//                return showDialog(
//                  context: context,
//                  barrierDismissible: false, // user must tap button for close dialog!
//                  builder: (BuildContext context) {
//                    return FormBusiness();
//                  },
//                );
//              },
//            ),
//          ),
//          Card(
//            child:  ListTile(
//              title: Text("Cliente A"),
//              subtitle: Text("Primer Contacto"),
//              trailing: Text("29-02-2019"),
//            ),
//          ),
//          Container(
//            padding: EdgeInsets.only(left: padding,right: 0,top: padding, bottom: 0),
//            width: MediaQuery.of(context).size.width,
//            height: MediaQuery.of(context).size.height * por,
//            color: PrimaryColor,
//            child: Text("Presentacion", style: TextStyle(
//                fontSize: 16, color: Colors.white)),
//          ),
//          Card(
//            child: ListTile(
//              title:  Text("Cliente A"),
//              subtitle: Text("Presentacion"),
//              trailing: Text("29-02-2019"),
//            ),
//          ),
//        ],
//      ),
//    );
//  }

  @override
  Widget build(BuildContext context) {
    var padding = 16.0;
    double por = 0.1;
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      por = 0.07;
    }
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.arrow_back),  onPressed:(){  Navigator.pushReplacementNamed(context, '/vistap');}),
        title: _appBarTitle,
        actions: <Widget>[
          ls.createState().searchButtonAppbar(_searchIcon, _searchPressed, 'Eliminar Tarea', 30),
        ],
      ),
      body: getData == true ? ListView.builder(
          itemCount:listBusiness.length,
          itemBuilder: (BuildContext context, index){
            return Card(
              child: Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(left: padding,right: 0,top: padding, bottom: 0),
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * por,
                    color: PrimaryColor,
                    child: Text("Primer contacto", style: TextStyle(
                        fontSize: 16, color: Colors.white)),
                  ),
                  Card(
                    child: ListTile(
                      title: Text("Negocio - ${listBusiness[index].customer}"),
                      subtitle: Text(listBusiness[index].name),
                      trailing:listBusiness[index].date != null ?Text(listBusiness[index].date.toString().substring(0,10)): Text('Sin Fecha asignada'),
                      onTap: (){
                        return showDialog(
                          context: context,
                          barrierDismissible: false, // user must tap button for close dialog!
                          builder: (BuildContext context) {
                            return FormBusiness(dataBusiness: listBusiness[index]);
                          },
                        );
                      },
                    ),
                  ),
                  Card(
                    child:  ListTile(
                      title: Text(listBusiness[index].customer),
                      subtitle: Text("Primer Contacto"),
                      trailing: Text("29-02-2019"),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: padding,right: 0,top: padding, bottom: 0),
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * por,
                    color: PrimaryColor,
                    child: Text("Presentacion", style: TextStyle(
                        fontSize: 16, color: Colors.white)),
                  ),
                  Card(
                    child: ListTile(
                      title:  Text("Cliente A"),
                      subtitle: Text("Presentacion"),
                      trailing: Text("29-02-2019"),
                    ),
                  ),
                ],
              ),
            );
          }


      ):Center(
        child: CircularProgressIndicator(

        ),
      ),

      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed:() {
          Navigator.pushReplacementNamed(context, '/FormBusiness');
        }
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

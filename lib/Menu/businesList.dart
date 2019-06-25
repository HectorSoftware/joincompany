import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:joincompany/Sqlite/database_helper.dart';
import 'package:joincompany/async_database/Database.dart';
import 'package:joincompany/async_operations/BusinessChannel.dart';
import 'package:joincompany/blocs/blocCheckConnectivity.dart';
import 'package:joincompany/main.dart';
import 'package:joincompany/models/BusinessModel.dart';
import 'package:joincompany/models/BusinessesModel.dart';
import 'package:joincompany/models/UserModel.dart';
import 'package:joincompany/models/WidgetsList.dart';
import 'package:joincompany/services/BusinessService.dart';
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

  BusinessesModel businessGlobal = BusinessesModel();
  List<BusinessModel> listBusiness = List<BusinessModel>();

  StreamSubscription _connectionChangeStream;
  bool isOnline = true;

  bool getData = false;
  @override

  void initState() {
    getAll();
    ConnectionStatusSingleton connectionStatus = ConnectionStatusSingleton.getInstance();
    _connectionChangeStream = connectionStatus.connectionChange.listen(connectionChanged);
    checkConnection(connectionStatus);
    super.initState();
  }

  void checkConnection(ConnectionStatusSingleton connectionStatus) async {
    isOnline = await connectionStatus.checkConnection();
    setState(() {});
  }

  void connectionChanged(dynamic hasConnection) {
    if (!isOnline && hasConnection){
      sync();
      syncDialog();
    }

    setState(() {
      isOnline = hasConnection;
    });
  }

  void sync() async{
    await BusinessChannel.syncEverything();
    Navigator.pop(context);
  }

  Future<void> syncDialog(){
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return AlertDialog(
            title: Text("Sincronizando ... "),
            content:SizedBox(
              height: 100.0,
              width: 100.0,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
        );
      },
    );
  }

  @override
  void dispose(){
    super.dispose();
  }

  getAll()async{
    UserModel user = await DatabaseProvider.db.RetrieveLastLoggedUser();
    var getAllBusinessesResponse = await getAllBusinesses(user.company,user.rememberToken);

    BusinessesModel busisness = getAllBusinessesResponse.body;

   setState(() {
     listBusiness = busisness.data == null ? List<BusinessModel>() : busisness.data;
     getData = true;
   });
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

  @override
  Widget build(BuildContext context) {
    var padding = 16.0;
    double por = 0.1;
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      por = 0.07;
    }
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed:(){
              if(!widget.vista){
                Navigator.pushReplacementNamed(context, '/vistap');
              }else{
                Navigator.of(context).pop();
              }
            }
            ),
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
                    child:listBusiness[index].stage != null? Text(listBusiness[index].stage.toString(), style: TextStyle(
                        fontSize: 16, color: Colors.white)): Text('Sin presentación', style: TextStyle(
                    fontSize: 16, color: Colors.white)),
                  ),
                  Card(
                    child: ListTile(
                      title: Text(listBusiness[index].name.toString()),
                      subtitle: listBusiness[index].stage != null? Text(listBusiness[index].stage.toString(), style: TextStyle(
                          color: Colors.black)): Text('Sin presentación', style: TextStyle(
                          color: Colors.black)),
                      trailing:listBusiness[index].date != null ?Text(listBusiness[index].date.toString().substring(0,10)): Text('Sin Fecha asignada'),
                      onTap: (){
                        if(!widget.vista){
                          return showDialog(
                            context: context,
                            barrierDismissible: false, // user must tap button for close dialog!
                            builder: (BuildContext context) {
                              return FormBusiness(dataBusiness: listBusiness[index]);
                            },
                          );
                        }else{
                          Navigator.of(context).pop(listBusiness[index]);
                        }
                      },
                    ),
                  ),
                  Card(
                    child:  ListTile(
                      title: Text(listBusiness[index].customer!= null ? listBusiness[index].customer: ""),
                      subtitle:listBusiness[index].stage != null? Text(listBusiness[index].stage.toString(), style: TextStyle(
                           color: Colors.black)): Text('Sin presentación', style: TextStyle(
                           color: Colors.black)),
                      trailing: listBusiness[index].date != null ?Text(listBusiness[index].updatedAt.toString().substring(0,10)): Text('Sin Fecha asignada'),
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
                      title:  Text(listBusiness[index].customer != null ? listBusiness[index].customer: ""),
                      subtitle: Text("Presentacion"),
                      trailing:listBusiness[index].date != null ?Text(listBusiness[index].date.toString().substring(0,10)): Text('Sin Fecha asignada'),
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

}

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:joincompany/async_database/Database.dart';
import 'package:joincompany/async_operations/AddressChannel.dart';
import 'package:joincompany/async_operations/BusinessChannel.dart';
import 'package:joincompany/async_operations/CustomerAddressesChannel.dart';
import 'package:joincompany/async_operations/CustomerChannel.dart';
import 'package:joincompany/blocs/blocCheckConnectivity.dart';
import 'package:joincompany/blocs/blocBusiness.dart';
import 'package:joincompany/main.dart';
import 'package:joincompany/models/BusinessModel.dart';
import 'package:joincompany/models/BusinessesModel.dart';
import 'package:joincompany/models/UserModel.dart';
import 'package:joincompany/models/WidgetsList.dart';
import 'package:joincompany/pages/LoginPage.dart';
import 'package:joincompany/services/BusinessService.dart';
import 'contactView.dart';
import 'formBusiness.dart';
import 'package:flutter/services.dart';

// ignore: must_be_immutable
class BusinessList extends StatefulWidget {
  STATUS_PAGE st;
  BusinessList(STATUS_PAGE st){
    this.st = st;
  }
  @override
  _BusinessListState createState() => _BusinessListState();
}

class _BusinessListState extends State<BusinessList> {

  //widgets
  ListWidgets ls = ListWidgets();

  //barra busqueda
  final TextEditingController _filter = new TextEditingController();
  Icon _searchIcon = new Icon(Icons.search);
  Widget _appBarTitle = new Text('Negocios');
  String textFilter='';
  BusinessesModel businessGlobal = BusinessesModel();

  List<BusinessModel> listBusiness = List<BusinessModel>();
  String stage="";
  StreamSubscription _connectionChangeStream;
  bool isOnline = true;
  bool syncStatus = false;
  bool getData = false;
  bool visible = true;
  @override

  void initState() {
    getAll();
    visible = true;
    ConnectionStatusSingleton connectionStatus = ConnectionStatusSingleton.getInstance();
    _connectionChangeStream = connectionStatus.connectionChange.listen(connectionChanged);
    checkConnection(connectionStatus);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.initState();
  }

  void checkConnection(ConnectionStatusSingleton connectionStatus) async {
    isOnline = await connectionStatus.checkConnection();
    setState(() {});
  }

  void connectionChanged(dynamic hasConnection) {
    if (!isOnline && hasConnection && !syncStatus && visible){
      wrapperSync();
    }

    setState(() {
      isOnline = hasConnection;
    });
  }

  void syncBusines() async{
    setState(() {syncStatus = true;});
    await AddressChannel.syncEverything();
    await CustomerChannel.syncEverything();
    await CustomerAddressesChannel.syncEverything();
    await BusinessChannel.syncEverything();
    setState(() {syncStatus = false;});
    Navigator.pop(context);
  }

  Future<void> syncDialog(){
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return AlertDialog(
            title: Text("Sincronizando Negocios..."),
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

  Future<void> errorDialog(){
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Error de Conexion"),
        );
      },
    );
  }

  void wrapperSync()async{
    setState(() {syncStatus = true;});
    await syncDialogAll();
    setState(() {syncStatus = false;});
  }

  Future syncDialogAll(){
    return showDialog(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return SyncApp();
      },
    );
  }


  @override
  void dispose(){
    visible = false;
    _connectionChangeStream.cancel();
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
              if(widget.st == STATUS_PAGE.full) {
                Navigator.pushReplacementNamed(context, '/vistap');
              }else if (widget.st == STATUS_PAGE.view || widget.st == STATUS_PAGE.select) {
                Navigator.of(context).pop();
              }
            }
        ),
        title: _appBarTitle,
        actions: <Widget>[
          ls.createState().searchButtonAppbar(_searchIcon, _searchPressed, 'Eliminar Tarea', 30),
          IconButton(
            onPressed: () {
              if(isOnline && !syncStatus){
                syncBusines();
                syncDialog();
              }else{
                errorDialog();
              }
            },
            icon: Icon(Icons.update),
          )
        ],
      ),
      body: Stack(
        children: <Widget>[
          Container(
            child:listViewCustomers(por,padding),

          ),
        ],
      ),
      floatingActionButton: widget.st == STATUS_PAGE.full ?
       FloatingActionButton(
        child: Icon(Icons.add),
        onPressed:() {
          Navigator.push(
              context,
              new MaterialPageRoute(
                  builder: (BuildContext context) => new FormBusiness()));
//          Navigator.pushReplacementNamed(context, '/FormBusiness');
        }
      ) : null,
    );
  }

  Widget listViewCustomers(double por, padding) {
    stage = '';
    BusinessBloc _bloc = new BusinessBloc();
    return StreamBuilder<List<BusinessModel>>(
        stream: _bloc.outBusiness,
        initialData: <BusinessModel>[],
        builder: (context, snapshot) {
          if(snapshot != null){
            if (snapshot.data.isNotEmpty) {
              return ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    var custommer = snapshot.data[index].customer != null ? snapshot.data[index].customer : "";
                    var name = snapshot.data[index].name != null ? snapshot.data[index].name:"";
                      if(snapshot.data.length == 0){
                        return Center(
                          child: Text('No hay Negocios Registrados'),
                        );
                      }
                      if(textFilter == ''){
                        if(snapshot.data[index].stage != stage){
                          stage = snapshot.data[index].stage;
                          return Card(
                            child: Column(
                              children: <Widget>[
                                Container(
                                  padding: EdgeInsets.only(left: padding,right: 0,top: padding, bottom: 0),
                                  width: MediaQuery.of(context).size.width,
                                  height: MediaQuery.of(context).size.height * por,
                                  color: PrimaryColor,
                                  child:snapshot.data[index].stage != null? Text(snapshot.data[index].stage.toString(), style: TextStyle(
                                      fontSize: 16, color: Colors.white)): Text('Sin presentación', style: TextStyle(
                                      fontSize: 16, color: Colors.white)),
                                ),
                                Card(
                                  child: ListTile(
                                    title: Text(snapshot.data[index].name.toString() + '  -  ' + snapshot.data[index].customer),
                                    subtitle: snapshot.data[index].stage != null? Text(snapshot.data[index].stage.toString(), style: TextStyle(
                                        color: Colors.black)): Text('', style: TextStyle(
                                        color: Colors.black)),
                                    trailing:snapshot.data[index].date != null ?Text(snapshot.data[index].date.toString().substring(0,10)): Text('Sin Fecha asignada'),
                                    onTap: (){
                                      if(widget.st == STATUS_PAGE.full){
                                        Navigator.push(context,new MaterialPageRoute(builder: (BuildContext context) =>FormBusiness(dataBusiness: snapshot.data[index],edit: true,)));
                                      }else if (widget.st == STATUS_PAGE.select){
                                        Navigator.of(context).pop(snapshot.data[index]);
                                      }
                                    },
                                  ),
                                ),

                              ],
                            ),
                          );
                        }else {
                          return Card(
                            child: Column(
                              children: <Widget>[
                                Card(
                                  child: ListTile(
                                    title: Text(snapshot.data[index].name.toString() + '  -  ' + snapshot.data[index].customer),
                                    subtitle: snapshot.data[index].stage != null? Text(snapshot.data[index].stage.toString(), style: TextStyle(
                                        color: Colors.black)): Text('', style: TextStyle(
                                        color: Colors.black)),
                                    trailing:snapshot.data[index].date != null ?Text(snapshot.data[index].date.toString().substring(0,10)): Text('Sin Fecha asignada'),
                                    onTap: (){
                                      if(widget.st == STATUS_PAGE.full){
                                        Navigator.push(context,new MaterialPageRoute(builder: (BuildContext context) =>FormBusiness(dataBusiness: snapshot.data[index],edit: true,)));
                                      }else if (widget.st == STATUS_PAGE.select){
                                        Navigator.of(context).pop(snapshot.data[index]);
                                      }
                                    },
                                  ),
                                ),

                              ],
                            ),
                          );
                        }
                      }else if(ls.createState().checkSearchInText(name, textFilter)||ls.createState().checkSearchInText(custommer, textFilter)) {
                        if(snapshot.data[index].stage != stage){
                          stage = snapshot.data[index].stage;
                          return Card(
                            child: Column(
                              children: <Widget>[
                                Container(
                                  padding: EdgeInsets.only(left: padding,right: 0,top: padding, bottom: 0),
                                  width: MediaQuery.of(context).size.width,
                                  height: MediaQuery.of(context).size.height * por,
                                  color: PrimaryColor,
                                  child:snapshot.data[index].stage != null? Text(snapshot.data[index].stage.toString(), style: TextStyle(
                                      fontSize: 16, color: Colors.white)): Text('Sin presentación', style: TextStyle(
                                      fontSize: 16, color: Colors.white)),
                                ),
                                Card(
                                  child: ListTile(
                                    title: Text(snapshot.data[index].name.toString() + '  -  ' + snapshot.data[index].customer),
                                    subtitle: snapshot.data[index].stage != null? Text(snapshot.data[index].stage.toString(), style: TextStyle(
                                        color: Colors.black)): Text('', style: TextStyle(
                                        color: Colors.black)),
                                    trailing:snapshot.data[index].date != null ?Text(snapshot.data[index].date.toString().substring(0,10)): Text('Sin Fecha asignada'),
                                    onTap: (){
                                      if(widget.st == STATUS_PAGE.full){
                                        Navigator.push(context,new MaterialPageRoute(builder: (BuildContext context) =>FormBusiness(dataBusiness: snapshot.data[index],edit: true,)));
                                      }else if(widget.st == STATUS_PAGE.select){
                                        Navigator.of(context).pop(snapshot.data[index]);
                                      }
                                    },
                                  ),
                                ),

                              ],
                            ),
                          );
                        }else{
                          return Card(
                            child: Column(
                              children: <Widget>[
                                Card(
                                  child: ListTile(
                                    title: Text(snapshot.data[index].name.toString() + '  -  ' + snapshot.data[index].customer),
                                    subtitle: snapshot.data[index].stage != null? Text(snapshot.data[index].stage.toString(), style: TextStyle(
                                        color: Colors.black)): Text('', style: TextStyle(
                                        color: Colors.black)),
                                    trailing:snapshot.data[index].date != null ?Text(snapshot.data[index].date.toString().substring(0,10)): Text('Sin Fecha asignada'),
                                    onTap: (){
                                      if(widget.st == STATUS_PAGE.full){
                                        Navigator.push(context,new MaterialPageRoute(builder: (BuildContext context) =>FormBusiness(dataBusiness: snapshot.data[index],edit: true,)));
                                      }else if(widget.st == STATUS_PAGE.select){
                                        Navigator.of(context).pop(snapshot.data[index]);
                                      }
                                    },
                                  ),
                                ),

                              ],
                            ),
                          );
                        }
                    }else{
                        return Container();
                      }
                  }
              );
            }else{
              if(snapshot.connectionState == ConnectionState.waiting){
                return new Center(
                  child: CircularProgressIndicator(),
                );
              }else{
                return new Container(
                  child: Center(
                    child: Text("No hay Negocios Registrados"),
                  ),
                );
              }
            }
          }else{
            return new Container(
              child: Center(
                child: Text("ha ocurrido un error"),
              ),
            );
          }

        }

    );
  }
}

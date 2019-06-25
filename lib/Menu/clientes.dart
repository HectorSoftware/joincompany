import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:joincompany/async_database/Database.dart';
import 'package:joincompany/async_operations/AddressChannel.dart';
import 'package:joincompany/async_operations/CustomerAddressesChannel.dart';
import 'package:joincompany/async_operations/CustomerChannel.dart';
import 'package:joincompany/blocs/blocCustomer.dart';
import 'package:joincompany/main.dart';
import 'package:joincompany/Menu//FormClients.dart';
import 'package:joincompany/models/CustomerModel.dart';
import 'package:joincompany/models/UserDataBase.dart';
import 'package:joincompany/models/WidgetsList.dart';
import 'package:joincompany/pages/FormTaskNew.dart';
import 'package:joincompany/blocs/blocCheckConnectivity.dart';

// ignore: must_be_immutable
class Client extends StatefulWidget {

  bool vista;
  Client(vista){
    this.vista = vista;
  }

  @override
  _ClientState createState() => _ClientState();
}

class _ClientState extends State<Client> {
  ListWidgets ls = ListWidgets();
  StreamSubscription _connectionChangeStream;
  bool isOffline = false;
  Icon _searchIcon = new Icon(Icons.search);
  Widget _appBarTitle = new Text('Clientes');
  String textFilter='';

  final TextEditingController _filter = new TextEditingController();

  @override
  void initState() {
    ConnectionStatusSingleton connectionStatus = ConnectionStatusSingleton.getInstance();
    _connectionChangeStream = connectionStatus.connectionChange.listen(connectionChanged);
    checkConnection(connectionStatus);
    super.initState();
  }

  void checkConnection(ConnectionStatusSingleton connectionStatus) async {
    isOffline = await connectionStatus.checkConnection();
    setState(() {
      isOffline = !isOffline;
    });
  }

  void connectionChanged(dynamic hasConnection) {
    setState(() {
      isOffline = !hasConnection;
    });

    if (!isOffline && hasConnection){
      sync();
      syncDialog();
    }
  }

  void sync() async{
    await AddressChannel.syncEverything();
    await CustomerChannel.syncEverything();
    await CustomerAddressesChannel.syncEverything();
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
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.arrow_back),  onPressed:(){  Navigator.pushReplacementNamed(context, '/vistap');}),
        title: _appBarTitle,
        actions: <Widget>[
          ls.createState().searchButtonAppbar(_searchIcon, _searchPressed, 'Eliminar Tarea', 30),
        ],
      ),
      body: Stack(
        children: <Widget>[
          listViewCustomers()
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        elevation: 12,
        backgroundColor: PrimaryColor,
        tooltip: 'Agregar Cliente',
        onPressed: (){
          Navigator.push(
              context,
              new MaterialPageRoute(
                  builder: (BuildContext context) => new  FormClient(null)));
        },

      ),
    );
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
        this._appBarTitle = new Text('Clientes');
        setState(() {
          textFilter='';
        });
        _filter.clear();
      }
    });
  }

  listViewCustomers(){
    CustomersBloc _bloc = new CustomersBloc();
    return StreamBuilder<List<CustomerWithAddressModel>>(
      stream: _bloc.outCustomers,
      initialData: <CustomerWithAddressModel>[],
      builder: (context, snapshot) {
        if(snapshot != null){
          if (snapshot.data.isNotEmpty) {
            return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index) {
                  var direction = snapshot.data[index].address != null ? snapshot.data[index].address : "";
                  var name = snapshot.data[index].name != null ? snapshot.data[index].name:"";
                  if(textFilter == ''){
                    return Card(
                      child: ListTile(
                        title: Text(name , style: TextStyle(fontSize: 14),),
                        subtitle: Text(direction, style: TextStyle(fontSize: 12),),
                        trailing:  IconButton(icon: Icon(Icons.border_color,size: 20,),onPressed: (){
                          if(!widget.vista){
                            Navigator.push(
                                context,
                                new MaterialPageRoute(builder: (BuildContext context) => FormTask(directionClient: snapshot.data[index],)));
                          }
                        },),
                        onTap:
                        widget.vista ? (){
                          Navigator.of(context).pop(snapshot.data[index]);
                        }: (){
                          Navigator.push(
                              context,
                              new MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                  new  FormClient(snapshot.data[index])
                              )
                          );
                        },
                      ),
                    );
                  }else if(ls.createState().checkSearchInText(name, textFilter)||ls.createState().checkSearchInText(direction, textFilter)) {
                    var direction = snapshot.data[index].address != null ? snapshot.data[index].address : "";
                    var name = snapshot.data[index].name != null ? snapshot.data[index].name:"";
                    return Card(
                      child: ListTile(
                        title: Text(name, style: TextStyle(fontSize: 14),),
                        subtitle: Text(direction, style: TextStyle(fontSize: 12),),
                        onTap: (){
                          setState(() {
                            textFilter='';
                          });
                          _filter.clear();
                          Navigator.push(
                              context,
                              new MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                  new  FormClient(snapshot.data[index])
                              )
                          );
                        },
                      ),
                    );
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
                  child: Text("No hay Clientes Registrados"),
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

  @override
  void dispose(){
    _connectionChangeStream.cancel();
    _filter.dispose();
    super.dispose();
  }
}

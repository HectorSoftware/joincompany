import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:joincompany/async_operations/AddressChannel.dart';
import 'package:joincompany/async_operations/ContactChannel.dart';
import 'package:joincompany/async_operations/CustomerAddressesChannel.dart';
import 'package:joincompany/async_operations/CustomerChannel.dart';
import 'package:joincompany/async_operations/CustomerContactsChannel.dart';
import 'package:joincompany/blocs/blocCustomer.dart';
import 'package:joincompany/main.dart';
import 'package:joincompany/Menu/FormClients.dart';
import 'package:joincompany/models/CustomerModel.dart';
import 'package:joincompany/models/WidgetsList.dart';
import 'package:joincompany/pages/FormTaskNew.dart';
import 'package:joincompany/blocs/blocCheckConnectivity.dart';
import 'package:flutter/services.dart';
import 'package:joincompany/pages/LoginPage.dart';
enum STATUS_PAGE_CLIENT{
  view,
  select,
  full
}

// ignore: must_be_immutable
class Client extends StatefulWidget {

  STATUS_PAGE_CLIENT statusPage;
  Client({this.statusPage, bool vista});

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
  STATUS_PAGE_CLIENT statusPage;
  bool syncStatus = false;
  bool active = true;
  final TextEditingController _filter = new TextEditingController();

  @override
  void initState() {
    statusPage = widget.statusPage;
    active = true;
    ConnectionStatusSingleton connectionStatus = ConnectionStatusSingleton.getInstance();
    _connectionChangeStream = connectionStatus.connectionChange.listen(connectionChanged);
    checkConnection(connectionStatus);
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void dispose(){
    active = false;
    _connectionChangeStream.cancel();
    _filter.dispose();
    super.dispose();
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

    if (!isOffline && hasConnection && !syncStatus && active){
      wrapperSync();
    }
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

  void syncClients() async{
    await AddressChannel.syncEverything();
    await CustomerChannel.syncEverything();
    await CustomerAddressesChannel.syncEverything();
    await ContactChannel.syncEverything();
    await CustomerContactsChannel.syncEverything();
    setState(() {syncStatus = false;});
    Navigator.pop(context);
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

  Future syncDialogLocal(){
    return showDialog(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Sincronizando Clientes..."),
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
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed:(){
              statusPage == STATUS_PAGE_CLIENT.full ?
              Navigator.pushReplacementNamed(context, '/vistap') : Navigator.pop(context);
            }
            ),
        title: _appBarTitle,
        actions: <Widget>[
          ls.createState().searchButtonAppbar(_searchIcon, _searchPressed, 'Eliminar Tarea', 30),
          IconButton(icon: Icon(Icons.update),
            onPressed: (){
              if(!isOffline && !syncStatus){
                setState(() {syncStatus = true;});
                syncClients();
                syncDialogLocal();
              }else{
                errorDialog();
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          listViewCustomers()
        ],
      ),
       floatingActionButton: statusPage == STATUS_PAGE_CLIENT.full ? FloatingActionButton(
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

      ) : null,
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
                          if(statusPage == STATUS_PAGE_CLIENT.full){
                            Navigator.push(context,new MaterialPageRoute(builder: (BuildContext context) => FormTask(directionClient: snapshot.data[index],taskmodelres: null,toListTask:false,)));
                          }
                        },),
                        onTap:(){
                          if(statusPage == STATUS_PAGE_CLIENT.select){
                            CustomerModel c = CustomerModel();
                            c.id = snapshot.data[index].id;
                            c.name = snapshot.data[index].name;
                            Navigator.of(context).pop(c);
                          }
                          if(statusPage == STATUS_PAGE_CLIENT.full){
                            Navigator.push(context,new MaterialPageRoute(builder: (BuildContext context) => new  FormClient(snapshot.data[index])));
                          }
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

}

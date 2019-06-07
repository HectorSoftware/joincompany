import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:joincompany/async_database/Database.dart';
import 'package:joincompany/blocs/blocCustomer.dart';
import 'package:joincompany/main.dart';
import 'package:joincompany/Menu//FormClients.dart';
import 'package:joincompany/models/CustomerModel.dart';
import 'package:joincompany/models/UserModel.dart';
import 'package:joincompany/models/WidgetsList.dart';
import 'package:joincompany/widgets/FormTaskNew.dart';
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
  String nameUser = '';
  String emailUser = '';

  @override
  void initState() {
    extraerUser();
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
      print("llego el internet yiiiiiiiii");
      sync();
    }
  }

  Future<void> sync(){
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return AlertDialog(
          content: Center(
            child: SizedBox(
                height: 80.0,
                width: 145.0,
                child:Column(
                  children: <Widget>[
                    Center(
                      child: CircularProgressIndicator(),
                    ),
                    Center(
                      child: Text("Sincronizando"),
                    )
                  ],
                )
            ),
          )
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      drawer: widget.vista ? null:buildDrawer(),
      appBar: AppBar(
        title: _appBarTitle,
        actions: <Widget>[
          ls.createState().searchButtonAppbar(_searchIcon, _searchPressed, 'Eliminar Tarea', 30),
        ],
      ),
      body: Stack(
        children: <Widget>[
          !isOffline ? listViewCustomers() : Text("no posee conexion a internet"),
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
            color: drawerCustomer ? Colors.grey[200] :  null,
            child: ListTile(
              title: new Text("Clientes"),
              trailing: new Icon(Icons.business),
              onTap: () {
                Navigator.pop(context);
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
                Navigator.pushNamed(context, '/configuracion');
              },
            ),
          ),
        ],
      ),
    );
  }

  extraerUser() async {
    UserModel user = await DatabaseProvider.db.RetrieveLastLoggedUser();
    
    setState(() {
      nameUser = user.name;
      emailUser = user.email;
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
        if (snapshot != null) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return new Container(
                child: Center(
                  child: Text("no hay datos disponibles"),
                ),
              );
            case ConnectionState.waiting:
              return new Stack(
                children: <Widget>[
                  Center(
                    child: SizedBox(
                      height: 100.0,
                      width: 100.0,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Colors.blue),
                        strokeWidth: 5.0,
                      ),
                    ),
                  ),
                  Center(
                    child: Text("cargando"),
                  )
                ],
              );
            case ConnectionState.done:
              return new Container(
                child: Center(
                  child: Text("Ha ocurrido un error"),
                ),
              );
            case ConnectionState.active:
              if (snapshot != null) {
                if (snapshot.data.isNotEmpty) {
                  return ListView.builder(
                      itemCount: snapshot.data.length,
                      itemBuilder: (BuildContext context, int index) {
                        var direction = snapshot.data[index].address != null
                            ? snapshot.data[index].address
                            : "";
                        var name = snapshot.data[index].name != null ? snapshot
                            .data[index].name : "";
                        if (textFilter == '') {
                          return Card(
                            child: ListTile(
                              title: Text(
                                name, style: TextStyle(fontSize: 14),),
                              subtitle: Text(
                                direction, style: TextStyle(fontSize: 12),),
                              trailing: IconButton(
                                icon: Icon(Icons.border_color, size: 20,),
                                onPressed: () async {
                                  Navigator.push(
                                      context,
                                      new MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              FormTask(
                                                directioncliente: snapshot
                                                    .data[index],)));
                                },),
                              onTap:
                              widget.vista ? () {
                                Navigator.of(context).pop(snapshot.data[index]);
                              } : () {
                                Navigator.push(
                                    context,
                                    new MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                        new FormClient(snapshot.data[index])
                                    )
                                );
                              },
                            ),
                          );
                        } else if (ls.createState().checkSearchInText(
                            name, textFilter) ||
                            ls.createState().checkSearchInText(
                                direction, textFilter)) {
                          var direction = snapshot.data[index].address != null
                              ? snapshot.data[index].address
                              : "";
                          var name = snapshot.data[index].name != null
                              ? snapshot.data[index].name
                              : "";
                          return Card(
                            child: ListTile(
                              title: Text(
                                name, style: TextStyle(fontSize: 14),),
                              subtitle: Text(
                                direction, style: TextStyle(fontSize: 12),),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    new MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                        new FormClient(snapshot.data[index])
                                    )
                                );
                              },
                            ),
                          );
                        }
                      }
                  );
                } else {
                  return new Container(
                    child: Center(
                      child: Text("No hay Clientes Registrados"),
                    ),
                  );
                }
              } else {
                return new Container(
                  child: Center(
                    child: Text("Ha ocurrido un error interno"),
                  ),
                );
              }
          }
      }else{
        return new Container(
        child: Center(
        child:
        Text("Ha ocurrido un error interno"),
        ),
        )
        ;
        }
      });
  }

  @override
  void dispose(){
    _connectionChangeStream.cancel();
    _filter.dispose();
    super.dispose();
  }
}

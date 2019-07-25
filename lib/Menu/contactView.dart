import 'dart:async';
import 'package:joincompany/async_operations/AddressChannel.dart';
import 'package:joincompany/async_operations/ContactChannel.dart';
import 'package:joincompany/async_operations/CustomerAddressesChannel.dart';
import 'package:joincompany/async_operations/CustomerChannel.dart';
import 'package:joincompany/async_operations/CustomerContactsChannel.dart';
import 'package:joincompany/blocs/blocCheckConnectivity.dart';
import 'package:joincompany/blocs/blocContact.dart';
import 'package:joincompany/models/ContactModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:joincompany/Menu/formContact.dart';
import 'package:joincompany/pages/LoginPage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:joincompany/models/WidgetsList.dart';
import 'package:flutter/services.dart';
enum STATUS_PAGE{
  view,
  select,
  full
}

// ignore: must_be_immutable
class ContactView extends StatefulWidget {
  STATUS_PAGE statusPage;

  ContactView(statusPage){
    this.statusPage = statusPage;
  }

  @override
  _ContactViewState createState() => _ContactViewState();
}

class _ContactViewState extends State<ContactView> {

  ListWidgets ls = ListWidgets();
  bool syncStatus = false;
  StreamSubscription _connectionChangeStream;
  bool isOnline = true;
  bool visible = true;
  Icon _searchIcon = new Icon(Icons.search);
  Widget _appBarTitle = new Text('Contactos');
  String textFilter='';
  final TextEditingController _filter = new TextEditingController();

  @override
  void initState() {
    visible = true;
    ConnectionStatusSingleton connectionStatus = ConnectionStatusSingleton.getInstance();
    _connectionChangeStream = connectionStatus.connectionChange.listen(connectionChanged);
    checkConnection(connectionStatus);
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
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

  void syncContacts() async{
    setState(() {syncStatus = true;});
    await AddressChannel.syncEverything();
    await CustomerChannel.syncEverything();
    await CustomerAddressesChannel.syncEverything();
    await ContactChannel.syncEverything();
    await CustomerContactsChannel.syncEverything();
    setState(() {syncStatus = false;});
    Navigator.pop(context);
  }

  Future<void> syncDialog(){
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return AlertDialog(
            title: Text("Sincronizando Contactos..."),
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
    _connectionChangeStream.cancel();
    visible = false;
    super.dispose();
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
        this._appBarTitle = new Text('Contactos');
        setState(() {
          textFilter='';
        });
        _filter.clear();
      }
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.arrow_back),
            onPressed:(){
              if(widget.statusPage == STATUS_PAGE.view){
                Navigator.of(context).pop(null);
              }
              if(widget.statusPage == STATUS_PAGE.select){
                Navigator.of(context).pop(null);
              }
              if(widget.statusPage == STATUS_PAGE.full){
                Navigator.pushReplacementNamed(context, '/vistap');
              }
        }),
        title:_appBarTitle,
        actions: <Widget>[
          ls.createState().searchButtonAppbar(_searchIcon, _searchPressed, 'Busqueda', 30),
          IconButton(icon: Icon(Icons.update),
            onPressed: (){
              if(isOnline && !syncStatus){
                syncContacts();
                syncDialog();
              }else{
                errorDialog();
              }
            },
          ),
        ],
      ),
      body: listViewContacts(),
      floatingActionButton: widget.statusPage == STATUS_PAGE.full ? FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          if(widget.statusPage == STATUS_PAGE.view){
//            Navigator.of(context).pop(contact);
          }
          if(widget.statusPage == STATUS_PAGE.select){
//            Navigator.of(context).pop(contact);
          }
          if(widget.statusPage == STATUS_PAGE.full){
            Navigator.push(
                context,
                new MaterialPageRoute(
                    builder: (BuildContext context) => new AddContact(null)));
          }
        },
      ) : null,
    );
  }

  Widget contactCard(ContactModel contact) {
    return Card(
      child: ListTile(
        title: Text(contact.name != null ? contact.name :"", style: TextStyle(fontSize: 16),),
        subtitle: Text(contact.customer != null ? contact.customer :"", style: TextStyle(fontSize: 14),),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            IconButton(
                icon: Icon(Icons.call),
                onPressed:(){
                  // ignore: unnecessary_statements
                  widget.statusPage == STATUS_PAGE.full ? _launchCall('tel:${contact.phone}') : null;
                }
            ),
            IconButton(
                icon: Icon(Icons.mail),
                onPressed:(){
                  _launchCall('mailto:${contact.email}');
                }
            )
          ],
        ),
        onTap: (){
          if(widget.statusPage == STATUS_PAGE.view){
//            Navigator.of(context).pop(contact);
          }
          if(widget.statusPage == STATUS_PAGE.select){
            Navigator.of(context).pop(contact);
          }
          if(widget.statusPage == STATUS_PAGE.full){
            Navigator.push(context,new MaterialPageRoute(builder: (BuildContext context) => new AddContact(contact)));
          }
        }
      ),
    );
  }

  _launchCall(String command) async {
    if (await canLaunch(command)) {
      await launch(command);
    } else {
      throw 'Could not launch $command';
    }
  }

  listViewContacts(){
    ContactBloc _bloc = new ContactBloc();
    return StreamBuilder<List<ContactModel>>(
        stream: _bloc.outContact,
        initialData: <ContactModel>[],
        builder: (context, snapshot) {
            if (snapshot != null) {
              if (snapshot.data.isNotEmpty) {
                return ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    var name = snapshot.data[index].name != null ? snapshot
                        .data[index].name : "";
                    var customer = snapshot.data[index].customer != null ? snapshot
                        .data[index].customer : "";
                    if (textFilter == '') {
                      return contactCard(snapshot.data[index]);
                    } else if (ls.createState().checkSearchInText(name, textFilter) || ls.createState().checkSearchInText(customer, textFilter)) {
                      return contactCard(snapshot.data[index]);
                    }else{
                      return Container();
                    }
                  }
              );
              } else {
                if(snapshot.connectionState == ConnectionState.waiting){
                  return new Center(
                    child: CircularProgressIndicator(),
                  );
                }else{
                  return new Container(
                    child: Center(
                      child: Text("No hay Contactos Registrados"),
                    ),
                  );
                }
              }
            } else {
              return new Container(
                child: Center(
                  child: Text("Ha ocurrido un error interno"),
                ),
              );
            }
          }
          );
  }

}

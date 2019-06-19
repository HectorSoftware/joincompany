import 'package:joincompany/blocs/blocContact.dart';
import 'package:joincompany/models/ContactModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:joincompany/Menu/addContact.dart';
import 'package:joincompany/Sqlite/database_helper.dart';
import 'package:joincompany/models/UserDataBase.dart';
import 'package:joincompany/models/WidgetsList.dart';

// ignore: must_be_immutable
class ContactView extends StatefulWidget {
  bool modVista;

  ContactView(vista){
    this.modVista = vista;
  }

  @override
  _ContactViewState createState() => _ContactViewState();
}

class _ContactViewState extends State<ContactView> {

  ListWidgets ls = ListWidgets();

  Icon _searchIcon = new Icon(Icons.search);
  Widget _appBarTitle = new Text('Contactos');
  String textFilter='';
  final TextEditingController _filter = new TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose(){
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.arrow_back),
            onPressed:(){
              if(widget.modVista){
                Navigator.of(context).pop(null);
              }else{
                Navigator.pushReplacementNamed(context, '/vistap');}
        }),
        title:_appBarTitle,
        actions: <Widget>[
          ls.createState().searchButtonAppbar(_searchIcon, _searchPressed, 'Busqueda', 30),
        ],
      ),
      body: listViewContacts(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
              context,
              new MaterialPageRoute(
                  builder: (BuildContext context) => new AddContact(null)));
        },
      ),
    );
  }

  Widget contactCard(ContactModel contact) {
    //TODO: change String for Contacts
    return Card(
      child: ListTile(
        title: Text(contact.name, style: TextStyle(fontSize: 14),),
        subtitle: Text(contact.customer, style: TextStyle(fontSize: 12),),
//        trailing: Column(
//          mainAxisSize: MainAxisSize.min,
//          children: <Widget>[
//            Align(alignment: Alignment.centerLeft,
//              child: Row(
//                children: <Widget>[
//                  IconButton(
//                    icon: Icon(
//                      Icons.mail,
//                      size: 20,
//                    ),
//                    onPressed: () {},
//                  ),
//
//                  IconButton(
//                    icon: Icon(
//                      Icons.call,
//                      size: 20,
//                    ),
//                    onPressed: () {},
//                  )
//                ],
//              ),
//            ),
//          ],
//        ),
        onTap: (){
          if(widget.modVista){
            Navigator.of(context).pop(contact);
          }else{
            Navigator.push(context,new MaterialPageRoute(builder: (BuildContext context) => new AddContact(contact)));
          }
        }
      ),
    );
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
                    if (textFilter == '') {
                      return contactCard(snapshot.data[index]);
                    } else if (ls.createState().checkSearchInText(name, textFilter)) {
                      return contactCard(snapshot.data[index]);
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




  Future<UserDataBase> deletetUser() async {
    UserDataBase userActiv = await ClientDatabaseProvider.db.getCodeId('1');
    return userActiv;
  }

}

import 'package:joincompany/blocs/blocContact.dart';
import 'package:joincompany/models/ContactModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:joincompany/Menu/addContact.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:joincompany/models/WidgetsList.dart';

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
        ],
      ),
      body: listViewContacts(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
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
      ),
    );
  }

  Widget contactCard(ContactModel contact) {
    //TODO: change String for Contacts
    return Card(
      child: ListTile(
        title: Text(contact.name, style: TextStyle(fontSize: 16),),
        subtitle: Text(contact.customer, style: TextStyle(fontSize: 14),),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            IconButton(
                icon: Icon(Icons.call),
                onPressed:(){
                  _launchCall(contact.phone);
                }
            ),
            IconButton(
                icon: Icon(Icons.mail),
                onPressed:(){
                  return showDialog(
                      context: context,
                      barrierDismissible: true, // user must tap button for close dialog!
                      builder: (BuildContext context) {
                        var email = contact.email;
                        return AlertDialog(
                            title: Text('Correo : $email')
                        );
                      }
                  );
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

  _launchCall(String phone) async {
    var command = 'tel:$phone';
    if (await canLaunch(command)) {
      await launch(command);
    } else {
      throw 'Could not launch $phone';
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

}

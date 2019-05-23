import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:joincompany/blocs/blocCustomer.dart';
import 'package:joincompany/main.dart';
import 'package:joincompany/Menu//FormClients.dart';
import 'package:joincompany/Menu/configCli.dart';
import 'package:joincompany/Menu/contactView.dart';
import 'package:joincompany/models/CustomerModel.dart';
import 'package:joincompany/models/CustomersModel.dart';
class Cliente extends StatefulWidget {
  @override
  _ClienteState createState() => _ClienteState();
}

class _ClienteState extends State<Cliente> {

  Widget clientCard(String titleCli, String subtitleCli, int idCli) {//TODO: change String for Client
    String title = titleCli;
    String subtitle = subtitleCli;
    int id = idCli;
    return Card(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                margin: EdgeInsets.all(12.0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    title,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.all(12.0),
                child: Align(alignment: Alignment.centerLeft,child: Text(subtitle),),
              ),
            ],
          ),
          IconButton(icon: Icon(Icons.mode_edit),onPressed: (){},),
        ],
      ),
    );
  }

  Drawer buildDrawer() {
    return Drawer(
      elevation: 12,
      child: new ListView(
        children: <Widget>[
          new UserAccountsDrawerHeader(
            decoration: new BoxDecoration(color: SecondaryColor,
            ),
            accountName: new Text('Nombre de la empresa:',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
              ),
            ),
            accountEmail : Text('Nombre de Usuario',
              style: TextStyle(
                color: Colors.black,
                fontSize: 17,
              ),),),
          new ListTile(
            trailing: new Icon(Icons.assignment),
            title: new Text('Tareas'),

            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/vistap');
            },
          ),
          new ListTile(
            title: new Text("Clientes"),
            trailing: new Icon(Icons.business),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  new MaterialPageRoute(
                      builder: (BuildContext context) => new  Cliente()));
            },
          ),
          new ListTile(
            title: new Text("Contactos"),
            trailing: new Icon(Icons.contacts),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.push(
                  context,
                  new MaterialPageRoute(
                      builder: (BuildContext context) => new  ContactView()));
            },
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
          new ListTile(
            title: new Text("Configuracion"),
            trailing: new Icon(Icons.filter_vintage),
            onTap: () {
              // Navigator.pushReplacementNamed(context, "/intro");
              Navigator.of(context).pop();
              Navigator.push(
                  context,
                  new MaterialPageRoute(
                      builder: (BuildContext context) => new  ConfigCli()));
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      drawer: buildDrawer(),
      appBar: AppBar(
        title: Text('Clientes'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            color: Colors.white,
            disabledColor: Colors.white,
            iconSize: 30,
            tooltip: 'Eliminar Tarea',
            onPressed: (){
              //TODO: AGREGAR FUNCION ELIMINAR TAREA
            },
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          listViewCustomers(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        elevation: 12,
        backgroundColor: PrimaryColor,
        tooltip: 'Agregar Tarea',
        onPressed: (){
          Navigator.push(
              context,
              new MaterialPageRoute(
                  builder: (BuildContext context) => new  FormClient(null)));
        },

      ),
    );
  }

  listViewCustomers(){
    CustomersBloc _bloc = new CustomersBloc();

    // ignore: missing_required_param
    return StreamBuilder<List<CustomerWithAddressModel>>(
      stream: _bloc.outCustomers,
      initialData: <CustomerWithAddressModel>[],
      builder: (context, snapshot) {
      if (snapshot.data.isNotEmpty) {
        return ListView.builder(
          itemCount: snapshot.data.length,
          itemBuilder: (BuildContext context, int index) {
              return Card(
                child: ListTile(
                  title: Text(snapshot.data[index].name, style: TextStyle(fontSize: 14),),
                  subtitle: Text(snapshot.data[index].address, style: TextStyle(fontSize: 12),),
                  onTap: (){
                    Navigator.push(
                        context,
                        new MaterialPageRoute(
                            builder: (BuildContext context) => new  FormClient(snapshot.data[index])));
                  },
                ),
              );
          }
        );
      }else{
        return new Container(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      }
      }
    );

  }
}

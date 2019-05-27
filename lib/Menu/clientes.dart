import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:joincompany/blocs/blocCustomer.dart';
import 'package:joincompany/main.dart';
import 'package:joincompany/Menu//FormClients.dart';
import 'package:joincompany/Menu/configCli.dart';
import 'package:joincompany/Menu/contactView.dart';
import 'package:joincompany/models/CustomerModel.dart';
import 'package:joincompany/models/CustomersModel.dart';
import 'package:joincompany/models/WidgetsList.dart';
class Cliente extends StatefulWidget {
  @override
  _ClienteState createState() => _ClienteState();
}

class _ClienteState extends State<Cliente> {

  ListWidgets ls = ListWidgets();

  Icon _searchIcon = new Icon(Icons.search);
  Widget _appBarTitle = new Text('Clientes');
  String textFilter='';
  final TextEditingController _filter = new TextEditingController();

  Widget clientCard(CustomerWithAddressModel client) {
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
                    client.name,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.all(12.0),
                child: Align(alignment: Alignment.centerLeft,child: Text(client.address),),
              ),
            ],
          ),
          IconButton(icon: Icon(Icons.contact_mail),onPressed: (){},),
        ],
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

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      //drawer: buildDrawer(),
      appBar: AppBar(
        title: _appBarTitle,
        actions: <Widget>[
          ls.createState().searchButtonAppbar(_searchIcon, _searchPressed, 'Eliminar Tarea', 30),
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
            var name = snapshot.data[index].name;
            var dir = snapshot.data[index].address;
            //var name = snapshot.data[index].name;
            if(textFilter == ''){
              return Card(
                child: ListTile(
                  title: Text(snapshot.data[index].name, style: TextStyle(fontSize: 14),),
                  subtitle: Text(snapshot.data[index].address, style: TextStyle(fontSize: 12),),
                  onTap: (){
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
//              return clientCard(snapshot.data[index]);

            }else if(ls.createState().checkSearchInText(name, textFilter)||ls.createState().checkSearchInText(dir, textFilter)){
              return Card(
                child: ListTile(
                  title: Text(snapshot.data[index].name, style: TextStyle(fontSize: 14),),
                  subtitle: Text(snapshot.data[index].address, style: TextStyle(fontSize: 12),),
                  onTap: (){
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
        return new Container(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      }
      }
    );

  }

  @override
  void dispose(){
    _filter.dispose();
    super.dispose();
  }
}

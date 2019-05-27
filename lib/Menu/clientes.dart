import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:joincompany/blocs/blocCustomer.dart';
import 'package:joincompany/main.dart';
import 'package:joincompany/Menu//FormClients.dart';
import 'package:joincompany/models/CustomerModel.dart';
import 'package:joincompany/models/WidgetsList.dart';
import 'package:loadmore/loadmore.dart';

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
      body: Container(
        child: RefreshIndicator(
            child: LoadMore(
              child: Stack(
                children: <Widget>[
                  listViewCustomers(),
                ],
              ),
              onLoadMore: null,
              whenEmptyLoad: false,
              delegate: DefaultLoadMoreDelegate(),
              textBuilder: DefaultLoadMoreTextBuilder.english,
            ),
            onRefresh: _refresh,
        ),
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

  Future<bool> _loadMore() async {//TODO
    print("onLoadMore");
    await Future.delayed(Duration(seconds: 0, milliseconds: 2000));
//    load();
    return true;
  }

  Future<void> _refresh() async {//TODO
    await Future.delayed(Duration(seconds: 0, milliseconds: 2000));
//    list.clear();
//    load();
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
                  trailing:  IconButton(icon: Icon(Icons.description),onPressed: (){},),
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

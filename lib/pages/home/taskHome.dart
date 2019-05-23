import 'package:flutter/material.dart';
import 'package:joincompany/Menu/configCli.dart';
import 'package:joincompany/Menu/contactView.dart';
import 'package:joincompany/blocs/blocListTask.dart';
import 'package:joincompany/blocs/blocListTaskFilter.dart';
import 'package:joincompany/main.dart';
import 'package:joincompany/pages/home/TaskHomeMap.dart';
import 'package:joincompany/pages/home/TaskHomeTask.dart';
import 'package:joincompany/Menu/clientes.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRagePicker;

class TaskHomePage extends StatefulWidget {
  _MyTaskPageState createState() => _MyTaskPageState();
}

class _MyTaskPageState extends State<TaskHomePage> with SingleTickerProviderStateMixin{
  TabController _controller;
  bool conditionalTask = false;
  bool conditionalMap = true;
  bool conditionalHome = true;
  blocListTask blocListTaskres;
  blocListTaskFilter blocListTaskresFilter;
  var DatepickedInit = (new DateTime.now()).add(new Duration(days: -14));
  var DatepickedEnd = new DateTime.now();
  Icon _searchIcon = new Icon(Icons.search);
  Widget _appBarTitle = new Text('Join');
  final TextEditingController _filter = new TextEditingController();

  @override
  void initState() {
    _controller = TabController(length: 2, vsync: this);
    _controller.addListener(
          () {setState((){});
      },
    );
    super.initState();
  }

  @override
  void dispose(){
    _controller.dispose();
    blocListTaskres.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      drawer: buildDrawer(),
      appBar: new AppBar(
        backgroundColor: PrimaryColor,
        title: _appBarTitle,
        actions: <Widget>[
          IconButton(
            icon: _searchIcon,
            tooltip: 'Eliminar Cliente',
            iconSize: 25,
            onPressed: _searchPressed,
          ),
          IconButton(
            icon: Icon(Icons.calendar_today),
            //ICONO DE ALMANAQUE NO LO ENCUENTRO
            tooltip: 'Eliminar Cliente',
            iconSize: 25,
            onPressed: (){
              //FUNCION DE FILTRO POR FECHA
              selectDate(context);
            },
          ),
        ],
        bottom: getTabBar(),
      ),
      body: getTabBarView(),
    );
  }

  TabBar getTabBar(){
    return TabBar(
      indicatorColor : Colors.white,
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white30,
      labelStyle: TextStyle(fontSize: 20),
      tabs: <Tab>[
        Tab(text: 'Tareas',),
        Tab(text: 'Mapa',),
      ],
      controller: _controller,
    );
  }

  TabBarView getTabBarView(){
    blocListTaskres = new blocListTask(valueselectDate);
    blocListTaskresFilter = new blocListTaskFilter(_filter);
    setState(() {
      blocListTaskres;
      blocListTaskresFilter;
    });
    return TabBarView(
      children: <Widget>[
        taskHomeTask(blocListTaskres: blocListTaskres,blocListTaskFilterRes: blocListTaskresFilter,),
        taskHomeMap(),
      ],
      controller: _controller,
      physics: _controller.index == 0
          ? AlwaysScrollableScrollPhysics()
          : NeverScrollableScrollPhysics(),
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
  List<DateTime> valueselectDate = new List<DateTime>();
  Future<Null> selectDate( context )async{
    final List<DateTime> picked = await DateRagePicker.showDatePicker(
    context: context,
    initialFirstDate: DatepickedInit,
    initialLastDate: DatepickedEnd,
    firstDate: new DateTime(1990),
    lastDate: new DateTime(2030)
    );
    if(picked != null){
      bool updateVarDataTime = false;
      if(picked.length == 1){
        if((DatepickedInit != picked[0])||(DatepickedEnd != picked[0])){
          updateVarDataTime = true; DatepickedInit = DatepickedEnd = picked[0];
        }
      }else{
        if((DatepickedInit != picked[0])||(DatepickedEnd != picked[1])){
          updateVarDataTime = true;
          DatepickedInit = picked[0];
          DatepickedEnd = picked[1];
        }
      }

      if(updateVarDataTime){
        setState(() =>
        valueselectDate = picked,
        );
        setState(() {
          DatepickedInit; DatepickedEnd;
          blocListTaskres;
        });
      }
    }
  }
  String textFilter = '';
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
                blocListTaskresFilter;
              });
            },
        );
      } else {
        this._searchIcon = new Icon(Icons.search);
        this._appBarTitle = new Text('Join');
        _filter.clear();
      }
    });
  }

}
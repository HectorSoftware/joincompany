import 'package:flutter/material.dart';
import 'package:joincompany/Menu/configCli.dart';
import 'package:joincompany/Menu/contactView.dart';
import 'package:joincompany/main.dart';
import 'package:joincompany/pages/BuscarRuta/BuscarDireccion.dart';
import 'package:joincompany/pages/home/TaskHomeMap.dart';
import 'package:joincompany/pages/home/TaskHomeTask.dart';
import 'package:joincompany/Menu/clientes.dart';

class taskHomePage extends StatefulWidget {
  _MytaskPageState createState() => _MytaskPageState();
}

class _MytaskPageState extends State<taskHomePage> with SingleTickerProviderStateMixin{
  TabController _controller;
  bool CondicionalTarea = false;
  bool CondicionalMapa = true;
  bool CondicionalHome = true;

  @override
  Future initState() {
    _controller = TabController(length: 2, vsync: this);
    _controller.addListener(
          () {
        setState(() {});
      },
    );
    super.initState();
  }

  @override
  void dispose(){
    _controller.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      drawer: buildDrawer(),
      appBar: new AppBar(
        backgroundColor: PrimaryColor,
        title: new Text('Join'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            tooltip: 'Eliminar Cliente',
            iconSize: 25,
            onPressed: (){
              //FUNCION DE BUSQUEDA EN TAREAS
              //Navigator.pushNamed(context,'/SearchAddress');MaterialPageRoute(builder: (context) => SearchAddress()
              /*Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchAddress()),
              );*/
            },
          ),
          IconButton(
            icon: Icon(Icons.calendar_today),
            //ICONO DE ALMANAQUE NO LO ENCUENTRO
            tooltip: 'Eliminar Cliente',
            iconSize: 25,
            onPressed: (){
              //FUNCION DE FILTRO POR FECHA
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
    return TabBarView(
      children: <Widget>[
        taskHomeTask(),
        taskHomeMap(),
      ],
      controller: _controller,
      physics: _controller.index == 0
          ? AlwaysScrollableScrollPhysics()
          : NeverScrollableScrollPhysics(),
    );
  }

  Container TabBarButton(){
    return Container(
      margin: EdgeInsets.only(top: 0),
      padding: EdgeInsets.only(top: 0),
      child: Row(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 0),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,
              height: MediaQuery.of(context).size.height * 0.07,
              child: RaisedButton(
                elevation: 10,
                color: CondicionalTarea? Colors.grey : Colors.white,
                child: Text('Tarea'),
                onPressed: (){
                  setState(() {
                    CondicionalTarea = false;
                    CondicionalMapa = true;
                    CondicionalHome = true;
                  });
                },
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 0),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,
              height: MediaQuery.of(context).size.height * 0.07,
              child: RaisedButton(
                elevation: 10,
                color: CondicionalTarea? Colors.grey : Colors.white,
                child: Text('Mapa'),
                onPressed: (){
                  setState(() {
                    CondicionalTarea = true;
                    CondicionalMapa = false;
                    CondicionalHome = false;
                  });
                },
              ),
            ),
          )
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

}
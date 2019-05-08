import 'package:flutter/material.dart';
import 'package:joincompany/main.dart';
import 'package:joincompany/pages/home/TaskHomeMap.dart';
import 'package:joincompany/pages/home/TaskHomeTask.dart';

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
    _controller = TabController(length: 2, vsync:this );
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
      drawer: getDrawer(),
      appBar: new AppBar(
        backgroundColor: PrimaryColor,
        title: new Text(' '),
      ),
      body: Column(
        children: <Widget>[
          TabBarButton(),
          Container(child: CondicionalHome ? taskHomeTask() : taskHomeMap())
        ],
      )
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
                color: CondicionalTarea? Colors.lightBlue[700] : Colors.red[300],
                child: Text('Tarea'),
                onPressed: (){
                  CondicionalTarea = false;CondicionalMapa = true; CondicionalHome = true;
                  setState(() {
                    CondicionalTarea;CondicionalMapa;CondicionalHome;
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
                color: CondicionalMapa? Colors.lightBlue[700] : Colors.red[300],
                child: Text('Mapa'),
                onPressed: (){
                  CondicionalTarea = true;CondicionalMapa = false;CondicionalHome = false;
                  setState(() {
                    CondicionalTarea;CondicionalMapa;CondicionalHome;
                  });
                },
              ),
            ),
          )
        ],
      ),
    );
  }

 Drawer getDrawer() {
    return Drawer(
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
              Navigator.of(context).pop();

            },
          ),
          new ListTile(
            title: new Text("Clientes"),
            trailing: new Icon(Icons.business),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          new ListTile(
            title: new Text("Contactos"),
            trailing: new Icon(Icons.contacts),
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
          Divider(
            height: 30.0,
          ),
          new ListTile(
            title: new Text("Configuracion"),
            trailing: new Icon(Icons.filter_vintage),
            onTap: () {
             // Navigator.pushReplacementNamed(context, "/intro");
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
 }

}
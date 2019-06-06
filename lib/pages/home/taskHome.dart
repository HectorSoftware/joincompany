import 'dart:io';

import 'package:flutter/material.dart';
import 'package:joincompany/Menu/businesList.dart';
import 'package:joincompany/Menu/configCli.dart';
import 'package:joincompany/Menu/contactView.dart';
import 'package:joincompany/Sqlite/database_helper.dart';
import 'package:joincompany/blocs/blocListTaskCalendar.dart';
import 'package:joincompany/blocs/blocListTaskFilter.dart';
import 'package:joincompany/main.dart';
import 'package:joincompany/models/UserDataBase.dart';
import 'package:joincompany/models/UserModel.dart';
import 'package:joincompany/models/WidgetsList.dart';
import 'package:joincompany/pages/home/TaskHomeMap.dart';
import 'package:joincompany/pages/home/TaskHomeTask.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRagePicker;
import 'package:joincompany/services/UserService.dart';

class TaskHomePage extends StatefulWidget {
  _MyTaskPageState createState() => _MyTaskPageState();
}

class _MyTaskPageState extends State<TaskHomePage> with SingleTickerProviderStateMixin{

  ListWidgets ls = ListWidgets();

  TabController _controller;
  bool conditionalTask = false;
  bool conditionalMap = true;
  bool conditionalHome = true;
  blocListTaskFilter blocListTaskresFilter;
  blocListTaskCalendar blocListTaskCalendarRes;
  var DatepickedInit = (new DateTime.now()).add(new Duration(days: -14));
  var DatepickedEnd = new DateTime.now();
  String nameUser = '';
  String emailUser = '';

  Icon _searchIcon = new Icon(Icons.search);
  Widget _appBarTitle = new Text('Join');
  final TextEditingController _filter = new TextEditingController();
  List<DateTime> _listCalendar = List<DateTime>();

  @override
  void initState() {
    _controller = TabController(length: 2, vsync: this);
    _controller.addListener(
          () {
            if (this.mounted){
              setState((){
                //Your state change code goes here
              });
            }
      },
    );
    extraerUser();
    _listCalendar.add(DatepickedInit);
    _listCalendar.add(DatepickedEnd);
    super.initState();
  }

  @override
  void dispose(){
    _controller.dispose();
    blocListTaskCalendarRes.dispose();
    blocListTaskresFilter.dispose();
    super.dispose();
  }

  @override
  void setState(fn) {
    if(mounted){
      super.setState(fn);
    }
  }


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      drawer: buildDrawer(),
      appBar: new AppBar(
        backgroundColor: PrimaryColor,
        title: _appBarTitle,
        actions: <Widget>[
          ls.createState().searchButtonAppbar(_searchIcon, _searchPressed, 'Eliminar Cliente', 25),
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

  TabBar getTabBar() {
    return TabBar(
      indicatorColor : Colors.white,
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white30,
      labelStyle: TextStyle(fontSize: 20),
      tabs: <Tab>[
        Tab(child: Text('TAREAS',style: TextStyle(fontSize: 15.5),),),
        Tab(child: Text('MAPA',style: TextStyle(fontSize: 15.5),),),
      ],
      controller: _controller,
    );
  }

  TabBarView getTabBarView() {

    blocListTaskresFilter = new blocListTaskFilter(_filter);
    blocListTaskCalendarRes = new blocListTaskCalendar();

    return TabBarView(
      children: <Widget>[
        taskHomeTask(blocListTaskFilterReswidget: blocListTaskresFilter,blocListTaskCalendarReswidget: blocListTaskCalendarRes,listCalendarRes: _listCalendar,),
        taskHomeMap(blocListTaskCalendarReswidget: blocListTaskCalendarRes,listCalendarRes: _listCalendar),
      ],
      controller: _controller,
      physics: _controller.index == 0
          ? AlwaysScrollableScrollPhysics()
          : NeverScrollableScrollPhysics(),
    );
  }

  bool drawerTask = true;
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
              color: drawerTask ? Colors.grey[200] :  null,
              child: ListTile(
                trailing: new Icon(Icons.assignment),
                title: new Text('Tareas'),
                onTap: () {
                  Navigator.pop(context);
                },
              )
          ),
          Container(
            child: ListTile(
              title: new Text("Clientes"),
              trailing: new Icon(Icons.business),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/cliente');
              },
            ),
          ),
          Container(
            child: new ListTile(
              title: new Text("Contactos"),
              trailing: new Icon(Icons.contacts),
              onTap: () {
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
                Navigator.pushNamed(context, '/negocios');
              },
            ),
          ),
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
                Navigator.push(context,new MaterialPageRoute(builder: (BuildContext context) => new  ConfigCli()));
              },
            ),
          ),
          Container(
            child: new ListTile(
              title: new Text("Cerrar Sesion"),
              trailing: new Icon(Icons.person_add),
              onTap: () {
                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context,'/App');
              },
            ),
          ),
          Container(
            child: new ListTile(
              title: new Text("Salir"),
              trailing: new Icon(Icons.directions_run),
              onTap: () {
                exit(0);
              },
            ),
          ),
        ],
      ),
    );
  }

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
        _listCalendar = new List<DateTime>();
        _listCalendar.add(picked[0]);
        if(picked.length == 2){_listCalendar.add(picked[1]);}else{_listCalendar.add(picked[0]);}
        blocListTaskCalendarRes.inTaksCalendar.add(_listCalendar);
        blocListTaskCalendarRes.inTaksCalendarMap.add(_listCalendar);
        setState(() {
          DatepickedInit; DatepickedEnd;
        });
      }
    }
  }

  String textFilter = '';
  void _searchPressed() {
    if (this.mounted){
      setState((){
        if (this._searchIcon.icon == Icons.search) {
          this._searchIcon = new Icon(Icons.close);
          this._appBarTitle = Container(
            child: new TextField(
              controller: _filter,
              style: TextStyle(color: Colors.white),
              decoration: new InputDecoration(
                prefixIcon: new Icon(Icons.search,color: Colors.white,),
                hintText: 'Buscar',
                fillColor: Colors.white,
              ),
              onChanged: (value){
                if (this.mounted){
                  setState((){
                    textFilter = value.toString();
                    blocListTaskresFilter;
                  });
                }
              },
            ),
          );
        } else {
          this._searchIcon = new Icon(Icons.search);
          this._appBarTitle = new Text('Join');
          _filter.clear();
        }
      });
    }
  }

  extraerUser() async {
    UserDataBase userAct = await ClientDatabaseProvider.db.getCodeId('1');
    var getUserResponse = await getUser(userAct.company, userAct.token);
    UserModel user = UserModel.fromJson(getUserResponse.body);

    if (this.mounted){
      setState((){
        nameUser = user.name;
        emailUser = user.email;
      });
    }
  }

}
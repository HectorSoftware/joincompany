import 'dart:async';

import 'package:flutter/material.dart';
import 'package:joincompany/Menu/configCli.dart';
import 'package:joincompany/Menu/contactView.dart';
import 'package:joincompany/async_database/Database.dart';
import 'package:joincompany/Sqlite/database_helper.dart';
import 'package:joincompany/async_operations/FormChannel.dart';
import 'package:joincompany/async_operations/TaskChannel.dart';
import 'package:joincompany/blocs/blocCheckConnectivity.dart';
import 'package:joincompany/blocs/blocListTaskCalendar.dart';
import 'package:joincompany/blocs/blocListTaskFilter.dart';
import 'package:joincompany/main.dart';
import 'package:joincompany/models/BusinessModel.dart';
import 'package:joincompany/models/UserModel.dart';
import 'package:joincompany/models/WidgetsList.dart';
import 'package:joincompany/pages/home/TaskHomeMap.dart';
import 'package:joincompany/pages/home/TaskHomeTask.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRagePicker;
import 'package:joincompany/services/UserService.dart';
import 'package:flutter/services.dart';

import '../LoginPage.dart';

class TaskHomePage extends StatefulWidget {

  TaskHomePage({this.business});

  final BusinessModel business;

  _MyTaskPageState createState() => _MyTaskPageState();
}

class _MyTaskPageState extends State<TaskHomePage> with SingleTickerProviderStateMixin{

  StreamSubscription _connectionChangeStream;
  bool isOnline = true;
  bool syncStatus = false;
  bool visible = true;
  ListWidgets ls = ListWidgets();

  TabController _controller;
  bool conditionalTask = false;
  bool conditionalMap = true;
  bool conditionalHome = true;
  BlocListTaskFilter blocListTaskResFilter;
  BlocListTaskCalendar blocListTaskCalendarRes;
  BlocListTaskCalendarMap blocListTaskCalendarResMap;
//  var datePickedInit = (new DateTime.now()).add(new Duration(days: -14));
//  var datePickedEnd = new DateTime.now().add(new Duration(days: 14));
  var datePickedInit = new DateTime.now();
  var datePickedEnd = new DateTime.now();
  String nameUser = '';
  String emailUser = '';
  Icon _searchIcon = new Icon(Icons.search);
  Widget _appBarTitle = new Text('Join');
  final TextEditingController _filter = new TextEditingController();
  List<DateTime> _listCalendar = List<DateTime>();
  bool showSearch = true;
  bool firsCalendar = false;

  @override
  void initState() {
    visible = true;
    ConnectionStatusSingleton connectionStatus = ConnectionStatusSingleton.getInstance();
    _connectionChangeStream = connectionStatus.connectionChange.listen(connectionChanged);
    checkConnection(connectionStatus);
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
    _listCalendar.add(datePickedInit);
    _listCalendar.add(datePickedEnd);
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  void checkConnection(ConnectionStatusSingleton connectionStatus) async {
    isOnline = await connectionStatus.checkConnection();
    setState(() {});
  }

  void connectionChanged(dynamic hasConnection) {
    if (!isOnline && hasConnection && !syncStatus && visible){
      syncStatus=true;
      wrapperSync();
    }

    setState(() {
      isOnline = hasConnection;
    });
  }

  void wrapperSync()async{
    await syncDialogAll();
    syncStatus = false;
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

  @override
  void dispose(){
    visible = false;
    _controller.dispose();
    _connectionChangeStream.cancel();
    blocListTaskCalendarRes.dispose();
    blocListTaskCalendarResMap.dispose();
    blocListTaskResFilter.dispose();
    super.dispose();
  }

  @override
  void setState(fn) {
    if(mounted){
      super.setState(fn);
    }
  }

  void syncTask() async{
    await FormChannel.syncEverything();
    await TaskChannel.syncEverything();
    syncStatus = false;
    Navigator.pop(context);
  }

  Future<void> syncDialog(){
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return AlertDialog(
            title: Text("Sincronizando Tareas..."),
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
  Widget build(BuildContext context) {
    return new Scaffold(
      drawer: widget.business == null ? buildDrawer() : null,
      appBar: new AppBar(
        leading: widget.business == null ? null : IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed:(){
              Navigator.pop(context);
            }
        ),
        backgroundColor: PrimaryColor,
        title: _appBarTitle,
        actions: <Widget>[
          showSearch ? ls.createState().searchButtonAppbar(_searchIcon, _searchPressed, 'Eliminar Cliente', 25) : Container(),
          IconButton(
            icon: Icon(Icons.calendar_today),
            //ICONO DE ALMANAQUE NO LO ENCUENTRO
            tooltip: 'Eliminar Cliente',
            iconSize: 25,
            onPressed: (){
              //FUNCION DE FILTRO POR FECHA
              if(_controller.index == 0){
                selectDate(context);
              }
              if(_controller.index == 1){
                selectDateMap(context);
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.update),
            onPressed:(){
              if(isOnline && !syncStatus){
                syncStatus = true;
                syncTask();
                syncDialog();
              }else{
                errorDialog();
              }
            },
          )
        ],
        bottom: getTabBar(),
      ),
      body: getTabBarView(),
    );
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

    blocListTaskResFilter = new BlocListTaskFilter(_filter);
    blocListTaskCalendarResMap = new BlocListTaskCalendarMap();
    blocListTaskCalendarRes = new BlocListTaskCalendar();

    if(_controller.index == 0){
      showSearch = true;
    }
    if(_controller.index == 1){
      showSearch = false;
    }


    return TabBarView(
      children: <Widget>[
        widget.business == null ?
        new TaskHomeTask(blocListTaskFilterReswidget: blocListTaskResFilter,blocListTaskCalendarReswidget: blocListTaskCalendarRes,listCalendarRes: _listCalendar,) :
        new TaskHomeTask(blocListTaskFilterReswidget: blocListTaskResFilter,blocListTaskCalendarReswidget: blocListTaskCalendarRes,listCalendarRes: _listCalendar,business: widget.business,),
        widget.business == null ?
        new TaskHomeMap(blocListTaskCalendarResMapwidget: blocListTaskCalendarResMap, dateActualRes: _date,):
        new TaskHomeMap(blocListTaskCalendarResMapwidget: blocListTaskCalendarResMap, dateActualRes: _date, business: widget.business,),
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
                  Navigator.pushReplacementNamed(context, '/vistap');
                },
              )
          ),
          Container(
            child: ListTile(
              title: new Text("Clientes"),
              trailing: new Icon(Icons.business),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/cliente');
              },
            ),
          ),
          Container(
            child: new ListTile(
              title: new Text("Contactos"),
              trailing: new Icon(Icons.contacts),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/contactos');
              },
            ),
          ),
          Container(
            //color: Colors.grey[400],
            child: new ListTile(
              title: new Text("Negocios"),
              trailing: new Icon(Icons.account_balance),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/negocios');
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
              title: new Text("Salir"),
              trailing: new Icon(Icons.directions_run),
              onTap: () {
                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context,'/App');
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<UserModel> deletetUser() async {
    UserModel user = await DatabaseProvider.db.RetrieveLastLoggedUser();
    return user;
  }

  Future<Null> selectDate( context )async{
    final List<DateTime> picked = await DateRagePicker.showDatePicker(
        context: context,
        initialFirstDate: datePickedInit,
        initialLastDate: datePickedEnd ,
        firstDate: new DateTime(1990),
        lastDate: new DateTime(2030)
    );
    if(picked != null){
      bool updateVarDataTime = false;
      if(picked.length == 1){
        if((datePickedInit != picked[0])||(datePickedEnd != picked[0])){
          updateVarDataTime = true; datePickedInit = datePickedEnd = picked[0];
        }
      }else{
        if((datePickedInit != picked[0])||(datePickedEnd != picked[1])){
          updateVarDataTime = true;
          datePickedInit = picked[0];
          datePickedEnd = picked[1];
        }
      }

      if(updateVarDataTime){
        _listCalendar = new List<DateTime>();
        _listCalendar.add(picked[0]);
        if(picked.length == 2){_listCalendar.add(picked[1]);}else{_listCalendar.add(picked[0]);}
        blocListTaskCalendarRes.inTaksCalendar.add(_listCalendar);
        setState(() {
          datePickedInit; datePickedEnd;
        });
      }
    }
  }

  DateTime _date = DateTime.now();
  Future<Null> selectDateMap(BuildContext context )async{
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: _date,
        firstDate: new DateTime(1990),
        lastDate: new DateTime(2030)
    );
    if (picked != null && picked != _date){
      blocListTaskCalendarResMap.inTaksCalendarMap.add(picked);
      setState(() {
        _date = picked;
      });

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
                    blocListTaskResFilter.inTaksFilter.add(textFilter);
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
    UserModel user = await DatabaseProvider.db.RetrieveLastLoggedUser();

    if (this.mounted){
      setState((){
        nameUser = user.name;
        emailUser = user.email;
      });
    }
  }
}
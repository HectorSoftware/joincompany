import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:joincompany/Sqlite/database_helper.dart';
import 'package:joincompany/blocs/blocListTaskCalendar.dart';
import 'package:joincompany/blocs/blocListTaskFilter.dart';
import 'package:joincompany/models/TaskModel.dart';
import 'package:joincompany/models/TasksModel.dart';
import 'package:joincompany/models/UserDataBase.dart';
import 'package:joincompany/models/WidgetsList.dart';
import 'package:joincompany/services/TaskService.dart';
import 'package:joincompany/widgets/FormTaskNew.dart';


import '../../main.dart';

class taskHomeTask extends StatefulWidget {

  taskHomeTask({this.blocListTaskFilterReswidget,this.blocListTaskCalendarReswidget});

  final blocListTaskFilter blocListTaskFilterReswidget;
  final blocListTaskCalendar blocListTaskCalendarReswidget;

  _MytaskPageTaskState createState() => _MytaskPageTaskState();
}

class _MytaskPageTaskState extends State<taskHomeTask> {
  ListWidgets ls = ListWidgets();
  bool MostrarLista = false;
  UserDataBase UserActiv;
  static LatLng _initialPosition;
  List<TaskModel> listTaskModellocal;
  String filterText = '';

  blocListTaskFilter bloctasksFilter;
  blocListTaskCalendar blocListTaskCalendarRes;
  List<DateTime> ListCalender = new List<DateTime>();

  @override
  void initState() {
    _getUserLocation();
    listTaskModellocal = new List<TaskModel>();
    actualizarusuario();
    super.initState();
  }

  actualizarusuario() async{
    UserActiv = await ClientDatabaseProvider.db.getCodeId('1');
    getdatalist(DateTime.now(),DateTime.now().add(Duration(days: -15)),1);
    setState(() {
      UserActiv;
    });
  }

  @override
  void dispose(){
    bloctasksFilter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final mediaQueryData = MediaQuery.of(context);
    double aument = 0.7;
    if (mediaQueryData.orientation == Orientation.portrait) {
      aument = 0.8;
    }

    String fechaHoy = DateTime.now().day.toString()+ ' ' + intsToMonths[DateTime.now().month.toString()]+ ' ' +DateTime.now().year.toString();

    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * aument,
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            ListViewTareas(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: (){
              Navigator.push(
                  context,
                  new MaterialPageRoute(builder: (BuildContext context) => FormTask()));
              //Navigator.pushNamed(context, '/formularioTareas');
            }),
      ),
    );
  }


  ListViewTareas(){

    /*bloctasks = widget.blocListTaskRes;
    try{
      // ignore: cancel_subscriptions
      StreamSubscription streamSubscription = bloctasks.outListTaks.listen((newVal)
      => setState((){
        listTaskModellocal = new List<TaskModel>();
        setState(() {
          listTaskModellocal;
        });
        for(int h = 0; h < 255; h++){
          var hasta = new DateTime.now().add(Duration(days: -h));
          for(int k = 0; k < newVal.length; k++){
            if ((hasta.day == DateTime.parse(newVal[k].createdAt).day)&&
                (hasta.month == DateTime.parse(newVal[k].createdAt).month)&&
                (hasta.year == DateTime.parse(newVal[k].createdAt).year)) {
              listTaskModellocal.add(newVal[k]);
            }
          }
        }
      }));
    }catch(e){ }*/

    blocListTaskCalendarRes = widget.blocListTaskCalendarReswidget;
    try{
      // ignore: cancel_subscriptions
      StreamSubscription streamSubscriptionCalendar = blocListTaskCalendarRes.outTaksCalendar.listen((onData)
      => setState((){
        listTaskModellocal.clear();
        getdatalist(onData[1],onData[0],1);
      }));
    }catch(e){}


    bloctasksFilter = widget.blocListTaskFilterReswidget;
    try{
      // ignore: cancel_subscriptions
      StreamSubscription streamSubscriptionFilter = bloctasksFilter.outTaksFilter.listen((newVal)
      => setState((){
        filterText = newVal;
      }));
    }catch(e){ }

    return listTaskModellocal.length != 0 ?
    listando() : Center(
      child: CircularProgressIndicator(),
    );
  }


  getdatalist(DateTime hastaf,DateTime desdef,int pageTasks) async {
    String diaDesde = desdef.year.toString()  + '-' + desdef.month.toString()  + '-' + desdef.day.toString();
    String diaHasta = hastaf.year.toString()  + '-' + hastaf.month.toString()  + '-' + hastaf.day.toString();

    String urlPageNext = '';
    TasksModel tasks = new TasksModel();
    var getAllTasksResponse;
    List<TaskModel> _listTask = new List<TaskModel>();
    try{

//      while(true){
//
//        if(urlPageNext == ''){
//          getAllTasksResponse = await getAllTasks(UserActiv.company,UserActiv.token,beginDate: diaDesde,endDate: diaHasta,responsibleId: UserActiv.idUserCompany.toString());
//        }else{
//          if(urlPageNext != 'nill'){
//            getAllTasksResponse = await getAllTasks(UserActiv.company,UserActiv.token,beginDate: diaDesde,endDate: diaHasta,responsibleId: UserActiv.idUserCompany.toString(),urlPage: urlPageNext);
//          }
//        }
//
//        if(getAllTasksResponse.statusCode == 200){
//          tasks = TasksModel.fromJson(getAllTasksResponse.body);
//          for(int i = 0; i < tasks.data.length; i++ ){
//            _listTask.add(tasks.data[i]);
//          }
//        }
//
//
//      break;
//      }

      for(int contpage = 0; contpage < pageTasks; contpage++){
        if(urlPageNext == ''){
          getAllTasksResponse = await getAllTasks(UserActiv.company,UserActiv.token,beginDate: diaDesde,endDate: diaHasta,responsibleId: UserActiv.idUserCompany.toString(), perPage: '20');
        }else{
          if(urlPageNext != 'nill'){
            getAllTasksResponse = await getAllTasks(UserActiv.company,UserActiv.token,beginDate: diaDesde,endDate: diaHasta,responsibleId: UserActiv.idUserCompany.toString(),urlPage: urlPageNext);
          }
        }
        if(getAllTasksResponse.statusCode == 200){
          var bodyy = getAllTasksResponse.body;
          print(getAllTasksResponse.body);
          tasks = TasksModel.fromJson(getAllTasksResponse.body);
          print(getAllTasksResponse.body);
          if(tasks.nextPageUrl != null){
            urlPageNext = tasks.nextPageUrl;
          }else{urlPageNext = 'nill';}
        }
      }
      for(int i = 0; i < tasks.data.length; i++ ){
        _listTask.add(tasks.data[i]);
      }
    }catch(e,s){ print(s);}
    setState(() {
      listTaskModellocal = _listTask;
    });
  }

  listando(){

    String DateTask = "1990-05-05 20:00:04Z";
    return ListView.builder(
        itemCount: listTaskModellocal.length,
        itemBuilder: (BuildContext context, int index) {

          int PosicionActual = index;
          String voidFieldMessage = "";

          var date;
          var title;
          var address;
          var customerName;

          if(listTaskModellocal[PosicionActual].customer == null){
            customerName = voidFieldMessage;
          }else{
            customerName = listTaskModellocal[PosicionActual].customer.name;
          }

          if (listTaskModellocal[PosicionActual].createdAt == null) {
            date = voidFieldMessage;
          } else {
            date = listTaskModellocal[PosicionActual].createdAt.substring(10, 16);
          }

          if (listTaskModellocal[PosicionActual].name == null) {
            title = voidFieldMessage;
          } else {
            title = listTaskModellocal[PosicionActual].name + ' - ' + listTaskModellocal[PosicionActual].id.toString();
          }

          if (listTaskModellocal[PosicionActual].address == null) {
            address = voidFieldMessage;
          } else {
            if (listTaskModellocal[PosicionActual].address.address == null) {
              address = voidFieldMessage;
            } else {
              address = customerName + ',  ' + listTaskModellocal[PosicionActual].address.address;
            }
          }

          if(filterText == ''){
            if ((DateTime.parse(DateTask).day != DateTime.parse(listTaskModellocal[PosicionActual].createdAt).day) ||
                (DateTime.parse(DateTask).month != DateTime.parse(listTaskModellocal[PosicionActual].createdAt).month) ||
                (DateTime.parse(DateTask).year != DateTime.parse(listTaskModellocal[PosicionActual].createdAt).year)) {
              DateTask = listTaskModellocal[PosicionActual].createdAt;
              String dateTitulo = DateTime.parse(listTaskModellocal[PosicionActual].createdAt).day
                  .toString() + ' de ' + intsToMonths[DateTime
                  .parse(listTaskModellocal[PosicionActual].createdAt)
                  .month
                  .toString()] + ' ' + DateTime
                  .parse(listTaskModellocal[PosicionActual].createdAt)
                  .year
                  .toString();

              var padding = 16.0;
              double por = 0.1;
              if (MediaQuery.of(context).orientation == Orientation.portrait) {
                por = 0.07;
              }

              if((DateTime.now().day == DateTime.parse(listTaskModellocal[PosicionActual].createdAt).day)&&
                  (DateTime.now().month == DateTime.parse(listTaskModellocal[PosicionActual].createdAt).month)&&
                  (DateTime.now().year == DateTime.parse(listTaskModellocal[PosicionActual].createdAt).year)){
                dateTitulo = 'Hoy, ' + dateTitulo;
              }
              return Container(
                child: Column(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(left: padding,right: 0,top: padding, bottom: 0),
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * por,
                      color: PrimaryColor,
                      child: Text(dateTitulo, style: TextStyle(
                          fontSize: 16, color: Colors.white)),
                    ),
                    ListCard(title, address, date, listTaskModellocal[PosicionActual],PosicionActual),
                  ],
                ),
              );
            } else {
              return ListCard(title, address, date, listTaskModellocal[PosicionActual], PosicionActual);
            }
          }else{
            if(ls.createState().checkSearchInText(title, filterText) ||
                ls.createState().checkSearchInText(address, filterText) ||
                ls.createState().checkSearchInText(customerName, filterText)){
              if ((DateTime.parse(DateTask).day != DateTime.parse(listTaskModellocal[PosicionActual].createdAt).day) ||
                  (DateTime.parse(DateTask).month != DateTime.parse(listTaskModellocal[PosicionActual].createdAt).month) ||
                  (DateTime.parse(DateTask).year != DateTime.parse(listTaskModellocal[PosicionActual].createdAt).year)) {
                DateTask = listTaskModellocal[PosicionActual].createdAt;
                String dateTitulo = DateTime.parse(listTaskModellocal[PosicionActual].createdAt).day
                    .toString() + ' de ' + intsToMonths[DateTime
                    .parse(listTaskModellocal[PosicionActual].createdAt)
                    .month
                    .toString()] + ' ' + DateTime
                    .parse(listTaskModellocal[PosicionActual].createdAt)
                    .year
                    .toString();

                var padding = 16.0;
                double por = 0.1;
                if (MediaQuery.of(context)
                    .orientation == Orientation.portrait) {
                  por = 0.07;
                }

                if((DateTime.now().day == DateTime.parse(listTaskModellocal[PosicionActual].createdAt).day)&&
                    (DateTime.now().month == DateTime.parse(listTaskModellocal[PosicionActual].createdAt).month)&&
                    (DateTime.now().year == DateTime.parse(listTaskModellocal[PosicionActual].createdAt).year)){
                  dateTitulo = 'Hoy, ' + dateTitulo;

                }
                return Container(
                  child: Column(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(left: padding,right: 0,top: padding, bottom: 0),
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * por,
                        color: PrimaryColor,
                        child: Text(dateTitulo, style: TextStyle(
                            fontSize: 16, color: Colors.white)),
                      ),
                      ListCard(title, address, date, listTaskModellocal[PosicionActual],PosicionActual),
                    ],
                  ),
                );
              } else {
                return ListCard(title, address, date, listTaskModellocal[PosicionActual], PosicionActual);
              }
            }else{
              return Container();
            }
          }
        }
    );
  }

  Container ListCard(String title, String address, String date,TaskModel listTask, int index){
    return Container(
        child: Card(
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16,right: 16),
                      child: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  Checkbox(
                    value: listTask.status.contains('done'),
                    onChanged: (bool value) async {
                      if(value){
                        var checkInTaskResponse = await checkOutTask(listTask.id.toString(),UserActiv.company,UserActiv.token,_initialPosition.latitude.toString(),_initialPosition.longitude.toString(),'0');
                        if(checkInTaskResponse.statusCode == 200){
                          listTaskModellocal[index].status = 'done';
                          setState(() {
//                            listTaskModellocal;
                          });
                        }
                      }else{
                        var checkInTaskResponse = await checkInTask(listTask.id.toString(),UserActiv.company,UserActiv.token,_initialPosition.latitude.toString(),_initialPosition.longitude.toString(),'0');
                        if(checkInTaskResponse.statusCode == 200){
                          listTaskModellocal[index].status = 'working';
                          setState(() {
//                            listTaskModellocal;
                          });
                        }
                      }
                    },
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16,right: 16),
                      child: Text(address, style: TextStyle(fontSize: 10)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Text(date),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Container(
                    child: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          deleteCustomer(listTask.id.toString(),index);
                        }
                    ),
                  ),
                ],
              )
            ],
          ),
        )
    );
  }


  deleteCustomer(String taskID, int index) async {
    var deleteTaskResponse = await deleteTask(taskID,UserActiv.company,UserActiv.token);
    if(deleteTaskResponse.statusCode == 200){
      listTaskModellocal.removeAt(index);
      setState(() {
        listTaskModellocal;
      });
    }
  }

  void _getUserLocation() async{
    Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemark = await Geolocator().placemarkFromCoordinates(position.latitude, position.longitude);
    setState(() {
      _initialPosition = LatLng(position.latitude, position.longitude);
    });
  }

  Map<String, String> intsToMonths = {
    '1':  'Enero',
    '2':  'Febrero',
    '3':  'Marzo',
    '4':  'Abril',
    '5':  'Mayo',
    '6':  'Junio',
    '7':  'Julio',
    '8':  'Agosto',
    '9':  'Septiembre',
    '10': 'Octubre',
    '11': 'Noviembre',
    '12': 'Diciembre',
  };
}

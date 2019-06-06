import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:joincompany/async_database/Database.dart';
import 'package:joincompany/blocs/blocListTask.dart';
import 'package:joincompany/blocs/blocListTaskCalendar.dart';
import 'package:joincompany/blocs/blocListTaskFilter.dart';
import 'package:joincompany/models/CustomerModel.dart';
import 'package:joincompany/models/TaskModel.dart';
import 'package:joincompany/models/TasksModel.dart';
import 'package:joincompany/models/UserModel.dart';
import 'package:joincompany/models/WidgetsList.dart';
import 'package:joincompany/services/TaskService.dart';
import 'package:joincompany/widgets/FormTaskNew.dart';
import 'package:loadmore/loadmore.dart';


import '../../main.dart';

class taskHomeTask extends StatefulWidget {

  taskHomeTask({this.blocListTaskFilterReswidget,this.blocListTaskCalendarReswidget,this.listCalendarRes});

  final blocListTaskFilter blocListTaskFilterReswidget;
  final blocListTaskCalendar blocListTaskCalendarReswidget;
  final List<DateTime> listCalendarRes;

  _MytaskPageTaskState createState() => _MytaskPageTaskState();
}

class _MytaskPageTaskState extends State<taskHomeTask> {
  ListWidgets ls = ListWidgets();
  bool MostrarLista = false;
  UserModel user;
  static LatLng _initialPosition;
  List<TaskModel> listTaskModellocal;
  List<bool> listTaskModellocalbool;
  String filterText = '';
  List<DateTime> listCalendar = new List<DateTime>();


  blocListTaskFilter bloctasksFilter;
  blocListTaskCalendar blocListTaskCalendarRes;
  blocListTask blocList;
  List<DateTime> ListCalender = new List<DateTime>();
  CustomerWithAddressModel directionClient = CustomerWithAddressModel();

  @override
  void initState() {
    _getUserLocation();
    listTaskModellocal = new List<TaskModel>();
    listTaskModellocalbool = new List<bool>();
    listCalendar = widget.listCalendarRes;
    actualizarusuario();
    super.initState();
  }

  actualizarusuario() async{
    user = await DatabaseProvider.db.RetrieveLastLoggedUser();
    ListCalender = widget.listCalendarRes;
    PageTasks = 1;
    //getdatalist(listCalendar[1],listCalendar[0],1);
    setState(() {
    user;ListCalender;
    });


  }

  @override
  void dispose(){
    bloctasksFilter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    blocListTaskCalendarRes = widget.blocListTaskCalendarReswidget;
    try{
      // ignore: cancel_subscriptions
      StreamSubscription streamSubscriptionCalendar = blocListTaskCalendarRes.outTaksCalendar.listen((onData)
      => setState((){
        listTaskModellocal.clear();
        listTaskModellocalbool.clear();
        PageTasks = 1;
        ListCalender = onData;
        //getdatalist(onData[1],onData[0],1);
      }));
    }catch(e){}

    final mediaQueryData = MediaQuery.of(context);//HORIZONTAL
    double aument = 0.7;
    if (mediaQueryData.orientation == Orientation.portrait) {//VERTICAL
      aument = 0.8;
    }

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
                  new MaterialPageRoute(builder: (BuildContext context) => FormTask(directioncliente: directionClient,)));
              //Navigator.pushNamed(context, '/formularioTareas');
            }),
      ),
    );
  }

  ListViewTareas(){

    blocList = new blocListTask(listCalendar[1],listCalendar[0],PageTasks);
    try{
      // ignore: cancel_subscriptions
      StreamSubscription streamSubscriptionList = blocList.outListTaks.listen((onDataList)
      => setState((){
        listTaskModellocal = onDataList;
        for(int cantlistTaskModellocal = 0; cantlistTaskModellocal < onDataList.length; cantlistTaskModellocal++){
          //listTaskModellocal.add(onDataList[cantlistTaskModellocal]);
          listTaskModellocalbool.add(onDataList[cantlistTaskModellocal].status.contains('done'));
        }
      }));
    }catch(e){  }
    try{
      // ignore: cancel_subscriptions
      StreamSubscription streamSubscriptionListToal = blocList.outListTaksTotal.listen((onDataListTotal)
      => setState((){
        TareasTotales = onDataListTotal;
      }));
    }catch(e){  }

    bloctasksFilter = widget.blocListTaskFilterReswidget;
    try{
      // ignore: cancel_subscriptions
      StreamSubscription streamSubscriptionFilter = bloctasksFilter.outTaksFilter.listen((newVal)
      => setState((){
        filterText = newVal;
      }));
    }catch(e){  }

    return ((listTaskModellocal.length != 0)) ?

    Container(
      child: RefreshIndicator(
        child: LoadMore(
          isFinish: countTaskList >= 100,
          onLoadMore: _loadMore,
          child: listando(),
          whenEmptyLoad: false,
          delegate: DefaultLoadMoreDelegate(),
          textBuilder: DefaultLoadMoreTextBuilder.english,
        ),
        onRefresh: _refresh,
      ),
    )
//    listando()
      : Center(
      child: CircularProgressIndicator(),
    );
  }

  int TareasTotales = 0;
  int get countTaskList => listTaskModellocal.length;
  Future<bool> _loadMore() async {
    PageTasks++;
//    print("onLoadMore ${listTaskModellocal.length}");
    await Future.delayed(Duration(seconds: 0, milliseconds: 5000));
//    print("Page $PageTasks");
    //getdatalist(listCalendar[1],listCalendar[0],PageTasks);
    return true;
  }

  Future<void> _refresh() async {
    await Future.delayed(Duration(seconds: 0, milliseconds: 2000));
    setState(() {
      PageTasks = 1;
      listTaskModellocal.clear();
    });
    //getdatalist(listCalendar[1],listCalendar[0],1);
  }

  int PageTasks = 1;
//  getdatalist(DateTime hastaf,DateTime desdef,int pageTasks) async {
//    String diaDesde =   desdef.year.toString()  + '-' + desdef.month.toString()  + '-' + desdef.day.toString() + ' 00:00:00';
//    String diaHasta = hastaf.year.toString()  + '-' + hastaf.month.toString()  + '-' + hastaf.day.toString() + ' 23:59:59';
//
//    TasksModel tasks = new TasksModel();
//    var getAllTasksResponse;
//    List<TaskModel> _listTask = new List<TaskModel>();
//    try{
//      getAllTasksResponse = await getAllTasks(UserActiv.company,UserActiv.token,beginDate: diaDesde,endDate: diaHasta,responsibleId: UserActiv.idUserCompany.toString(), perPage: '20',page: pageTasks.toString());
//      if(getAllTasksResponse.statusCode == 200){
//        tasks = TasksModel.fromJson(getAllTasksResponse.body);
//        setState(() {
//          TareasTotales = tasks.total;
//        });
//        DateTime FechaNueva = DateTime.parse('1990-05-05');
//        for(int i = 0; i < tasks.data.length; i++ ){
//          DateTime Fechatask = DateTime.parse(tasks.data[i].createdAt);
//          int c = 0;
//          for(int countPasar = 0; countPasar < listTaskModellocal.length; countPasar++){
//            if(listTaskModellocal[countPasar].id == tasks.data[i].id){
//              c++;
//            }
//          }
//          if(c < 2){
//            if((tasks.data.length == 1)||
//                ((FechaNueva.day != Fechatask.day) || (FechaNueva.month != Fechatask.month) || (FechaNueva.year != Fechatask.year))){
//              listTaskModellocal.add(tasks.data[i]);
//              listTaskModellocalbool.add(tasks.data[i].status.contains('done'));
//              FechaNueva = Fechatask;
//            }
//            listTaskModellocal.add(tasks.data[i]);
//            listTaskModellocalbool.add(tasks.data[i].status.contains('done'));
//          }
//        }
//      }
//    }catch(e){}
//    setState(() {
//      listTaskModellocal;
//      listTaskModellocalbool;
//    });
//
//  }

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
            title = listTaskModellocal[PosicionActual].name /*+ ' - ' + listTaskModellocal[PosicionActual].id.toString()*/;
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
            bool res = false;

            if((PosicionActual != listTaskModellocal.length - 1)){
              if(listTaskModellocal[PosicionActual].id == listTaskModellocal[PosicionActual + 1].id){
                res = true;
              }
            }

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
              return res ?
              Container(
                padding: EdgeInsets.only(left: padding,right: 0,top: padding, bottom: 0),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * por,
                color: PrimaryColor,
                child: Text(dateTitulo, style: TextStyle(
                    fontSize: 16, color: Colors.white)),
              ) :
              ListCard(title, address, date, listTaskModellocal[PosicionActual],PosicionActual);
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
                return ListCard(title,address,date,listTaskModellocal[PosicionActual], PosicionActual);
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
                    value: listTaskModellocal[index].status.contains('done'),
                    onChanged: (bool value) async {
                      if(value){
                        setState(() {
                          listTaskModellocal[index].status = 'working';
                        });
                        var checkInTaskResponse = await checkOutTask(listTask.id.toString(), user.company, user.rememberToken,_initialPosition.latitude.toString(),_initialPosition.longitude.toString(),'0');
                        if(checkInTaskResponse.statusCode != 200){
                          setState(() {
                            listTaskModellocal[index].status = 'done';
                          });
                        }
                      }else{
                        setState(() {
                          listTaskModellocal[index].status = 'done';
                        });
                        var checkInTaskResponse = await checkInTask(listTask.id.toString(), user.company, user.rememberToken,_initialPosition.latitude.toString(),_initialPosition.longitude.toString(),'0');
                        if(checkInTaskResponse.statusCode != 200){
                          setState(() {
                            listTaskModellocal[index].status = 'working';
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
    var deleteTaskResponse = await deleteTask(taskID, user.company, user.rememberToken);
    if(deleteTaskResponse.statusCode == 200){
//      if((listTaskModellocal[index].id == listTaskModellocal[index - 1].id) &&
//          (
//          (DateTime.parse(listTaskModellocal[index].createdAt).day != DateTime.parse(listTaskModellocal[index + 1].createdAt).day)||
//          (DateTime.parse(listTaskModellocal[index].createdAt).month != DateTime.parse(listTaskModellocal[index + 1].createdAt).month)||
//          (DateTime.parse(listTaskModellocal[index].createdAt).year != DateTime.parse(listTaskModellocal[index + 1].createdAt).year)
//          )){
//        listTaskModellocal.removeAt(index - 1);
//        listTaskModellocalbool.removeAt(index - 1);
//        listTaskModellocal.removeAt(index - 1);
//        listTaskModellocalbool.removeAt(index - 1);
//      }else{
//        listTaskModellocal.removeAt(index);
//        listTaskModellocalbool.removeAt(index);
//      }
//      setState(() {
//        listTaskModellocal;
//        listTaskModellocalbool;
//      });
    }
  }

  void _getUserLocation() async{
    Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    // List<Placemark> placemark = await Geolocator().placemarkFromCoordinates(position.latitude, position.longitude);
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

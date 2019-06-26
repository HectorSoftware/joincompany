import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:joincompany/Sqlite/database_helper.dart';
import 'package:joincompany/blocs/blocListTask.dart';
import 'package:joincompany/blocs/blocListTaskCalendar.dart';
import 'package:joincompany/blocs/blocListTaskFilter.dart';
import 'package:joincompany/models/CustomerModel.dart';
import 'package:joincompany/models/TaskModel.dart';
import 'package:joincompany/models/UserDataBase.dart';
import 'package:joincompany/models/WidgetsList.dart';
import 'package:joincompany/pages/FormTaskNew.dart';
import 'package:joincompany/services/TaskService.dart';
import 'package:loadmore/loadmore.dart';
import 'package:sentry/sentry.dart';


import '../../main.dart';
import 'package:flutter/services.dart';
class TaskHomeTask extends StatefulWidget {

  TaskHomeTask({this.blocListTaskFilterReswidget,this.blocListTaskCalendarReswidget,this.listCalendarRes});

  final BlocListTaskFilter blocListTaskFilterReswidget;
  final BlocListTaskCalendar blocListTaskCalendarReswidget;
  final List<DateTime> listCalendarRes;

  _MytaskPageTaskState createState() => _MytaskPageTaskState();
}

class _MytaskPageTaskState extends State<TaskHomeTask> {
  ListWidgets ls = ListWidgets();
  bool viewList = false;
  UserDataBase userActivity;
  static LatLng _initialPosition;
  List<TaskModel> listTaskModellocal;
  List<bool> listTaskModellocalbool;
  String filterText = '';
  List<DateTime> listCalendar = new List<DateTime>();
  BlocListTaskFilter bloctasksFilter;
  BlocListTaskCalendar blocListTaskCalendarRes;
  BlocListTask blocList;
  List<DateTime> listCalender = new List<DateTime>();
  CustomerWithAddressModel directionClient = CustomerWithAddressModel();
  SentryClient sentry;


  @override
  void initState() {
    _getUserLocation();
    listTaskModellocal = new List<TaskModel>();
    listTaskModellocalbool = new List<bool>();
    listCalendar = widget.listCalendarRes;
    actualizarusuario();
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  actualizarusuario() async {
    userActivity = await ClientDatabaseProvider.db.getCodeId('1');

    pageTasks = 1;
    if (this.mounted) {
      setState(() {
        userActivity;
        listCalender = widget.listCalendarRes;
      });
    }
  }

  @override
  void dispose() {
    bloctasksFilter.dispose();
    blocListTaskCalendarRes.dispose();
    blocList.dispose();
    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }


  @override
  Widget build(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context); //HORIZONTAL
    double aument = 0.7;
    if (mediaQueryData.orientation == Orientation.portrait) { //VERTICAL
      aument = 0.8;
    }

    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * aument,
      child: Scaffold(
        body:
        Stack(
          children: <Widget>[
            listViewTasks(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () {
              TaskModel taskk = new TaskModel();
              Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context) => FormTask(directionClient: directionClient,toBusiness: false,toListTask: false,taskmodelres: taskk)));
              //Navigator.pushNamed(context, '/formularioTareas');
            }),
      ),
    );
  }

  listViewTasks() {
    //BLOCK CALENDARIO
    blocListTaskCalendarRes = widget.blocListTaskCalendarReswidget;
    try {
      if (this.mounted){
        setState(() {
          // ignore: cancel_subscriptions
          StreamSubscription streamSubscriptionCalendar = blocListTaskCalendarRes
              .outTaksCalendar.listen((onData) =>
              setState(() {
                listTaskModellocal.clear();
                listTaskModellocalbool.clear();
                pageTasks = 1;
                listCalendar = onData;
                //getdatalist(onData[1],onData[0],1);
              }));
        });
      }
    } catch (e) {}

    //BLOCK LISTA
    blocList = new BlocListTask(listCalendar[1], listCalendar[0], pageTasks);
    try {
      if (this.mounted) {
        setState(() {
          // ignore: cancel_subscriptions
          StreamSubscription streamSubscriptionList = blocList.outListTaks
              .listen((onDataList) =>
              setState(() {
                //if(PageTasks == 1){
                listTaskModellocal = onDataList;
                //}
                if (onDataList.length != 0) {
                  chanceCircule = true;
                  for (int cantlistTaskModellocal = 0; cantlistTaskModellocal <
                      onDataList.length; cantlistTaskModellocal++) {
                    listTaskModellocalbool.add(
                        onDataList[cantlistTaskModellocal].status.contains(
                            'done'));
                  }
                } else {
                  LastCircule();
                }
              }));
        });
      }
    } catch (e) {}
    try {
      if (this.mounted) {
        setState(() {
          // ignore: cancel_subscriptions
          StreamSubscription streamSubscriptionListToal = blocList.outListTaksTotal.listen((onDataListTotal) => setState(() { taskTotals = onDataListTotal; }));
        });
      }
    } catch (e) {}

    //BLOCK FILTRO
    bloctasksFilter = widget.blocListTaskFilterReswidget;
    try {
      if (this.mounted) {
        setState(() {
          // ignore: cancel_subscriptions
          StreamSubscription streamSubscriptionFilter = bloctasksFilter.outTaksFilter.listen((newVal) => setState(() {filterText = newVal;}));
        });
      }
    } catch (e) {}

    return ((listTaskModellocal.length != 0)) ?

    Container(
      child: RefreshIndicator(
        child: LoadMore(
          isFinish: countTaskList >= taskTotals,
          onLoadMore: _loadMore,
          child: listando(),
          whenEmptyLoad: false,
          delegate: DefaultLoadMoreDelegate(),
          textBuilder: DefaultLoadMoreTextBuilder.english,
        ),
        onRefresh: _refresh,
      ),
    )
    //listando()
        : chanceCircule
        ? Center(child: CircularProgressIndicator(),)
        : Container(
      child: Center(
        child: Text("No existen tareas."),
      ),
    );
  }


  bool chanceCircule = true;

  LastCircule() async {
    await Future.delayed(Duration(seconds: 6, milliseconds: 0));
    if (this.mounted){
      setState(() {
        chanceCircule = false;
      });
    }
  }

  int taskTotals = 0;

//  int get countTaskList => listTaskModellocal.length;
  int get countTaskList => listTaskModellocal.length;

  Future<bool> _loadMore() async {
    if (this.mounted) {
      setState(() {
        pageTasks++;
      });
    }

    await Future.delayed(Duration(seconds: 0, milliseconds: 5000));
    //getdatalist(listCalendar[1],listCalendar[0],PageTasks);
    return true;
  }

  Future<void> _refresh() async {
    await Future.delayed(Duration(seconds: 0, milliseconds: 2000));
    if (this.mounted) {
      setState(() {
        pageTasks = 1;
        listCalendar;
        listTaskModellocal.clear();
      });
    }
    //getdatalist(listCalendar[1],listCalendar[0],1);
  }

  int pageTasks = 1;

  listando() {
    String dateTask = "1990-05-05 20:00:04Z";
    return ListView.builder(
        itemCount: listTaskModellocal.length,
        itemBuilder: (BuildContext context, int index) {
          int positionActual = index;
          String voidFieldMessage = "";

          var date;
          var title;
          var address;
          var customerName;

          if (listTaskModellocal[positionActual].customer == null) {
            customerName = voidFieldMessage;
          } else {
            customerName = listTaskModellocal[positionActual].customer.name;
          }

          if (listTaskModellocal[positionActual].createdAt == null) {
            date = voidFieldMessage;
          } else {
            if(listTaskModellocal[positionActual].planningDate == null){
              date = listTaskModellocal[positionActual].createdAt.substring(10, 16);
            }else{
              date = listTaskModellocal[positionActual].planningDate.substring(10, 16);
            }

          }

          if (listTaskModellocal[positionActual].name == null) {
            title = voidFieldMessage;
          } else {
            title = listTaskModellocal[positionActual]
                .name /*+ ' - ' + listTaskModellocal[PosicionActual].id.toString()*/;
          }

          if (listTaskModellocal[positionActual].address == null) {
            address = voidFieldMessage;
          } else {
            if (listTaskModellocal[positionActual].address.address == null) {
              address = voidFieldMessage;
            } else {
              address = customerName + ',  ' +
                  listTaskModellocal[positionActual].address.address;
            }
          }

          if (filterText == '') {
            bool res = false;

            if ((positionActual != listTaskModellocal.length - 1)) {
              if (listTaskModellocal[positionActual].id ==
                  listTaskModellocal[positionActual + 1].id) {
                res = true;
              }
            }

            String dateTitulo = "";
            if(listTaskModellocal[positionActual].planningDate == null){
              dateTitulo = DateTime.parse(listTaskModellocal[positionActual].createdAt).day.toString() + ' de ' + intsToMonths[DateTime.parse(listTaskModellocal[positionActual].createdAt)
                  .month.toString()] + ' ' + DateTime.parse(listTaskModellocal[positionActual].createdAt).year.toString();
            }else{
              dateTitulo = DateTime
                  .parse(listTaskModellocal[positionActual].planningDate)
                  .day.toString() + ' de ' + intsToMonths[DateTime.parse(listTaskModellocal[positionActual].planningDate).month.toString()] + ' ' + DateTime.parse(listTaskModellocal[positionActual].planningDate).year.toString();
            }

            var padding = 16.0;
            double por = 0.1;
            if (MediaQuery.of(context).orientation == Orientation.portrait) {
              por = 0.07;
            }


            if(listTaskModellocal[positionActual].planningDate == null){
              if ((DateTime.now().day == DateTime.parse(listTaskModellocal[positionActual].createdAt).day) &&
                  (DateTime.now().month == DateTime.parse(listTaskModellocal[positionActual].createdAt).month) &&
                  (DateTime.now().year == DateTime.parse(listTaskModellocal[positionActual].createdAt).year)) {
                dateTitulo = 'Hoy, ' + dateTitulo;
              }
            }else{
              if ((DateTime.now().day == DateTime.parse(listTaskModellocal[positionActual].planningDate).day) &&
                  (DateTime.now().month == DateTime.parse(listTaskModellocal[positionActual].planningDate).month) &&
                  (DateTime.now().year == DateTime.parse(listTaskModellocal[positionActual].planningDate).year)) {
                dateTitulo = 'Hoy, ' + dateTitulo;
              }
            }

            return res ?
            Container(
              padding: EdgeInsets.only(
                  left: padding, right: 0, top: padding, bottom: 0),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * por,
              color: PrimaryColor,
              child: Text(dateTitulo, style: TextStyle(
                  fontSize: 16, color: Colors.white)),
            ) :
            listCard(title, address, date, listTaskModellocal[positionActual],
                positionActual);
          } else {


            if (ls.createState().checkSearchInText(title, filterText) ||
                ls.createState().checkSearchInText(address, filterText) ||
                ls.createState().checkSearchInText(customerName, filterText)) {

              DateTime DateSearch;
              if(listTaskModellocal[positionActual].planningDate == null){
                DateSearch = DateTime.parse(listTaskModellocal[positionActual].createdAt);
              }else{
                DateSearch = DateTime.parse(listTaskModellocal[positionActual].planningDate);
              }


              if ((DateTime.parse(dateTask).day != DateSearch.day) ||
                  (DateTime.parse(dateTask).month != DateSearch.month) ||
                  (DateTime.parse(dateTask).year != DateSearch.year)) {

                if(listTaskModellocal[positionActual].planningDate == null){
                  dateTask = listTaskModellocal[positionActual].createdAt;
                }else{
                  dateTask = listTaskModellocal[positionActual].planningDate;
                }

                String dateTitulo = DateSearch.day.toString() + ' de ' + intsToMonths[DateSearch.month.toString()] + ' ' + DateSearch.year.toString();

                var padding = 16.0;
                double por = 0.1;
                if (MediaQuery
                    .of(context)
                    .orientation == Orientation.portrait) {
                  por = 0.07;
                }

                if ((DateTime.now().day == DateSearch.day) &&
                    (DateTime.now().month == DateSearch.month) &&
                    (DateTime.now().year == DateSearch.year)) {
                  dateTitulo = 'Hoy, ' + dateTitulo;
                }
                return Container(
                  child: Column(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(
                            left: padding, right: 0, top: padding, bottom: 0),
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * por,
                        color: PrimaryColor,
                        child: Text(dateTitulo, style: TextStyle(
                            fontSize: 16, color: Colors.white)),
                      ),
                      listCard(title, address, date,
                          listTaskModellocal[positionActual], positionActual),
                    ],
                  ),
                );
              } else {
                return listCard(
                    title, address, date, listTaskModellocal[positionActual],
                    positionActual);
              }
            } else {
              return Container();
            }
          }
        }
    );
  }

  Container listCard(String title, String address, String date,TaskModel listTask, int index) {
    return Container(
        child: Card(
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16, right: 16),
                      child: Text(title, style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  Checkbox(
                    value: listTaskModellocal[index].status.contains('done'),
                    onChanged: (bool value) async {
                      if (value) {
                        if (this.mounted) {
                          setState(() {
                            listTaskModellocal[index].status = 'working';
                          });
                        }
                        var checkInTaskResponse = await checkOutTask(
                            listTask.id.toString(), userActivity.company,
                            userActivity.token,
                            _initialPosition.latitude.toString(),
                            _initialPosition.longitude.toString(), '0');
                        if (checkInTaskResponse.statusCode != 200) {
                          if (this.mounted) {
                            setState(() {
                              listTaskModellocal[index].status = 'done';
                            });
                          }
                        }
                      } else {
                        if (this.mounted) {
                          setState(() {
                            listTaskModellocal[index].status = 'done';
                          });
                        }
                        var checkInTaskResponse = await checkInTask(
                            listTask.id.toString(), userActivity.company,
                            userActivity.token,
                            _initialPosition.latitude.toString(),
                            _initialPosition.longitude.toString(), '0');
                        if (checkInTaskResponse.statusCode != 200) {
                          if (this.mounted) {
                            setState(() {
                              listTaskModellocal[index].status = 'working';
                            });
                          }
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
                      padding: const EdgeInsets.only(left: 16, right: 16),
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
                          deleteCustomer(listTask.id.toString(), index);
                        }
                    ),
                  ),
                  Container(
                    child: IconButton(
                        icon: Icon(Icons.remove_red_eye,size: 20,),
                        onPressed: () {
                          String idTask = '',idAddress ='',nameAddress='',customerName='';
                          if(listTask.customerId != null){idTask = listTask.customerId.toString();}
                          if(listTask.addressId != null){idAddress = listTask.addressId.toString();}
                          if(listTask.address != null){nameAddress = listTask.address.address.toString();}
                          if(listTask.customer != null){customerName = listTask.customer.name.toString();}

                          CustomerWithAddressModel custoWandress = new CustomerWithAddressModel();
                          if(listTask.customerId != null){
                            custoWandress = new CustomerWithAddressModel(
                              id: int.parse(idTask),// listTask.customerId,
                              addressId: int.parse(idAddress), //listTask.addressId,
                              address: nameAddress,//listTask.address.address,
                              name: customerName,//listTask.customer.name,
                            );
                          }
                          Navigator.push(context,new MaterialPageRoute(builder: (BuildContext context) => FormTask(directionClient: custoWandress,taskmodelres: listTask,toListTask: true,toBusiness: false,)));
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
    await deleteTask(taskID, userActivity.company, userActivity.token);
  }

  void _getUserLocation() async {
    Position position = await Geolocator().getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    // List<Placemark> placemark = await Geolocator().placemarkFromCoordinates(position.latitude, position.longitude);
    if (this.mounted) {
      setState(() {
        _initialPosition = LatLng(position.latitude, position.longitude);
      });
      try {
        Position position = await Geolocator().getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        List<Placemark> placemark = await Geolocator().placemarkFromCoordinates(
            position.latitude, position.longitude);
        if (this.mounted) {
          setState(() {
            _initialPosition = LatLng(position.latitude, position.longitude);
          });
        }
      } catch (error, stackTrace) {
        await sentry.captureException(
          exception: error,
          stackTrace: stackTrace,
        );
      }
    }
  }

    Map<String, String> intsToMonths = {
      '1': 'Enero',
      '2': 'Febrero',
      '3': 'Marzo',
      '4': 'Abril',
      '5': 'Mayo',
      '6': 'Junio',
      '7': 'Julio',
      '8': 'Agosto',
      '9': 'Septiembre',
      '10': 'Octubre',
      '11': 'Noviembre',
      '12': 'Diciembre',
    };
  }


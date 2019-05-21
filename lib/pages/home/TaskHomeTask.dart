
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:joincompany/Sqlite/database_helper.dart';
import 'package:joincompany/blocs/blocListTask.dart';
import 'package:joincompany/models/AddressModel.dart';
import 'package:joincompany/models/TaskModel.dart';
import 'package:joincompany/models/UserDataBase.dart';
import 'package:joincompany/services/TaskService.dart';

import '../../main.dart';

class taskHomeTask extends StatefulWidget {
  _MytaskPageTaskState createState() => _MytaskPageTaskState();
}

class _MytaskPageTaskState extends State<taskHomeTask> {

  bool MostrarLista = false;
  UserDataBase UserActiv;
  static LatLng _initialPosition;

  @override
  void initState() {
    listTaskModellocal = new List<TaskModel>();
    actualizarusuario();
    _getUserLocation();
    super.initState();
  }

  @override
  void dispose(){
    super.dispose();
  }

  bool _checked = false;
  Widget returnCheckedCheckBox(){

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
              Navigator.pushReplacementNamed(context, '/formularioTareas');

            }),
      ),
    );
  }

  String DateTask = "2019-05-05 20:00:04Z";
  List<TaskModel> listTaskModellocal;

  ListViewTareas(){
    blocListTask bloctasks = new blocListTask();

    try{
      // ignore: cancel_subscriptions
      StreamSubscription streamSubscription = bloctasks.outListTaks.listen((newVal)
      => setState((){
        listTaskModellocal = newVal;
      }));

    }catch(e){ }

    return ListView.builder(
        itemCount: listTaskModellocal.length,
        itemBuilder: (BuildContext context, int index) {

          int PosicionActual = listTaskModellocal.length - index - 1;

          String _date = listTaskModellocal[PosicionActual].createdAt;
          String _title = listTaskModellocal[PosicionActual].name;
          AddressModel _address = listTaskModellocal[PosicionActual].address;
          String voidFieldMessage = "Desconocido";

          var date;
          var title;
          var address;

          if (_date == null) {
            date = voidFieldMessage;
          } else {
            date = _date.substring(10,16);
          }

          if (_title == null) {
            title = voidFieldMessage;
          } else {
            title = _title;
          }

          if (_address == null) {
            address = voidFieldMessage;
          } else {
            if (_address.address == null) {
              address = voidFieldMessage;
            } else {
              address = _address.address;
            }
          }

          if((DateTime.parse(DateTask).day != DateTime.parse(listTaskModellocal[PosicionActual].createdAt).day)||
              (DateTime.parse(DateTask).month != DateTime.parse(listTaskModellocal[PosicionActual].createdAt).month)||
              (DateTime.parse(DateTask).year != DateTime.parse(listTaskModellocal[PosicionActual].createdAt).year)){
            DateTask = listTaskModellocal[PosicionActual].createdAt;
            String dateTitulo = DateTime.parse(listTaskModellocal[PosicionActual].createdAt).day.toString() + ' de ' + intsToMonths[DateTime.parse(listTaskModellocal[PosicionActual].createdAt).month.toString()] + ' ' + DateTime.parse(listTaskModellocal[PosicionActual].createdAt).year.toString();

            var padding = 16.0;
            double por = 0.1;
            if (MediaQuery.of(context).orientation == Orientation.portrait) {
              por = 0.07;
            }
            return Container(
              child: Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(left: padding, right: 0, top: padding, bottom: 0),
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * por,
                    color: PrimaryColor,
                    child: Text(dateTitulo, style: TextStyle(fontSize:16, color: Colors.white)),
                  ),
                  ListCard(title,address,date,listTaskModellocal[PosicionActual]),
                ],
              ),
            );
          }else{
            return ListCard(title,address,date,listTaskModellocal[PosicionActual]);
          }
        }
    );
  }

  Container ListCard(String title, String address, String date,TaskModel listTask){

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
                        var getAllTasksResponse = await checkInTask(listTask.id.toString(),UserActiv.company,UserActiv.token,_initialPosition.latitude.toString(),_initialPosition.longitude.toString(),'0');
                      }else{
                        var getAllTasksResponse = await checkOutTask(listTask.id.toString(),UserActiv.company,UserActiv.token,_initialPosition.latitude.toString(),_initialPosition.longitude.toString(),'0');
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
                        onPressed: (){
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

  actualizarusuario() async{
    UserActiv = await ClientDatabaseProvider.db.getCodeId('1');
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



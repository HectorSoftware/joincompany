
import 'package:flutter/material.dart';
import 'package:joincompany/blocs/blocListTask.dart';
import 'package:joincompany/models/AddressModel.dart';
import 'package:joincompany/models/TaskModel.dart';

import '../../main.dart';

class taskHomeTask extends StatefulWidget {
  _MytaskPageTaskState createState() => _MytaskPageTaskState();
}

class _MytaskPageTaskState extends State<taskHomeTask> {

  bool MostrarLista = false;

  @override
  void initState() {
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

    String fechaHoy = DateTime.now().day.toString()+ ' ' + obtenerMes(DateTime.now().month.toString())+ ' ' +DateTime.now().year.toString();

    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * aument,
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            /*MostrarLista ? ListViewTareas() :
            Container(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),*/
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
  ListViewTareas(){
    blocListTask bloctasks = new blocListTask();
    return StreamBuilder<List<Task>>(
      stream: bloctasks.outListTaks,
      initialData: <Task>[],
      builder: (context, snapshot){

        var withinCardPadding = 2.0;

        if(snapshot.data.isNotEmpty){
          return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {
                String _date = snapshot.data[index].createdAt;
                String _title = snapshot.data[index].name;
                Address _address = snapshot.data[index].address;
                String voidFieldMessage = "Unknown";

                var date;
                var title;
                var address;

                if (_date == null) {
                  date = voidFieldMessage;
                } else {
                  date = _date;
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

                if((DateTime.parse(DateTask).day != DateTime.parse(snapshot.data[index].createdAt).day)||
                    (DateTime.parse(DateTask).month != DateTime.parse(snapshot.data[index].createdAt).month)||
                    (DateTime.parse(DateTask).year != DateTime.parse(snapshot.data[index].createdAt).year)){
                  DateTask = snapshot.data[index].createdAt;
                  String date = DateTime.parse(snapshot.data[index].createdAt).day.toString() + ' ' + obtenerMes(DateTime.parse(snapshot.data[index].createdAt).day.toString()) + ' ' + DateTime.parse(snapshot.data[index].createdAt).year.toString();

                  var padding = 25.0;
                  return Container(
                    child: Column(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(left: padding, right: padding, top: padding, bottom: padding),
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * 0.1,
                          color: PrimaryColor,
                          child: Text(date, style: TextStyle(fontSize:16, color: Colors.white)),
                        ),
                        Container(

                        )
                      ],
                    ),
                  );
                }else{
                  return Container(
                    child: Column(
                      children: <Widget>[
                        Card(
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  children: <Widget>[
                                    Container(
                                      child: Column(
                                        children: <Widget>[
                                          Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                          Text(address, style: TextStyle(fontSize: 10)),
                                          IconButton(icon: Icon(Icons.delete), onPressed: (){}),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                children: <Widget>[
                                  Checkbox(value: false, tristate: false),
                                  Text(date),
                                  Container(),
                                ],
                              )
                            ],
                          ),
                        )
                      ]
                    )
                  );
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

      },
    );
  }

  String obtenerMes(String mes){
    if(mes == '1'){return 'Enero';}
    if(mes == '2'){return 'Febrero';}
    if(mes == '3'){return 'Marzo';}
    if(mes == '4'){return 'Abril';}
    if(mes == '5'){return 'Mayo';}
    if(mes == '6'){return 'Junio';}
    if(mes == '7'){return 'Julio';}
    if(mes == '8'){return 'Agosto';}
    if(mes == '9'){return 'Septiembre';}
    if(mes == '10'){return 'Octubre';}
    if(mes == '11'){return 'Noviembre';}
    if(mes == '12'){return 'Diciembre';}
    return 'Hoy';
  }
}



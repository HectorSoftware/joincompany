import 'package:flutter/material.dart';
import 'package:joincompany/main.dart';
import 'package:joincompany/models/BuildViewClass.dart';
import 'dart:async';
class FormTask extends StatefulWidget {
  

  @override
  _FormTaskState createState() => new _FormTaskState();

}
class _FormTaskState extends State<FormTask> {

  DateTime _date = new DateTime.now();
  TimeOfDay _time = new TimeOfDay.now();

  List<Widget> listWidget = List<Widget>();
  List<String> listElement = List<String>();
  List<WidgetBuild> listnew = List<WidgetBuild>();

@override

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
       appBar: AppBar(
         elevation: 12,
         backgroundColor: PrimaryColor,
         actions: <Widget>[
           Container(
             child: Row(
               children: <Widget>[
                 Container(
                   width: MediaQuery.of(context).size.width,
                   height: MediaQuery.of(context).size.height,
                   child: Row(
                     children: <Widget>[
                       Padding(
                         padding: const EdgeInsets.only(right: 10),
                         child: IconButton(
                           icon: Icon(Icons.arrow_back),
                           color: Colors.white,
                           disabledColor: Colors.white,
                           iconSize: 30,
                           tooltip: 'Atras',
                           onPressed: (){
                             Navigator.pushReplacementNamed(context, '/vistap');
                             //AGREGAR FUNCION GUARDE Y ENVIE FORMULARIO
                           },
                         ),
                       ),
                       Padding(
                         padding: const EdgeInsets.only(right: 150,top: 5),
                         child: Text('Agregar tareas',
                           style:TextStyle(
                               fontSize: 23
                           ) ,),
                       ),
                       Container(
                         child: IconButton(
                           icon: Icon(Icons.delete),
                           color: Colors.white,
                           disabledColor: Colors.white,
                           iconSize: 30,
                           tooltip: 'Eliminar Tarea',
                           onPressed: (){
                             //AGREGAR FUNCION ELIMINAR TAREA
                           },
                         ),
                       ),
                     ],
                   ),
                 ),

               ],
             ),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
           )

         ],
       ),

      body: dateTime(),


        //AQUI ABAJO VAN LOS BOTONES DEL FOOTER
     /* persistentFooterButtons: <Widget>[
        Container(

          child: RaisedButton(
            onPressed: () {
              expansionTile();
            },
              color: PrimaryColor,
            child: Padding(
              padding: const EdgeInsets.only(left: 320),
              child: Icon(
                Icons.keyboard_arrow_up,
                color: Colors.black,
                size: 35,
              ),
            ),

          ),
          width: MediaQuery.of(context).size.width*0.95,

        ),
      ],*/
    );

  }
  Widget ContruirLista()
  {
    return  StreamBuilder<Object>(
      stream: null,
      builder: (context, snapshot) {
        return ListView.builder
          (

            itemCount: listWidget.length,
            itemBuilder: (BuildContext context, int index) => buildBody(context, index)
        );
      }
    );
  }


  Widget buildBody(BuildContext context, int index) {

    return  Container(
        child: listWidget[index]);
  }
  TextField textField2 (){
    return TextField(
      maxLines: 3,
    );
  }


  Text text(){
    return Text('Titulo 1');
  }

Container container(){
    return Container(
      child: Column(
        children: <Widget>[
          text(),
          textField2(),


        ],
      ),
    );
}

//------------------------WIDGETS DES JSON-------------------------------------------

Widget textArea(){
  return
    //-------------------------------------TEXTAREA---------------
  Padding(
    padding: const EdgeInsets.only(top: 200,left: 20),
    child: Container(
      width: MediaQuery.of(context).size.width/1.2,
      height: 150,
      padding: EdgeInsets.only(
          top: 4,left: 16, right: 16, bottom: 4
      ),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(
              Radius.circular(20)
          ),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black12,
                blurRadius: 5
            )
          ]
      ),
      child: TextField(
        maxLines: 4,
        //controller: nameController,
        decoration: InputDecoration(

          border: InputBorder.none,

          hintText: '',
        ),
      ),
    ),
  );
}

Widget input(){
  //-----------------------------------------INPUT----------------------------------
  return Padding(
    padding: const EdgeInsets.only(top: 200,left: 20),
    child: Container(
      width: MediaQuery.of(context).size.width/1.2,
      height: 150,
      padding: EdgeInsets.only(
          top: 4,left: 16, right: 16, bottom: 4
      ),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(
              Radius.circular(20)
          ),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black12,
                blurRadius: 5
            )
          ]
      ),
      child: TextField(
        maxLines: 1,
        //controller: nameController,
        decoration: InputDecoration(

          border: InputBorder.none,

          hintText: '',
        ),
      ),
    ),
  );
}

Widget label(string){
  //------------------------------------LABEL----------------------------
  return Text(string);
}

Future<Null> selectDate(BuildContext context )async{
  final DateTime picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: new DateTime(2000),
      lastDate: new DateTime(2020));

  if(picked != null && picked != _date)
    {
      setState(() {
        _date = picked;
      });
    }

}
Widget date(){
  //------------------------------DATE--------------------------
  return RaisedButton(
    child: Text('Fecha: ${_date.toLocal()}'),
    onPressed: (){selectDate(context);},
  );
}

Future<Null> _selectTime(BuildContext context) async {
    final TimeOfDay picked = await showTimePicker(
        context: context,
        initialTime: _time
    );

    if(picked != null && picked != _time) {
      setState((){
        _time = picked;
      });
    }
  }
  Widget dateTime(){
    //------------------------------DATE------------------------
    return RaisedButton(
      child: Text('Hora: ${_time.format(context)}'),
      onPressed: (){_selectTime(context);},
    );
  }

}



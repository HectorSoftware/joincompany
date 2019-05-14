import 'package:flutter/material.dart';
import 'package:joincompany/blocs/bloc_task_form.dart';
import 'package:joincompany/main.dart';
import 'package:joincompany/models/BuildViewClass.dart';
import 'dart:async';
class FormTask extends StatefulWidget {
  

  @override
  _FormTaskState createState() => new _FormTaskState();

}
class _FormTaskState extends State<FormTask> {


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

        body:ContruirLista(context) ,


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
  Widget ContruirLista(context)
  {
   //
    final BlocTaskForm _Bloc = new BlocTaskForm(context);

    // ignore: cancel_subscriptions
    StreamSubscription streamSubscription = _Bloc.outListWidget.listen((newVal)
    => setState(() {

      print('/////////////////////');

      return  StreamBuilder<List<Widget>>(
          stream: _Bloc.outListWidget,
          builder: (context, snapshot) {
            print('*********1234*********');
            if (snapshot != null && snapshot.hasData) {
              print('*********hghf*********');
            }else{
              print('*********hgh5555f*********');
            }
            return Container();
            /*  return ListView.builder
          (

            itemCount: listWidget.length,
            itemBuilder: (BuildContext context, int index) => buildBody(context, index)
        );*/
          }
      );
    }));
  }

  Widget buildBody(BuildContext context, int index) {

    return  Container(
        child: listWidget[index]);
  }


}



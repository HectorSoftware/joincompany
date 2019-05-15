import 'package:flutter/material.dart';
import 'package:joincompany/blocs/bloc_task_form.dart';
import 'package:joincompany/main.dart';
import 'dart:async';
import 'package:joincompany/models/lista_widgets.dart';
class FormTask extends StatefulWidget {
  

  @override
  _FormTaskState createState() => new _FormTaskState();

}
class _FormTaskState extends State<FormTask> {


//  List<Widget> listWidget = List<Widget>();
  List<String> listElement = List<String>();
  List<Widget> listWidgetMain = List<Widget>();



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

        body:ContruirLista(context),


        //AQUI ABAJO VAN LOS BOTONES DEL FOOTER
     persistentFooterButtons: <Widget>[
        Container(

          child: RaisedButton(
            onPressed: () {
              //expansionTile();
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
      ],
    );

  }
  Widget ContruirLista(context)
  {
    ListWidgets items = new ListWidgets();
    final BlocTaskForm _bloc = new BlocTaskForm(context);
      return  StreamBuilder<List<dynamic>>(
          stream: _bloc.outListWidget,
          builder: (context, snapshot) {
            if (snapshot.hasError) return Text('Error: ${snapshot.error}');
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return Text('Not connected to the Stream or null');
              case ConnectionState.waiting:
                return Text('awaiting interaction');
              case ConnectionState.active:
                return ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (BuildContext context, int index) {
                      return new Container(
                        child: snapshot.data[index],
                      );
                    }
                );
                //return Text('Stream has started but not finished  ${snapshot.data.length}');
              case ConnectionState.done:
                return Text('Stream has finished');
            }
          }


      );

  }

  Widget buildBody(BuildContext context, int index) {

    return  Container(
        child: listWidgetMain[index],
    );
  }


}



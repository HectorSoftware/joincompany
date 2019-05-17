import 'package:flutter/material.dart';
import 'package:joincompany/blocs/BlocTypeTask.dart';
import 'package:joincompany/blocs/blocFaskForm.dart';
import 'package:joincompany/main.dart';
import 'dart:async';
import 'package:joincompany/models/WidgetsList.dart';
import 'package:joincompany/pages/BuscarRuta/BuscarDireccion.dart';
class FormTask extends StatefulWidget {
  

  @override
  _FormTaskState createState() => new _FormTaskState();

}
class _FormTaskState extends State<FormTask> {


//  List<Widget> listWidget = List<Widget>();
  List<String> listElement = List<String>();
  List<Widget> listWidgetMain = List<Widget>();
  bool changedView = false;



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

         width: MediaQuery.of(context).size.width * 0.96,
         child: BottomAppBar(
           color: PrimaryColor,
           child: new Row(
             mainAxisSize: MainAxisSize.max,
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: <Widget>[
               IconButton(
                 icon: Icon(Icons.menu),
                 onPressed: (){
                   _showModalDateTimeAndDirections();

                 },
               ),
               IconButton(
                   icon: Icon(Icons.business),
                   onPressed: () {
                     _showModal(context);
                   }
               ),

             ],
           ),
         ),
       )
      ],
    );

  }
  Widget ContruirLista(context)
  {
    final BlocTaskForm _bloc = new BlocTaskForm(context);
      return  StreamBuilder<List<dynamic>>(
          stream: _bloc.outListWidget,
          builder: (context, snapshot) {
            if (snapshot.hasError) return Text('Error: ${snapshot.error}');
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return Text('Not connected to the Stream or null');
              case ConnectionState.waiting:
                return Column(
                  children: <Widget>[
                    CircularProgressIndicator(),
                    Text('awaiting interaction'),
                  ],
                );
              case ConnectionState.active:
                return  ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    return new Container(
                      child: snapshot.data[index],
                    );
                  }
                ) ;
                //return Text('Stream has started but not finished  ${snapshot.data.length}');
              case ConnectionState.done:
                return Text('Stream has finished');
            }
          }


      );

  }



  void _showModal(context) {
    final BlocTaskForm _bloc = new BlocTaskForm(context);
      showModalBottomSheet<String>(
        context: context,
        builder: (BuildContext context) {

          return StreamBuilder<dynamic>(

            stream: _bloc.outListWidget,
            builder: (context, snapshot) {
              return new Column(

                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  new ListTile(
                    leading: new Icon(Icons.business),
                    title: new Text('Gestion Comercial'),
                    onTap: () {
                      _bloc.updateListWidget(context,'Gestion Comercial');
                      changedView = true;
                      setState(() {
                        changedView;
                      });
                      Navigator.pop(context);
                    },
                  ),
                  new ListTile(
                    leading: new Icon(Icons.subject),
                    title: new Text('Encuesta'),
                    onTap: () {
                      _bloc.updateListWidget(context,"Encuesta");
                      changedView = true;
                      setState(() {
                        changedView;
                      });
                      Navigator.pop(context);
                    },
                  ),
                  new ListTile(
                    leading: new Icon(Icons.label),
                    title: new Text('Tarea/ Nota Vacia'),
                    onTap: () {
                      _bloc.updateListWidget(context,'Nota Vacia');
                      Navigator.pop(context);
                    },
                  ),
                ],
              );
            }
          );
        });
  }

  void _showModalDateTimeAndDirections() {
    showModalBottomSheet<void>(
        context: context,
        builder: (BuildContext context) {
          return new Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new ListTile(
                leading: new Icon(Icons.location_on),
                title: new Text('Lugar'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SearchAddress()),
                  );

                },
              ),
              new ListTile(
                leading: new Icon(Icons.access_time),
                title: new Text('Hora'),
                onTap: () {

                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

}



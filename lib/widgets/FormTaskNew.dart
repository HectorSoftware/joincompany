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
  final BlocTaskForm _bloc = new BlocTaskForm(context);
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

        body:Stack(
          children: <Widget>[

             StreamBuilder<List<dynamic>>(
            stream: _bloc.outListWidget,
            builder: (context, snapshot) {
              if (snapshot.hasError) return Text('Error: ${snapshot.error}');
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                  return Text('Not connected to the Stream or null');
                case ConnectionState.waiting:
                  {
                    return Column(
                      children: <Widget>[
                        Center(
                          child: Column(
                            children: <Widget>[
                              Center(child: CircularProgressIndicator()),
                            ],
                          ),
                        ),
                        Text('awaiting interaction'),
                      ],
                    );
                  }
                case ConnectionState.active:
                  {

                    final data = snapshot.data;

                    return  ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (BuildContext context, int index) {
                          return new Container(
                            child: data[index],
                          );
                        }
                    ) ;
                  }

              // return Text('Stream has started but not finished  ${snapshot.data.length}');
                case ConnectionState.done:
                  return Text('Stream has finished');
              }
            }


        ),
          ],
        ),
      bottomNavigationBar: BottomAppBar(
        color: PrimaryColor,
        child: new Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.menu,color: Colors.white,),
              onPressed: (){
                _showModalDateTimeAndDirections();

              },
            ),
            IconButton(
                icon: Icon(Icons.business,color: Colors.white,),
                onPressed: () {
                  showModalBottomSheet<String>(
                      context: context,
                      builder: (BuildContext context) {
                              return new Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  new ListTile(
                                    leading: new Icon(Icons.business),
                                    title: new Text('Gestion Comercial'),
                                    onTap: () {
                                      _bloc.typeForm = 'Gestion Comercial';
                                      _bloc.updateListWidget(context);

                                      Navigator.pop(context);
                                    },
                                  ),
                                  new ListTile(
                                    leading: new Icon(Icons.subject),
                                    title: new Text('Encuesta'),
                                    onTap: () {
                                      _bloc.typeForm = 'Encuesta';
                                      _bloc.updateListWidget(context);
                                      Navigator.pop(context);
                                    },
                                  ),
                                  new ListTile(
                                    leading: new Icon(Icons.label),
                                    title: new Text('Tarea/ Nota Vacia'),
                                    onTap: () {
                                      _bloc.typeForm = 'Nota Vacia';
                                      _bloc.updateListWidget(context);
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              );
                            }
                        );

                }
            ),

          ],
        ),
      ),
    );

  }


 cl(_bloc){
  // ignore: cancel_subscriptions
  StreamSubscription streamSubscription = _bloc.outListWidget.listen((newVal)
  => setState((){
    print(newVal);

  }));
}

  void _showModal(context) {
    final BlocTaskForm _bloc = new BlocTaskForm(context);

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



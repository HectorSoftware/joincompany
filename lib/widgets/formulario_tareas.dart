import 'package:flutter/material.dart';
import 'package:joincompany/main.dart';
import 'package:joincompany/models/BuildViewClass.dart';

class FormTask extends StatelessWidget {

  List<Widget> listWidget = List<Widget>();
  List<String> listElement = List<String>();
  List<ViewClass> listClass = List<ViewClass>();
  ViewClass elementAdd;

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
     body: Column(
       children: <Widget>[
         Container(
         child: container(),
         ),


       ],
     ),
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

  TextField textField (){
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
          textField(),


        ],
      ),
    );
}

Widget buildView(){

    listElement.add('text');
    listElement.add('container');
    listElement.add('textfield');
    
    listWidget.add(text());
    listWidget.add(textField());
    listWidget.add(container());


    return Stack(
      children: <Widget>[

      ],



    );



}

}


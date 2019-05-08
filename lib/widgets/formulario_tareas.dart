import 'package:flutter/material.dart';
import 'package:joincompany/main.dart';

class FormTask extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
       appBar: AppBar(
         elevation: 12,
         backgroundColor: PrimaryColor,
         actions: <Widget>[
           Padding(
             padding: const EdgeInsets.only(right: 25),
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
             padding: const EdgeInsets.only(right: 120,top: 12),
             child: Text('Agregar tareas',
               style:TextStyle(
                 fontSize: 23
               ) ,),
           ),
           IconButton(
             icon: Icon(Icons.delete),
             color: Colors.white,
             disabledColor: Colors.white,
             iconSize: 30,
             tooltip: 'Eliminar Tarea',
             onPressed: (){
               //AGREGAR FUNCION ELIMINAR TAREA
             },
           ),
         ],
       ),

      body: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 480,left: 10),
            child: RaisedButton(
              color: PrimaryColor,
              child: Text('label'),
              onPressed: (){

              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 480,left: 100),
            child: RaisedButton(
              color: PrimaryColor,
              child: Text('texarea'),
              onPressed: (){

              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 480,left: 200),
            child: RaisedButton(
              color: PrimaryColor,
              child: Text('datatime'),
              onPressed: (){

              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 480,left: 300),
            child: RaisedButton(
              color: PrimaryColor,
              child: Text('Input Text'),
              onPressed: (){

              },
            ),
          ),
        ],
      ),

    );
  }

  TextField textField(){
    return TextField(

    );
  }

}
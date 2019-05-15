import 'package:flutter/material.dart';
import 'package:joincompany/main.dart';
import 'package:joincompany/pages/LoginPage.dart';
import 'package:joincompany/pages/home/taskHome.dart';
import 'package:joincompany/widgets/Formulario_clientes.dart';

class Cliente extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return new Scaffold(

      appBar: AppBar(
        title: Text('Clientes'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
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
              Container(),
            ]
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          elevation: 12,
          backgroundColor: PrimaryColor,
          tooltip: 'Agregar Tarea',
          onPressed: (){
            Navigator.push(
                context,
                new MaterialPageRoute(
                    builder: (BuildContext context) => new  AddClient()));

          },

        ),
    );

  }
}
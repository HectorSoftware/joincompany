import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class ConfigCli extends StatefulWidget {
  @override
  _ConfigCliState createState() => _ConfigCliState();
}

class _ConfigCliState extends State<ConfigCli> {

  String a;

  Widget customTextField(String title, String savedData,int maxLines){
    return Container(
      margin: EdgeInsets.all(12.0),
      color: Colors.grey.shade300,
      child: TextFormField(
        maxLines: maxLines,
        textInputAction: TextInputAction.next,
        validator: (value){
          //TODO
        },
        onSaved: (value){
          savedData = value;
        },
        decoration: InputDecoration(
          hintText: title,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Configuracion"),
        automaticallyImplyLeading: true,
      ),
      body:SingleChildScrollView(
          child: Column(
            children: <Widget>[
              customTextField("Nombre",a,1),
              customTextField("Codigo",a,1),
              customTextField("????",a,1),
              customTextField("Cargo",a,1),
              customTextField("Telefono fijo",a,1),
              customTextField("Telefono movil",a,1),
              customTextField("Emails",a,1),
              customTextField("Notas",a,4),
              customTextField("Contraseña",a,1),
              customTextField("Repetir Contraseña",a,1),
            ],
          ),
        ),
    );
  }
}
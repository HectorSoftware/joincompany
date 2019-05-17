import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

enum type{
  NAME,
  CODE,
  DEFAULT,
  POSITIONS,
  TLF_F,
  TLF_M,
  EMAIL,
  NOTE,
  PASSWORD,
}

class ConfigCli extends StatefulWidget {
  @override
  _ConfigCliState createState() => _ConfigCliState();
}

class _ConfigCliState extends State<ConfigCli> {

  String a;

  void setDataForm(String data, type t){

  }

  Widget customTextField(String title, type t, int maxLines){
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
          setDataForm(value, t);
        },
        decoration: InputDecoration(
          hintText: title,
          border: InputBorder.none
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
              customTextField("Nombre",type.NAME,1),
              customTextField("Codigo",type.CODE,1),
              customTextField("????",type.DEFAULT,1),
              customTextField("Cargo",type.POSITIONS,1),
              customTextField("Telefono fijo",type.TLF_F,1),
              customTextField("Telefono movil",type.TLF_M,1),
              customTextField("Emails",type.EMAIL,1),
              customTextField("Notas",type.NOTE,4),
              customTextField("Contraseña",type.PASSWORD,1),
              customTextField("Repetir Contraseña",type.PASSWORD,1),
            ],
          ),
        ),
    );
  }
}
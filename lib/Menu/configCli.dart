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

  //Const
  static const int linesInputsBasic = 1;
  static const int linesInputsTextAreaBasic = 4;

  String a;//TODO: implement model setData

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
              customTextField("Nombre",type.NAME,linesInputsBasic),
              customTextField("Codigo",type.CODE,linesInputsBasic),
              customTextField("????",type.DEFAULT,linesInputsBasic),
              customTextField("Cargo",type.POSITIONS,linesInputsBasic),
              customTextField("Telefono fijo",type.TLF_F,linesInputsBasic),
              customTextField("Telefono movil",type.TLF_M,linesInputsBasic),
              customTextField("Emails",type.EMAIL,linesInputsBasic),
              customTextField("Notas",type.NOTE,linesInputsTextAreaBasic),
              customTextField("Contraseña",type.PASSWORD,linesInputsBasic),
              customTextField("Repetir Contraseña",type.PASSWORD,linesInputsBasic),
            ],
          ),
        ),
    );
  }
}
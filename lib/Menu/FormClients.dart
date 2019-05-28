import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:joincompany/Menu/contactView.dart';
import 'package:joincompany/Sqlite/database_helper.dart';
import 'package:joincompany/main.dart';
import 'package:joincompany/models/CustomerModel.dart';
import 'package:joincompany/models/UserDataBase.dart';
import 'package:joincompany/pages/BuscarRuta/BuscarDireccion.dart';
import 'package:joincompany/services/CustomerService.dart';

import 'clientes.dart';

enum type{NAME,CODE,NOTE}


// ignore: must_be_immutable
class FormClient extends StatefulWidget {

  CustomerWithAddressModel client;

  FormClient(CustomerWithAddressModel client){
    this.client = client;
  }

  @override
  _FormClientState createState() => _FormClientState();
}

class _FormClientState extends State<FormClient> {

  Widget popUp;

  CustomerWithAddressModel client;

  TextEditingController name,code,note;
  String errorTextFieldName,errorTextFieldCode,errorTextFieldNote;

  Widget customTextField(String title, type t, int maxLines){
    return Container(
      margin: EdgeInsets.all(12.0),
      color: Colors.grey.shade300,
      child: TextField(
        controller: getController(t),
        maxLines: maxLines,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
            hintText: title,
            border: InputBorder.none,
            errorText: getErrorText(t),
        ),
        onChanged: _onChanges(t),
      ),
    );
  }

  String getErrorText(type t){
    switch(t){
      case type.NAME:{
        return errorTextFieldName;
      }
      case type.CODE:{
        return errorTextFieldCode;
      }
      case type.NOTE:{
        return errorTextFieldNote;
      }
    }
    return "";
  }

  _onChanges(type t){
    switch(t){
      case type.NAME:{
        setState(() {
          errorTextFieldName = '';
        });
        break;
      }
      case type.CODE:{
        setState(() {
          errorTextFieldCode = '';
        });
        break;
      }
      case type.NOTE:{
        setState(() {
          errorTextFieldNote = '';
        });
        break;
      }
    }
  }

  TextEditingController getController(type t){
    switch(t){
      case type.NAME:{
        return name;
      }
      case type.CODE:{
        return code;
      }
      case type.NOTE:{
        return note;
      }
    }
    return null;
  }

  void initData(){

    popUp =  AlertDialog(
      title: Text('¿Guardar?'),
      content: const Text(
          '¿estas seguro que desea guardar estos datos?'),
      actions: <Widget>[
        FlatButton(
          child: const Text('CANCELAR'),
          onPressed: () {
            Navigator.of(context).pop(false);
          },
        ),
        FlatButton(
          child: const Text('ACEPTAR'),
          onPressed: () {
            if(validateData()){
              savedData();
            }else{
              Navigator.of(context).pop(false);
            }
          },
        )
      ],
    );

    name = TextEditingController();
    code = TextEditingController();
    note = TextEditingController();

    if(widget.client != null){
        name.text = widget.client.name;
        code.text = widget.client.code;
        note.text = widget.client.details;
    }
  }

  Future<bool> _asyncConfirmDialog() async {
    if(widget.client != null){
      if(name.text == widget.client.name && code.text == widget.client.code){
        Navigator.of(context).pop(true);
      }else{
        return showDialog<bool>(
          context: context,
          barrierDismissible: false, // user must tap button for close dialog!
          builder: (BuildContext context) {
            return popUp;
          },
        );
      }
      if(name.text == '' && code.text == ''){
        Navigator.of(context).pop(true);
      }
    }else if(name.text == '' && code.text == ''){
      Navigator.of(context).pop(true);
    }else{
      return showDialog<bool>(
        context: context,
        barrierDismissible: false, // user must tap button for close dialog!
        builder: (BuildContext context) {
          return popUp;
        },
      );
    }
    return false;
  }

  void disposeController(){
    name.dispose();
    code.dispose();
    note.dispose();
  }

  void savedData() async {
     UserDataBase userAct = await ClientDatabaseProvider.db.getCodeId('1');
      if(validateData()){
        if(widget.client != null){
          CustomerModel client = CustomerModel(
            id: widget.client.id,
            name: name.text,
            code: code.text,
            details: note.text,
          );
          var response = await updateCustomer(client.id.toString(), client, userAct.company, userAct.token);

          if(response.statusCode == 200){
            Navigator.of(context).pop(true);
          }else{
            Navigator.of(context).pop(false);
          }

        }else{
          CustomerModel client = CustomerModel(
            name: name.text,
            code: code.text,
            details: note.text,
          );
          var response = await createCustomer(client, userAct.company, userAct.token);

          if(response.statusCode == 200){
            Navigator.of(context).pop(true);
          }else{
            Navigator.of(context).pop(false);
          }
        }
      }
  }

  bool validateData(){//TODO
    if(name.text == ''){
      setState(() {
        errorTextFieldName = 'Campo requerido';
      });
      return false;
    }
    if( code.text == ''){
      setState(() {
        errorTextFieldCode = 'Campo requerido';
      });
      return false;
    }else{
      return true;
    }
  }

  @override
  void dispose() {
    disposeController();
    super.dispose();
  }

  @override
  void initState() {
    initData();
    super.initState();
  }

  Future<bool> _asyncConfirmDialogDeleteUser() async {
    if(widget.client != null){
      return showDialog<bool>(
        context: context,
        barrierDismissible: false, // user must tap button for close dialog!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('ELIMINIAR'),
            content: const Text(
                '¿estas seguro que desea guardar estos datos?'),
            actions: <Widget>[
              FlatButton(
                child: const Text('CANCELAR'),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              FlatButton(
                child: const Text('ACEPTAR'),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              )
            ],
          );
        },
      );
    }
    return false;
  }

  void deleteCli()async{
    var resp = await  _asyncConfirmDialogDeleteUser();
    if(resp){
      UserDataBase userAct = await ClientDatabaseProvider.db.getCodeId('1');
      var responseDelete = await deleteCustomer( widget.client.id.toString(), userAct.company, userAct.token);
      bool eliminado = responseDelete.body == '1' ? true : false;


    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _asyncConfirmDialog,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Cliente'),
          elevation: 12,
          backgroundColor: PrimaryColor,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.delete),
              tooltip: 'Eliminar Cliente',
              iconSize: 25,
              onPressed: widget.client != null ? deleteCli:null,
            )
          ],
        ),
        body:SingleChildScrollView(
          child:Column(
            children: <Widget>[
              customTextField(" Nombre *",type.NAME,1),
              customTextField(" Codigo *",type.CODE,1),
              customTextField("Notas",type.NOTE,4),
              Container(
                margin: EdgeInsets.all(12.0),
                height: MediaQuery.of(context).size.height * 0.030,
                child:Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                  Text("Contacto"),
                  Row(
                    children: <Widget>[
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: Icon(Icons.add),
                        onPressed: (){
                          Navigator.of(context).pop();
                          Navigator.push(
                              context,
                              new MaterialPageRoute(
                                  builder: (BuildContext context) => new  ContactView()));
                        },
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: Icon(Icons.visibility),
                        onPressed: (){
                          Navigator.of(context).pop();
                          Navigator.push(
                              context,
                              new MaterialPageRoute(
                                  builder: (BuildContext context) => new  ContactView()));
                        },
                        ),
                      ),
                    ],
                    )
                  ],
                )
              ),//client
              Container(
                margin: EdgeInsets.all(12.0),
                height: MediaQuery.of(context).size.height * 0.030,
                child:Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                    Text("Direccion"),
                    Row(
                      children: <Widget>[
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: Icon(Icons.add),
                            onPressed: (){
                              Navigator.of(context).pop();
                              Navigator.push(
                                  context,
                                  new MaterialPageRoute(
                                      builder: (BuildContext context) => new  SearchAddress()));
                            },
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: Icon(Icons.visibility),
                            onPressed: (){
                              Navigator.of(context).pop();
                              Navigator.push(
                                  context,
                                  new MaterialPageRoute(
                                      builder: (BuildContext context) => new  SearchAddress()));
                            },
                          ),
                        ),
                      ],
                    )
                  ],
                  )
                ),//Direction
              Container(
                  height: MediaQuery.of(context).size.height * 0.030,
                  margin: EdgeInsets.all(12.0),
                  child:Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text("Negocios"),
                      Row(
                        children: <Widget>[
                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              icon: Icon(Icons.add),
                                onPressed: (){},
                              ),
                            ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                            icon: Icon(Icons.visibility),
                            onPressed: (){
                              //TODO
                            },
                            ),
                          ),
                        ],
                      )
                    ],
                  )
                ),//Negotiates
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:joincompany/Sqlite/database_helper.dart';
import 'package:joincompany/main.dart';
import 'package:joincompany/models/CustomerModel.dart';
import 'package:joincompany/models/UserDataBase.dart';
import 'package:joincompany/pages/BuscarRuta/BuscarDireccion.dart';
import 'package:joincompany/services/CustomerService.dart';

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
              Navigator.of(context).pop(true);
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
    if((name.text == '' && code.text == '') || name.text == widget.client.name && code.text == widget.client.code){
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
            name: widget.client.name,
            code: widget.client.code,
            details: widget.client.details,
          );
          var responseCreate = await updateCustomer(client.id.toString(), client, userAct.company, userAct.token);
          print(responseCreate.statusCode);
          print(responseCreate.body);
        }else{
          CustomerModel client = CustomerModel(
            name: name.text,
            code: code.text,
            details: note.text,
          );
          var responseCreate = await createCustomer(client, userAct.company, userAct.token);
          print(responseCreate.statusCode);
          print(responseCreate.body);
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
              iconSize: 35,
              onPressed: (){},
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
                        onPressed: (){},
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: Icon(Icons.visibility),
                        onPressed: (){},//TODO
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
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => SearchAddress()));
                            },
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: Icon(Icons.visibility),
                            onPressed: (){},
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
                            onPressed: (){},
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

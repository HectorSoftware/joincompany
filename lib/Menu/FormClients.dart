import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:joincompany/Sqlite/database_helper.dart';
import 'package:joincompany/main.dart';
import 'package:joincompany/models/CustomerModel.dart';
import 'package:joincompany/models/UserDataBase.dart';
import 'package:joincompany/services/CustomerService.dart';

enum type{
  NAME,
  CODE,
  NOTE,
}

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

  CustomerWithAddressModel client;

  TextEditingController name,code,note;

  void setDataForm(String data, type t){}

  Widget customTextField(String title, type t, int maxLines){
    return Container(
      margin: EdgeInsets.all(12.0),
      color: Colors.grey.shade300,
      child: TextFormField(
        controller: getController(t),
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
    name = TextEditingController();
    code = TextEditingController();
    note = TextEditingController();

    if(widget.client != null){
        name.text = widget.client.name;
        code.text = widget.client.code;
        note.text = widget.client.details;
    }
  }

  void disposeController(){
    name.dispose();
    code.dispose();
    note.dispose();
  }

  void savedData() async {
    UserDataBase userAct = await ClientDatabaseProvider.db.getCodeId('1');

    if(widget.client != null){
      //TODO: method update
    }else{
      CustomerModel client = CustomerModel(
        name: name.text,
        code: code.text,
        details: note.text,
      );
      var responseCreate = await createCustomer(client, userAct.company, userAct.token);
      print(responseCreate.body);
    }
  }

  bool validateData(){
    return true;// TODO;
  }

  @override
  void dispose() {
    savedData();
    disposeController();
    super.dispose();
  }

  void initState() {
    initData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
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
                                onPressed: (){

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
                                  showDialog(context: context,
                                      builder: (BuildContext contex){
                                        return AlertDialog(
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Text("TODO"),//TODO
                                            ],
                                          ),
                                        );
                                      }
                                  );
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
            )
        )
    );
  }
}

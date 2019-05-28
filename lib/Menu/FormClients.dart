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

  List<String> directions = List<String>();
  List<String> contacts = List<String>();

  TextEditingController name,code,note;
  String errorTextFieldName,errorTextFieldCode,errorTextFieldNote;

  Widget customTextField(String title, type t, int maxLines){
    return Container(
      margin: EdgeInsets.all(12.0),
      decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10)),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black12,
                blurRadius: 5
            )
          ]
      ),
      //color: Colors.grey.shade300,
      child: TextField(
        controller: getController(t),
        maxLines: maxLines,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
            hintText: title,
            border: InputBorder.none,
            errorText: getErrorText(t),
            contentPadding: EdgeInsets.all(12.0),
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
          child: const Text('SALIR'),
          onPressed: () {
            Navigator.of(context).pop(true);
          },
        ),
        FlatButton(
          child: const Text('ACEPTAR'),
          onPressed: () {
            Navigator.of(context).pop(false);
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
        return true;
      }else{
        if(name.text == '' && code.text == ''){
          return true;
        }
        return showDialog<bool>(
          context: context,
          barrierDismissible: false, // user must tap button for close dialog!
          builder: (BuildContext context) {
            return popUp;
          },
        );
      }

    }else if(name.text == '' && code.text == ''){
      return true;
    }else{
      return showDialog<bool>(
        context: context,
        barrierDismissible: true, // user must tap button for close dialog!
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

  Future<bool> savedData() async {
    bool resp = await _asyncConfirmDialog();
    if(resp){
      return true;
    }else{
      if(validateData()){
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
             return true;
            }else{
              return showDialog(
                  context: context,
                  barrierDismissible: true, // user must tap button for close dialog!
                  builder: (BuildContext context) {
                    return AlertDialog(
                        title: Text('Ha ocurrido un error')
                    );
                  }
              );
            }

          }else{
            CustomerModel client = CustomerModel(
              name: name.text,
              code: code.text,
              details: note.text,
            );
            var response = await createCustomer(client, userAct.company, userAct.token);

            if(response.statusCode == 200){
              return true;
            }else{
              return showDialog(
                  context: context,
                  barrierDismissible: true, // user must tap button for close dialog!
                  builder: (BuildContext context) {
                    return AlertDialog(
                        title: Text('Ha ocurrido un error')
                    );
                  }
              );
            }
          }
        }
      }else{
        return false;
      }
    }
    return false;
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
                '¿estas seguro que desea eliminar este cliente?'),
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

  Future<String> getDirections() async{
    return showDialog<String>(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return SearchAddress();
      },
    );
  }

  Future<String> getContact() async{
    return showDialog<String>(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return ContactView(true);
      },
    );
  }

  Future<String> getNegocios() async{
    return showDialog<String>(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return ContactView(true);
      },
    );
  }//TODO

  void exitDeletedClient()async{
    await Future.delayed(Duration(seconds: 0, milliseconds: 1000));
    Navigator.push(
        context,
        new MaterialPageRoute(
            builder: (BuildContext context) => Cliente()));
  }

  void deleteCli()async{
    var resp = await  _asyncConfirmDialogDeleteUser();
    if(resp){
      UserDataBase userAct = await ClientDatabaseProvider.db.getCodeId('1');
      var responseDelete = await deleteCustomer( widget.client.id.toString(), userAct.company, userAct.token);
      if(responseDelete.statusCode == 200){
        exitDeletedClient();
        return showDialog(
            context: context,
            barrierDismissible: true, // user must tap button for close dialog!
            builder: (BuildContext context) {
              return AlertDialog(
                  title: Text('Cliente eliminado')
              );
            }
        );
      }else{
        return showDialog(
            context: context,
            barrierDismissible: true, // user must tap button for close dialog!
            builder: (BuildContext context) {
              return AlertDialog(
                  title: Text('No se ha podido eliminar')
              );
            }
        );
      }


    }
  }

  Future<bool> exitFuture(bool exit)async{
    await Future.delayed(Duration(seconds: 0, milliseconds: 1000));
    return exit;
  }

  ListView getDirectionsBuilder() {
    return ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: directions.length,
        itemBuilder: (context, int index) {
          return Container(
            child: ListTile(
              leading: const Icon(Icons.location_on,
                  size: 25.0),
              title: Text(directions[index]),
              trailing: IconButton(icon: Icon(Icons.delete), onPressed: (){
                setState(() {
                  directions.remove(directions[index]);
                });
              }),
            ),
          );
        }
    );
  }

  ListView getContactBuilder() {
    return ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: contacts.length,
        itemBuilder: (context, int index) {
          return Container(
            child: ListTile(
              leading: const Icon(Icons.account_box,
                  size: 25.0),
              title: Text(contacts[index]),
              trailing: IconButton(icon: Icon(Icons.delete), onPressed: (){
                setState(() {
                  contacts.remove(contacts[index]);
                });
              }),
            ),
          );
        }
    );
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: savedData,
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
        body:Stack(
          children: <Widget>[
              SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    customTextField(" Nombre *",type.NAME,1),
                    customTextField(" Codigo *",type.CODE,1),
                    customTextField("Notas",type.NOTE,4),
                    Container(
                      margin: EdgeInsets.all(12.0),
                      height: MediaQuery.of(context).size.height *0.03,
                      child:Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text("Contacto"),
                          Row(
                            children: <Widget>[
                              IconButton(
                                  icon: Icon(Icons.add),
                                  onPressed: ()async{
                                    var contact = await getContact();
                                    if (contact != null){
                                      setState(() {
                                        contacts.add(contact);
                                      });
                                    }
                                  }
                              ),
                              IconButton(
                                  icon: Icon(Icons.visibility),
                                  onPressed: ()async{
                                    getContact();
                                  }
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      child: contacts.isNotEmpty ? Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * (0.1 * contacts.length),
                          child:getContactBuilder()): Container() ,
                    ),
                    Container(
                      margin: EdgeInsets.all(12.0),
                      height: MediaQuery.of(context).size.height *0.03,
                      child:Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text("Direccion"),
                          Row(
                            children: <Widget>[
                              IconButton(
                                  icon: Icon(Icons.add),
                                  onPressed: ()async{
                                    var resp = await getDirections();
                                    if(resp != null){
                                      setState(() {
                                        directions.add(resp);
                                      });
                                    }
                                  }
                              ),
                              IconButton(
                                  icon: Icon(Icons.visibility),
                                  onPressed: ()async{
                                    getDirections();
                                  }
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      child: directions.isNotEmpty ? Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * (0.1 * directions.length),
                          child:getDirectionsBuilder()): Container() ,

                    ),
                    Container(
                      margin: EdgeInsets.all(12.0),
                      height: MediaQuery.of(context).size.height *0.03,
                      child:Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text("Negocios"),
                          Row(
                            children: <Widget>[
                              IconButton(
                                  icon: Icon(Icons.add),
                                  onPressed: ()async{
                                    var resp = await getNegocios();
                                    directions.add(resp);
                                  }
                              ),
                              IconButton(
                                  icon: Icon(Icons.visibility),
                                  onPressed: ()async{
                                    getNegocios();
                                  }
                              )
                            ],
                          ),
                        ],
                      ),
                    ),

                  ],
                ),
              ),
              ],
            ),
          ),
    );
  }
}

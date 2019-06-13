import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:joincompany/Menu/clientes.dart';
import 'package:joincompany/models/CustomerModel.dart';

enum type{
  NAME,
  CODE,
  CARGO,
  TLF_F,
  TLF_M,
  EMAIL,
  NOTE
}

class AddContact extends StatefulWidget {

  @override
  _AddContactState createState() => _AddContactState();
}

class _AddContactState extends State<AddContact> {

  Widget popUp;

  List<CustomerWithAddressModel> clients = List<CustomerWithAddressModel>();

  TextEditingController name, code, cargo, tlfF, tlfM, email, note;
  String errorTextFieldName, errorTextFieldCode, errorTextFieldNote;

  Future<CustomerWithAddressModel> getClient() async {
    return showDialog<CustomerWithAddressModel>(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return Cliente(true);
      },
    );
  }

  Widget customTextField(String title, type t, int maxLines) {
    return Container(
      margin: EdgeInsets.all(12.0),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
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

  String getErrorText(type t) {
    switch (t) {
      case type.NAME:
        {
          return errorTextFieldName;
        }
      case type.CODE:
        {
          return errorTextFieldCode;
        }
      case type.NOTE:
        {
          return errorTextFieldNote;
        }
      case type.NOTE:
        {
          //TODO
          break;
        }
      case type.CARGO:
        {
          //TODO
          break;
        }
      case type.EMAIL:
        {
          //TODO
          break;
        }
      case type.TLF_F:
        {
          //TODO
          break;
        }
      case type.TLF_M:
        {
          //TODO
          break;
        }
    }
    return "";
  }

  _onChanges(type t) {
    switch (t) {
      case type.NAME:
        {
          setState(() {
            errorTextFieldName = '';
          });
          break;
        }
      case type.CODE:
        {
          setState(() {
            errorTextFieldCode = '';
          });
          break;
        }
      case type.NOTE:
        {
          //TODO
          break;
        }
      case type.CARGO:
        {
          //TODO
          break;
        }
      case type.EMAIL:
        {
          //TODO
          break;
        }
      case type.TLF_F:
        {
          //TODO
          break;
        }
      case type.TLF_M:
        {
          //TODO
          break;
        }
    }
  }

  void initController() {
    name = TextEditingController();
    code = TextEditingController();
    tlfF = TextEditingController();
    tlfM = TextEditingController();
    email = TextEditingController();
    note = TextEditingController();
  }

  void disposeController() {
    name.dispose();
    code.dispose();
    tlfF.dispose();
    tlfM.dispose();
    email.dispose();
    note.dispose();
  }

  TextEditingController getController(type t) {
    switch (t) {
      case type.NAME:
        {
          return name;
        }
      case type.CODE:
        {
          return code;
        }
      case type.TLF_F:
        {
          return tlfF;
        }
      case type.TLF_M:
        {
          return tlfM;
        }
      case type.EMAIL:
        {
          return email;
        }
      case type.NOTE:
        {
          return note;
        }
      case type.CARGO:
        {
          return cargo;
        }
    }
    return null;
  }

  ListView getClientBuilder() {
    return ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: clients.length,
        itemBuilder: (context, int index) {
          return Container(
            child: ListTile(
              leading: const Icon(Icons.account_box,
                  size: 25.0),
              title: Text(clients[index].name),
              subtitle: Text(clients[index].address),
              trailing: IconButton(icon: Icon(Icons.delete), onPressed: () {
                setState(() {
                  clients.remove(clients[index]);
                });
              }),
            ),
          );
        }
    );
  }

  @override
  void initState() {
    initController();
    setState(() {
      popUp = AlertDialog(
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
    });
    super.initState();
  }

  @override
  void dispose() {
    disposeController();
    super.dispose();
  }

  Future<bool> _asyncConfirmDialog() async {
    if (name.text == '' && code.text == '') {
      return true;
    } else {
      return showDialog<bool>(
        context: context,
        barrierDismissible: true, // user must tap button for close dialog!
        builder: (BuildContext context) {
          return popUp;
        },
      );
    }
  }

  Future<bool> savedData() async {
    bool resp = await _asyncConfirmDialog();
    if (resp) {
      return true;
    } else {
      return true;
    }
  }

  Future<bool> _asyncConfirmDialogDeleteUser() async {
    if (true) {
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
//    return false;
  }

  void exitDeletedContact() async {
    await Future.delayed(Duration(seconds: 0, milliseconds: 300));
    Navigator.of(context).pop();
  }

  void deleteContact() async {
    var resp = await _asyncConfirmDialogDeleteUser();
    if (resp) {
//      var responseDelete = await deleteCustomer( widget.client.id.toString(), user.company, user.rememberToken);
//      if(responseDelete.statusCode == 200){
      exitDeletedContact();
    } else {
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: savedData,
        child: Scaffold(
          appBar: AppBar(
            title: Text("Contacto"),
            automaticallyImplyLeading: true,
          ),
          body:SingleChildScrollView(
            child: Column(
              children: <Widget>[
                customTextField("Nombre / apellido *",type.NAME,1),
                customTextField("Codigo *",type.CODE,1),
                customTextField("Cargo",type.CARGO,1),
                customTextField("Telefono fijo",type.TLF_F,1),
                customTextField("Telefono movil",type.TLF_M,1),
                customTextField("Emails",type.EMAIL,1),
                customTextField("Notas",type.NOTE,4),
                Container(
                    margin: EdgeInsets.all(12.0),
                    child:Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text("cliente"),
                        Row(
                          children: <Widget>[
                            Align(
                              alignment: Alignment.centerRight,
                              child: IconButton(
                                icon: Icon(Icons.add),
                                onPressed: ()async{
                                  var client = await getClient();
                                  if (client != null){
                                    setState(() {
                                      clients.add(client);
                                    });
                                  }
                                },
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: IconButton(
                                icon: Icon(Icons.visibility),
                                onPressed: (){
                                  getClient();
                                },
                              ),
                            ),
                          ],
                        )
                      ],
                    )
                ),
                Container(
                  child: clients.isNotEmpty ? Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * (0.1 * clients.length),
                      child:getClientBuilder()): Container() ,
                ),
              ],
            ),
          ),
        ),
    );
  }
}

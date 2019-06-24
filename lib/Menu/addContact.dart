import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:joincompany/Menu/clientes.dart';
import 'package:joincompany/Sqlite/database_helper.dart';
import 'package:joincompany/models/CustomerModel.dart';
import 'package:joincompany/models/ContactModel.dart';
import 'package:joincompany/models/UserDataBase.dart';
import 'package:joincompany/services/ContactService.dart';
import 'package:joincompany/services/CustomerService.dart';

enum type{
  NAME,
  CODE,
  CARGO,
  PHONE_F,
  PHONE_M,
  EMAIL,
  NOTE
}

// ignore: must_be_immutable
class AddContact extends StatefulWidget {
  ContactModel contact;

  AddContact(ContactModel contact){
    this.contact = contact;
  }

  @override
  _AddContactState createState() => _AddContactState();
}

class _AddContactState extends State<AddContact> {

  UserDataBase userAct;

  Widget popUp;

  int lengthNumberTlf = 13;
  int lengthNumberText = 80;

  CustomerWithAddressModel clientAct,clientOld;

  TextEditingController name, code, cargo, phoneF, phoneM, email, note;
  String errorTextFieldName, errorTextFieldCode, errorTextFieldNote;

  Future<CustomerWithAddressModel> getClient() async {
    return showDialog<CustomerWithAddressModel>(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return Client(true);
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
        keyboardType: setInput(t),
        maxLength: t == type.PHONE_F ? lengthNumberTlf:lengthNumberText,
        decoration: InputDecoration(
          hintText: title,
          border: InputBorder.none,
          errorText: getErrorText(t),
          contentPadding: EdgeInsets.all(12.0),
        ),
        onChanged:(value) => _onChanges(t,value),
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
      case type.PHONE_F:
        {
          //TODO
          break;
        }
      case type.PHONE_M:
        {
          //TODO
          break;
        }
    }
    return "";
  }

  TextInputType setInput(type t){
    switch(t){
      case type.NAME:
        return TextInputType.text;
      case type.CODE:
        return TextInputType.text;
      case type.CARGO:
        return TextInputType.text;
      case type.PHONE_F:
        return TextInputType.number;
      case type.PHONE_M:
        return TextInputType.number;
      case type.EMAIL:
        return TextInputType.emailAddress;
      case type.NOTE:
        return TextInputType.multiline;
    }
    return TextInputType.text;
  }

  _onChanges(type t, String value) {
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
      case type.PHONE_F:
        {
          break;
        }
      case type.PHONE_M:
        {
          //TODO
          break;
        }
    }
  }

  void initController() {
    name = TextEditingController();
    code = TextEditingController();
    phoneF = TextEditingController();
    phoneM = TextEditingController();
    email = TextEditingController();
    note = TextEditingController();
  }

  void initData() async {
    userAct = await ClientDatabaseProvider.db.getCodeId('1');
    initController();

    if(widget.contact != null){
      var resp = await getCustomer(widget.contact.customerId.toString(),userAct.company,userAct.token);
      if(resp.statusCode == 200 || resp.statusCode == 201){
        clientAct = CustomerWithAddressModel.fromJson(resp.body);
        clientOld = clientAct;
      }
    }

    setState((){
      if(widget.contact != null){
        name.text = widget.contact.name;
        code.text = widget.contact.code;
        phoneF.text = widget.contact.phone;
        phoneM.text = widget.contact.phone;
        email.text = widget.contact.email;
        note.text = widget.contact.details;
      }
    });
  }

  void disposeController() {
    name.dispose();
    code.dispose();
    phoneF.dispose();
    phoneM.dispose();
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
      case type.PHONE_F:
        {
          return phoneF;
        }
      case type.PHONE_M:
        {
          return phoneM;
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

  @override
  void initState() {
    initData();
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

  Future<bool> validateData()async{
    if(name.text == ''){
      setState(() {
        errorTextFieldName = "Campo Requerido";
      });
      return false;
    }
    if(code.text == ''){
      setState(() {
        errorTextFieldCode = "Campo Requerido";
      });
      return false;
    }
    if(clientAct == null){
      return showDialog<bool>(
          context: context,
          barrierDismissible: false, // user must tap button for close dialog!
          builder: (BuildContext context) {
            return AlertDialog(
                title: ListTile(
                  leading: Icon(Icons.error),
                  title: Text('Nesecita seleccionar un cliente'),
                  onTap: () => Navigator.of(context).pop(false),
                )
            );
          }
      );
    }
    return true;
  }

  Future<bool> _asyncConfirmDialog() async {
    if(widget.contact != null){
      if (name.text == widget.contact.name && code.text == widget.contact.code && clientAct == clientOld && phoneF.text == widget.contact.phone && email.text == widget.contact.email && note.text == widget.contact.details) {
        return true;
      } else {
        return showDialog<bool>(
          context: context,
          barrierDismissible: false, // user must tap button for close dialog!
          builder: (BuildContext context) {
            return popUp;
          },
        );
      }
    }else{
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
  }

  Future<bool> savedData() async {
    bool resp = await _asyncConfirmDialog();
    if (resp) {
      return resp;
    } else {
      if(await validateData()){
        if(widget.contact != null){
          ContactModel contact = ContactModel(
            id: widget.contact.id,
            name: name.text,
            code: code.text,
            phone: phoneF.text,
            email: email.text,
            details: note.text,
            customerId: clientAct.id,
          );

          var resposeUpdateContact = await updateContact(contact.id.toString(),contact,userAct.company,userAct.token);
          if (resposeUpdateContact.statusCode == 200){
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
          ContactModel contact = ContactModel(
            name: name.text,
            code: code.text,
            phone: phoneF.text,
            email: email.text,
            details: note.text,
            customerId: clientAct.id,//TODO:customerID
          );
          var resposeCreateContact = await createContact(contact,userAct.company,userAct.token);
          if (resposeCreateContact.statusCode == 200){
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
      }else{
        return false;
      }
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
                '¿estas seguro que desea eliminar este Contacto?'),
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

  void deleteContactView() async {
    var resp = await _asyncConfirmDialogDeleteUser();
    if (resp) {
      var responseDelete = await deleteContact(
          widget.contact.id.toString(), userAct.company, userAct.token);
      if (responseDelete.statusCode == 200) {
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
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: savedData,
        child: Scaffold(
          appBar: AppBar(
            title: Text("Contacto"),
            automaticallyImplyLeading: true,
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.delete),
                tooltip: 'Eliminar Cliente',
                color: Colors.white,
                iconSize: 25,
                onPressed: widget.contact != null ? deleteContactView:null,
              )
            ],
          ),
          body:SingleChildScrollView(
            child: Column(
              children: <Widget>[
                customTextField("Nombre / apellido *",type.NAME,1),
                customTextField("Codigo *",type.CODE,1),
                //customTextField("Cargo",type.CARGO,1),
                customTextField("Telefono",type.PHONE_F,1),
                //customTextField("Telefono movil",type.PHONE_M,1),
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
                                    print(client.toString());
                                    setState(() {
                                      clientAct = client;
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
                clientAct != null ? ListTile(
                  leading: const Icon(Icons.account_box, size: 25.0),
                  title: Text(clientAct.name!=null ?clientAct.name:" "),
                  subtitle: Text(clientAct.address!=null ?clientAct.address:" "),
                  trailing: IconButton(icon: Icon(Icons.delete), onPressed: () {
                    setState(() {
                      clientAct = null;
                    });
                  }),
                ):Container(),
              ],
            ),
          ),
        ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:joincompany/Menu/clientes.dart';
import 'package:joincompany/async_database/Database.dart';
import 'package:joincompany/models/CustomerModel.dart';
import 'package:joincompany/models/ContactModel.dart';
import 'package:joincompany/models/UserModel.dart';
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
  UserModel user;
  bool loading = false;

  Widget popUp;

  int lengthNumberTlf = 13;
  int lengthNumberText = 80;

  CustomerModel clientAct,clientOld;

  TextEditingController name, code, cargo, phone, phoneM, email, note;
  String errorTextFieldName, errorTextFieldCode, errorTextFieldNote;

  Future<CustomerModel> getClient(STATUS_PAGE_CLIENT state) async {
    return showDialog<CustomerModel>(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return Client(statusPage: state);
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
    phone = TextEditingController();
    phoneM = TextEditingController();
    email = TextEditingController();
    note = TextEditingController();
  }

  void initData() async {
    user  = await DatabaseProvider.db.RetrieveLastLoggedUser();
    initController();

    setState((){
      if(widget.contact != null){
        name.text = widget.contact.name;
        code.text = widget.contact.code;
        phone.text = widget.contact.phone;
        phoneM.text = widget.contact.phone;
        email.text = widget.contact.email;
        note.text = widget.contact.details;
      }
    });

    if(widget.contact != null){
      if(widget.contact.customerId != null){
        var resp = await getCustomer(widget.contact.customerId.toString(),user.company,user.rememberToken);
        if(resp.statusCode == 200 || resp.statusCode == 201){
          setState(() {
            clientAct = resp.body;
            clientOld = clientAct;
          });
        }
      }
    }

  }

  void disposeController() {
    name.dispose();
    code.dispose();
    phone.dispose();
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
          return phone;
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
            '¿Estás seguro que desea guardar estos datos?'),
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
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
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
    return true;
  }

  Future<bool> _asyncConfirmDialog() async {
    if(widget.contact != null){
      if (name.text == widget.contact.name && code.text == widget.contact.code && phone.text == widget.contact.phone && email.text == widget.contact.email && note.text == widget.contact.details && clientOld == clientAct) {
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
        setState(() {loading = true;});
        if(widget.contact != null){
          ContactModel contact = widget.contact;
          contact.name = name.text;
          contact.code = code.text;
          contact.phone = phone.text;
          contact.email = email.text;
          contact.details = note.text;
          contact.updatedAt = DateTime.now().toIso8601String();
          var resposeUpdateContact = await updateContact(contact.id.toString(),contact,user.company,user.rememberToken);
          if (resposeUpdateContact.statusCode == 200){
            if(clientAct != null){
              if(clientOld == null){
                var responseRelateCustomerContact = await relateCustomerContact(clientAct.id.toString(), contact.id.toString(), user.company,user.rememberToken);
                if(responseRelateCustomerContact.statusCode == 200){
                  setState(() {loading = false;});
                  showToast('Contacto Actualizado.');
                  return true;
                }else{
                  setState(() {loading = false;});
                  return showDialog(
                      context: context,
                      barrierDismissible: true, // user must tap button for close dialog!
                      builder: (BuildContext context) {
                        return AlertDialog(
                            title: Text(responseRelateCustomerContact.body == 'Cliente ya tiene el contacto asociado' ? 'Cliente ya tiene el contacto asociado' : 'Ha ocurrido un error')
                        );
                      }
                  );
                }
              }else if(clientOld.id != clientAct.id){
                var responseRelateCustomerContact = await relateCustomerContact(clientAct.id.toString(), contact.id.toString(), user.company,user.rememberToken);
                if(responseRelateCustomerContact.statusCode == 200){
                  var responseUnRelateCustomerContact = await unrelateCustomerContact(clientOld.id.toString(), contact.id.toString(), user.company,user.rememberToken);
                  if(responseUnRelateCustomerContact.statusCode == 200){
                    setState(() {loading = false;});
                    showToast('Contacto Actualizado.');
                    return true;
                  }else{
                    setState(() {loading = false;});
                    return showDialog(
                        context: context,
                        barrierDismissible: true, // user must tap button for close dialog!
                        builder: (BuildContext context) {
                          return AlertDialog(
                              title: Text('Ha ocurrido un error desasociando el cliente')
                          );
                        }
                    );
                  }
                }else{
                  setState(() {loading = false;});
                  return showDialog(
                      context: context,
                      barrierDismissible: true, // user must tap button for close dialog!
                      builder: (BuildContext context) {
                        return AlertDialog(
                            title: Text(responseRelateCustomerContact.body == 'Cliente ya tiene el contacto asociado' ? 'Cliente ya tiene el contacto asociado' : 'Ha ocurrido un error')
                        );
                      }
                  );
                }
              }else{
                showToast('Contacto Actualizado.');
                setState(() {loading = false;});
                return true;
              }
            }else{
              if(clientOld != null){
                var responseUnRelateCustomerContact = await unrelateCustomerContact(clientOld.id.toString(), contact.id.toString(), user.company,user.rememberToken);
                if(responseUnRelateCustomerContact.statusCode == 200){
                  setState(() {loading = false;});
                  showToast('Contacto Actualizado.');
                  return true;
                }else{
                  setState(() {loading = false;});
                  return showDialog(
                      context: context,
                      barrierDismissible: true, // user must tap button for close dialog!
                      builder: (BuildContext context) {
                        return AlertDialog(
                            title: Text('Ha ocurrido un error desasociando el cliente')
                        );
                      }
                  );
                }
              }
            }
          }else{
            setState(() {loading = false;});
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
            createdById: user.id,
            updatedById: user.id,
            deletedById: user.id,
            createdAt: DateTime.now().toIso8601String(),
            updatedAt: DateTime.now().toIso8601String(),
            deletedAt: DateTime.now().toIso8601String(),
            name: name.text,
            code: code.text,
            phone: phone.text,
            email: email.text,
            details: note.text,
          );
          var responseCreateContact = await createContact(contact,user.company,user.rememberToken);
          if (responseCreateContact.statusCode == 200){
            if(clientAct != null){
              var responseRelateCustomerContact = await relateCustomerContact(clientAct.id.toString(), responseCreateContact.body.id.toString(), user.company,user.rememberToken);
              if(responseRelateCustomerContact.statusCode == 200){
                setState(() {loading = false;});
                showToast('Contacto Creado.');
                return true;
              }else{
                setState(() {loading = false;});
                return showDialog(
                    context: context,
                    barrierDismissible: true, // user must tap button for close dialog!
                    builder: (BuildContext context) {
                      return AlertDialog(
                          title: Text('Ya existe un contacto con ese cliente')
                      );
                    }
                );
              }
            }else{
              setState(() {loading = false;});
              return true;
            }
          }else{
            setState(() {loading = false;});
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
        setState(() {loading = false;});
        return false;
      }
    }
  }

  Future<bool> save() async {
    var resp = await savedData();
    return resp != null ? resp : false;
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
                '¿Estás seguro que desea eliminar este Contacto?.'),
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
    setState(() {loading = false;});
    Navigator.of(context).pop();
  }

  void showToast(String text){
    Fluttertoast.showToast(
        msg: text,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 15,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
        fontSize: 14.0
    );
  }

  void deleteContactView() async {
    var resp = await _asyncConfirmDialogDeleteUser();
    if (resp) {
      setState(() {loading = true;});
      var responseDelete = await deleteContact(widget.contact.id.toString(), user.company, user.rememberToken);
      if (responseDelete.statusCode == 200) {
        showToast('Contacto Eliminado.');
        exitDeletedContact();
      } else {
        setState(() {loading = false;});
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

  Future<bool> futureFalse()async{
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: loading ? futureFalse : save,
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
          body:Stack(
            children: <Widget>[
              SingleChildScrollView(
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
                                      var client = await getClient(STATUS_PAGE_CLIENT.select);
                                      if (client != null){
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
                                      getClient(STATUS_PAGE_CLIENT.view);
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
//                  subtitle: Text(clientAct.address!=null ?clientAct.address:" "),
                      trailing: IconButton(icon: Icon(Icons.delete), onPressed: () {
                        //unrelateCustomerContact(idCustomer, idContact, customer, authorization)
                        setState(() {
                          clientAct = null;
                        });
                      }),
                    ):Container(),
                  ],
                ),
              ),
              loading ? Center(child: CircularProgressIndicator(),):Container(),
            ],
          )
        ),
    );
  }
}
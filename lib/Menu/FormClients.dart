import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:joincompany/Menu/contactView.dart';
import 'package:joincompany/Sqlite/database_helper.dart';
import 'package:joincompany/main.dart';
import 'package:joincompany/models/AddressModel.dart';
import 'package:joincompany/models/BusinessModel.dart';
import 'package:joincompany/models/BusinessesModel.dart';
import 'package:joincompany/models/ContactModel.dart';
import 'package:joincompany/models/ContactsModel.dart';
import 'package:joincompany/models/CustomerModel.dart';
import 'package:joincompany/models/UserDataBase.dart';
import 'package:joincompany/pages/BuscarRuta/searchAddress.dart';
import 'package:joincompany/services/AddressService.dart';
import 'package:joincompany/services/BusinessService.dart';
import 'package:joincompany/services/CustomerService.dart';

import 'businesList.dart';

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

  UserDataBase userAct;
  bool loading = false;
  Widget popUp;

  CustomerWithAddressModel client;

  List<AddressModel> directionsNews = List<AddressModel>();
  List<AddressModel> directionsOld = List<AddressModel>();
  List<AddressModel> directionsAll = List<AddressModel>();

  List<ContactModel> contactsAll = List<ContactModel>();
  List<ContactModel> contactsOld = List<ContactModel>();
  List<ContactModel> contactsNew = List<ContactModel>();


  List<BusinessModel> businessAll = List<BusinessModel>();
  List<BusinessModel> businessOld = List<BusinessModel>();
  List<BusinessModel> businessNew = List<BusinessModel>();

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

  void initData() async {
    setState(() {
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
      loading = true;
    });

    userAct = await ClientDatabaseProvider.db.getCodeId('1');

    if(widget.client != null){
      var getCustomerAddressesResponse = await getCustomerAddresses(widget.client.id.toString(),userAct.company,userAct.token);
      if(getCustomerAddressesResponse.statusCode == 200 || getCustomerAddressesResponse.statusCode == 201){
        directionsOld =  new List<CustomerWithAddressModel>.from(json.decode(getCustomerAddressesResponse.body).map((x) => CustomerWithAddressModel.fromMap(x)));
        for(CustomerWithAddressModel direction in directionsOld){
          directionsAll.add(direction);
        }
      }

      var getCustomerContactsResponse = await getCustomerContacts(widget.client.id.toString(),userAct.company,userAct.token);
      if(getCustomerContactsResponse.statusCode == 200 || getCustomerContactsResponse.statusCode == 201){
        ContactsModel customerContacts = ContactsModel.fromJson(getCustomerContactsResponse.body);
        contactsOld = customerContacts.data;
        for(ContactModel contact in contactsOld){
          contactsAll.add(contact);
        }
      }

      var getCustomerBusinessesResponse = await getCustomerBusinesses(widget.client.id.toString(),userAct.company,userAct.token);
      if(getCustomerBusinessesResponse.statusCode == 200 || getCustomerBusinessesResponse.statusCode == 201){
        BusinessesModel customerbusiness = BusinessesModel.fromJson(getCustomerBusinessesResponse.body);
        businessOld = customerbusiness.data;
        for(BusinessModel buss in businessOld){
          businessAll.add(buss);
        }
      }
    }

    setState(() {
      loading = false;
    });
  }

  Future<int> deletedAddressCustomer(AddressModel direction)async{
     var resp = await unrelateCustomerAddress(widget.client.id.toString(),direction.id.toString(),userAct.company,userAct.token);
     return resp.statusCode;
  }

  Future<int> addAddressCustomer(AddressModel direction, int id)async{
    var resp = await relateCustomerAddress(id.toString(),direction.id.toString(),userAct.company,userAct.token);
    return resp.statusCode;
  }

  Future<int> deletedContactCustomer(ContactModel contact)async{
    var resp = await unrelateCustomerContact(widget.client.id.toString(),contact.id.toString(),userAct.company,userAct.token);
    return resp.statusCode;
  }

  Future<int> addContactCustomer(ContactModel contact, int id)async{
    var resp = await relateCustomerContact(id.toString(),contact.id.toString(),userAct.company,userAct.token);
    return resp.statusCode;
  }

  Future<int> deletedBusinessCustomer(BusinessModel business)async{
    var resp = await deleteBusiness(business.id.toString(),userAct.company,userAct.token);
    return resp.statusCode;
  }

  Future<int> addBusinessCustomer(BusinessModel business, int id)async{
    var resp = await relateCustomerBusiness(id.toString(),business.id.toString(),userAct.company,userAct.token);
    return resp.statusCode;
  }

  Future<bool> _asyncConfirmDialog() async {
    if(widget.client != null){
      if(name.text == widget.client.name && note.text == widget.client.details && code.text == widget.client.code && directionsNews.isEmpty && contactsNew.isEmpty && businessNew.isEmpty && directionsOld.length == directionsAll.length && contactsAll.length == contactsOld.length && businessAll.length == businessOld.length ){
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
  }

  void disposeController(){
    name.dispose();
    code.dispose();
    note.dispose();
  }

  Future<bool> savedData() async {
    bool resp = await _asyncConfirmDialog();
    if(resp){
      return resp;
    }else{
      if(validateData()){
          if(widget.client != null){
            CustomerModel client = CustomerModel(
              id: widget.client.id,
              name: name.text,
              code: code.text,
              details: note.text,
            );

            var response = await updateCustomer(client.id.toString(), client, userAct.company, userAct.token);
            bool saveContact = await setContacts(client.id);
            if(!saveContact){
              return showDialog(
                  context: context,
                  barrierDismissible: true, // user must tap button for close dialog!
                  builder: (BuildContext context) {
                    return AlertDialog(
                        title: Text('Ha ocurrido un error guardando los contactos')
                    );
                  }
              );
            }
            bool saveDirections = await setDirections(client.id);
            if(!saveDirections){
              return showDialog(
                  context: context,
                  barrierDismissible: true, // user must tap button for close dialog!
                  builder: (BuildContext context) {
                    return AlertDialog(
                        title: Text('Ha ocurrido un error guardando las direcciones')
                    );
                  }
              );
            }
            bool saveBussines = await setBusiness(client.id);
            if(!saveBussines){
              return showDialog(
                  context: context,
                  barrierDismissible: true, // user must tap button for close dialog!
                  builder: (BuildContext context) {
                    return AlertDialog(
                        title: Text('Ha ocurrido un error guardando los negocios.')
                    );
                  }
              );
            }
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
            if((response.statusCode == 200 || response.statusCode ==  201) && response.body != "Cliente ya existe"){
              var cli = CustomerModel.fromJson(response.body);
              bool saveContact = await setContacts(cli.id);
              if(!saveContact){
                return showDialog(
                    context: context,
                    barrierDismissible: true, // user must tap button for close dialog!
                    builder: (BuildContext context) {
                      return AlertDialog(
                          title: Text('Ha ocurrido un error guardando las direcciones')
                      );
                    }
                );
              }
              bool saveDirections = await setDirections(cli.id);
              if(!saveDirections){
                return showDialog(
                    context: context,
                    barrierDismissible: true, // user must tap button for close dialog!
                    builder: (BuildContext context) {
                      return AlertDialog(
                          title: Text('Ha ocurrido un error con las direcciones.')
                      );
                    }
                );
              }
              bool saveBussines = await setBusiness(cli.id);
              if(!saveBussines){
                return showDialog(
                    context: context,
                    barrierDismissible: true, // user must tap button for close dialog!
                    builder: (BuildContext context) {
                      return AlertDialog(
                          title: Text('Ha ocurrido un error guardando los negocios.')
                      );
                    }
                );
              }
              return true;
            }else{
              return showDialog(
                  context: context,
                  barrierDismissible: true, // user must tap button for close dialog!
                  builder: (BuildContext context) {
                    return AlertDialog(
                        title: Text(response.body == "Cliente ya existe"? "Cliente ya existe":"Ha ocurrido un error"),
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

  bool searchOldDirections(AddressModel direction){
    for(var directionOld in directionsOld){
      if(directionOld.googlePlaceId == direction.googlePlaceId){
        return true;
      }
    }
    return false;
  }

  bool searchOldContacts(ContactModel contact){
//    for(var cont in contactsOld){
//      if(cont.id == contact.id){
//        return true;
//      }
//    }
    for(var cont in contactsNew){
      if(cont.id == contact.id){
        return true;
      }
    }
    return false;
  }

  bool searchOldBusiness(BusinessModel business){
    for(var buss in businessOld){
      if(buss.id == business.id){
        return true;
      }
    }
    return false;
  }

  Future<bool> setDirections(int id)async{
    bool statusCreate = true;
    int resp;
    for(var directionAct in directionsNews){
      if(!searchOldDirections(directionAct)){
        if(directionAct.id != null){
          resp = await addAddressCustomer(directionAct,id);
          statusCreate = responseStatus(resp);
        }else{
          var responseCreateAddress = await createAddress(directionAct,userAct.company,userAct.token);
          if(responseStatus(responseCreateAddress.statusCode)){
            var directionAdd = AddressModel.fromJson(responseCreateAddress.body);
            resp = await addAddressCustomer(directionAdd,id);
            statusCreate = responseStatus(resp);
          }
        }
      }
    }
    for(var direction in directionsOld){
      if(oldToEliminatedDirection(direction)){
        resp = await deletedAddressCustomer(direction);
        statusCreate = responseStatus(resp);
      }
    }

    return statusCreate;
  }

  Future<bool> setContacts(int id)async{
    bool statusCreate = true;
    int resp;
    for(var contact in contactsNew){
        if(contact.id != null){
          resp = await addContactCustomer(contact,id);
          statusCreate = responseStatus(resp);
        }else{
          return false;
        }
    }
    for(var contact in contactsOld){
      if(oldToEliminatedContact(contact)){
        resp = await deletedContactCustomer(contact);
        statusCreate = responseStatus(resp);
      }
    }
    return statusCreate;
  }

  Future<bool> setBusiness(int id)async{//todo
    bool statusCreate = true;
    int resp;

    for(var business in businessNew){
      if(business.id != null){
        resp = await addBusinessCustomer(business,id);
        statusCreate = responseStatus(resp);
      }else{
        return false;
      }
    }

    for(var business in businessOld){
      if(oldToEliminatedBusiness(business)){
        resp = await deletedBusinessCustomer(business);
        statusCreate = responseStatus(resp);
      }
    }
    return statusCreate;
  }

  bool responseStatus(int resp){
    switch(resp){
      case 200:{
        return true;
      }
      case 201:{
        return true;
      }
    }
    return false;
  }

  bool oldToEliminatedDirection(CustomerWithAddressModel direction){
    for(var dir in directionsAll){
      if(dir == direction){
        return false;
      }
    }
    return true;
  }

  bool oldToEliminatedContact(ContactModel contact){
    for(var c in contactsAll){
      if(c == contact){
        return false;
      }
    }
    return true;
  }

  bool oldToEliminatedBusiness(BusinessModel business){
    for(var bus in businessAll){
      if(bus == business){
        return false;
      }
    }
    return true;
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

  Future<AddressModel> getDirections() async{
    return showDialog<AddressModel>(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return SearchAddress();
      },
    );
  }

  Future<ContactModel> getContact(STATUS_PAGE st) async{
    return showDialog<ContactModel>(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return ContactView(st);
      },
    );
  }

  Future<BusinessModel> getBusiness() async{
    return showDialog<BusinessModel>(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return BusinessList(true);
      },
    );
  }

  void exitDeletedClient()async{
    await Future.delayed(Duration(seconds: 0, milliseconds: 300));
    Navigator.of(context).pop();
  }

  void deleteCli()async{
    var resp = await  _asyncConfirmDialogDeleteUser();
    if(resp){
      var responseDelete = await deleteCustomer( widget.client.id.toString(), userAct.company, userAct.token);
      if(responseDelete.statusCode == 200){
        exitDeletedClient();
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

  ListView getDirectionsBuilder() {
    return ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: directionsAll.length,
        itemBuilder: (context, int index) {
          return Container(
            child: ListTile(
              leading: const Icon(Icons.location_on,
                  size: 25.0),
              title: Text(directionsAll[index].address),
              trailing: IconButton(icon: Icon(Icons.delete), onPressed: (){
                setState(() {
                  directionsNews.remove(directionsAll[index]);
                  directionsAll.remove(directionsAll[index]);
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
        itemCount: contactsAll.length,
        itemBuilder: (context, int index) {
          return Container(
            child: ListTile(
              leading: const Icon(Icons.account_box,
                  size: 25.0),
              title: Text(contactsAll[index].name),
              trailing: IconButton(icon: Icon(Icons.delete), onPressed: (){
                setState(() {
                  contactsAll.remove(contactsAll[index]);
                  contactsNew.remove(contactsAll[index]);
                });
              }),
            ),
          );
        }
    );
  }

  ListView getBusinessBuilder() {
    return ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: businessAll.length,
        itemBuilder: (context, int index) {
          return Container(
            child: ListTile(
              leading: const Icon(Icons.business,
                  size: 25.0),
              title: Text('${businessAll[index].name}-${businessAll[index].customer}'),
              trailing: IconButton(icon: Icon(Icons.delete), onPressed: (){
                setState(() {
                  businessNew.remove(businessAll[index]);
                  businessAll.remove(businessAll[index]);
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
              color: Colors.white,
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
                                    var contact = await getContact(STATUS_PAGE.select);
                                    if (contact != null){
                                      if(!searchOldContacts(contact)){
                                        setState(() {
                                          contactsNew.add(contact);
                                          contactsAll.add(contact);
                                        });
                                      }
                                    }
                                  }
                              ),
                              IconButton(
                                  icon: Icon(Icons.visibility),
                                  onPressed: ()async{
                                    getContact(STATUS_PAGE.view);
                                  }
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      child: contactsAll.isNotEmpty ? Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * (0.1 * contactsAll.length),
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
                                        if(!searchOldDirections(resp)){
                                          directionsNews.add(resp);
                                          directionsAll.add(resp);
                                        }
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
                      child: directionsAll.isNotEmpty ? Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * (0.1 * directionsAll.length),
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
                                    var resp = await getBusiness();
                                    if(resp != null){
                                      setState(() {
                                        if(!searchOldBusiness(resp)){
                                          businessAll.add(resp);
                                          businessNew.add(resp);
                                        }
                                      });
                                    }
                                  }
                              ),
                              IconButton(
                                  icon: Icon(Icons.visibility),
                                  onPressed: ()async{
                                    getBusiness();
                                  }
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      child: businessAll.isNotEmpty ? Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * (0.1 * businessAll.length),
                          child:getBusinessBuilder()): Container() ,

                    ),
                  ],
                ),
              ),
              loading ?  Center(
                child: CircularProgressIndicator(),
                ):Container()
              ],
            ),
          ),
    );
  }
}

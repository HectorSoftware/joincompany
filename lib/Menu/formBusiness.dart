import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:joincompany/Sqlite/database_helper.dart';
import 'package:joincompany/async_database/Database.dart';
import 'package:joincompany/models/BusinessModel.dart';
import 'package:joincompany/models/ContactModel.dart';
import 'package:joincompany/models/ContactsModel.dart';
import 'package:joincompany/models/CustomerModel.dart';
import 'package:joincompany/models/CustomersModel.dart';
import 'package:joincompany/models/FieldModel.dart';
import 'package:joincompany/models/TaskModel.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRagePicker;
import 'package:joincompany/models/UserModel.dart';
import 'package:joincompany/services/BusinessService.dart';
import 'package:joincompany/services/ContactService.dart';
import 'package:joincompany/services/CustomerService.dart';

import 'clientes.dart';

enum type{
  POSS,
  CLIENT,
  CONTACT,
  DATE,
  MOUNT,
}

class FormBusiness extends StatefulWidget {

  FormBusiness({this.dataBusiness});
  final BusinessModel dataBusiness;


  @override
  _FormBusinessState createState() => _FormBusinessState();
}

class _FormBusinessState extends State<FormBusiness> {


  String value;
  DateTime _date = new DateTime.now();
  BusinessModel businessGet = BusinessModel();

  List<FieldOptionModel> optionsContacts = List<FieldOptionModel>();
  List<FieldOptionModel> optionsClients = List<FieldOptionModel>();
  List<CustomerModel> listCustomers = List<CustomerModel>();
  List<ContactModel> listContacts = List<ContactModel>();
  FieldOptionModel auxClient =FieldOptionModel();
  FieldOptionModel auxContact =FieldOptionModel();
  List<TaskModel> task = List<TaskModel>();
  List<String> dropdownMenuItemsClients = List<String>();
  List<String> dropdownMenuItemsContact = List<String>();
  String dropdownValueContact ;
  String dropdownValueClient ;
  int customerId;


  TextEditingController posController = TextEditingController();
  TextEditingController clientController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  String errorTextFieldName,errorTextFieldCode,errorTextFieldNote;

  BusinessModel saveBusiness = BusinessModel();

  bool _dateBool = false;
  bool getData = false;
  bool saveBusinessEnd = false;

  Future<TaskModel> getTask() async{
    return showDialog<TaskModel>(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return Client(true);
      },
    );
  }//
  convertToModelToFieldOption(){
    for(CustomerModel v in listCustomers)
      {
        auxClient.value = v.id;
        auxClient.name = v.name;

        optionsClients.add(auxClient);
        auxClient = FieldOptionModel();
      }
    for(FieldOptionModel v in optionsClients){
      dropdownMenuItemsClients.add(v.name);
    }

    for(ContactModel v in listContacts)
    {
      auxContact.value = v.id;
      auxContact.name = v.name;
      optionsContacts.add(auxContact);
      auxContact = FieldOptionModel();
    }
    for(FieldOptionModel v in optionsContacts){
      dropdownMenuItemsContact.add(v.name);
    }

}
  Widget customDropdownMenu(List<FieldOptionModel> elements, String title, String value){

    for(FieldOptionModel v in elements){
     // dropdownMenuItems.add(v.name);
    }

   /* return Container(
      width: MediaQuery.of(context).size.width*0.95,
        height: MediaQuery.of(context).size.height * 0.10,
        child: DropdownButton<String>(
          isDense: false,
          icon: Icon(Icons.arrow_drop_down),
          elevation: 10,
          value: value,
          hint: Text(title),
          isExpanded: true,
          onChanged: (String newValue) {
            setState(() {
              value = newValue;
            });
          },
        items: dropdownMenuItems.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        ),
    );*/
  }
  initTextController(){
    if(widget.dataBusiness != null){
//      print(widget.dataBusiness.name);
//      print(widget.dataBusiness.customer);
//      print(widget.dataBusiness.amount);
//      print(widget.dataBusiness.id);
      setState(() {
        saveBusiness.id = widget.dataBusiness.id;
        posController.text = widget.dataBusiness.name;
        dropdownValueClient = widget.dataBusiness.customer;
        amountController.text = widget.dataBusiness.amount;
      });




    }
  }
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
   customForm(type t){
    switch(t){
      case type.POSS:
        return customTextField('Posicionamiento cliente',t,1);
      case type.CLIENT:
        return customDropdownMenu(optionsClients,' cliente B',value);
      case type.CONTACT:
        return customDropdownMenu(optionsContacts,' Primer Contacto',value);
      case type.DATE:
        return ListTile(
          title: _date.toString() != null ?Text("Fecha ${_date.toLocal()}"): Text("Fecha"),
          trailing: Icon(Icons.calendar_today),
          onTap: ()async{
            final DateTime picked = await showDatePicker(
                context: context,
                initialDate: _date,
                firstDate: new DateTime(2000),
                lastDate: new DateTime(2020)
            );
            if (picked != null && picked != _date){
              setState(() {
                _date = picked;
              });
            }
          },
        );
      case type.MOUNT:
        return customTextField('Monto',t,1);
    }
  }

  String getErrorText(type t){
    switch(t){
      case type.POSS:

        break;
      case type.CLIENT:

        break;
      case type.CONTACT:

        break;
      case type.DATE:

        break;
      case type.MOUNT:

        break;
    }
    return "";
  }

  _onChanges(type t){
    switch(t){
      case type.POSS:

        break;
      case type.CLIENT:

        break;
      case type.CONTACT:

        break;
      case type.DATE:

        break;
      case type.MOUNT:
        break;
    }
  }

  void initController(){
//    name = TextEditingController();
//    code = TextEditingController();
//    tlfF = TextEditingController();
//    tlfM = TextEditingController();
//    email = TextEditingController();
//    note = TextEditingController();
  }

  void disposeController(){
    posController.dispose();
    amountController.dispose();
    clientController.dispose();
    dateController.dispose();
//    name.dispose();
//    code.dispose();
//    tlfF.dispose();
//    tlfM.dispose();
//    email.dispose();
//    note.dispose();
  }

  List<DateTime> valueselectDate = new List<DateTime>();
  Future<Null> selectDate( context )async{
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: _date,
        firstDate: new DateTime(2000),
        lastDate: new DateTime(2020)
    );
    if (picked != null && picked != _date){
      setState(() {
        _date = picked;
      });
    }
  }

  TextEditingController getController(type t){
    switch (t){
      case type.POSS:

        break;
      case type.CLIENT:

        break;
      case type.CONTACT:

        break;
      case type.DATE:

        break;
      case type.MOUNT:

        break;
    }
    return null;
  }

  ListView getClientBuilder() {
    return ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: task.length,
        itemBuilder: (context, int index) {
          return Container(
            child: ListTile(
              leading: const Icon(Icons.account_box,
                  size: 25.0),
              title: Text(task[index].name),
              trailing: IconButton(icon: Icon(Icons.delete), onPressed: (){
                setState(() {
                  task.remove(task[index]);
                });
              }),
            ),
          );
        }
    );
  }

  @override
  void initState() {
    initTextController();
    initController();
    getOther();
    businessGet = widget.dataBusiness;
    super.initState();
  }

  @override
  void dispose() {
    disposeController();
    super.dispose();
  }
  getOther()async{
    UserModel user = await DatabaseProvider.db.RetrieveLastLoggedUser();

    var getAllContactsResponse = await getAllContacts(user.company, user.rememberToken);
    ContactsModel contacts = ContactsModel.fromJson(getAllContactsResponse.body);

    var getAllCustomersResponse = await getAllCustomers(user.company, user.rememberToken);
    CustomersModel customers = CustomersModel.fromJson(getAllCustomersResponse.body);
    listCustomers = customers.data;
    listContacts = contacts.data;
    setState(() {
      getData = true;
    });

    await convertToModelToFieldOption();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: ()=> showDialog(
                context: context,
                builder: (BuildContext context) {
                  return
                    Container(
                      width: MediaQuery.of(context).size.width *0.9,
                      child: AlertDialog(
                        title: Text('Guardar'),
                        content: const Text(
                            'Desea Guardar Tarea'),
                        actions: <Widget>[
                          Row(
                            children: <Widget>[
                              FlatButton(
                                child: const Text('SALIR'),
                                onPressed: () {
                                  Navigator.pushReplacementNamed(context, '/negocios');
                                },
                              ),
                              FlatButton(
                                child: const Text('CANCELAR'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              FlatButton(
                                child: const Text('ACEPTAR'),
                                onPressed: () async {
                                  saveBusiness.customer = clientController.text;
                                  saveBusiness.amount = amountController.text;
                                  saveBusiness.date = _date.toLocal().toString().substring(0,10);
                                  saveBusiness.name = posController.text;
                                  saveBusiness.customerId = customerId;
                                await   saveBusinessApi();
                                if(saveBusinessEnd == true){
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return   AlertDialog(
                                          title: Text('Guardado con Exito'),
                                          actions: <Widget>[
                                            FlatButton(

                                              child: const Text('Aceptar'),
                                              onPressed: () {
                                                Navigator.pushReplacementNamed(context, '/vistap');
                                              },
                                            ),
                                          ],
                                        );
                                      }
                                  );
                                }else{
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return   AlertDialog(
                                          title: Text('A ocurido un Error '),
                                          actions: <Widget>[
                                            FlatButton(
                                              child: const Text('Aceptar'),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                                Navigator.of(context).pop();

                                              },
                                            ),

                                          ],
                                        );
                                      }
                                  );
                                }
                                },
                              )
                            ],
                          ),
                        ],
                      ),
                    );
                }
            )

        ),
        title: Text("Negocio"),
        automaticallyImplyLeading: true,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.delete),
              onPressed: () async {
                UserModel user = await DatabaseProvider.db.RetrieveLastLoggedUser();
                deleteBusiness(saveBusiness.id.toString(),user.company,user.rememberToken);
              }
          ),
        ],
      ),
      body:getData? ListView.builder(
        itemCount: 1,
        itemBuilder: (context, index) {
          return Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(6.0),
                child: Container(
                  margin: EdgeInsets.all(10.0),
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
                    controller: posController,
                   // maxLines: maxLines,
                    decoration: InputDecoration(
                      hintText: 'Posicionamiento',
                      border: InputBorder.none,
                     // errorText: getErrorText(t),
                      contentPadding: EdgeInsets.all(12.0),
                    ),
                   // onChanged: _onChanges(t),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: DropdownButton<String>(
                    isDense: false,
                    icon: Icon(Icons.arrow_drop_down),
                    elevation: 10,
                    value: dropdownValueClient,
                    hint: Text('Clientes'),
                    onChanged: (String newValue) {
                      setState(() {
                        dropdownValueClient = newValue;
                        clientController.text = newValue;
                        for(FieldOptionModel v in optionsClients){
                          if(dropdownValueClient == v.name){
                            customerId = v.value;


                          }
                        }

                      });
                    },
                    items: dropdownMenuItemsClients.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ),
//              Padding(
//                padding: const EdgeInsets.all(12.0),
//                child: Container(
//                  width: MediaQuery.of(context).size.width,
//                  child: DropdownButton<String>(
//                    isDense: false,
//                    icon: Icon(Icons.arrow_drop_down),
//                    elevation: 10,
//                    value: dropdownValueContact,
//                    hint: Text('Contactos'),
//                    onChanged: (String newValue) {
//                      setState(() {
//                        dropdownValueContact = newValue;
//                      });
//                    },
//                    items: dropdownMenuItemsContact.map<DropdownMenuItem<String>>((String value) {
//                      return DropdownMenuItem<String>(
//                        value: value,
//                        child: Text(value),
//                      );
//                    }).toList(),
//                  ),
//                ),
//              ),
              ListTile(
                title: _dateBool ?Text("Fecha :    ${_date.toLocal().toString().substring(0,10)}"): Text("Fecha"),
                trailing: Icon(Icons.calendar_today),
                onTap: ()async{
                  final DateTime picked = await showDatePicker(
                      context: context,
                      initialDate: _date,
                      firstDate: new DateTime(2000),
                      lastDate: new DateTime(2020)
                  );
                  if (picked != null && picked != _date){
                    setState(() {
                      _date = picked;
                      _dateBool = true;
                    });
                  }
                },
              ),
              Container(
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
                  controller:amountController,
                 // maxLines: maxLines,
                  decoration: InputDecoration(
                    hintText: 'Monto',
                    border: InputBorder.none,
                   // errorText: getErrorText(t),
                    contentPadding: EdgeInsets.all(12.0),
                  ),
                //  onChanged: _onChanges(t),
                ),
              ),

          Container(
                margin: EdgeInsets.all(12.0),
                child:Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("Tarea o Nota",style: TextStyle(fontSize: 18),),
                    Row(
                      children: <Widget>[
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: Icon(Icons.add),
                            onPressed: ()async{
//                              var t = await getTask();
//                              if (t != null){
//                                setState(() {
//                                  task.add(t);
//                                });
//                              }
                            },
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: Icon(Icons.visibility),
                            onPressed: (){
                              getTask();
                            },
                          ),
                        ),
                      ],
                    )
                  ],
                )
            ),
            Container(
              child: task.isNotEmpty ? Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * (0.1 * task.length),
                  child:getClientBuilder()): Container() ,
            ),
            ],
          );
        }
      ): Center(child: CircularProgressIndicator(),),

//

    );
  }
  saveBusinessApi() async{
    UserModel user = await DatabaseProvider.db.RetrieveLastLoggedUser();
    var createBusinessResponse = await createBusiness(saveBusiness, user.company, user.rememberToken);
//    print(createBusinessResponse.statusCode);
//      print(createBusinessResponse.body);

    if(createBusinessResponse.statusCode == 201 || createBusinessResponse.statusCode == 200){
      setState(() {
        saveBusinessEnd = true;
      });
    }
    if(createBusinessResponse.statusCode == 500){
      setState(() {
      saveBusinessEnd = false;
      });
    }
  }
}

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:joincompany/Menu/clientes.dart';
import 'package:joincompany/Sqlite/database_helper.dart';
import 'package:joincompany/async_database/Database.dart';
import 'package:joincompany/models/AddressModel.dart';
import 'package:joincompany/models/AddressesModel.dart';
import 'package:joincompany/models/BusinessModel.dart';
import 'package:joincompany/models/ContactModel.dart';
import 'package:joincompany/models/ContactsModel.dart';
import 'package:joincompany/models/CustomerModel.dart';
import 'package:joincompany/models/CustomersModel.dart';
import 'package:joincompany/models/FieldModel.dart';
import 'package:joincompany/models/TaskModel.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRagePicker;
import 'package:joincompany/models/UserModel.dart';
import 'package:joincompany/models/TasksModel.dart';
import 'package:joincompany/pages/FormTaskNew.dart';
import 'package:joincompany/pages/home/taskHome.dart';
import 'package:joincompany/services/BusinessService.dart';
import 'package:joincompany/services/ContactService.dart';
import 'package:joincompany/services/CustomerService.dart';
import 'package:joincompany/services/TaskService.dart';
import 'package:flutter/services.dart';
import 'clientes.dart';

enum type{
  PRIMER,
  CLIENT,
  CONTACT,
  DATE,
  MOUNT,
}

class FormBusiness extends StatefulWidget {

  FormBusiness({this.dataBusiness, this.edit, this.client});
  final BusinessModel dataBusiness;
  final bool edit;
  final CustomerModel client;

  @override
  _FormBusinessState createState() => _FormBusinessState();
}

class _FormBusinessState extends State<FormBusiness> {


  String value;
  DateTime _date = new DateTime.now();
  BusinessModel businessGet = BusinessModel();
  List<FieldOptionModel> optionsClients = List<FieldOptionModel>();
  List<CustomerModel> listCustomers = List<CustomerModel>();
  List<TaskModel> listTasksBusiness = List<TaskModel>();
  List<AddressModel> listDirectionsClients = List<AddressModel>();

  FieldOptionModel auxClient =FieldOptionModel();
  List<TaskModel> task = List<TaskModel>();
  List<String> dropdownMenuItemsClients = List<String>();
  List<String> dropdownMenuItemsHeader = List<String>();
  String dropdownValueMenuHeader ;
  String dropdownValueClient ;
  String bodyError;
  int businessId;
  int customerId;


  TextEditingController posController = TextEditingController();
  TextEditingController clientController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController headerController = TextEditingController();

  String dateG;
  BusinessModel saveBusiness = BusinessModel();

  bool _dateBool = false;
  bool getData = false;
  bool saveBusinessEnd = false;
  bool getClients = false;

  Future<TaskModel> getTask() async{
    return showDialog<TaskModel>(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return Client(vista: true,statusPage: STATUS_PAGE_CLIENT.full);
      },
    );
  }//

  Future<TaskModel> createTaskBusiness(AddressModel addressClient) async{
    return showDialog<TaskModel>(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        CustomerWithAddressModel directionClientBus = CustomerWithAddressModel();
        if(addressClient == null){
          directionClientBus = CustomerWithAddressModel();
        }
        else{
          directionClientBus = CustomerWithAddressModel(
            address: addressClient.address,
            name:dropdownValueClient ,
            id: addressClient.id,
            city: addressClient.city,
            addressId: 1,
            createdById:addressClient.createdById,
            customerId: 1,
            longitude: addressClient.longitude,
            latitude: addressClient.latitude,
            googlePlaceId: addressClient.googlePlaceId,
            locality: addressClient.locality,
            localityId: addressClient.localityId,
            state: addressClient.state,
            country: addressClient.country,
            details: addressClient.details,
            createdAt: addressClient.createdAt,
            updatedAt: addressClient.updatedAt,
            reference: addressClient.reference,
            updatedById: addressClient.updatedById,
            contactEmail: addressClient.contactEmail,
          );
        }
        return FormTask(directionClient: directionClientBus,toBusiness: true ,businessAs: widget.dataBusiness);
      },
    );
  }//

  convertToModelToFieldOption(){
    if(widget.client == null){
      if(getClients == true){
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
      }else{
        dropdownMenuItemsClients.add('Sin Clientes');
      }
    }


    dropdownMenuItemsHeader.add('Primer contacto');
    dropdownMenuItemsHeader.add('Presentación');
    dropdownMenuItemsHeader.add('Envío ppta');
    dropdownMenuItemsHeader.add('Ganado');
    dropdownMenuItemsHeader.add('Perdido');
}

  initTextController() async {
    if(widget.dataBusiness != null){
      UserModel user = await DatabaseProvider.db.RetrieveLastLoggedUser();
      var  getCustomerResponse = await  getCustomer(widget.dataBusiness.customerId.toString(),user.company, user.rememberToken,);
      if(getCustomerResponse.statusCode == 200 || getCustomerResponse.statusCode == 201){
        dropdownValueClient = widget.dataBusiness.customer;
        saveBusiness.customerId = widget.dataBusiness.customerId;
      }else if(widget.dataBusiness.customer == null){
      }
      setState(() {
        saveBusiness.id = widget.dataBusiness.id;
        posController.text = widget.dataBusiness.name;
        amountController.text = widget.dataBusiness.amount;
        headerController.text = widget.dataBusiness.stage;
        businessId = widget.dataBusiness.id;
        saveBusiness.date = widget.dataBusiness.date.toString();
        dateG = widget.dataBusiness.date != null ?  widget.dataBusiness.date.toString().substring(0,10) : "" ;
        _dateBool =true;
        if(widget.dataBusiness.stage != null) {
            dropdownValueMenuHeader = widget.dataBusiness.stage;
        }
      });
    }
    if(widget.client != null){
      customerId = widget.client.id;
    }
  }

  void disposeController(){
    posController.dispose();
    amountController.dispose();
    clientController.dispose();
    dateController.dispose();
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
    if(widget.dataBusiness != null){
      saveBusiness = widget.dataBusiness;
      customerId = widget.dataBusiness.customerId;
      clientController.text = widget.dataBusiness.customer;
    }
    getOther();
    businessGet = widget.dataBusiness;
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

  getOther()async{
    UserModel user = await DatabaseProvider.db.RetrieveLastLoggedUser();

    var getAllContactsResponse = await getAllContacts(user.company, user.rememberToken);
    ContactsModel contacts = getAllContactsResponse.body;
    if(widget.client == null){
      var getAllCustomersResponse = await getAllCustomers(user.company, user.rememberToken);
      CustomersModel customers = getAllCustomersResponse.body;
      listCustomers = customers.data;
      if(listCustomers != null){
        getClients = true;
      }
    }else{
      dropdownMenuItemsClients.add(widget.client.name);
    }

    setState(() {
      getData = true;
    });

    await convertToModelToFieldOption();
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

  @override
  Widget build(BuildContext context) {
    getDirTask();
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
                        content: const Text('Desea Guardar'),
                        actions: <Widget>[
                          Row(
                            children: <Widget>[
                              FlatButton(
                                child: const Text('SALIR'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop();
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
                                  saveBusiness.date = dateG;
                                  saveBusiness.name = posController.text;
                                  saveBusiness.customerId = customerId;
                                  saveBusiness.stage = headerController.text;
                                  if(widget.edit == true){
                                    await updateBusinessApi();
                                  }
                                  else{
                                    await saveBusinessApi();
                                  }
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
                                                showToast('Negocio Creado.');
                                                Navigator.of(context).pop();
                                                Navigator.of(context).pop();
                                                Navigator.of(context).pop(saveBusiness);
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
                                        if(saveBusiness.customerId ==null){
                                          return   AlertDialog(
                                            title: Text('Selecccione un cliente para poder continuar '),
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
                                        }else if(saveBusinessEnd == false && bodyError == 'Negocio ya existe'){
                                          return   AlertDialog(
                                            title: Text('El Negocio ya existe.'),
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
                                        if(saveBusinessEnd == false){
                                          return   AlertDialog(
                                            title: Text('Ha ocurrido un error.'),
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
              icon: Icon(Icons.delete,
              color: widget.edit == true ? Colors.white : Colors.grey),
              onPressed: () async {
                if(widget.edit == true){
                  UserModel user = await DatabaseProvider.db.RetrieveLastLoggedUser();
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return   AlertDialog(
                          title: Text('Desea Eliminiar Negocio'),
                          actions: <Widget>[
                            FlatButton(
                              child: const Text('Volver'),
                              onPressed: () async {
                                Navigator.pop(context);
                              },
                            ),
                            FlatButton(
                              child: const Text('Aceptar'),
                              onPressed: () async {
                                var del = await deleteBusiness(saveBusiness.id.toString(),user.company,user.rememberToken);
                                if(del.statusCode == 200 || del.statusCode == 201){
                                  showToast('Negocio Eliminado');
                                  Navigator.pushReplacementNamed(context, '/negocios');
                                }else{
                                  showToast('Error Inesperado');
                                }
                              },
                            ),

                          ],
                        );
                      }
                  );
                }
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
                  margin: EdgeInsets.only(top: 20,left: 5,right: 5,bottom: 5),
                  decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5)),
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
                      contentPadding: EdgeInsets.all(15.0),
                    ),
                   // onChanged: _onChanges(t),
                  ),
                ),
              ), //Posicionamiento
              Container(
                height: 50,
                margin: EdgeInsets.all(10.0),
                decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5)),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black12,
                          blurRadius: 5
                      )
                    ]
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: DropdownButton<String>(
                      isExpanded: true,
                      isDense: false,
                      underline: Container(),
                      iconSize: 35,
                      icon:widget.client == null ? Icon(Icons.arrow_drop_down): null,
                      elevation: 10,
                      value: widget.client != null ? widget.client.name : dropdownValueClient,
                      hint:  widget.client == null ? getClients ?  Text('Clientes') : Text('Sin clientes') : null,
                      onChanged: (String newValue) {
                        setState(() {
                          if(widget.client == null){
                            dropdownValueClient = newValue;
                            clientController.text = newValue;
                            for(FieldOptionModel v in optionsClients){
                              if(dropdownValueClient == v.name){
                                customerId = v.value;
                              }
                            }
                          }else{
                            clientController.text = newValue;
                            customerId = widget.client.id;
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
              ), //Clientes
              Container(
                height: 50,
                margin: EdgeInsets.all(10.0),
                decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5)),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black12,
                          blurRadius: 5
                      )
                    ]
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: DropdownButton<String>(
                      isExpanded: true,
                      isDense: false,
                      iconSize: 35,
                      underline: Container(),
                      icon: Icon(Icons.arrow_drop_down),
                      elevation: 10,
                      value: dropdownValueMenuHeader,
                      hint: Text('Negocio'),
                      onChanged: (String newValue) {
                        setState(() {
                          dropdownValueMenuHeader = newValue;
                          headerController.text = dropdownValueMenuHeader;
                        });
                      },
                      items: dropdownMenuItemsHeader.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),//Negocio
              Container(
                height: 50,
                margin: EdgeInsets.all(10.0),
                decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5)),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black12,
                          blurRadius: 5
                      )
                    ]
                ),
                child: ListTile(
                  title: _dateBool ?Text(dateG): Text("Fecha" ,style: TextStyle(color: Colors.grey[600]),),
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
                        dateG = _date.toLocal().toString().substring(0,10);
                        _dateBool = true;
                      });
                    }
                  },
                ),
              ), //Fecha
              Container(
                margin: EdgeInsets.all(12.0),
                decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5)),
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
                ),
              ), //Monto
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
                              onPressed: () async {
                              if(widget.edit == true && listDirectionsClients.length > 0 && widget.client == null){
                                return showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return
                                        Container(
                                            width: MediaQuery.of(context).size.width,
                                            height: MediaQuery.of(context).size.height *(1.0 *listDirectionsClients.length ),
                                            child: SimpleDialog(
                                                title: Text('Escoja una direccion para crear una tarea:'),
                                                children: <Widget>[
                                                  Column(
                                                    children: <Widget>[
                                                      Container(
                                                        width: MediaQuery.of(context).size.width ,
                                                        height: MediaQuery.of(context).size.height *(0.1 *listDirectionsClients.length ),
                                                        child: listDirectionsClients.length != 0 ? ListView.builder(
                                                          itemCount: listDirectionsClients.length,
                                                          itemBuilder: (context, index) {
                                                            return Container(
                                                              decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5)),
                                                                  color: Colors.white,
                                                                  boxShadow: [
                                                                    BoxShadow(
                                                                        color: Colors.black12,
                                                                        blurRadius: 5
                                                                    )
                                                                  ]
                                                              ),
                                                              child: ListTile(
                                                                title: Text(listDirectionsClients[index].address,style: TextStyle(fontSize: 18),),
                                                                subtitle:dropdownValueClient!= null ? Text(dropdownValueClient,style: TextStyle(fontSize: 16),):Text(''),
                                                                leading: Icon(Icons.location_on),
                                                                onTap: () async {
                                                                  var t = await createTaskBusiness(listDirectionsClients[index]);
                                                                  if (t != null){
                                                                    setState(() {
                                                                      task.add(t);
                                                                    });
                                                                  }
                                                                },
                                                              ),
                                                            );
                                                          },
                                                        ): Center(child: Text('Cliente sin direcciones'),),

                                                      ),
                                                    ],
                                                  )
                                                ]
                                            )
                                        );
                                    }
                                );
                              }else if(widget.edit == true && widget.client == null){
                                return showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return
                                        Container(
                                            width: MediaQuery.of(context).size.width *0.9,
                                            child: SimpleDialog(
                                                title: Text('Cliente sin direcciones.'),
                                                children: <Widget>[
                                                  Column(
                                                    children: <Widget>[
                                                      Container(
                                                        width: MediaQuery.of(context).size.width ,
                                                        height: MediaQuery.of(context).size.height *0.1,
                                                      ),
                                                      Row(
                                                        children: <Widget>[
                                                          Expanded(
                                                            child: FlatButton(
                                                              child: const Text('CONTINUAR'),
                                                              onPressed: ()async {
                                                                Navigator.of(context).pop();
                                                                var t = await createTaskBusiness(null);
                                                                if (t != null){
                                                                  setState(() {
                                                                    task.add(t);
                                                                  });
                                                                }
                                                              },
                                                            ),
                                                          ),
                                                        ],
                                                      )
                                                    ],
                                                  )
                                                ]
                                            )
                                        );
                                    }
                                );
                              }
                              }

                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: Icon(Icons.visibility),
                            onPressed: () async {
//                              if(widget.edit == true && widget.client == null){
//                                return   showDialog(
//                                    context: context,
//                                    // ignore: deprecated_member_use
//                                    child: SimpleDialog(
//                                        title: Text('Tareas:'),
//                                        children: <Widget>[
//                                          Column(
//                                            children: <Widget>[
//                                              Container(
//                                                width: MediaQuery.of(context).size.width ,
//                                                height: MediaQuery.of(context).size.height * (0.1 *listTasksBusiness.length) +50,
//                                                child: listTasksBusiness.length != 0 ? ListView.builder(
//                                                  itemCount: listTasksBusiness.length,
//                                                  itemBuilder: (context, index) {
//                                                    return Container(
//                                                      decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5)),
//                                                          color: Colors.white,
//                                                          boxShadow: [
//                                                            BoxShadow(
//                                                                color: Colors.black12,
//                                                                blurRadius: 5
//                                                            )
//                                                          ]
//                                                      ),
//                                                      child: ListTile(
//                                                        title: Text(listTasksBusiness[index].name,style: TextStyle(fontSize: 18),),
//                                                        subtitle:listTasksBusiness[index].id != null ? Text(dropdownValueClient,style: TextStyle(fontSize: 16),):Text('Sin Cliente Asociado'),
//                                                        leading: Icon(Icons.message),
//                                                        onTap: (){
//
//                                                        },
//                                                      ),
//                                                    );
//                                                  },
//                                                ): Center(child: Text('No hay tareas asociadas'),),
//
//                                              ),
//                                            ],
//                                          )
//                                        ]
//                                    )
//                                );
//                              }else{
//
//                              }
                              if(widget.dataBusiness != null){
                                await showTask();
                              }
                            }

                          ),
                        ),
                      ],
                    )
                  ],
                )
            ),  //tarea o nota
              Container(
              child: task.isNotEmpty ? Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * (0.1 * task.length),
                  child:getClientBuilder()): Container() ,
            ), //Container de tareas asociadas
            ],
          );
        }
      ): Center(child: CircularProgressIndicator(),),
    );
  }

  getDirTask()async{
    try{
      await getDirectionsClients();
      await getTaskBusiness();
    }catch(e){

    }

  }

  getDirectionsClients()async{
    UserModel user = await DatabaseProvider.db.RetrieveLastLoggedUser();

    var getCustomerAddressesResponse = await getCustomerAddresses( saveBusiness.customerId.toString(), user.company, user.rememberToken);
    List<AddressModel> customerAddresses =getCustomerAddressesResponse.body ;
    listDirectionsClients = customerAddresses;
  }

  getTaskBusiness() async{
    UserModel user = await DatabaseProvider.db.RetrieveLastLoggedUser();
    var getAllTasksResponse = await getAllTasks(user.company, user.rememberToken, businessId: saveBusiness.id.toString());
    TasksModel tasks = getAllTasksResponse.body;
     setState(() {
       listTasksBusiness = tasks.data;
     });
  }

  saveBusinessApi() async{
    UserModel user = await DatabaseProvider.db.RetrieveLastLoggedUser();
    var createBusinessResponse = await createBusiness(saveBusiness, user.company, user.rememberToken);
//    print(createBusinessResponse.statusCode);
//      print(createBusinessResponse.body);

    if(createBusinessResponse.statusCode == 201 || createBusinessResponse.statusCode == 200){
      setState(() {
        saveBusiness = createBusinessResponse.body;
        saveBusinessEnd = true;
      });
    }
    if(createBusinessResponse.statusCode == 500 &&  createBusinessResponse.body == 'Negocio ya existe'){
      setState(() {
        bodyError = 'Negocio ya existe';
            saveBusinessEnd = false;
      });
    }
  }

  updateBusinessApi() async{
    UserModel user = await DatabaseProvider.db.RetrieveLastLoggedUser();

    var updateBusinessResponse = await updateBusiness(saveBusiness.id.toString(),saveBusiness,user.company, user.rememberToken);

    if(updateBusinessResponse.statusCode == 201 || updateBusinessResponse.statusCode == 200){
      setState(() {
        saveBusinessEnd = true;
      });
    }
    if(updateBusinessResponse.statusCode == 500){
      setState(() {
        saveBusinessEnd = false;
      });
    }
  }

  Future showTask() async{
    return showDialog(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return TaskHomePage(business: widget.dataBusiness,);
      },
    );
  }

}

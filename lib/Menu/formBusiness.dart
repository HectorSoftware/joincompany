import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:joincompany/Menu/clientes.dart';
import 'package:joincompany/Sqlite/database_helper.dart';
import 'package:joincompany/models/AddressModel.dart';
import 'package:joincompany/models/BusinessModel.dart';
import 'package:joincompany/models/CustomerModel.dart';
import 'package:joincompany/models/CustomersModel.dart';
import 'package:joincompany/models/FieldModel.dart';
import 'package:joincompany/models/TaskModel.dart';
import 'package:joincompany/models/TasksModel.dart';
import 'package:joincompany/models/UserDataBase.dart';
import 'package:joincompany/pages/FormTaskNew.dart';
import 'package:joincompany/services/BusinessService.dart';
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

  FormBusiness({this.dataBusiness, this.edit});
  final BusinessModel dataBusiness;
  final bool edit;


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
            addressId: addressClient.id,
            createdById:addressClient.createdById,
            customerId: customerId,
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
      dropdownMenuItemsHeader.add('Primer contacto');
      dropdownMenuItemsHeader.add('Presentación');
      dropdownMenuItemsHeader.add('Envío ppta');
      dropdownMenuItemsHeader.add('Ganado');
      dropdownMenuItemsHeader.add('Perdido');
}

  initTextController() async {
    if(widget.dataBusiness != null){
      UserDataBase user = await ClientDatabaseProvider.db.getCodeId('1');
      var  getCustomerResponse = await  getCustomer(widget.dataBusiness.customerId.toString(),user.company, user.token,);
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
        dateG = widget.dataBusiness.date.toString().substring(0,10);
        _dateBool =true;
        if(widget.dataBusiness.stage != null) {
            dropdownValueMenuHeader = widget.dataBusiness.stage;
        }
      });

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
    UserDataBase user = await ClientDatabaseProvider.db.getCodeId('1');
    var getAllCustomersResponse = await getAllCustomers(user.company, user.token);
    CustomersModel customers = CustomersModel.fromJson(getAllCustomersResponse.body);
    listCustomers = customers.data;
    if(listCustomers != null){
      getClients = true;
    }
    setState(() {
      getData = true;
    });
    await convertToModelToFieldOption();
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
                        title: Text('Desea guardar'),
                        actions: <Widget>[
                          Row(
                            children: <Widget>[
                              FlatButton(
                                child: const Text('Salir'),
                                onPressed: () {
                                  Navigator.pushReplacementNamed(context, '/negocios');
                                },
                              ),
                              FlatButton(
                                child: const Text('Cancelar'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              FlatButton(
                                child: const Text('Aceptar'),
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
                                    await   saveBusinessApi();
                                  }

                                if(saveBusinessEnd == true){
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return   AlertDialog(
                                          title: Text('Guardado con exito'),
                                          actions: <Widget>[
                                            FlatButton(

                                              child: const Text('Aceptar'),
                                              onPressed: () {
                                                Navigator.pushReplacementNamed(context, '/negocios');
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
                                        }else{
                                          return   AlertDialog(
                                            title: Text('A ocurido un Error inesperado '),
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
                  UserDataBase user = await ClientDatabaseProvider.db.getCodeId('1');
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return   AlertDialog(
                          title: Text('Desea eliminiar negocio'),
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
                                await deleteBusiness(saveBusiness.id.toString(),user.company,user.token);
                                Navigator.pushReplacementNamed(context, '/negocios');
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
                      hintText: 'Negocio',
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
                      icon: Icon(Icons.arrow_drop_down),
                      elevation: 10,
                      value: dropdownValueClient,
                      hint: getClients ?  Text('Clientes') : Text('Sin clientes'),
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
                      hint: Text('Etapa'),
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
                  title: _dateBool ?Text(dateG): Text("Fecha de Cierre" ,style: TextStyle(color: Colors.grey[600]),),
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
                              if(widget.edit == true && listDirectionsClients.length > 0){
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
                              }else if(widget.edit == true){
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
                            onPressed: () {
                              setState(() {

                              });
                              if(widget.edit == true){
                                return   showDialog(
                                    context: context,
                                    // ignore: deprecated_member_use
                                    child: SimpleDialog(
                                        title: Text('Tareas:'),
                                        children: <Widget>[
                                          Column(
                                            children: <Widget>[
                                              Container(
                                                width: MediaQuery.of(context).size.width ,
                                                height: MediaQuery.of(context).size.height * (0.1 *listTasksBusiness.length) +50,
                                                child: listTasksBusiness.length != 0 ? ListView.builder(
                                                  itemCount: listTasksBusiness.length,
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
                                                        title: Text(listTasksBusiness[index].name,style: TextStyle(fontSize: 18),),
                                                        subtitle:listTasksBusiness[index].id != null ? Text(dropdownValueClient,style: TextStyle(fontSize: 16),):Text('Sin Cliente Asociado'),
                                                        leading: Icon(Icons.message),
                                                        onTap: (){

                                                        },
                                                      ),
                                                    );
                                                  },
                                                ): Center(child: Text('No hay tareas asociadas'),),

                                              ),
                                            ],
                                          )
                                        ]
                                    )
                                );
                              }else{

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
    UserDataBase user = await ClientDatabaseProvider.db.getCodeId('1');
    var getCustomerAddressesResponse = await getCustomerAddresses( saveBusiness.customerId.toString(), user.company, user.token);
    List<AddressModel> customerAddresses = new List<AddressModel>.from(json.decode(getCustomerAddressesResponse.body).map((x) => AddressModel.fromMap(x)));
    listDirectionsClients = customerAddresses;
  }
  getTaskBusiness() async{
    UserDataBase user = await ClientDatabaseProvider.db.getCodeId('1');
    var getAllTasksResponse = await getAllTasks(user.company, user.token, businessId: saveBusiness.id.toString());
    TasksModel tasks = TasksModel.fromJson(getAllTasksResponse.body);
     setState(() {
       listTasksBusiness = tasks.data;
     });
  }
  saveBusinessApi() async{
    UserDataBase user = await ClientDatabaseProvider.db.getCodeId('1');
    var createBusinessResponse = await createBusiness(saveBusiness, user.company, user.token);
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
  updateBusinessApi() async{
    UserDataBase user = await ClientDatabaseProvider.db.getCodeId('1');
    var updateBusinessResponse = await updateBusiness(saveBusiness.id.toString(),saveBusiness,user.company, user.token);

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
}
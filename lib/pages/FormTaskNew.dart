import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:joincompany/Menu/ImageAndPhoto.dart';
import 'package:joincompany/blocs/blocTypeForm.dart';
import 'package:joincompany/models/AddressModel.dart';
import 'package:joincompany/models/BusinessModel.dart';
import 'package:joincompany/services/AddressService.dart';
import 'dart:io';
import 'package:sentry/sentry.dart';
import 'package:joincompany/main.dart';
import 'package:joincompany/models/CustomerModel.dart';
import 'package:joincompany/models/FieldModel.dart';
import 'package:joincompany/models/FormModel.dart';
import 'package:joincompany/models/FormsModel.dart';
import 'package:joincompany/models/SectionModel.dart';
import 'package:joincompany/models/TaskModel.dart';
import 'package:joincompany/models/UserDataBase.dart';
import 'package:joincompany/models/WidgetsList.dart';
import 'package:joincompany/pages/BuscarRuta/searchAddressWithClient.dart';
import 'package:joincompany/pages/ImageBackNetwork.dart';
import 'package:joincompany/pages/canvasIMG/pickerImg.dart';
import 'package:joincompany/services/FormService.dart';
import 'package:http/http.dart' as http;
import 'package:joincompany/Sqlite/database_helper.dart';
import 'package:joincompany/services/TaskService.dart';
import 'dart:io';

class FormTask extends StatefulWidget {

  FormTask({this.directionClient,this.toBusiness,this.businessAs,this.taskmodelres,this.toListTask});
  final CustomerWithAddressModel  directionClient;
  final bool toBusiness;
  final BusinessModel businessAs;
  final TaskModel taskmodelres;
  final bool toListTask;

  @override
  _FormTaskState createState() => new _FormTaskState();

}
class _FormTaskState extends State<FormTask> {

  SentryClient sentry;
  Image image;
  Image image2;
  TimeOfDay _time = new TimeOfDay.now();
  TimeOfDay _timeDT = new TimeOfDay.now();
  DateTime _date = new DateTime.now();
  DateTime _dateDT = new DateTime.now();
  DateTime _dateTask = new DateTime.now();
  TimeOfDay _timeTask = new TimeOfDay.now();
  FieldOptionModel options = FieldOptionModel(name: '0',value: 1);
  Map data = new Map();
  Map<String,String> dataInfo = Map<String,String>();
  BuildContext globalContext;
  List<FieldModel> listFieldsModels = List<FieldModel>();
  FormModel formGlobal;
  UserDataBase userToken ;
  String token,customer, user;
  int responsibleId;
  FormsModel formType;
  bool taskCU = false;
  bool pass= false;
  int taskEnd;
  bool _value1 = false;
  CustomerWithAddressModel  directionClient = new  CustomerWithAddressModel();
  TaskModel saveTask = new TaskModel();
  CustomerWithAddressModel  directionClientIn= new  CustomerWithAddressModel();
  String defaultValue = 'NO';
  String valuesTable = '';
  TaskModel taskOne;

  @override
  void initState(){
    sentry = new SentryClient(dsn: 'https://3b62a478921e4919a71cdeebe4f8f2fc@sentry.io/1445102');
    directionClientIn = widget.directionClient;
    initFormsTypes();
    if(widget.toListTask == true){
      listWithTask();
    }
    super.initState();
  }

  Future listWithTask() async {
    await getElements();

    //SOLICITAR TAREA CON DETALLES
    var responseTaskone = await getTask(widget.taskmodelres.id.toString(),customer, token);
    taskOne = TaskModel.fromJson(responseTaskone.body);
    //SOLICITAR FORMULARIOS
    var getFormResponse = await getForm(widget.taskmodelres.formId.toString(), customer, token);
    FormModel form = FormModel.fromJson(getFormResponse.body);
    setState(() {
      _dateTask = DateTime.parse(widget.taskmodelres.planningDate);
    });

    setState(() {
      pass = true;
      //image = null;
      dataInfo = new Map();
      taskCU = true;
      //image2 = null;
    });

    for(var sectionform in form.sections){
      for(var fieldform in sectionform.fields){
        dataInfo.putIfAbsent(fieldform.id.toString() ,()=> '');
        dataInfo[fieldform.id.toString()] = '';
      }
    }
    for(var list in taskOne.customValues){
      var varValue = '';
      if(list.field.fieldType == 'Photo'){
        varValue = list.imageBase64;
      }
      if(list.field.fieldType == 'TextArea'){
        varValue = list.value;
      }
      dataInfo.putIfAbsent(list.field.id.toString() ,()=> varValue);
      dataInfo[list.field.id.toString()] = varValue;
    }

    await lisC(form);


  }

  @override
  Widget build(BuildContext context) {
    globalContext = context;
    return new Scaffold(
      appBar: AppBar(
        elevation: 12,
        backgroundColor: PrimaryColor,
        leading:  IconButton(
            icon: Icon(Icons.arrow_back,size: 25,),
            tooltip: 'Guardar tarea',
            iconSize: 35,
            onPressed: ()=> showDialog(
                context: context,
                builder: (BuildContext context) {
                  return
                    Container(
                      width: MediaQuery.of(context).size.width *0.9,
                      child: AlertDialog(
                        title: Text('Desea guardar tarea'),
                        actions: <Widget>[
                          Row(
                            children: <Widget>[
                              FlatButton(
                                child: const Text('SALIR'),
                                onPressed: () {
                                  Navigator.pushReplacementNamed(context, '/vistap');
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
                                  if(dataInfo.isNotEmpty) {
                                    saveTask.formId = formGlobal.id;
                                    saveTask.responsibleId = responsibleId;
                                    saveTask.name = formGlobal.name;
                                    saveTask.customerId = directionClientIn.id;
                                    if(widget.toBusiness == true ){
                                      saveTask.businessId = widget.businessAs.id;
                                    }
                                    if( directionClientIn.googlePlaceId != null) {
                                      if(directionClientIn.id == null) {
                                        AddressModel auxAddressModel = new AddressModel(
                                            address: directionClientIn.address ,
                                            latitude: directionClientIn.latitude,
                                            longitude: directionClientIn.longitude,
                                            googlePlaceId: directionClientIn.googlePlaceId
                                        );
                                        var responseCreateAddress = await createAddress(auxAddressModel,customer,token);
                                        if(responseCreateAddress.statusCode == 200 || responseCreateAddress.statusCode == 201){
                                          var directionAdd = AddressModel.fromJson(responseCreateAddress.body);
                                          saveTask.addressId = directionAdd.id;
                                        }
                                      } else {
                                        saveTask.customerId = directionClientIn.id;
                                        saveTask.addressId = directionClientIn.addressId;
                                      }
                                    }
                                    //SI VIENE DE VER TAREA Y NO EXISTE CLIENTE PERO SI DIRECCION
                                    if(widget.toListTask == true){
                                      if(widget.taskmodelres.addressId != null){
                                        saveTask.addressId = widget.taskmodelres.addressId;
                                      }
                                    }
                                    String minute;
                                    if(_timeTask.minute.toString().length < 2){
                                      minute = '0'+ _timeTask.minute.toString();
                                    }else{
                                      minute = _timeTask.minute.toString();
                                    }
                                    saveTask.planningDate = _dateTask.toString().substring(0,10) + ' ' + _timeTask.hour.toString() +':'+ minute+':00';
                                    saveTask.customValuesMap = dataInfo;
                                  await  saveTaskApi();
                                    if(taskEnd == 201 || taskEnd == 200){
                                      showDialog(
                                        context: context,
                                      builder: (BuildContext context) {
                                          return   AlertDialog(
                                            title: Text('Tarea guardada con exito'),
                                            actions: <Widget>[
                                              FlatButton(
                                                child: Text('ACEPTAR'),
                                                onPressed: () {
                                                  if(widget.toBusiness != true){
                                                    Navigator.pushReplacementNamed(context, '/vistap');
                                                  }else{
                                                    Navigator.pop(context);
                                                    Navigator.pop(context);
                                                    Navigator.of(context).pop();

                                                  }

                                                },
                                              ),
                                            ],
                                          );
                                      }
                                      );
                                    }else
                                    if(taskEnd == 422  || taskEnd == 413){
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return   AlertDialog(
                                              title: Text('Error al procesar la tarea por el Servidor'),
                                                content: Text('Calidad de imagen elevada. Considere enviar una imagen de menor calidad '),
                                              actions: <Widget>[
                                                FlatButton(
                                                  child: const Text('Aceptar'),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();

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
                                              title: Text('Ha ocurrido un error al crear la tarea'),
                                              actions: <Widget>[
                                                FlatButton(
                                                  child: const Text('Aceptar'),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();

                                                  },
                                                ),

                                              ],
                                            );
                                          }
                                      );
                                    }
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
        ) ,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.delete,size: 25,),
              tooltip: 'Descartar Formulario',
              iconSize: 35,
              onPressed: ()=> showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return
                      AlertDialog(
                        title: Text('Desea descartar Formulario'),
                        actions: <Widget>[
                          FlatButton(
                            child: const Text('CANCELAR'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          FlatButton(
                            child: const Text('ACEPTAR'),
                            onPressed: (){
                              setState(() {
                                dataInfo = new Map();
                                pass= false;
                                //  dropdownValue = null;
                                image = null;
                                taskCU = false;
                                image2= null;
                                listFieldsModels.clear();
                              });
                              Navigator.pop(context);
                            },
                          )
                        ],
                      );

                  }
              )
          )
        ],
        title: widget.toListTask == true ? Text('Detalle de Tarea ' + widget.taskmodelres.name.toString(), style: TextStyle(fontSize: 15),)
                                 : Text('Agregar Tareas', style: TextStyle(fontSize: 20),),
      ),
      body:  pass? ListView(

        children: <Widget>[

          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.8,
            child: Column(
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.65, //0.4
                  child: returnsStack(),
                ),
                Row(
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width ,
                      height: MediaQuery.of(context).size.height * 0.05, //0.2
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: directionClientIn.address != null ? Text('Direccion:  ${directionClientIn.address}',style: TextStyle(fontSize: 15),)
                              : widget.toListTask == true ?
                                widget.taskmodelres.address != null ? Text('Direccion:  ${widget.taskmodelres.address.address}',style: TextStyle(fontSize: 15),)
                                                                    : Text('Direccion: Sin Asignar')
                                : Text('Direccion: Sin Asignar')
                      ),

                    ),

                  ],
                ),

                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.05, //0.2
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: taskCU  ? Text('Fecha:   ${_dateTask.toIso8601String().substring(0,10)}   ${_timeTask.format(context)}',style: TextStyle(fontSize: 15),): Text('Fecha: Sin asignar'),
                  ),

                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.05, //0.2
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: directionClientIn.name != null ? Text('Cliente : ${directionClientIn.name} ',style: TextStyle(fontSize: 15),):Text('Cliente: Sin Asignar'),
                  ),

                ),
              ],
            ),
          )

        ],
      ) : Center(child: Text('Seleccione un Formulario')),



      bottomNavigationBar: BottomAppBar(
        color: PrimaryColor,
        child: new Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
                icon: Icon(Icons.menu,color: pass? Colors.white: Colors.grey),
                onPressed: () => pass ?  _showModalDateTimeAndDirections(): null
            ),
            IconButton(
                icon: Icon(Icons.business,color: Colors.white,),
                onPressed: () {
                  showModalBottomSheet<String>(
                      context: context,
                      builder: (BuildContext context) {
                        return  Container(
                          height: MediaQuery.of(context).size.height * 0.3,
                          child: buildListTypeForm(),
                        );
                      }
                  );
                }
            ),
          ],
        ),
      ),
    );
  }


buildListTypeForm(){
  FormTypeBloc _bloc = new FormTypeBloc();
  return StreamBuilder<List<FormModel>>(
      stream: _bloc.outForm,
      initialData: <FormModel>[],
      builder: (context, snapshot) {
        if(snapshot != null){
          if (snapshot.data.isNotEmpty) {
            return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    leading: Icon(Icons.poll),
                    title: Text('${snapshot.data[index].name.toString()}'),
                    onTap: () async {
                      var getFormResponse = await getForm(snapshot.data[index].id.toString(), customer, token);
                      FormModel form = FormModel.fromJson(getFormResponse.body);
                      await lisC(form);
                      setState(() {
                        //   dropdownValue = null;
                        pass = true;
                        image = null;
                        dataInfo = new Map();
                        taskCU = false;
                        image2 = null;
                      });
                      Navigator.pop(context);

                    },
                  );
                }
            );
          }else{
            if(snapshot.connectionState == ConnectionState.waiting){
              return new Center(
                child: CircularProgressIndicator(),
              );
            }else{
              return new Container(
                child: Center(
                  child: Text("No hay Formularios"),
                ),);
            }
          }
        }

      }

  );
}

  bool findKeys(String key){
    for(var k in data.keys){
      if(k == key){
        return true;
      }
    }
    return false;
  }

  void initDataTable(List<FieldOptionModel> listOptions){
    if(!findKeys('table')){
      data["table"] = new Map();

      for(FieldOptionModel varV in listOptions)
      {
        data["table"][varV.name] = new Map();
        data["table"][varV.name]["name"] = varV.name;
        data["table"][varV.name][varV.value.toString()] = new TextEditingController();
      }
    }
  }
conC(String value){
    if(value != null){
    }
}
  String savedDataTablet(){
    String dat="";
    var keys = data.keys;
    if(!keys.contains("table")){
      return dat;
    }else{
      var titules = data["table"].keys;
      for(String titule in titules){
        dat = dat + titule + "*" ;
      }
      dat = dat + ';';
      for(String titule in titules){
        Map dataColumn = data["table"][titule];
        for (var key in dataColumn.keys){
          if(key != "name"){
            dat = dat +  data["table"][titule][key].text;
          }
        }
        dat = dat + "*";
      }
    }
    return dat;
  }
  Widget generatedTable(List<FieldOptionModel> listOptions, String id){
    initDataTable(listOptions);
    valuesTable = savedDataTablet();
    saveData(valuesTable,id);
    Card card(TextEditingController t){
      return Card(
        child: TextField(
          onChanged: (value){
          },
          controller: t,
          decoration: InputDecoration(
            hintText: '',
          ),
        ),
      );
    }

    //COLUMNAS
    Container columna(Map column, bool colorcolum){
      List<Widget> listCard = new List<Widget>();
      for(var key in column.keys){
        if(key != 'name'){
          listCard.add(card(column[key]));
        }
      }

      return Container(
        width: MediaQuery.of(context).size.width * 0.5,
        height: MediaQuery.of(context).size.height *(listCard.length*0.1),
        color: colorcolum ? Colors.blue[50] : Colors.grey[200],
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width * 0.5,
              height: MediaQuery.of(context).size.height *(listCard.length*0.05),
              child: Card(
                child: Center(
                    child: Text(column["name"])
                ),
              ),
            ),

            Divider(
              height: 20,
              color: Colors.black,
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.5,
              height: MediaQuery.of(context).size.height *(listCard.length*0.1),
              child: ListView.builder(
                itemCount: listCard.length,
                itemBuilder: (context,index){
                  return listCard[index];
                },
              ),
            )
          ],
        ),
      );
    }

    //LISTA DE COLUMNAS
    List<Widget> listColuma = new List<Widget>();
    Map column = data["table"];
    bool colorcolum = false;
    for(var key in column.keys)
    {
      if(colorcolum){colorcolum = false;}else{colorcolum = true;}
      listColuma.add(columna(column[key],colorcolum));
    }

    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.all(10),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.3,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: listColuma.length,
          itemBuilder: (context,index){
            return listColuma[index];
          },
          // This next line does the trick.
        ) ,
      ),
    );

  }
  Future<Uint8List> getImg() async{
    return showDialog<Uint8List>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return PickerImg();
      },
    );
  }
  Future<Uint8List> getImgNetWork(String netImage) async{
    return showDialog<Uint8List>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return PickerImgNetwork(netImage: netImage,);
      },
    );
  }
  Future<Uint8List> photoAndImage() async{
    return showDialog<Uint8List>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return TomarImage();
      },
    );
  }
  String base64String(Uint8List data) {
    return base64Encode(data);
  }
  Image imageFromBase64String(String base64String) {
    return Image.memory(base64Decode(base64String));
  }
  Uint8List dataFromBase64String(String base64String) {
    return base64Decode(base64String);
  }
  Stack returnsStack(){
    return Stack(
      children: <Widget>[
        ListView.builder(
            itemCount: listFieldsModels.length,
            itemBuilder: (BuildContext context, index){
              if(listFieldsModels[index].fieldType == null)
              {
                return Center(child: Text('Sin datos'),);
              }
              if(listFieldsModels[index].fieldType == 'Button'||listFieldsModels[index].fieldType == "button")
              {
                return Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 70),
                      child: Container(
                          child: new Checkbox(
                              value: _value1,
                              onChanged: _value1Changed
                          )
                      ),
                    ),
                    Spacer(),
                    Container(
                      width: MediaQuery.of(context).size.width *0.5,
                      height: MediaQuery.of(context).size.height *0.1,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 60, top: 10),
                          child: _value1 == true ? Text('${listFieldsModels[index].type}',style: TextStyle(fontSize: 20),)
                          : Text(''),
                        ),

                      ),
                    ),
                  ],
                );
              }
              if(listFieldsModels[index].fieldType == 'TextArea' ||  listFieldsModels[index].fieldType == 'Textarea'||  listFieldsModels[index].fieldType == "TextArea"){
                //TEXTAREA
                return Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Container(
                    width: MediaQuery.of(globalContext).size.width,
                    height: 150,
                    padding: EdgeInsets.only(
                        top: 4,left: 16, right: 16, bottom: 4
                    ),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                            Radius.circular(10)
                        ),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black12,
                              blurRadius: 5
                          )
                        ]
                    ),
                    child: TextField(
                      controller: new TextEditingController(text: dataInfo[listFieldsModels[index].id.toString()]),
                      onChanged: (value){
                        saveData(value,listFieldsModels[index].id.toString());
                      },
                      maxLines: 4,
                      //controller: nameController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: listFieldsModels[index].name,
                      ),
                    ),
                  ),
                );
              }
              if(listFieldsModels[index].fieldType == 'Text'){
                //TEXT
                return  Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Container(
                    width: MediaQuery.of(globalContext).size.width,
                    height: 40,
                    padding: EdgeInsets.only(
                        top: 4,left: 16, right: 16, bottom: 4
                    ),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                            Radius.circular(10)
                        ),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black12,
                              blurRadius: 5
                          )
                        ]
                    ),
                    child: TextField(
                      controller: new TextEditingController(text: dataInfo[listFieldsModels[index].id.toString()]),
                      onChanged: (value){
                        saveData(value,listFieldsModels[index].id.toString());
                      },
                      maxLines: 1,
                      //controller: nameController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: listFieldsModels[index].name,
                      ),
                    ),
                  ),
                );
              }
              if(listFieldsModels[index].fieldType == 'Number'){
                return  Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Container(
                    width:  40,
                    height: 40,
                    padding: EdgeInsets.only(
                        top: 4,left: 16, right: 16, bottom: 4
                    ),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                            Radius.circular(10)
                        ),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black12,
                              blurRadius: 5
                          )
                        ]
                    ),
                    child: TextField(
                      controller: new TextEditingController(text: dataInfo[listFieldsModels[index].id.toString()]),
                      onChanged: (value){
                        saveData(value,listFieldsModels[index].id.toString());
                      },
                      keyboardType: TextInputType.number,
                      maxLines: 1,
                      // controller: nameController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: listFieldsModels[index].name,
                      ),
                    ),
                  ),
                );
              }
              if(listFieldsModels[index].fieldType == 'Combo'){

                List<String> dropdownMenuItems = List<String>();
                for(FieldOptionModel v in listFieldsModels[index].fieldOptions){
                  dropdownMenuItems.add(v.name);
                }
                return Container(
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
                  child: new  Padding(
                    padding: const EdgeInsets.only(left: 20,right: 10,bottom: 10,top: 10),
                    child: Container(
                      width: MediaQuery.of(context).size.width *0.5,
                      child: new DropdownButton<String>(
                        isExpanded: true,
                        underline: Container(),
                        isDense: false,
                        icon: Icon(Icons.arrow_drop_down),
                        elevation: 10,
                        value: dataInfo[listFieldsModels[index].id],
                        hint:  dataInfo[listFieldsModels[index].id.toString()] != null  ? Text(dataInfo[listFieldsModels[index].id.toString()]): Text(listFieldsModels[index].name),

                        onChanged: (newValue) {

                          setState(() {
                            //dropdownValue = newValue;
                            dataInfo.putIfAbsent(listFieldsModels[index].id.toString() ,()=> newValue);
                          });

                        },
                        items: dropdownMenuItems.map<DropdownMenuItem<String>>((String value) {
                          return new DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                );
              }

              if(listFieldsModels[index].fieldType == 'Date'){
                return Row(
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(top: 1,left: 16),
                              child: Text(listFieldsModels[index].name),
                            ),
                          ],
                        ),

                      ],

                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: RaisedButton(
                        child: dataInfo[listFieldsModels[index].id.toString()] != null ? Text('${_date.toString().substring(0,10)}') : Text('Sin Asignar'),
                        onPressed: (){selectDate(context);
                        saveData(_date.toString().substring(0,10),listFieldsModels[index].id.toString());

                        },
                      ),
                    ),
                  ],
                );
              }
              if(listFieldsModels[index].fieldType == 'DateTime'){
                return Row(
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(top: 1,left: 16),
                              child: Text(listFieldsModels[index].name),
                            ),
                          ],
                        ),

                      ],

                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: RaisedButton(
                        child: Text('${_dateDT.toString().substring(0,10)}' + ' ' +'${_timeDT.format(context) }'),
                        onPressed: (){
                          selectTimeDatetime(context);
                          selectDateDateTime(context);
                          var dateCo = _dateDT.toString().substring(0,10) + ' ' +_timeDT.format(context).toString();
                          saveData(dateCo.toString(),listFieldsModels[index].id.toString());
                        },
                      ),
                    ),
                  ],
                );
              }
              if(listFieldsModels[index].fieldType =='Table'){
                return generatedTable(listFieldsModels[index].fieldOptions, listFieldsModels[index].id.toString(),);
              }
              if(listFieldsModels[index].fieldType == 'Time')
              {
                saveData(_time.format(context).toString(), listFieldsModels[index].id.toString()) ;
                return new Row(
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(top: 1,left: 16),
                              child: Text(listFieldsModels[index].name),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: RaisedButton(
                        child: dataInfo[listFieldsModels[index].id.toString()] != null ? Text('${_time.format(context).toString()}') : Text('Sin Asignar'),
                        onPressed: (){
                          selectTime(context);
                          setState(() {
                            saveData(_time.format(context).toString(), listFieldsModels[index].id.toString()) ;
                          });

                        },

                      ),
                    ),
                  ],
                );
              }
              if(listFieldsModels[index].fieldType == 'Photo'){
                Uint8List img;
                String b64;

                return  Container(

                  child: Row(
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(top: 10,left: 5,bottom: 30),
                                child: RaisedButton(
                                  onPressed: () async{
                                    img = await photoAndImage();
                                    if (img != null) {
                                      setState(() {
                                        b64 = base64String(img);
                                        image2 = Image.memory(img);
                                        saveData(b64, listFieldsModels[index].id.toString());
                                      });
                                    }
                                  },
                                  child: Text(listFieldsModels[index].name),
                                  color: PrimaryColor,
                                ),
                              ),
                            ],
                          ),
                       /*   Container(
                            width: MediaQuery.of(globalContext).size.width*0.50,
                            height: 40,
                            padding: EdgeInsets.only(
                                top: 20,left: 20, right: 16, bottom: 4
                            ),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(10)
                                ),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 5
                                  )
                                ]
                            ),
                            child: TextField(
                              onChanged: (value){
                              },
                              maxLines: 1,
                              //controller: nameController,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Comentario ',
                              ),
                            ),
                          ),*/
                        ],
                      ),
                      Spacer(

                      ),
                      Container(
                        width: MediaQuery.of(context).size.width* 0.5,
                        child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                  child: Card(color: Colors.white,child: SizedBox(height: 200,width: 300,
                                      child:  dataInfo[listFieldsModels[index].id.toString()] != null ?  Image(image: imageFromBase64String(dataInfo[listFieldsModels[index].id.toString()]).image,)
                                                                                                        :Center(child: Text('Sin Asignar',style: TextStyle( color: PrimaryColor),),)),)),
                            )),
                      ),
                    ],
                  ),
                );
              }
              if(listFieldsModels[index].fieldType == 'Image'){
                return Row(
                  children: <Widget>[

                    Container(
                      child:Center(
                        child: listFieldsModels[index].name.length >20 ?  new Text(listFieldsModels[index].name.substring(0,11),style: TextStyle(
                            color: PrimaryColor),
                        ): Text(listFieldsModels[index].name,style: TextStyle(color: PrimaryColor),),
                      ),
                    ),
                    Spacer(),
                    Column(
                      children: <Widget>[
                        Image.network(listFieldsModels[index].fieldDefaultValue,height: MediaQuery.of(context).size.height*0.25,),
                      ],

                    ),
                  ],
                );

              }
              if(listFieldsModels[index].fieldType == 'Label'){
                return Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(listFieldsModels[index].name,style: TextStyle(
                    fontSize: 20,
                  ),
                  ),
                );

              }
              if(listFieldsModels[index].fieldType == 'CanvanSignature'){
                String b64;
                return  Row(
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Container(
                          child: Row(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(top: 10,left: 5,bottom: 30),
                                child: RaisedButton(
                                  onPressed: () async{
                                    //File img = await ImagePicker.pickImage(source: ImageSource.camera);
                                    var bytes = await getImg();
                                    Image img = Image.memory(bytes);
                                    if (img != null) {
                                      setState(() {
                                        b64 = base64String(bytes);
                                        dataInfo.putIfAbsent( listFieldsModels[index].id.toString(),()=> image.toString());
                                        image = img;
                                        saveData(b64.toString(), listFieldsModels[index].id.toString());
                                      });
                                    }
                                  },
                                  child:Center(child: listFieldsModels[index].name.length > 15 ? Text(listFieldsModels[index].name.substring(0,14) + '...') :  Text(listFieldsModels[index].name)),
                                  color: PrimaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),

                    /*    Container(
                          width: MediaQuery.of(globalContext).size.width*0.50,
                          height: 40,
                          padding: EdgeInsets.only(
                              top: 20,left: 20, right: 16, bottom: 4
                          ),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                  Radius.circular(10)
                              ),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 5
                                )
                              ]
                          ),
                          child: TextField(
                            onChanged: (value){
                            },
                            maxLines: 1,
                            //controller: nameController,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Comentario ',
                            ),
                          ),
                        ),*/
                      ],

                    ),
                    Spacer(

                    ),
                    Container(
                      width: MediaQuery.of(context).size.width* 0.5,
                      child: Center(
                          child: Container(
                              child: Card(color: Colors.white,child: SizedBox(height: 200,width: 250,
                                  child:  dataInfo[listFieldsModels[index].id.toString()] != null ? Image(image: imageFromBase64String(dataInfo[listFieldsModels[index].id.toString()]).image,height: 200,width:300 ,):Center(child: Text('Sin Asignar',style: TextStyle( color: PrimaryColor),),)),))),
                    ),
                  ],
                );
              }
              if(listFieldsModels[index].fieldType == 'CanvanImage'){
                String b64;
                return  Row(
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Container(
                          child: Row(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(top: 10,left: 5,bottom: 30),
                                child: RaisedButton(
                                  onPressed: () async{
                                    //File img = await ImagePicker.pickImage(source: ImageSource.camera);
                                    var bytes = await getImgNetWork(listFieldsModels[index].fieldDefaultValue);
                                    Image img = Image.memory(bytes);
                                    if (img != null) {
                                      setState(() {
                                        b64 = base64String(bytes);
                                        dataInfo.putIfAbsent( listFieldsModels[index].id.toString(),()=> image.toString());
                                        image = img;
                                        saveData(b64.toString(), listFieldsModels[index].id.toString());
                                      });
                                    }
                                  },
                                  child:listFieldsModels[index].name.length > 15 ? Text(listFieldsModels[index].name.substring(0,15) + '...') :  Text(listFieldsModels[index].name),
                                  color: PrimaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),

                      ],
                    ),
                    Spacer(

                    ),
                    Container(
                      width: MediaQuery.of(context).size.width* 0.5,
                      child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                                child: Card(color: Colors.white,child: SizedBox(height: 200,width: 300,
                                  child:  dataInfo[listFieldsModels[index].id.toString()] != null ? Image(image: imageFromBase64String(dataInfo[listFieldsModels[index].id.toString()]).image,):Center(child: Text('Sin asignar',style: TextStyle( color: PrimaryColor),),)),)),
                          )),
                    ),

                  ],
                );

              }
              if(listFieldsModels[index].fieldType == 'Boolean')
              {
              //  for(FieldOptionModel v in listFieldsModels[index].fieldOptions){}
                return Row(
                  children: <Widget>[
                    Container(
                        width: MediaQuery.of(context).size.width*0.5,
                        child:Row(
                          children: <Widget>[
                          ],
                        )
                    ),
                  ],

                );
              }
              if(listFieldsModels[index].fieldType == 'ComboSearch')
              {

                return Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Container(
                        width: MediaQuery.of(context).size.width*0.5,
                        height: 40,
                        padding: EdgeInsets.only(
                            top: 4,left: 16, right: 16, bottom: 4
                        ),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(
                                Radius.circular(10)
                            ),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 5
                              )
                            ]
                        ),
                        child: TextField(
                          controller: new TextEditingController(text: dataInfo[listFieldsModels[index].id.toString()]),
                          onChanged: (value){
                            saveData(value,listFieldsModels[index].id.toString());
                          },
                          maxLines: 1,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: listFieldsModels[index].name,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.search),
                      tooltip: 'Busqueda',
                      iconSize: 20,
                      onPressed: (){},
                    ),

                  ],
                );
              }
            }
        ),


      ],
    );
  }
  void _value1Changed(bool value) => setState(() => _value1 = value);


  addDirection() async{
    CustomerWithAddressModel resp = await getDirections();
    if(resp != null) {
      setState(() {
        directionClientIn = resp;

      });
    }
  }
  Future<Null> selectDate(BuildContext context )async{
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
  Future<Null> selectDateTask(BuildContext context )async{
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: _dateTask,
        firstDate: new DateTime(2000),
        lastDate: new DateTime(2020)
    );
    if (picked != null && picked != _dateTask){
      setState(() {
        _dateTask = picked;
      });

    }

  }
  Future<Null> selectTimeTask(BuildContext context )async{
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: _timeTask,
    );
    if (picked != null && picked != _timeTask){
      setState(() {
        _timeTask = picked;
      });
    }
  }
  Future<Null> selectTime(BuildContext context )async{
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    if (picked != null && picked != _time){
      setState(() {
        _time = picked;
      });
    }
  }
  Future<Null> selectTimeDatetime(BuildContext context )async{
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: _timeDT,
    );
    if (picked != null && picked != _timeDT){
      setState(() {
        _timeDT = picked;
      });
    }
  }
  Future<Null> selectDateDateTime(BuildContext context )async{
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: _dateDT,
        firstDate: new DateTime(2000),
        lastDate: new DateTime(2020)
    );
    if (picked != null && picked != _dateDT){
      setState(() {
        _dateDT = picked;
      });

    }

  }
  Future<CustomerWithAddressModel> getDirections() async{
    return showDialog<CustomerWithAddressModel>(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return SearchAddressWithClient();
      },
    );
  }
  Future<bool> lisC(FormModel form)async {
    //listFieldsModels.clear();
    List<FieldModel> listFieldsModelsCopia = List<FieldModel>();
    setState(() {
      formGlobal = form;
      listFieldsModels.clear();
    });
    for(SectionModel section in form.sections){
      for(FieldModel fields in section.fields){
        listFieldsModelsCopia.add(fields);
      }
    }
    listFieldsModels = listFieldsModelsCopia;
    return true;
  }
  pickerImage(Method m) async {
    File img = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (img != null) {
      setState(() {
        image = Image.file(img);
      });
    }
  }
  pickerPhoto(String name) async {}
  Widget buildView(){
    return  ListView.builder(
        itemBuilder: (BuildContext context, int index) {

        }
    ) ;
  }
  getAll()async{
    FormsModel forms;
    FormsModel formType;
    await getElements();
    http.Response getAllFormsResponse = await getAllForms(customer , token);
    try{
      if(getAllFormsResponse.statusCode == 200){
        //  print(getAllFormsResponse.headers['content-type']);
        forms = FormsModel.fromJson(getAllFormsResponse.body);
        formType = forms;

      }
    }catch(e){

    }
    return formType;
  }
  initFormsTypes() async {
    formType = await getAll();
  }
  getElements()async{
    userToken = await ClientDatabaseProvider.db.getCodeId('1');
    token = userToken.token;
    customer = userToken.company;
    user = userToken.name;
    responsibleId = userToken.idUserCompany;
  }
  void _showModalDateTimeAndDirections() {

    showModalBottomSheet<void>(
        context: context,
        builder: (BuildContext context) {
          return new Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new ListTile(
                leading: new Icon(Icons.location_on),
                title: new Text('Lugar' + '  '),
                onTap: () {
                  Navigator.pop(context);
                  addDirection();
                },
              ),
              new ListTile(
                leading: new Icon(Icons.access_time),
                title: new Text('Hora' + '    '),
                onTap: () {

                  Navigator.pop(context);
                  selectTimeTask(globalContext);
                  selectDateTask(globalContext);
                  setState(() {
                    taskCU= true;
                  });
                },
              ),
            ],
          );
        });
  }
   Future<bool> saveTaskApi() async{
   var createTaskResponse = await createTask(saveTask, customer, token);
   if(createTaskResponse.statusCode == 201 || createTaskResponse.statusCode == 200){
     setState(() {
       taskEnd = createTaskResponse.statusCode;
     });
   }
     if(createTaskResponse.statusCode == 500){
       setState(() {
         taskEnd = 500;
       });
     }
   if(createTaskResponse.statusCode == 413 || createTaskResponse.statusCode == 422 ){
     setState(() {
       taskEnd = createTaskResponse.statusCode;
     });
   }
  return true;
  }
  void saveData(String dataController, String id) {
    var value = dataController;
    dataInfo.putIfAbsent(id ,()=> value);
    dataInfo[id] = value;
  }

}

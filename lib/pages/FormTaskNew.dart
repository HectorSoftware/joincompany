import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:joincompany/Menu/ImageAndPhoto.dart';
import 'package:joincompany/async_database/Database.dart';
import 'package:joincompany/blocs/blocTypeForm.dart';
import 'package:joincompany/models/AddressModel.dart';
import 'package:joincompany/models/UserModel.dart';
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
import 'package:joincompany/models/WidgetsList.dart';
import 'package:joincompany/pages/BuscarRuta/searchAddressWithClient.dart';
import 'package:joincompany/pages/ImageBackNetwork.dart';
import 'package:joincompany/pages/canvasIMG/pickerImg.dart';
import 'package:joincompany/services/FormService.dart';
import 'package:joincompany/services/TaskService.dart';

class FormTask extends StatefulWidget {

  FormTask({this.directionClient,this.toBusiness=false,this.businessAs,this.taskmodelres,this.toListTask=false});
  final CustomerWithAddressModel  directionClient;
  final bool toBusiness;
  final BusinessModel businessAs;
  final TaskModel taskmodelres;
  final bool toListTask;

  @override
  _FormTaskState createState() => new _FormTaskState();

}
class _FormTaskState extends State<FormTask> {
  bool isSwitched = true;
  SentryClient sentry;
  Image image;
  Image image2;
  TimeOfDay _time = new TimeOfDay(hour: 0, minute: 0);
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
  UserModel userToken;
  String token,customer, user;
  int responsibleId;
  FormsModel formType;
  bool taskCU = false;
  bool pass= false;
  int taskEnd;
  bool _value1 = false;
  bool flag = false;
  CustomerWithAddressModel  directionClient = new  CustomerWithAddressModel();
  TaskModel saveTask = new TaskModel();
  CustomerWithAddressModel  directionClientIn= new  CustomerWithAddressModel();
  String defaultValue = 'NO';
  String valuesTable = '';
  TaskModel taskOne;
  List<String> searchList = new List<String>();
  static LatLng _initialPosition;

  @override
  void initState(){
    _getUserLocation();
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
                                  if(dataInfo.isNotEmpty) {
                                    saveTask.formId = formGlobal.id;
                                    saveTask.responsibleId = responsibleId;
                                    saveTask.name = formGlobal.name;
                                    saveTask.customerId = directionClientIn.id;
                                    if(widget.toBusiness){
                                      saveTask.businessId = widget.businessAs.id;
                                      saveTask.customerId = widget.businessAs.customerId;
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
                                          var directionAdd = responseCreateAddress.body;
                                          saveTask.addressId = directionAdd.id;
                                        }
                                      } else {
                                        saveTask.addressId = directionClientIn.addressId;
                                      }
                                    }
                                    //SI VIENE DE VER TAREA Y NO EXISTE CLIENTE PERO SI DIRECCION
                                    if(widget.toListTask){
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
                                      showToast('Tarea Creada');
                                      Navigator.of(context).pop();
                                      Navigator.of(context).pop();
                                      Navigator.pushReplacementNamed(context, '/vistap');
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
      // ignore: missing_return
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
                      FormModel form = getFormResponse.body;
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

  bool checkKeyInTable(String key){
    for(String k in data["table"].keys){
      if(k.toLowerCase() == key.toLowerCase()){
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
        varV.name = varV.name.replaceAll("Item", "");
        var split = varV.name.split('x');
        if(!checkKeyInTable(split[1])){
          data["table"][split[1]] = new Map();
        }

        data["table"][split[1]]["name"] = split[1];
        data["table"][split[1]][varV.name] = new TextEditingController();
      }
    }
  }

  bool seachKeyInData(String key){
    for(var k in data.keys){
      if(k.toLowerCase() == key.toLowerCase()){
        return true;
      }
    }
    return false;
  }

  String savedDataTablet(){
    String dat="";
    var keys = data.keys;
    if(!keys.contains("table")){
      return dat;
    }else{
      for(String k in  data["table"].keys){
        for(String Sk in data["table"][k].keys){
          if(data["table"][k][Sk] is TextEditingController){
            String value = data["table"][k][Sk].text != "" ? data["table"][k][Sk].text : " ";
            dat = dat + "$Sk:$value;";
          }
        }
      }
    }
    return dat;
  }

  Widget generatedTable(List<FieldOptionModel> listOptions, String id){
    initDataTable(listOptions);

    saveData(savedDataTablet(),id);
    Card card(TextEditingController t){
      return Card(
        child: TextField(
          keyboardType: TextInputType.number,
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
      for(String key in column.keys){
        if(key != 'name'){
          listCard.add(card(column[key]));
        }
      }
      if(listOptions.isNotEmpty){
        return Container(
          width: MediaQuery.of(context).size.width * 0.5,
          height: MediaQuery.of(context).size.height *(listCard.length*0.1),
          color: colorcolum ? Colors.blue[50] : Colors.grey[200],
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width * 0.6,
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
      }else{
        return Container();
      }

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
        height: MediaQuery.of(context).size.height * 0.4,
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
            // ignore: missing_return
            itemBuilder: (BuildContext context, index){


              if(listFieldsModels[index].fieldType == null){
                return Center(child: Text('Sin datos'),);
              }
              // ignore: missing_return
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
              // ignore: missing_return
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
              if(listFieldsModels[index].fieldType == 'Label'){
                return Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(listFieldsModels[index].name,style: TextStyle(
                    fontSize: 20,
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
                        child: dataInfo[listFieldsModels[index].id.toString()] != null ? Text('${dataInfo[listFieldsModels[index].id.toString()]}') : Text('Sin Asignar'),
                        onPressed: ()async {
                            var cambio = await selectDate(context);
                            if(cambio){
                              saveData(_date.toString().substring(0,10),listFieldsModels[index].id.toString());
                              setState(() {});
                            }
                        },
                      ),
                    ),
                  ],
                );

              }
              if(listFieldsModels[index].fieldType == 'Time')
              {
                //saveData('Sin Asignar', listFieldsModels[index].id.toString()) ;
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
                        child: dataInfo[listFieldsModels[index].id.toString()] != null ? Text(dataInfo[listFieldsModels[index].id.toString()]) : Text('Sin Asignar'),
                        onPressed: () async {
                          var cambio = await selectTime(context);
                          if(cambio){
                            saveData(_time.format(context).toString(), listFieldsModels[index].id.toString()) ;
                            setState(() {});
                          }
                        },
                      ),
                    ),
                  ],
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
                        child: dataInfo[listFieldsModels[index].id.toString()] != null  ? Text(dataInfo[listFieldsModels[index].id.toString()]): Text('Sin Asignar'),
                        onPressed: () async {
                          var cambioF = await selectDateDateTime(context);
                          var cambioH = await selectTimeDatetime(context);
                          if(cambioF && cambioH){
                            var dateCo = _dateDT.toString().substring(0,10) + ' ' +_timeDT.format(context).toString();
                            saveData(dateCo.toString(),listFieldsModels[index].id.toString());
                          }
                          setState(() {});
                        },
                      ),
                    ),
                  ],
                );
              }
              if(listFieldsModels[index].fieldType == 'Button')
              {
                return Container(
                  margin: EdgeInsets.only(top: 30,bottom: 30),
                    width: MediaQuery.of(context).size.width*0.5,
                    child:Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        RaisedButton(
                          onPressed: (){
                            saveData( '${_initialPosition.latitude} , ${_initialPosition.longitude}' ,listFieldsModels[index].id.toString());
                            setState(() {});
                          },
                          child: Text(listFieldsModels[index].name),
                        ),
                        Container(
                          child: dataInfo[listFieldsModels[index].id.toString()] != null  ? Text(dataInfo[listFieldsModels[index].id.toString()]): Text('Sin Asignar'),
                          margin: EdgeInsets.only(left: 30),
                        )
                      ],
                    )
                );
              }
              if(listFieldsModels[index].fieldType == 'Boolean'){
                saveData(_value1.toString(),listFieldsModels[index].id.toString());
                return Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 70),
                      child: Container(
                          child: new Checkbox(
                              value: _value1,
                              onChanged: (value){
                                setState(() {
                                  _value1 = value;
                                });
                                saveData(value.toString(),listFieldsModels[index].id.toString());
                              }
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
                          child: Text('${listFieldsModels[index].name}',style: TextStyle(fontSize: 20),),
                        ),
                      ),
                    ),
                  ],
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

              if(listFieldsModels[index].fieldType =='Table'){
                return generatedTable(listFieldsModels[index].fieldOptions, listFieldsModels[index].id.toString(),);
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
                        ): Text(listFieldsModels[index].name,style: TextStyle(color: PrimaryColor,fontSize: 25),),
                      ),
                      margin: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.13),
                    ),
                    Spacer(),
                    Column(
                      children: <Widget>[
                        Image.file(listFieldsModels[index].image,height: MediaQuery.of(context).size.height*0.25,),
                      ],

                    ),
                  ],
                );
              }


              if(listFieldsModels[index].fieldType == 'ComboSearch'){

                if(!seachKeyInData('ComboSearch')){
                  data['ComboSearch'] = TextEditingController(text: dataInfo[listFieldsModels[index].id.toString()]);
                }

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width*0.5,
                          height: MediaQuery.of(context).size.height * 0.06,
                          margin: EdgeInsets.only(top: 30,bottom: 1),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                  Radius.circular(10)
                              ),
                              color: Colors.white,

                          ),
                          child: TextField(
                            controller: data['ComboSearch'],
                            onChanged: (value){
                              searchList.clear();
                              setState(() {});

                              if(listFieldsModels[index].fieldOptions != null){
                                for(FieldOptionModel values in listFieldsModels[index].fieldOptions){
                                  if(values.name.toLowerCase().contains(value.toLowerCase()) && value.isNotEmpty){
                                    searchList.add(values.name);
                                    setState(() {});
                                  }
                                }
                              }
                            },
                            decoration: InputDecoration(

                              border: InputBorder.none,
                              hintText: listFieldsModels[index].name,
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 30,bottom: 1),
                          child: Icon(Icons.search)
                        ),
                      ],
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.3,
                      height: searchList.length * 60.0,
                      child: searchList.isNotEmpty ? ListView.builder(
                          itemCount: searchList.length,
                          itemBuilder: (BuildContext context, int inde){
                            return Card(
                              child: ListTile(
                                title: Text(searchList[inde],style: TextStyle(fontSize: 15),),
                                onTap: (){
                                  data['ComboSearch'].text = searchList[inde];
                                  searchList.clear();
                                  saveData(data['ComboSearch'].text,listFieldsModels[index].id.toString());
                                  setState(() {});
                                },
                              ),
                            );
                          },
                      ):Container(),
                    ),
                  ],
                );
              }
            }
        ),


      ],
    );
  }

  Future<bool> selectDate(BuildContext context )async{
    bool cambio = false;
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: _date,
        firstDate: new DateTime(2000),
        lastDate: new DateTime(2020)
    );
    if (picked != null){
        _date = picked;
        cambio = true;
    }
    return cambio;
  }

  Future<bool> selectDateTask(BuildContext context )async{
    bool cambio = false;
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: _dateTask,
        firstDate: new DateTime(2000),
        lastDate: new DateTime(2020)
    );
    if (picked != null){
      setState(() {
        _dateTask = picked;
      });
      cambio = true;
    }
    return cambio;
  }

  Future<bool> selectTimeTask(BuildContext context )async{
    bool cambio = false;
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: _timeTask,
    );
    if (picked != null){
      setState(() {
        _timeTask = picked;
      });
      cambio = true;
    }
    return cambio;
  }

  Future<bool> selectTime(BuildContext context )async{
    bool cambio = false;
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null){
       _time = picked;
       cambio = true;
    }
    return cambio;
  }

  Future<bool> selectTimeDatetime(BuildContext context )async{
    bool cambio = false;
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: _timeDT,
    );
    if (picked != null){
      _timeDT = picked;
      cambio = true;
    }
    return cambio;
  }

  Future<bool> selectDateDateTime(BuildContext context )async{
    bool cambio = false;
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: _dateDT,
        firstDate: new DateTime(2000),
        lastDate: new DateTime(2020)
    );
    if (picked != null){
       _dateDT = picked;
      cambio = true;
    }
    return cambio;
  }

  addDirection() async{
    CustomerWithAddressModel resp = await getDirections();
    if(resp != null) {
      setState(() {
        directionClientIn = resp;

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
    var getAllFormsResponse = await getAllForms(customer , token);
    try{
      if(getAllFormsResponse.statusCode == 200){
        forms = getAllFormsResponse.body;
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
    userToken = await DatabaseProvider.db.RetrieveLastLoggedUser();
    token = userToken.rememberToken;
    customer = userToken.company;
    user = userToken.name;
    responsibleId = userToken.id;
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
                onTap: () async {

                  Navigator.pop(context);
                  var date = await selectDateTask(globalContext);
                  var time = await selectTimeTask(globalContext);
                  if(date && time){
                    setState(() {taskCU= true;});
                  }
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

  Future _getUserLocation() async{
    try{
      Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _initialPosition = LatLng(position.latitude, position.longitude);
      });
    }catch(e){}
  }
}

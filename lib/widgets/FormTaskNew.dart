import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
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
import 'package:joincompany/pages/canvasIMG/pickerImg.dart';
import 'package:joincompany/services/FormService.dart';
import 'package:http/http.dart' as http;
import 'package:joincompany/Sqlite/database_helper.dart';
import 'package:joincompany/services/TaskService.dart';
import 'package:joincompany/widgets/prueba.dart';

class Combo{
  var value;
  var state;
  Combo({this.value, this.state});

}

class FormTask extends StatefulWidget {


  FormTask({this.directioncliente});
   final CustomerWithAddressModel  directioncliente;

  @override
  _FormTaskState createState() => new _FormTaskState();

}
class _FormTaskState extends State<FormTask> {

  Image image;
  File image2;

  TimeOfDay _time = new TimeOfDay.now();
  DateTime _date = new DateTime.now();
  DateTime _dateTask = new DateTime.now();
  TimeOfDay _timeTask = new TimeOfDay.now();
   Map<String,String> dataInfo = Map<String,String>();
  List<Map<String, String>> dataSaveState =  List<Map<String, String>>();
  BuildContext globalContext;
  List<FieldModel> listFieldsModels = List<FieldModel>();
  FormModel formGlobal;
  UserDataBase userToken ;
  String token;
  String customer;
  String user;
  int responsibleId;
  FormsModel formType;
  bool taskCU = false;
  bool pass = false;
  bool taskEnd = false;
  CustomerWithAddressModel  directionClient = new  CustomerWithAddressModel();
  TaskModel saveTask = new TaskModel();
  CustomerWithAddressModel  directioncliente;

  Map data = new Map();

  @override
  void initState(){
    directioncliente = widget.directioncliente;
    initFormsTypes();
    super.initState();
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
           tooltip: 'Guardar Tarea',
           iconSize: 35,
           onPressed: ()=> showDialog(
               context: context,
               builder: (BuildContext context) {
                 return
                   AlertDialog(
                     title: Text('Guardar'),
                     content: const Text(
                         'Desea Guardar Tarea'),
                     actions: <Widget>[
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

                          /* dataSaveState.clear();

                           List<Map<String, String>> listOfMaps = new List<Map<String, String>>();
                           dataInfo.forEach((key, value) {
                             listOfMaps.add({key: value});
                           }
                           );*/

                            if(dataInfo.isNotEmpty) {
                              saveTask.formId = formGlobal.id;
                              saveTask.responsibleId = responsibleId;
                              saveTask.name = formGlobal.name;
                              saveTask.customerId = directioncliente.customerId;
                              saveTask.addressId = directioncliente.addressId;
                              saveTask.planningDate = _dateTask.toString().substring(0,19);
                              saveTask.customValuesMap = dataInfo;
                              saveTaskApi(); //DESCOMETAR PARA GUARDAR TAREAS
                              Navigator.pop(context);
                              Navigator.of(context).pop(saveTask);
                            }

                         },
                       )
                     ],
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
                      title: Text('Descartar'),
                      content: const Text(
                          'Desea descartar Formulario'),
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
        title: Text('Agregar Tareas'),
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
                  height: MediaQuery.of(context).size.height * 0.70, //0.4
                  child: returnsStack(),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.05, //0.2
                 child: Padding(
                   padding: const EdgeInsets.all(8.0),
                   child: directioncliente.address != null ? Text('Direccion:  ${directioncliente.address}',style: TextStyle(fontSize: 15),):Text('Direccion: Sin Asignar'),
                 ),

                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.05, //0.2
                   child: Padding(
                     padding: const EdgeInsets.all(8.0),
                     child: taskCU  ? Text('Fecha:   ${_dateTask.toIso8601String().substring(0,10)}   ${_timeTask.format(context)}',style: TextStyle(fontSize: 15),): Text('Fecha: Sin asignar'),
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
                          child: formType != null ?
                          new ListView.builder(
                            itemCount: formType.data.length,
                            itemBuilder: (BuildContext context, index){
                              return ListTile(
                                title: Text('${formType.data[index].name}'),
                                leading: Icon(Icons.poll),
                                onTap: () async {
                                  var getFormResponse = await getForm(formType.data[index].id.toString(), customer, token);
                                  FormModel form = FormModel.fromJson(getFormResponse.body);
                                  lisC(form);
                                  setState(() {
                                    directionClient.address = null;
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
                            },
                          ) :  Center(child: CircularProgressIndicator()),
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

  Widget generatedTable(List<FieldOptionModel> listOptions, String id){

    data["table"] = new Map();

    for(FieldOptionModel varV in listOptions)
    {
      data["table"][varV.name] = new Map();
      data["table"][varV.name]["name"] = varV.name;
      data["table"][varV.name][varV.value.toString()] =new TextEditingController();
    }

    Card card(TextEditingController t){
      return Card(
        child: TextField(
          decoration: InputDecoration(
            hintText: '',
          ),
          controller: t,
        ),
      );
    }

    //COLUMNAS
    Container columna(Map column){
      List<Widget> listCard = new List<Widget>();
      for(var key in column.keys){
        if(key != 'name'){
          listCard.add(card(column[key]));
        }
      }
      return Container(
        width: MediaQuery.of(context).size.width * 0.5,
        height: MediaQuery.of(context).size.height *(listCard.length*0.1),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Card(
              child: Container(
                child: Text(column["name"]),
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
    for(var key in column.keys)
    {
      listColuma.add(columna(column[key]));
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
  Future<File> photoAndImage() async{
    return showDialog<File>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return TomarImage();
      },
    );
  }
  Stack returnsStack(){
    return Stack(
      children: <Widget>[
        ListView.builder(
            itemCount: listFieldsModels.length,
            itemBuilder: (BuildContext context, index){
              if(listFieldsModels[index].fieldType == 'TextArea' ||  listFieldsModels[index].fieldType == 'Textarea'){
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
                      onChanged: (value){
                        saveData(value,index.toString());
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

               String dropdownValue ;
                return new  Padding(
                  padding: const EdgeInsets.only(left: 20,right: 10,bottom: 10,top: 10),
                  child: new DropdownButton<String>(
                    isDense: false,
                    icon: Icon(Icons.arrow_drop_down),
                    elevation: 10,
                    value: dataInfo[[index].toString()],
                    hint:  dataInfo[index.toString()] != null  ? Text(dataInfo[index.toString()]): Text(listFieldsModels[index].name),

                    onChanged: (newValue) {

                      setState(() {
                        //dropdownValue = newValue;
                        dataInfo.putIfAbsent([index].toString() ,()=> newValue);
                      });

                    },
                    items: dropdownMenuItems.map<DropdownMenuItem<String>>((String value) {
                      return new DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
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
                        child: Text('${_date.toString().substring(0,10)}'),
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
                        child: Text('${_date.toString().substring(0,10)}' + ' ' +'${_time.format(context) }'),
                        onPressed: (){
                          selectTime(context);
                          selectDate(context);
                          var dateCo = _date.toString().substring(0,10) + _time.format(context).toString();
                          saveData(dateCo.toString(),listFieldsModels[index].id.toString());
                          },
                      ),
                    ),
                  ],
                );
              }
              if(listFieldsModels[index].fieldType =='Table'){
                return generatedTable(listFieldsModels[index].fieldOptions, listFieldsModels[index].id.toString());
              }
              if(listFieldsModels[index].fieldType == 'Time')
              {
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
                        child: dataInfo[listFieldsModels[index].id.toString()] == null ? Text('${dataInfo[listFieldsModels[index].id]}') : Text('Sin Asignar'),
                        onPressed: (){selectTime(context);
                        saveData(_time.format(context).toString(),  listFieldsModels[index].id.toString()) ;
                        print(dataInfo[listFieldsModels[index].id]);
                        print(_time.format(context).toString());
                        },

                      ),
                    ),
                  ],
                );
              }
              if(listFieldsModels[index].fieldType == 'Photo'){
                return  Row(
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(top: 10,left: 5),
                              child: RaisedButton(
                                onPressed: () async{
                                  var img = await photoAndImage();
                                  if (img != null) {
                                    setState(() {

                                      image2 = img;
                                      saveData(img.readAsBytesSync().toString(), listFieldsModels[index].id.toString());
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
                    Container(
                      width: MediaQuery.of(context).size.width* 0.5,

                      child: Center(
                        child: Container(
                            child: image2 == null ? new Text('')
                                : new Text('Imagen Guardada', style: TextStyle(
                              color: PrimaryColor,
                            ),)
                        ),
                      ),
                    ),
                  ],
                );
              }
              if(listFieldsModels[index].fieldType == 'Image'){
                return Row(
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(top: 5,left: 10),
                              child: RaisedButton(
                                onPressed: (){
                                  pickerImage(Method.GALLERY);
                                },
                                child: Text(''),
                                color: PrimaryColor,
                              ),
                            ),
                          ],
                        ),

                      ],

                    ),
              Container(
              width: MediaQuery.of(context).size.width* 0.5,

              child: Container(
              child: image2 == null ? new Text('')
                  : new Text('Imagen Guardada',style: TextStyle(
                color: PrimaryColor,
              ),),

              ),
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
              if(listFieldsModels[index].fieldType == 'CanvanSignature' || listFieldsModels[index].fieldType == 'CanvanImage')
              return  Row(
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(top: 10,left: 5),
                              child: RaisedButton(
                                onPressed: () async{
                                  //File img = await ImagePicker.pickImage(source: ImageSource.camera);
                                  var bytes = await getImg();
                                  Image img = Image.memory(bytes);
                                  if (img != null) {
                                    setState(() {
                                      print(bytes);
                                      image = img;
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
                    Container(
                      width: MediaQuery.of(context).size.width* 0.5,

                      child: Container(
                          child: image2 == null ? new Text('')
                              : new Image.file(image2,height: 200,width: 200,)

                      ),
                    ),
                  ],
                );
              if(listFieldsModels[index].fieldType == 'Boolean')
                {
                  return Container(
                      width: 30,
                      child: Switch(value: true, onChanged: null));
                }

            }
        ),


      ],
    );
  }
  addDirection() async{
    CustomerWithAddressModel resp = await getDirections();
    print(resp.address);
    if(resp != null) {
      setState(() {
        directioncliente = resp;
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
  Future<CustomerWithAddressModel> getDirections() async{
    return showDialog<CustomerWithAddressModel>(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return searchAddressWithClient();
      },
    );
  }
  Future<Null> lisC(FormModel form)async {
    listFieldsModels.clear();
    setState(() {
      formGlobal = form;
      listFieldsModels.clear();
    });
    for(SectionModel section in form.sections)
      {
        for(FieldModel fields in section.fields)
        {
          listFieldsModels.add(fields);
        }
      }

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
      if(getAllFormsResponse.statusCode == 200)
      {
        //  print(getAllFormsResponse.headers['content-type']);
        forms = FormsModel.fromJson(getAllFormsResponse.body);
        formType = forms;

      }
    }catch(e){

    }
    return formType;
  }
  initFormsTypes()async{
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
    setState(() {
      taskCU= true;
    });
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
                },
              ),
            ],
          );
        });
  }
   saveTaskApi() async{
     var createTaskResponse = await createTask(saveTask, customer, token);
    print(createTaskResponse.request);
//
    print(createTaskResponse.statusCode);
   print(createTaskResponse.body);
   if(createTaskResponse.statusCode == 201){
     setState(() {
       taskEnd = true;
     });
   }

  }
  void saveData(String dataController, String id) {
    var value = dataController;
    dataInfo.putIfAbsent(id ,()=> value);
    dataInfo[id] = value;
  }
}



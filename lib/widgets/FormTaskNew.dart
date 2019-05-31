import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:joincompany/main.dart';
import 'package:joincompany/models/AddressModel.dart';
import 'package:joincompany/models/FieldModel.dart';
import 'package:joincompany/pages/FirmTouch.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart' as Date;
import 'package:joincompany/models/FormModel.dart';
import 'package:joincompany/models/FormsModel.dart';
import 'package:joincompany/models/SectionModel.dart';
import 'package:joincompany/models/TaskModel.dart';
import 'package:joincompany/models/UserDataBase.dart';
import 'package:joincompany/models/WidgetsList.dart';
import 'package:joincompany/pages/BuscarRuta/BuscarDireccion.dart';
import 'package:joincompany/services/FormService.dart';
import 'package:http/http.dart' as http;
import 'package:joincompany/Sqlite/database_helper.dart';
import 'package:joincompany/services/TaskService.dart';


class FormTask extends StatefulWidget {


  FormTask({this.directioncliente});
   final  AddressModel  directioncliente;

  @override
  _FormTaskState createState() => new _FormTaskState();

}
class _FormTaskState extends State<FormTask> {

  File image;
  String dropdownValue ;
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
  bool pass = false;
  AddressModel  directionClient = new  AddressModel();
  List<FieldOptionModel> elementsOptions = List<FieldOptionModel>();
  TaskModel saveTask = new TaskModel();

  @override
  void initState(){
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    initFormType();
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
               child: SimpleDialog(

                 title: Text('Guardar Tarea'),
                 children: <Widget>[
                   Padding(
                     padding: const EdgeInsets.only(left: 100),
                     child: Column(
                       children: <Widget>[
                         Padding(
                           padding: const EdgeInsets.all(10),
                           child: Row(
                             children: <Widget>[

                               RaisedButton(
                                 child:  Text('Aceptar'),
                                 color: Colors.white,
                                 elevation: 0,
                                 onPressed: (){
                                   dataSaveState.clear();
                                   List<Map<String, String>> listOfMaps = new List<Map<String, String>>();
                                   dataInfo.forEach((key, value) {
                                      listOfMaps.add({key: value});
                                    }
                                   );
                                   dataSaveState = listOfMaps;
//                                   print(dataSaveState);
                                   if(dataSaveState.isNotEmpty) {
                                     // var createCustomerResponse = await createCustomer(customerObjNew, customer, authorization);
                                     // print(createCustomerResponse.request);
                                     // print(createCustomerResponse.statusCode);
                                     // print(createCustomerResponse.body);

                                     saveTask.formId = formGlobal.id;
                                     saveTask.responsibleId = responsibleId;
                                     saveTask.name = formGlobal.name;
                                     saveTask.addressId = directionClient.id;
                                     saveTask.planningDate = _dateTask.toString().substring(0,19);
                                     saveTask.customValuesMap = dataSaveState;
//                                     print(saveTask.formId);
//                                     print(saveTask.responsibleId);
//                                     print(saveTask.name);

                                     saveTaskApi();
                                   }
                                   Navigator.pop(context);
                                   Navigator.pop(context);
                                 },
                               ),
                             ],
                           ),
                         ),
                       ],
                     ),
                   ),
                 ],
               ))
         ) ,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.delete,size: 25,),
            tooltip: 'Descartar Formulario',
            iconSize: 35,
            onPressed: ()=> showDialog(
                context: context,
            child: SimpleDialog(
              title: Text('Descartar Formulario'),
              children: <Widget>[
               Padding(
                 padding: const EdgeInsets.only(right: 80),
                 child: Column(
                   children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 0),
                        child: Row(
                          children: <Widget>[
                            IconButton(
                              icon: Icon(Icons.arrow_back),
                              onPressed: (){
                                Navigator.pop(context);
                              },
                            ),
                            RaisedButton(
                              elevation: 0,
                              color: Colors.white,
                              child: Text('Volver'),
                              onPressed: () {

                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      ),
                     Row(
                       children: <Widget>[
                         IconButton(
                           icon: Icon(Icons.delete),
                             onPressed: (){
                               setState(() {
                                 pass= false;
                                 dropdownValue = null;
                               });

                               //Navigator.pop(context);
                             }
                         ),
                         RaisedButton(
                           child: Text('Descartar Formulario'),
                           elevation: 0,
                           color: Colors.white,
                             onPressed: (){
                               setState(() {
                                 pass= false;
                                 dropdownValue = null;
                                 image = null;
                               });
                               Navigator.pop(context);
                             }
                         ),
                       ],
                     ),

                   ],
                 ),
               ),
              ],
            ))
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
                   child: directionClient.address != null ? Text('Direccion:  ${directionClient.address}',style: TextStyle(fontSize: 15),):Text('Direccion: Sin Asignar'),
                 ),

                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.05, //0.2
                   child: Padding(
                     padding: const EdgeInsets.all(8.0),
                     child: directionClient.address != null ? Text('Fecha:   ${_dateTask.toIso8601String().substring(0,10)}   ${_timeTask.format(context)}',style: TextStyle(fontSize: 15),): Text('Fecha: Sin asignar'),
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
                        return  formType != null ?

                        new ListView.builder(
                          itemCount: formType.data.length,
                          itemBuilder: (BuildContext context, index){
                            return ListTile(
                             contentPadding: EdgeInsets.all(10),
                              title: Text('${formType.data[index].name}'),
                              leading: Icon(Icons.poll),
                              onTap: () async {
                                var getFormResponse = await getForm(formType.data[index].id.toString(), customer, token);
                                FormModel form = FormModel.fromJson(getFormResponse.body);
//                                getFormResponse.body.split(' ').forEach((word) => print(" " + word));
                                lisC(form);
                                setState(() {
                                  directionClient.address = null;
                                  dropdownValue = null;
                                  pass = true;
                                  image = null;
                                });
                                Navigator.pop(context);
                              },
                            );
                          },
                        ) :  Center(child: CircularProgressIndicator());
                      }
                  );
                }
            ),
          ],
        ),
      ),
    );
  }

  Stack returnsStack(){
    return Stack(
      children: <Widget>[
        ListView.builder(
            itemCount: listFieldsModels.length,
            itemBuilder: (BuildContext context, index){
              if(listFieldsModels[index].fieldType == null) {
                return Center(child: Text('Formulario no Disponible'),);
              }
              if(listFieldsModels[index].fieldType == 'Textarea'){
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
                for(FieldOptionModel v in listFieldsModels[index].fieldOptions) dropdownMenuItems.add(v.name);
                return  Padding(
                  padding: const EdgeInsets.only(left: 20,right: 10,bottom: 10,top: 10),
                  child: DropdownButton<String>(
                    isDense: false,
                    icon: Icon(Icons.arrow_drop_down),
                    elevation: 10,
                    value: dropdownValue,
                    hint: Text(listFieldsModels[index].name),

                    onChanged: (newValue) {
                      setState(() {
                        dropdownValue = newValue;
                      });
                      saveData(dropdownValue,index.toString());
                    },
                    items: dropdownMenuItems.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
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
                        onPressed: (){selectDate(context);},
                      ),
                    ),
                  ],
                );
              }//CAMBIAR A DATETIME
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
                        child: Text('${_date.toString().substring(0,10)}'),
                        onPressed: (){selectDate(context);},
                      ),
                    ),
                  ],
                );
              }
              if(listFieldsModels[index].fieldType =='table'){
                Card card(){
                  return Card(
                    child:
                    TextField(
                    ),
                  );
                }
                //COLUMNAS
                Container columna(Color col,int intCard){
                  List<Widget> ListCard = new List<Widget>();
                  for(int i = 0; i < intCard; i++){
                    ListCard.add(card());
                  }
                  return Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    color: col,
                    child: Column(
                      children: <Widget>[
                        card(),
                        Divider(
                          height: 20,
                          color: Colors.black,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.5,
                          height: MediaQuery.of(context).size.height * 0.25,
                          child: ListView.builder(
                            itemCount: ListCard.length,
                            itemBuilder: (contex,index){
                              return ListCard[index];
                            },
                          ),
                        )
                      ],
                    ),
                  );
                }
                //LISTA DE COLUMNAS
                List<Widget> ListColuma = new List<Widget>();
                ListColuma.add(columna(Colors.red[50],2));
                ListColuma.add(columna(Colors.blue[50],5));
                ListColuma.add(columna(Colors.grey[200],3));
                ListColuma.add(columna(Colors.green[100],1));
                return SingleChildScrollView(
                  child: Container(
                    margin: EdgeInsets.all(10),
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.4,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: ListColuma.length,
                      itemBuilder: (context,index){
                        return ListColuma[index];
                      },
                      // This next line does the trick.
                    ) ,
                  ),
                );
              }
              if(listFieldsModels[index].fieldType == 'ComboSearch'){
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
                          maxLines: 1,
                          //  controller: nameController,
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
              if(listFieldsModels[index].fieldType == 'Time')
              {
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
                        child: Text(_time.format(context)),
                        onPressed: (){selectTime(context);},
                      ),
                    ),
                  ],
                );
              }
              if(listFieldsModels[index].fieldType == 'Photo'){
                return Row(
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(top: 10,left: 5),
                              child: RaisedButton(
                                onPressed: (){
                                  pickerPhoto(Method.CAMERA);
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

                      child: new Center(
                        child: Container(
                          child: image == null
                              ? new Text('')

                              : new Card(
                                    elevation: 12,
                                         child:  Image.file(image,height: 200,width: 200,),

                                               )

                        ),

                      ),
                    )
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
                      child: new Center(
                        child: image == null
                            ? new Text(listFieldsModels[index].name)
                            : new Image.file(image),

                      ),
                    )
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
            }
        ),


      ],
    );
  }
   direction(){
    setState(() {
      directionClient;
    });
    return Text(directionClient.address,style: TextStyle(
        fontSize: 13
    ),);
  }
  addDirection() async{
    AddressModel resp = await getDirections();
    if(resp != null) {
      setState(() {
        directionClient = resp;
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
  Future<AddressModel> getDirections() async{
    return showDialog<AddressModel>(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return SearchAddress();
      },
    );
  }


  Future<Null> lisC(FormModel form)async {
    listFieldsModels.clear();
    setState(() {
      formGlobal = form;
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
        image = img;
      });
    }
  }
  pickerPhoto(Method m) async {

    File img = await ImagePicker.pickImage(source: ImageSource.camera);
    if (img != null) {
      setState(() {
        image = img;
      });
    }
  }


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

  initFormType()async{
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
                },
              ),
            ],
          );
        });
  }
  Future saveTaskApi() async{
     var createTaskResponse = await createTask(saveTask, customer, token);
    print(createTaskResponse.request);
//
    print(createTaskResponse.statusCode);
    print('--------------------------------------');
   print(createTaskResponse.body);
  }
  void saveData(String dataController, String id) {
    var value = dataController;
    dataInfo.putIfAbsent(id ,()=> value);
    dataInfo[id] = value;

  }

}



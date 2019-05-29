import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:joincompany/main.dart';
import 'package:joincompany/models/FieldModel.dart';
import 'package:joincompany/pages/FirmTouch.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart' as Date;
import 'package:flutter/material.dart';
import 'package:joincompany/main.dart';
import 'package:joincompany/models/FieldModel.dart';
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


  @override
  _FormTaskState createState() => new _FormTaskState();

}
class _FormTaskState extends State<FormTask> {

  Map<String,String> dataInfo = Map<String,String>();
  List<Map<String, String>> dataSaveState =  List<Map<String, String>>();
  ListWidgets items = new ListWidgets();
  BuildContext globalContext;
  List<String> listElement = List<String>();
  List<Widget> listWidgetMain = List<Widget>();
  List<FieldModel> listFieldsModels = List<FieldModel>();
  SectionModel section;
  FormModel formGlobal;
  UserDataBase userToken ;
  String token;
  String customer;
  String user;
  int responsibleId;
  FormsModel formType;
  bool pass = false;
  List<FieldOptionModel> elementsOptions = List<FieldOptionModel>();

  TaskModel saveTask = new TaskModel();
  TextEditingController nameController;

  @override
  void initState(){
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
                                   Map<String,String> dataAux = Map<String,String>();
                                    iterateMapEntry(key, value) {
                                      dataAux.putIfAbsent(key,()=> value);
                                      dataSaveState.add(dataAux);
                                   }
                                   print(dataSaveState);

                                   dataInfo.forEach(iterateMapEntry);

                                   if(dataSaveState.isNotEmpty) {
                                     saveTask.formId = formGlobal.id;
                                     saveTask.responsibleId = responsibleId;
                                     saveTask.name = formGlobal.name;
                                     saveTask.customValuesMap = dataSaveState;
                                     print(saveTask.formId);
                                     print(saveTask.responsibleId);
                                     print(saveTask.name);
                                     print(saveTask.customValuesMap);
                                   }
                                   saveTaskApi();
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
                              onPressed: (){
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
      body: (){
        return pass?
        Stack(
            children: <Widget>[
              ListView.builder(

                  itemCount: listFieldsModels.length,
                  itemBuilder: (BuildContext context, index){

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
                      String dropdownValue ;
                      for(FieldOptionModel v in listFieldsModels[index].fieldOptions) dropdownMenuItems.add(v.name);

                      return  Padding(
                        padding: const EdgeInsets.only(left: 20,right: 10,bottom: 10,top: 10),
                        child: DropdownButton<String>(
                          isDense: false,
                          icon: Icon(Icons.arrow_drop_down),
                          elevation: 10,
                          value: dropdownValue,
                          hint: Text(listFieldsModels[index].name),
                          onChanged: (String newValue) {
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

                    }


                  }

              )
            ]

        ) : Center(child: Text('Seleccione un Formulario'),);
      }() ,
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
                        initFormType();
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
                                lisC(form);
                                setState(() {

                                  pass = true;
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
                title: new Text('Lugar'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SearchAddress()),
                  );

                },
              ),
              new ListTile(
                leading: new Icon(Icons.access_time),
                title: new Text('Hora'),
                onTap: () {

                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }
  Future saveTaskApi() async{

    await createTask(saveTask,customer, token);
    //if(){}
  }

  void saveData(String dataController, String id) {

    var value = dataController;
    dataInfo.putIfAbsent(id ,()=> value);
    dataInfo[id] = value;

  }

}



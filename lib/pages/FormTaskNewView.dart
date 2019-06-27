import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:joincompany/Menu/ImageAndPhoto.dart';
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

class FormTaskView extends StatefulWidget {
  FormTaskView({this.taskmodelres});
  final TaskModel taskmodelres;
  @override
  _FormTaskViewState createState() => new _FormTaskViewState();
}
class _FormTaskViewState extends State<FormTaskView> {

  UserDataBase userToken ;
  String token,customer, user;
  int responsibleId;
  TaskModel taskOne;
  DateTime _dateTask = new DateTime.now();
  Map<String,String> dataInfo = Map<String,String>();
  FormModel formGlobal;
  List<FieldModel> listFieldsModels = List<FieldModel>();

  @override
  void initState(){

    _dateTask = DateTime.parse(widget.taskmodelres.planningDate);

    //listWithTask();
    super.initState();
  }

  @override
  void Dispose(){
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalle de Tarea ' + widget.taskmodelres.name.toString(), style: TextStyle(fontSize: 15),),
      ),
      body: ListView(
        children: <Widget>[
          Container(

            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text('Cliente :',style: TextStyle(fontSize: 20),),
                    ),
                    Expanded(
                      child: widget.taskmodelres.customer.name != null ? Text('Direccion:  ${widget.taskmodelres.customer.name}',style: TextStyle(fontSize: 15),)
                          : Text('Sin Asignar'),
                    )
                  ],
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text('Direccion :',style: TextStyle(fontSize: 20),),
                    ),
                    Expanded(
                      child: widget.taskmodelres.address != null ? Text('Direccion:  ${widget.taskmodelres.address.address}',style: TextStyle(fontSize: 15),)
                          : Text('Sin Asignar'),
                    )
                  ],
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text('Fecha :',style: TextStyle(fontSize: 20),),
                    ),
                    Expanded(child: Text(_dateTask.toString())),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future listWithTask() async {

    await getElements();

    //SOLICITAR TAREA CON DETALLES
    var responseTaskone = await getTask(widget.taskmodelres.id.toString(),customer, token);
    taskOne = TaskModel.fromJson(responseTaskone.body);

    //SOLICITAR FORMULARIOS
    var getFormResponse = await getForm(widget.taskmodelres.formId.toString(), customer, token);
    FormModel form = FormModel.fromJson(getFormResponse.body);

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

  getElements()async{
    userToken = await ClientDatabaseProvider.db.getCodeId('1');
    token = userToken.token;
    customer = userToken.company;
    user = userToken.name;
    responsibleId = userToken.idUserCompany;
  }

  Future<bool> lisC(FormModel form)async {
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

}

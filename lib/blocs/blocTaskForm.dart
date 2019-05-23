import 'dart:async';
import 'package:flutter/material.dart';
import 'package:joincompany/models/CustomerModel.dart';
import 'package:joincompany/models/FieldModel.dart';
import 'package:joincompany/models/FormModel.dart';
import 'package:joincompany/models/SectionModel.dart';
import 'package:joincompany/models/WidgetsList.dart';


class BlocTaskForm  {


  ListWidgets items = new ListWidgets();
  List<Widget> listWidget = List<Widget>();
  String token;
  String customer;
  var idFormType;
  FormModel form;
  FieldModel camposWidgets;
  List<FieldOptionModel> optionsElements = List<FieldOptionModel>();

  var  _taskFormController   = StreamController<List<dynamic>>();
  Stream<List<dynamic>> get outListWidget => _taskFormController.stream;
  Sink<List<dynamic>> get inListWidget => _taskFormController.sink;


  final  _taskTypeFormController   = StreamController<String>();
  Stream<String> get outTaskType => _taskTypeFormController.stream;
  Sink<String> get inTaskType => _taskTypeFormController.sink;


  final  _saveFormController   = StreamController<String>();
  Stream<String> get outSaveForm => _saveFormController.stream;
  Sink<String> get inSaveForm => _saveFormController.sink;

  final  _formController   = StreamController<String>();
  Stream<String> get outForm => _formController.stream;
  Sink<String> get inForm => _formController.sink;


  void updateListWidget(context)
  {
    listWidget.clear();
   if(idFormType != null)
     {
      for(SectionModel v in form.sections)
        {
          for(FieldModel k in v.fields)
            {
              camposWidgets = k;
             switch(k.fieldType){
               case 'Combo':
                 {
                   optionsElements = k.fieldOptions;
                   listWidget.add(items.createState().tab(optionsElements,context));
                 }
               break;
               case 'Text':
                 {
                   final nameController = TextEditingController();
                   listWidget.add(items.createState().text(context,k.name,nameController ));
                 }
                 break;
               case 'Textarea':
                 {
                   final nameController = TextEditingController();
                   listWidget.add(items.createState().textArea(context,k.name,nameController));
                 }
                 break;
               case 'Number':
                 {
                   final nameController = TextEditingController();
                   listWidget.add(items.createState().number(context,k.name,nameController));
                 }
                 break;
               case 'Date':
                 {
                   listWidget.add(items.createState().date(context,k.name));
                 }
                 break;
               case 'Table':
                 {
                   optionsElements = k.fieldOptions;
                   listWidget.add(items.createState().tab(optionsElements,context));
                 }
                 break;
               case 'CanvanSignature':
                 {
                   listWidget.add(items.createState().loadingTask(k.fieldType));
                 }
                 break;
               case 'Photo':
                 {
                   listWidget.add(items.createState().imagePhoto(context,k.name));
                 }
                 break;
               case 'Image':
                 {
                   listWidget.add(items.createState().imageImage(context,k.name));
                 }
                 break;
                     //Desde aca para abajo
               case 'Time':
                 {
                   listWidget.add(items.createState().loadingTask(k.fieldType));
                 }
                 break;
               case 'DateTime':
                 {
                   listWidget.add(items.createState().loadingTask(k.fieldType));
                 }
                 break;
               case 'ComboSearch':
                 {
                   listWidget.add(items.createState().loadingTask(k.fieldType));
                 }
                 break;
               case 'Boolean':
                 {
                   listWidget.add(items.createState().loadingTask(k.fieldType));
                 }
                 break;
               case 'CanvanImage':
               {
                 listWidget.add(items.createState().loadingTask(k.fieldType));
               }
               break;
               default:
                 {
                 listWidget.add(items.createState().label(k.fieldType));
                 }
                 break;
             }
            }
        }
      inListWidget.add(listWidget);
     }else{
   }
  }


  @override
  void dispose() {
    _taskFormController.close();
    _taskTypeFormController.close();
    _formController.close();
    _saveFormController.close();
  }

  BlocTaskForm(context) {
    updateListWidget(context);
  }




}
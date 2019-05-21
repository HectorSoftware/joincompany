import 'dart:async';
import 'package:flutter/material.dart';
import 'package:joincompany/models/CustomerModel.dart';
import 'package:joincompany/models/FieldModel.dart';
import 'package:joincompany/models/FormModel.dart';
import 'package:joincompany/models/SectionModel.dart';
import 'package:joincompany/models/WidgetsList.dart';


class BlocTaskForm {

  ListWidgets items = new ListWidgets();
  List<Widget> listWidget = List<Widget>();
  List<String> listStringG = List<String>();
  String typeForm ;
  String validateTypeForm = '';
  String token;
  String customer;
  var idFormType;
  bool pass ;
  FormModel form;
  FieldModel camposWidgets;
  List<FieldOptionModel> optionsElements = List<FieldOptionModel>();
  List<String> elementDrop = List<String>();
  bool value =false;
  String defaultValue = ' ';


  var  _taskFormController   = StreamController<List<dynamic>>();
  Stream<List<dynamic>> get outListWidget => _taskFormController.stream;
  Sink<List<dynamic>> get inListWidget => _taskFormController.sink;


  final  _taskTypeFormController   = StreamController<String>();
  Stream<String> get outTaskType => _taskTypeFormController.stream;
  Sink<String> get inTaskType => _taskTypeFormController.sink;

  var  _formController   = StreamController<FormModel>();
  Stream<FormModel> get outForm => _formController.stream;
  Sink<FormModel> get inForm => _formController.sink;

  void updateListWidget(context)
  {
    inListWidget.add(listWidget);

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
                   listWidget.add(items.createState().combo(optionsElements));
                 }
               break;
               case 'Text':
                 {

                   listWidget.add(items.createState().label(defaultValue));
                 }
                 break;
               case 'Textarea':
                 {

                   listWidget.add(items.createState().textArea(context,k.name));
                 }
                 break;
               case 'Number':
                 {
                   listWidget.add(items.createState().number(context, k.name));
                 }
                 break;
               case 'Date':
                 {
                   listWidget.add(items.createState().date(context,k.name));
                 }
                 break;
               case 'table':
                 {
                   optionsElements = k.fieldOptions;
                   listWidget.add(items.createState().tab(context));
                 }
                 break;
               case 'CanvanSignature':
                 {
                   listWidget.add(items.createState().loadingTask(context));
                 }
                 break;
               default:
                 {

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
  }

  BlocTaskForm(context) {
    updateListWidget(context);
  }
}
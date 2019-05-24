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
  List<FieldModel> listFieldPrint = List<FieldModel>();
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


  final  saveFormController   = StreamController<String>();
  Stream<String> get outSaveForm => saveFormController.stream;
  Sink<String> get inSaveForm => saveFormController.sink;

  final  _formController   = StreamController<String>();
  Stream<String> get outForm => _formController.stream;
  Sink<String> get inForm => _formController.sink;

  final  fieldModelController   = StreamController<List<FieldModel>>();
  Stream<List<FieldModel>> get outFieldModel=> fieldModelController.stream;
  Sink<List<FieldModel>> get inFieldModel=> fieldModelController.sink;


  void updateListWidget(BuildContext context) {

    try {
      if (idFormType != null) {
        for (SectionModel v in form.sections) {
          for (FieldModel k in v.fields) {
            listFieldPrint.add(k);

          }
          inFieldModel.add(listFieldPrint);
        }
      } else {}
    }catch(e){}
  }
  @override
  void dispose() {
    _taskFormController.close();
    _taskTypeFormController.close();
    _formController.close();
    saveFormController.close();
    fieldModelController.close();
  }

  BlocTaskForm(context) {
    updateListWidget(context);
  }
}
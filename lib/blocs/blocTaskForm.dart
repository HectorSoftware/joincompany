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
  List<Map<String,String>> dataSave =  List<Map<String,String>>();

  var  _taskFormController   = StreamController<List<dynamic>>();
  Stream<List<dynamic>> get outListWidget => _taskFormController.stream;
  Sink<List<dynamic>> get inListWidget => _taskFormController.sink;


  void updateListWidget(context){
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
                listWidget.add(items.createState().combo(optionsElements,k.name));
              //  listWidget.add(items.createState().dateTime());
              }
              break;
            case 'Text':
              {
                final nameController = TextEditingController();
                listWidget.add(items.createState().text(context,k.name,nameController,v.id.toString() ));
              }
              break;
            case 'Textarea':
              {
                final nameController = TextEditingController();
                listWidget.add(items.createState().textArea(context,k.name,nameController,v.id.toString()));
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
                listWidget.add(items.createState().dateT(context,k.name));
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
                listWidget.add(items.createState().newFirm(context, k.name));
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
            case 'Time':
              {
                listWidget.add(items.createState().timeWidget(context,k.name));
              }
              break;
            case 'DateTime'://
              {
                listWidget.add(items.createState().loadingTask(k.fieldType));
              }
              break;
            case 'ComboSearch':
              {
                listWidget.add(items.createState().ComboSearch(context, k.name));
              }
              break;
            case 'Boolean':
              {
                listWidget.add(items.createState().bolean());
              }
              break;
            case 'CanvanImage'://
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
  void saveTask(BuildContext context, data,){


  }

  @override
  void dispose() {
    _taskFormController.close();
  }

  BlocTaskForm(context) {
    updateListWidget(context);
  }
}
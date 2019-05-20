import 'dart:async';
import 'package:flutter/material.dart';
import 'package:joincompany/models/WidgetsList.dart';
import 'package:rxdart/rxdart.dart';



class BlocTaskForm {

  ListWidgets items = new ListWidgets();
  List<Widget> listWidget = List<Widget>();
  List<String> listStringG = List<String>();
  String typeForm ;
  String validateTypeForm = 'Nota Vacia';

  bool pass ;



  var  _taskFormController   = StreamController<List<dynamic>>();
  Stream<List<dynamic>> get outListWidget => _taskFormController.stream;
  Sink<List<dynamic>> get inListWidget => _taskFormController.sink;


  final  _taskTypeFormController   = StreamController<String>();
  Stream<String> get outTaskType => _taskTypeFormController.stream;
  Sink<String> get inTaskType => _taskTypeFormController.sink;


  void updateListWidget(context)
  {

    listWidget.clear();
    inListWidget.add(listWidget);
      if(typeForm != null) {
        validateTypeForm = typeForm;
        }
      switch(validateTypeForm){
        case 'Encuesta':
          {
            listWidget.add(items.label("Titulo Encuensta"));
            listWidget.add(items.label("Titulo Encuensta"));
            listWidget.add(items.label("Titulo Encuensta"));
            inListWidget.add(listWidget);
          }
          break;
        case 'Nota Vacia':
          {
            listWidget.add(items.label("Titulo "));
            listWidget.add(items.textArea(context));
            inListWidget.add(listWidget);
          }
          break;
        default:
          {
            listWidget.clear();
            inListWidget.add(listWidget);

          }
          break;
      }
      print(listWidget.length);

  /*      if(typeForm != null){
          List<String> listString = List<String>();
          listString.add('label');
          listString.add('input');
          listString.add('label');
          listString.add('TextArea');
          listString.add('label');
          listString.add('date');
          listString.add('image');
          listString.add('input');

          for (String v in listString) {
            switch (v) {
              case 'label':
                {
                  listWidget.add(items.label("Titulo "));
                }
                break;

              case 'input':
                {
                  listWidget.add(items.input(context));
                }
                break;
              case 'TextArea':
                {
                  listWidget.add(items.textArea(context));
                }
                break;
              case 'date':
                {
                  listWidget.add(items.date(context));
                }
                break;
              case 'image':
                {
                  listWidget.add(items.uploadImage(context));
                }
                break;
              default:
                {

                }
                break;
            }
          }

        }*/

  }


  @override
  void dispose() {
    _taskFormController.close();
    _taskTypeFormController.close();
  }

  BlocTaskForm(context) {
    updateListWidget(context);
  }
}
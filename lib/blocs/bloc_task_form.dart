import 'dart:async';
import 'package:flutter/material.dart';
import 'package:joincompany/models/ModelUser.dart';
import 'package:joincompany/models/lista_widgets.dart';
import 'package:rxdart/rxdart.dart';


class BlocTaskForm{

  ListWidgets items = new ListWidgets();
  List<Widget> listWidget = List<Widget>();
  List<String> listStringG = List<String>();


  final  _taskController   = StreamController<List<Widget>>();

  Stream<List<Widget>> get outListWidget => _taskController.stream;
  Sink<List<Widget>> get _inListWidget => _taskController.sink;



  void updateListWidget(context)
  {
    List<String> listString = List<String>();
    listString.add('TextArea');
    listString.add('input');
    listString.add('label');
    listString.add('date');
    for(String v in listString)
    {
      switch(v) {
        case 'TextArea': {
          listWidget.add(items.label());
        }
        break;

        case 'input': {
          listWidget.add(items.label());
        }
        break;

        default: {

        }
        break;
      }
    }
    if(listWidget.length != 0) {
      print(listWidget[0]);
      _inListWidget.add(listWidget);
    }



  }


  @override
  void dispose() {
    _taskController.close();
  }

  BlocTaskForm(context){
    updateListWidget(context);
  }
}
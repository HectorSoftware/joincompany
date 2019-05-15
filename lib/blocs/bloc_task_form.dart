import 'dart:async';
import 'package:flutter/material.dart';
import 'package:joincompany/blocs/bloc_provider.dart';
import 'package:joincompany/models/ModelUser.dart';
import 'package:joincompany/models/lista_widgets.dart';


class BlocTaskForm extends BlocBase{

  ListWidgets items = new ListWidgets();
  List<Widget> listWidget = List<Widget>();
  List<String> listStringG = List<String>();


  final  _taskFormController   = StreamController<List<dynamic>>();

  Stream<List<dynamic>> get outListWidget => _taskFormController.stream;
  Sink<List<dynamic>> get _inListWidget => _taskFormController.sink;



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
          listWidget.add(items.label());
          listWidget.add(items.label());
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
      _inListWidget.add(listWidget);
    }



  }


  @override
  void dispose() {
    _taskFormController.close();
  }

  BlocTaskForm(context){
    updateListWidget(context);
  }
}
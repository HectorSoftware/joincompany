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
    listString.add('label');
    listString.add('TextArea');
    listString.add('input');
    listString.add('input');
    listString.add('input');
    listString.add('input');
    listString.add('input');
    listString.add('input');
    listString.add('input');
    listString.add('label');
    listString.add('date');

    for(String v in listString)
    {
      switch(v) {
        case 'label': {
          listWidget.add(items.label('Hello'));
        }
        break;

        case 'date': {
          listWidget.add(items.dateTime(context));
        }
        break;
        case 'TextArea': {
          listWidget.add(items.textArea(context));
        }
        break; case 'input': {
        listWidget.add(items.input(context));
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
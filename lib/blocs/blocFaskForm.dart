import 'dart:async';
import 'package:flutter/material.dart';
import 'package:joincompany/models/WidgetsList.dart';
import 'package:joincompany/blocs/BlocTypeTask.dart';
import 'package:path/path.dart';


class BlocTaskForm {

  TypeTaskBloc _taskBloc = TypeTaskBloc(context);

  ListWidgets items = new ListWidgets();
  List<Widget> listWidget = List<Widget>();
  List<String> listStringG = List<String>();

  final  _taskFormController   = StreamController<List<dynamic>>();

  Stream<List<dynamic>> get outListWidget => _taskFormController.stream;
  Sink<List<dynamic>> get _inListWidget => _taskFormController.sink;



  void updateListWidget(context)
  {
    //_taskBloc.formTypeTask(string);
    List<String> listString = List<String>();
    listString.add('label');
    listString.add('input');
    listString.add('label');
    listString.add('TextArea');
    listString.add('label');
    listString.add('date');
    listString.add('image');
    listString.add('input');

    for(String v in listString)
    {
      switch(v) {
        case 'label': {
          listWidget.add(items.label("Titulo "));
        }
        break;

        case 'input': {
          listWidget.add(items.input(context));
        }
        break;
        case 'TextArea': {
          listWidget.add(items.textArea(context));
        }
        break;
        case 'date': {
        listWidget.add(items.date(context));
         }
         break;
        case 'image': {
          listWidget.add(items.uploadImage(context));
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

  BlocTaskForm(context) {
    updateListWidget(context);
  }
}
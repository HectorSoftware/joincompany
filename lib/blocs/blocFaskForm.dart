import 'dart:async';
import 'package:flutter/material.dart';
import 'package:joincompany/models/WidgetsList.dart';



class BlocTaskForm {

  ListWidgets items = new ListWidgets();
  List<Widget> listWidget = List<Widget>();
  List<String> listStringG = List<String>();

  var  _taskFormController   = StreamController<List<dynamic>>();
  var strG ='Nota vacia';

  Stream<List<dynamic>> get outListWidget => _taskFormController.stream;
  Sink<List<dynamic>> get _inListWidget => _taskFormController.sink;

  void resetController(){
    _taskFormController.sink.close();
    _taskFormController   = StreamController<List<dynamic>>();

  }

  void updateListWidget(context,str)
  {
    if(strG != null && str != 'Nota vacia') {
      strG = str;
      switch (strG) {
        case 'Nota vacia':
          {
            listWidget.add(items.label('Titulo 1'));
            listWidget.add(items.textArea(context));
          }
          break;
        case 'Encuesta':
          {}
          break;
        case 'Gestion Comercial':
          {
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

            //fin de Gestion
          }
          break;

        default:
          {
            /*   listWidget.add(items.loadingTask());
          _inListWidget.add(listWidget);*/
          }
      }
      _inListWidget.add(listWidget);
    }
  }


  @override
  void dispose() {
    _taskFormController.close();
  }

  BlocTaskForm(context) {
    updateListWidget(context,strG);
  }
}
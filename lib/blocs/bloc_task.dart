import 'dart:async';
import 'package:flutter/material.dart';
import 'package:joincompany/models/ModelUser.dart';
import 'package:rxdart/rxdart.dart';


class BlocTask{

  List<Widget> listWidget = List<Widget>();
  List<String> listString = List<String>();

  final _taskController = StreamController<Widget>();
  final _taskUpdateController = StreamController<String>();

  Stream<Widget> get listListen => _taskController.stream;

  void updateListWidget(String string, Widget listWidget)
  {


  }


  @override
  void dispose() {
    _taskController.close();
    _taskUpdateController.close();
  }

  BlocTask();
}
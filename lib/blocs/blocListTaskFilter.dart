import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:joincompany/Sqlite/database_helper.dart';
import 'package:joincompany/models/TaskModel.dart';
import 'package:joincompany/models/TasksModel.dart';
import 'package:joincompany/models/UserDataBase.dart';
import 'package:joincompany/services/TaskService.dart';


class blocListTaskFilter {

  var _tasksFilterController = StreamController<String>();
  Stream<String> get outTaksFilter => _tasksFilterController.stream;
  Sink<String> get inTaksFilter => _tasksFilterController.sink;

  updateFilter(TextEditingController _filter){
    inTaksFilter.add(_filter.text);
  }

  @override
  void dispose() {
    _tasksFilterController.close();
  }

  blocListTaskFilter(TextEditingController _filter) {
    updateFilter(_filter);
  }
}
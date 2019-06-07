import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:joincompany/Sqlite/database_helper.dart';
import 'package:joincompany/models/TaskModel.dart';
import 'package:joincompany/models/TasksModel.dart';
import 'package:joincompany/models/UserDataBase.dart';
import 'package:joincompany/services/TaskService.dart';


class blocListTaskCalendar {

  var _tasksCalendarController = new StreamController<List<DateTime>>();
  Stream<List<DateTime>> get outTaksCalendar => _tasksCalendarController.stream;
  Sink<List<DateTime>> get inTaksCalendar => _tasksCalendarController.sink;

  var _tasksCalendarControllerMap = new StreamController<List<DateTime>>();
  Stream<List<DateTime>> get outTaksCalendarMap => _tasksCalendarControllerMap.stream;
  Sink<List<DateTime>> get inTaksCalendarMap => _tasksCalendarControllerMap.sink;

  updateCalendar(List<DateTime> calendar){
    inTaksCalendar.add(calendar);
    inTaksCalendarMap.add(calendar);
  }

  @override
  void dispose() {
    _tasksCalendarController.close();
    _tasksCalendarControllerMap.close();
  }

  blocListTaskCalendar(/*List<DateTime> calendar*/) {
    //updateCalendar(calendar);
  }
}
import 'dart:async';



class BlocListTaskCalendar {

  var _tasksCalendarController = new StreamController<List<DateTime>>.broadcast();
  Stream<List<DateTime>> get outTaksCalendar => _tasksCalendarController.stream;
  Sink<List<DateTime>> get inTaksCalendar => _tasksCalendarController.sink;

  updateCalendar(List<DateTime> calendar){
    inTaksCalendar.add(calendar);
  }

  void dispose() {
    _tasksCalendarController.close();
  }

  BlocListTaskCalendar(/*List<DateTime> calendar*/) {
    //updateCalendar(calendar);
  }
}

class BlocListTaskCalendarMap {

  var _tasksCalendarControllerMap = new StreamController<DateTime>.broadcast();
  Stream<DateTime> get outTaksCalendarMap => _tasksCalendarControllerMap.stream;
  Sink<DateTime> get inTaksCalendarMap => _tasksCalendarControllerMap.sink;

  updateCalendarMap(DateTime calendar){
    inTaksCalendarMap.add(calendar);
  }


  void dispose() {
    _tasksCalendarControllerMap.close();
  }

  BlocListTaskCalendarMap(/*List<DateTime> calendar*/) {
    //updateCalendar(calendar);
  }
}
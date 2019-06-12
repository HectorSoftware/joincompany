import 'dart:async';



class BlocListTaskCalendar {

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


  void dispose() {
    _tasksCalendarController.close();
    _tasksCalendarControllerMap.close();
  }

  BlocListTaskCalendar(/*List<DateTime> calendar*/) {
    //updateCalendar(calendar);
  }
}
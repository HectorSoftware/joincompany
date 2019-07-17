import 'dart:async';
import 'package:flutter/widgets.dart';

class BlocListTaskFilter {

  var _tasksFilterController = StreamController<String>.broadcast();
  Stream<String> get outTaksFilter => _tasksFilterController.stream;
  Sink<String> get inTaksFilter => _tasksFilterController.sink;

  var _tasksController = StreamController<String>.broadcast();
  Stream<String> get outTaks => _tasksController.stream;
  Sink<String> get inTaks => _tasksController.sink;

  updateFilter(TextEditingController _filter){
    inTaksFilter.add(_filter.text);
  }

  refreshList(){
    inTaks.add('refresh');
  }

  void dispose() {
    _tasksFilterController.close();
    _tasksController.close();
  }

  BlocListTaskFilter(TextEditingController _filter) {
    updateFilter(_filter);
  }
}
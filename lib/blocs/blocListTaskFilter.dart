import 'dart:async';
import 'package:flutter/widgets.dart';

class BlocListTaskFilter {

  var _tasksFilterController = StreamController<String>.broadcast();
  Stream<String> get outTaksFilter => _tasksFilterController.stream;
  Sink<String> get inTaksFilter => _tasksFilterController.sink;

  updateFilter(TextEditingController _filter){
    inTaksFilter.add(_filter.text);
  }

  void dispose() {
    _tasksFilterController.close();
  }

  BlocListTaskFilter(TextEditingController _filter) {
    updateFilter(_filter);
  }
}
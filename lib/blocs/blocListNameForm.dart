import 'dart:async';

import 'package:joincompany/models/FormsModel.dart';


class NameFormBloc{
  // ignore: unused_field
  FormsModel _listformModel = new FormsModel();

  final _formscontroller = StreamController<FormsModel>();
  // ignore: unused_element
  Sink<FormsModel> get _inForm => _formscontroller.sink;
  Stream<FormsModel> get outForm => _formscontroller.stream;


  Future getCustomers() async {

  }

  NameFormBloc(){
    getCustomers();
  }

  void dispose() {
    _formscontroller.close();
  }
}
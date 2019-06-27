import 'dart:async';

import 'package:joincompany/models/FormsModel.dart';


class NameFormBloc{
  FormsModel _listformModel = new FormsModel();

  final _formscontroller = StreamController<FormsModel>();
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
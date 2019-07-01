import 'dart:async';
import 'package:joincompany/Sqlite/database_helper.dart';
import 'package:joincompany/models/FormModel.dart';
import 'package:joincompany/models/FormsModel.dart';
import 'package:joincompany/models/UserDataBase.dart';

import 'package:joincompany/services/FormService.dart';



class FormTypeBloc{
  List<FormModel> _listforms = new List<FormModel>();

  final _formTypeBloccontroller = StreamController<List<FormModel>>();
  Sink<List<FormModel>> get _inContact => _formTypeBloccontroller.sink;
  Stream<List<FormModel>> get outForm => _formTypeBloccontroller.stream;

  FormTypeBloc(){
    getBusiness();
  }

  Future getBusiness() async {

    UserDataBase user = await ClientDatabaseProvider.db.getCodeId('1');
    var getAllFormsResponse = await getAllForms(user.company , user.token);

    FormsModel forms = FormsModel.fromJson(getAllFormsResponse.body);

    _listforms = forms.data;

    if(_listforms != null){
      _formTypeBloccontroller.add(_listforms);
    }
  }

  @override
  void dispose() {
    _formTypeBloccontroller.close();
  }
}

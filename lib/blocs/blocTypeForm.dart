import 'dart:async';
import 'package:joincompany/async_database/Database.dart';
import 'package:joincompany/models/FormModel.dart';
import 'package:joincompany/models/FormsModel.dart';
import 'package:joincompany/models/UserModel.dart';
import 'package:joincompany/services/FormService.dart';



class FormTypeBloc{
  List<FormModel> _listforms = new List<FormModel>();

  final _formTypeBloccontroller = StreamController<List<FormModel>>();
  // ignore: unused_element
  Sink<List<FormModel>> get _inContact => _formTypeBloccontroller.sink;
  Stream<List<FormModel>> get outForm => _formTypeBloccontroller.stream;

  FormTypeBloc(){
    getBusiness();
  }

  Future getBusiness() async {

    UserModel user = await DatabaseProvider.db.RetrieveLastLoggedUser();
    var getAllFormsResponse = await getAllForms(user.company , user.rememberToken);

    FormsModel forms = getAllFormsResponse.body;

    _listforms = forms.data;

    if(_listforms != null){
      _formTypeBloccontroller.add(_listforms);
    }
  }

  void dispose() {
    _formTypeBloccontroller.close();
  }
}

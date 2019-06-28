import 'dart:async';
import 'package:joincompany/Sqlite/database_helper.dart';
import 'package:joincompany/async_database/Database.dart';
import 'package:joincompany/models/BusinessModel.dart';
import 'package:joincompany/models/BusinessesModel.dart';
import 'package:joincompany/models/ContactModel.dart';
import 'package:joincompany/models/ContactsModel.dart';
import 'package:joincompany/models/UserModel.dart';
import 'package:joincompany/services/BusinessService.dart';



class BusinessBloc{

  BusinessModel header = BusinessModel();
  List<BusinessModel> _listbusisness = new List<BusinessModel>();

  final _businessBloccontroller = StreamController<List<BusinessModel>>();
  Sink<List<BusinessModel>> get _inContact => _businessBloccontroller.sink;
  Stream<List<BusinessModel>> get outBusiness => _businessBloccontroller.stream;

  BusinessBloc(){
    getBusiness();
  }

  Future getBusiness() async {

    UserModel user = await DatabaseProvider.db.RetrieveLastLoggedUser();
    var getAllBusinessesResponse = await getAllBusinesses(user.company,user.rememberToken);
    BusinessesModel busisness = getAllBusinessesResponse.body;

    _listbusisness = busisness.data;

    if(_listbusisness != null){
      _listbusisness.sort((a,b) => a.stage.compareTo(b.stage));
      _businessBloccontroller.add(_listbusisness);
      _businessBloccontroller.close();
    }
  }
}

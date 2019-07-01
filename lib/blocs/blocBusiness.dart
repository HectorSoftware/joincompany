import 'dart:async';
import 'package:joincompany/Sqlite/database_helper.dart';
import 'package:joincompany/models/BusinessModel.dart';
import 'package:joincompany/models/BusinessesModel.dart';
import 'package:joincompany/models/UserDataBase.dart';
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
    UserDataBase user = await ClientDatabaseProvider.db.getCodeId('1');
    var getAllBusinessesResponse = await getAllBusinesses(user.company,user.token);
    BusinessesModel busisness = BusinessesModel.fromJson(getAllBusinessesResponse.body);
    _listbusisness = busisness.data;

    if(_listbusisness != null){

    //  _listbusisness.sort((a,b) => a.stage.compareTo(b.stage));
      _businessBloccontroller.add(_listbusisness);
    }


  }

  @override
  void dispose() {
    _businessBloccontroller.close();
  }
}

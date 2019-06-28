import 'dart:async';
import 'package:joincompany/Sqlite/database_helper.dart';
import 'package:joincompany/models/BusinessModel.dart';
import 'package:joincompany/models/BusinessesModel.dart';
import 'package:joincompany/models/UserDataBase.dart';
import 'package:joincompany/services/BusinessService.dart';



class BusinessBloc{

  BusinessModel header = BusinessModel();
  List<BusinessModel> _listbusisness = new List<BusinessModel>();

  List<BusinessModel> _listbusisnessOrdenada = new List<BusinessModel>();
  List<BusinessModel> _listPresentacion = new List<BusinessModel>();
  List<BusinessModel> _listEnvioppta = new List<BusinessModel>();
  List<BusinessModel> _listGanado = new List<BusinessModel>();
  List<BusinessModel> _listPerdido = new List<BusinessModel>();
  List<BusinessModel> _listPrimerContacto = new List<BusinessModel>();




  final _businessBloccontroller = StreamController<List<BusinessModel>>();
  Sink<List<BusinessModel>> get _inContact => _businessBloccontroller.sink;
  Stream<List<BusinessModel>> get outBusiness => _businessBloccontroller.stream;

  BusinessBloc(){
    getBusiness();
  }

  Future getBusiness() async {
    int c = 0;
    UserDataBase user = await ClientDatabaseProvider.db.getCodeId('1');
    var getAllBusinessesResponse = await getAllBusinesses(user.company,user.token);
    BusinessesModel busisness = BusinessesModel.fromJson(getAllBusinessesResponse.body);
    _listbusisness = busisness.data;





    for(BusinessModel v in _listbusisness){

     if(v.stage == 'Presentación'){
       _listPresentacion.add(v);
     }
     if(v.stage == 'Envío ppta'){
       _listEnvioppta.add(v);
     }
     if(v.stage == 'Ganado'){
       _listGanado.add(v);
     }
     if(v.stage == 'Perdido'){
       _listPerdido.add(v);
     }
     if(v.stage == 'Primer contacto'){
       _listPrimerContacto.add(v);
     }


    }
    if(_listbusisness != null){
      _listbusisness.sort((a,b) => a.stage.compareTo(b.stage));
        print(_listbusisness.length);
      _businessBloccontroller.add(_listbusisness);
    }


  }

  @override
  void dispose() {
    _businessBloccontroller.close();
  }
}

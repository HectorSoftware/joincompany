import 'dart:async';
import 'package:joincompany/Sqlite/database_helper.dart';
import 'package:joincompany/main.dart';
import 'package:joincompany/models/CustomerModel.dart';
import 'package:joincompany/models/CustomersModel.dart';
import 'package:joincompany/models/Marker.dart';
import 'package:joincompany/models/TasksModel.dart';
import 'package:joincompany/models/UserDataBase.dart';
import 'package:joincompany/services/CustomerService.dart';
import 'package:joincompany/services/TaskService.dart';

class CustomersBloc{
  List<CustomerModel> _listMarker = new List<CustomerModel>();

  final _customerscontroller = StreamController<List<CustomerModel>>();
  Sink<List<CustomerModel>> get _inCustomers => _customerscontroller.sink;
  Stream<List<CustomerModel>> get outCustomers => _customerscontroller.stream;

  CustomersBloc(){
    getCustomers();
  }

  Future getCustomers() async {
    UserDataBase UserActiv = await ClientDatabaseProvider.db.getCodeId('1');
    var customersResponse = await getAllCustomers(UserActiv.company,UserActiv.token);
    CustomersModel customers = CustomersModel.fromJson(customersResponse.body);
    _customerscontroller.add(customers.data);
  }

  @override
  void dispose() {
    _customerscontroller.close();
  }
}
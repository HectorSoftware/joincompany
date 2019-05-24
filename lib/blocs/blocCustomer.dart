import 'dart:async';
import 'package:joincompany/Sqlite/database_helper.dart';
import 'package:joincompany/models/CustomerModel.dart';
import 'package:joincompany/models/CustomersModel.dart';
import 'package:joincompany/models/UserDataBase.dart';
import 'package:joincompany/services/CustomerService.dart';


class CustomersBloc{
  List<CustomerWithAddressModel> _listCustomersWithAddress = new List<CustomerWithAddressModel>();

  final _customerscontroller = StreamController<List<CustomerWithAddressModel>>();
  Sink<List<CustomerWithAddressModel>> get _inCustomers => _customerscontroller.sink;
  Stream<List<CustomerWithAddressModel>> get outCustomers => _customerscontroller.stream;

  CustomersBloc(){
    getCustomers();
  }

  Future getCustomers() async {
    UserDataBase UserActiv = await ClientDatabaseProvider.db.getCodeId('1');
    /*var customersResponse = await getAllCustomers(UserActiv.company,UserActiv.token);
    CustomersModel customers = CustomersModel.fromJson(customersResponse.body);*/

    print('******');

    var customersWithAddressResponse = await getAllCustomersWithAddress(UserActiv.company,UserActiv.token);
    CustomersWithAddressModel customersWithAddress = CustomersWithAddressModel.fromJson(customersWithAddressResponse.body);
    _listCustomersWithAddress = customersWithAddress.data;

    print(_listCustomersWithAddress.length);

    _customerscontroller.add(_listCustomersWithAddress);
  }

  @override
  void dispose() {
    _customerscontroller.close();
  }
}
import 'dart:async';
import 'package:joincompany/async_database/Database.dart';
import 'package:joincompany/models/CustomerModel.dart';
import 'package:joincompany/models/CustomersModel.dart';
import 'package:joincompany/models/UserModel.dart';
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
    UserModel user = await DatabaseProvider.db.RetrieveLastLoggedUser();
    // var customersResponse = await getAllCustomers(user.company, user.rememberToken);
    // CustomersModel customers = customersResponse.body;

    var customersWithAddressResponse = await getAllCustomersWithAddress(user.company, user.rememberToken);
    CustomersWithAddressModel customersWithAddress = customersWithAddressResponse.body;
    _listCustomersWithAddress = customersWithAddress.data;
    if(_listCustomersWithAddress != null){
      _customerscontroller.add(_listCustomersWithAddress);
    }

  }

  @override
  void dispose() {
    _customerscontroller.close();
  }
}
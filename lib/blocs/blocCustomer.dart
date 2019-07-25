import 'dart:async';
import 'package:joincompany/async_database/Database.dart';
import 'package:joincompany/models/CustomerModel.dart';
import 'package:joincompany/models/CustomersModel.dart';
import 'package:joincompany/models/UserModel.dart';
import 'package:joincompany/services/CustomerService.dart';


class CustomersBloc{
  List<CustomerWithAddressModel> _listCustomersWithAddress = new List<CustomerWithAddressModel>();

  final _customerscontroller = StreamController<List<CustomerWithAddressModel>>();
  // ignore: unused_element
  Sink<List<CustomerWithAddressModel>> get _inCustomers => _customerscontroller.sink;
  Stream<List<CustomerWithAddressModel>> get outCustomers => _customerscontroller.stream;

  CustomersBloc(){
    getCustomers();
  }

  Future getCustomers() async {
    UserModel user = await DatabaseProvider.db.RetrieveLastLoggedUser();
    // var customersResponse = await getAllCustomers(user.company, user.rememberToken);
    // CustomersModel customers = customersResponse.body;

    var customersWithAddressResponse = await getAllCustomersWithAddress(user.company, user.rememberToken,excludeDeleted: true);
    CustomersWithAddressModel customersWithAddress = customersWithAddressResponse.body;
    _listCustomersWithAddress = customersWithAddress.data;
    _listCustomersWithAddress.sort((a,b)=>a.name.compareTo(b.name));
    if(_listCustomersWithAddress != null){
      _listCustomersWithAddress.sort((a,b)=>a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      _customerscontroller.add(_listCustomersWithAddress);
    }

    _customerscontroller.close();
  }
}
import 'dart:async';
import 'package:joincompany/Sqlite/database_helper.dart';
import 'package:joincompany/models/CustomerModel.dart';
import 'package:joincompany/models/CustomersModel.dart';
import 'package:joincompany/models/UserDataBase.dart';
import 'package:joincompany/services/CustomerService.dart';


class CustomersBloc{
  List<CustomerWithAddressModel> _listCustomersWithAddress = new List<CustomerWithAddressModel>();

  final _customerscontroller = StreamController<List<CustomerWithAddressModel>>();
  //Sink<List<CustomerWithAddressModel>> get _inCustomers => _customerscontroller.sink;
  Stream<List<CustomerWithAddressModel>> get outCustomers => _customerscontroller.stream;

  CustomersBloc(){
    getCustomers();
  }

  Future getCustomers() async {
    UserDataBase userActivity = await ClientDatabaseProvider.db.getCodeId('1');
    /*var customersResponse = await getAllCustomers(UserActiv.company,UserActiv.token);
    CustomersModel customers = CustomersModel.fromJson(customersResponse.body);*/

    var customersWithAddressResponse = await getAllCustomersWithAddress(userActivity.company,userActivity.token);
    CustomersWithAddressModel customersWithAddress = CustomersWithAddressModel.fromJson(customersWithAddressResponse.body);
    _listCustomersWithAddress = customersWithAddress.data;



    if(_listCustomersWithAddress != null){
      _listCustomersWithAddress.sort((a,b)=>a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      _customerscontroller.add(_listCustomersWithAddress);
    }

  }

  List<CustomerWithAddressModel> ordenByCreate( List<CustomerWithAddressModel> serverList){
    List<CustomerWithAddressModel> ordenByCreate = new List<CustomerWithAddressModel>();


    return ordenByCreate;
  }

  void dispose() {
    _customerscontroller.close();
  }
}
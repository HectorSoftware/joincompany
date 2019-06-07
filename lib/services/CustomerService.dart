import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:joincompany/async_database/Database.dart';
import 'package:joincompany/models/AddressModel.dart';
import 'package:joincompany/models/AddressesModel.dart';
import 'dart:async';
import 'package:joincompany/models/CustomerModel.dart';
import 'package:joincompany/models/CustomersModel.dart';
import 'package:joincompany/models/ResponseModel.dart';
import 'package:joincompany/models/UserModel.dart';
import 'package:joincompany/services/BaseService.dart';
import 'package:joincompany/blocs/blocCheckConnectivity.dart';

String resourcePath = '/customers';

ConnectionStatusSingleton connectionStatus = ConnectionStatusSingleton.getInstance(); 

bool isOnline = connectionStatus.connectionStatus;

StreamSubscription _controller = connectionStatus.connectionChange.listen(connectionChanged);

void connectionChanged(dynamic hasConnection) {
  isOnline = !hasConnection;
}

Future<ResponseModel> getAllCustomers(String customer, String authorization, { String perPage, String page } ) async{
  
  List<CustomerModel> customers = await DatabaseProvider.db.RetrieveCustomersByUserToken(authorization);

  CustomersModel customersObj = new CustomersModel(data: customers, perPage: 0);

  ResponseModel response = new ResponseModel(statusCode: 200, body: customersObj);

  return response;
}

Future<http.Response> getAllCustomersFromServer(String customer, String authorization, { String perPage, String page } ) async{
  
  var params = new Map<String, String>();

  if (perPage != null && perPage!=''){
      params["per_page"]=perPage;
  }

  if (page != null && page!=''){
    params["page"]=page;
  }

  return await httpGet(customer, authorization, resourcePath, params: params);
}

Future<ResponseModel> getAllCustomersWithAddress(String customer, String authorization, { String perPage, String page } ) async{
  
  List<CustomerWithAddressModel> customers = await DatabaseProvider.db.RetrieveCustomersWithAddressByUserToken(authorization);

  CustomersWithAddressModel customersObj = new CustomersWithAddressModel(data: customers, perPage: 0);

  ResponseModel response = new ResponseModel(statusCode: 200, body: customersObj);

  return response;
}

Future<http.Response> getAllCustomersWithAddressFromServer(String customer, String authorization, { String perPage, String page } ) async{
  
  String resourcePath = '/customer_addresses';

  var params = new Map<String, String>();

  if (perPage != null && perPage!=''){
      params["per_page"]=perPage;
  }

  if (page != null && page!=''){
    params["page"]=page;
  }

  return await httpGet(customer, authorization, resourcePath, params: params);
}

Future<ResponseModel> getCustomer(String id, String customer, String authorization) async{

  CustomerModel customerObj = await DatabaseProvider.db.ReadCustomerById(int.parse(id));

  ResponseModel response = new ResponseModel(statusCode: 200, body: customerObj);

  return response;
}

Future<http.Response> getCustomerFromServer(String id, String customer, String authorization) async{

  return await httpGet(customer, authorization, resourcePath, id: id);
}

Future<ResponseModel> createCustomer(CustomerModel customerObj, String customer, String authorization) async{
  var syncState = SyncState.created;

  if (isOnline) {
    var createCustomerResponse = await createCustomerFromServer(customerObj, customer, authorization);
    if (createCustomerResponse.statusCode==200 || createCustomerResponse.statusCode==201) {
      customerObj = CustomerModel.fromJson(createCustomerResponse.body);
      syncState = SyncState.synchronized;
    }
  }
  
  CustomerModel customerCreated = await DatabaseProvider.db.CreateCustomer(customerObj, syncState);
  UserModel user = await DatabaseProvider.db.RetrieveLastLoggedUser();
  await DatabaseProvider.db.CreateCustomerUser(null, null, null, null, customerCreated.id, user.id, syncState);

  ResponseModel response = new ResponseModel(statusCode: 200, body: customerCreated);

  return response;
}

Future<http.Response> createCustomerFromServer(CustomerModel customerObj, String customer, String authorization) async{
  
  var bodyJson = customerObj.toJson();

  return await httpPost(bodyJson, customer, authorization, resourcePath);
}

Future<ResponseModel> updateCustomer(String id, CustomerModel customerObj, String customer, String authorization) async {

  var syncState = SyncState.updated;

  if (isOnline) {
    var updateCustomerResponse = await updateCustomerFromServer(customerObj.id.toString(), customerObj, customer, authorization);
    if (updateCustomerResponse.statusCode==200 || updateCustomerResponse.statusCode==201) {
      customerObj = CustomerModel.fromJson(updateCustomerResponse.body);
      syncState = SyncState.synchronized;
    }
  }
  
  CustomerModel customerUpdated = await DatabaseProvider.db.UpdateCustomer(int.parse(id), customerObj, syncState);

  ResponseModel response = new ResponseModel(statusCode: 200, body: customerUpdated);

  return response;
}

Future<http.Response> updateCustomerFromServer(String id, CustomerModel customerObj, String customer, String authorization) async{
  
  var bodyJson = customerObj.toJson();

  return await httpPut(id, bodyJson, customer, authorization, resourcePath);
}

Future<ResponseModel> deleteCustomer(String id, String customer, String authorization) async {

  bool deletedFromServer = false;

  if (isOnline) {
    var deleteCustomerResponse = await deleteCustomerFromServer(id, customer, authorization);
    if (deleteCustomerResponse.statusCode==200 || deleteCustomerResponse.statusCode==201) {
      deletedFromServer = true;
    }
  }

  int responseDelete;

  if (deletedFromServer) {
    responseDelete = await DatabaseProvider.db.DeleteCustomerById(int.parse(id));
  } else {
    responseDelete = await DatabaseProvider.db.ChangeSyncStateCustomer(int.parse(id), SyncState.deleted);
  }

  ResponseModel response = new ResponseModel(statusCode: 200, body: responseDelete.toString());

  return response;
}

Future<http.Response> deleteCustomerFromServer(String id, String customer, String authorization) async{
  String resourcePath = '/customer/delete';
  
  return await httpDelete(id, customer, authorization, resourcePath, false);
}

Future<ResponseModel> getCustomerAddresses(String id, String customer, String authorization ) async{
  List<AddressModel> addresses = await DatabaseProvider.db.RetrieveAddressModelByCustomerId(int.parse(id));

  ResponseModel response = new ResponseModel(statusCode: 200, body: addresses);

  return response;
}

Future<http.Response> getCustomerAddressesFromServer(String id, String customer, String authorization ) async{
  
  String extraPath = "/addresses";

  return await httpGet(customer, authorization, resourcePath, id: id, extraPath: extraPath);
}

Future<ResponseModel> relateCustomerAddress(String idCustomer, String idAddress, String customer, String authorization) async{

  var syncState = SyncState.created;

  if (isOnline) {
    var relateCustomerAddressResponse = await relateCustomerAddressFromServer(idCustomer, idAddress, customer, authorization);
    if (relateCustomerAddressResponse.statusCode==200 || relateCustomerAddressResponse.statusCode==201) {
      syncState = SyncState.synchronized;
    }
  }
  
  var customerAddressCreated = await DatabaseProvider.db.CreateCustomerAddress(null, null, null, null, int.parse(idCustomer), int.parse(idAddress), true, syncState);

  ResponseModel response = new ResponseModel(statusCode: 200, body: customerAddressCreated.toString());

  return response;
}

Future<http.Response> relateCustomerAddressFromServer(String idCustomer, String idAddress, String customer, String authorization) async{
  String resourcePath = '/addresses/customers/relate';

  var body = json.encode({
    'customer_id': idCustomer,
    'address_id': idAddress,
    'approved' : 1,
  });

  return await httpPost(body, customer, authorization, resourcePath);
}

Future<ResponseModel> unrelateCustomerAddress(String idCustomer, String idAddress, String customer, String authorization) async{
  var syncState = SyncState.deleted;
  bool unrelateFromServer = false;

  if (isOnline) {
    var unrelateCustomerAddressResponse = await unrelateCustomerAddressFromServer(idCustomer, idAddress, customer, authorization);
    if (unrelateCustomerAddressResponse.statusCode==200 || unrelateCustomerAddressResponse.statusCode==201) {
      unrelateFromServer = true;
    }
  }

  var customerAddressDelete;

  if (unrelateFromServer) {
    customerAddressDelete = await DatabaseProvider.db.DeleteCustomerAddressById(int.parse(idCustomer), int.parse(idAddress));
  } else {
    customerAddressDelete = await DatabaseProvider.db.ChangeSyncStateCustomerAddress(int.parse(idCustomer), int.parse(idAddress), syncState);
  }

  ResponseModel response = new ResponseModel(statusCode: 200, body: customerAddressDelete.toString());

  return response;
}

Future<http.Response> unrelateCustomerAddressFromServer(String idCustomer, String idAddress, String customer, String authorization) async{
  String resourcePath = '/customer/delete_address';
  String id = '$idCustomer/$idAddress';
  
  return await httpGet(customer, authorization, resourcePath, id: id);
}
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:joincompany/models/CustomerModel.dart';
import 'package:joincompany/services/BaseService.dart';

String resourcePath = '/customers';

Future<http.Response> getAllCustomers(String customer, String authorization, { String perPage, String urlPage } ) async{
  
  var params = new Map<String, String>();

  if (perPage != null && perPage!=''){
      params["per_page"]=perPage;
  }

  return await httpGet(customer, authorization, resourcePath, params: params, urlPage: urlPage);
}

Future<http.Response> getAllCustomersWithAddress(String customer, String authorization, { String perPage, String urlPage } ) async{
  
  String resourcePath = '/customer_addresses';

  var params = new Map<String, String>();

  if (perPage != null && perPage!=''){
      params["per_page"]=perPage;
  }

  return await httpGet(customer, authorization, resourcePath, params: params, urlPage: urlPage);
}

Future<http.Response> getCustomer(String id, String customer, String authorization) async{

  return await httpGet(customer, authorization, resourcePath, id: id);
}

Future<http.Response> createCustomer(CustomerModel customerObj, String customer, String authorization) async{
  
  var bodyJson = customerObj.toJson();

  return await httpPost(bodyJson, customer, authorization, resourcePath);
}

Future<http.Response> updateCustomer(String id, CustomerModel customerObj, String customer, String authorization) async{
  
  var bodyJson = customerObj.toJson();

  return await httpPut(id, bodyJson, customer, authorization, resourcePath);
}

Future<http.Response> deleteCustomer(String id, String customer, String authorization) async{
  String resourcePath = '/customer/delete';
  
  return await httpDelete(id, customer, authorization, resourcePath, false);
}
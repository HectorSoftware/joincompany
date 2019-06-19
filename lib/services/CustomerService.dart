import 'dart:convert';

import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:joincompany/models/CustomerModel.dart';

import 'package:joincompany/services/BaseService.dart';

String resourcePath = '/customers';

Future<http.Response> getAllCustomers(String customer, String authorization, { String perPage, String page } ) async{
  
  var params = new Map<String, String>();

  if (perPage != null && perPage!=''){
      params["per_page"]=perPage;
  }

  if (page != null && page!=''){
    params["page"]=page;
  }

  return await httpGet(customer, authorization, resourcePath, params: params);
}

Future<http.Response> getAllCustomersWithAddress(String customer, String authorization, { String perPage, String page } ) async{
  
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

Future<http.Response> getCustomerAddresses(String id, String customer, String authorization ) async{
  
  String extraPath = "/addresses";

  return await httpGet(customer, authorization, resourcePath, id: id, extraPath: extraPath);
}

Future<http.Response> relateCustomerAddress(String idCustomer, String idAddress, String customer, String authorization) async{
  String resourcePath = '/addresses/customers/relate';

  var body = json.encode({
    'customer_id': idCustomer,
    'address_id': idAddress,
    'approved' : 1,
  });

  return await httpPost(body, customer, authorization, resourcePath);
}

Future<http.Response> unrelateCustomerAddress(String idCustomer, String idAddress, String customer, String authorization) async{
  String resourcePath = '/customer/delete_address';
  String id = '$idCustomer/$idAddress';
  
  return await httpGet(customer, authorization, resourcePath, id: id);
}
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:joincompany/async_database/Database.dart';
import 'dart:async';
import 'package:joincompany/models/AddressModel.dart';
import 'package:joincompany/models/AddressesModel.dart';
import 'package:joincompany/models/ResponseModel.dart';
import 'package:joincompany/services/BaseService.dart';

String resourcePath = '/addresses';

Future<ResponseModel> getAllAddresses(String customer, String authorization, {String perPage, String page} ) async{

  List<AddressModel> addresses = await DatabaseProvider.db.ListAddresses();

  AddressesModel addressesObj = new AddressesModel(data: addresses, perPage: 0);

  ResponseModel response = new ResponseModel(statusCode: 200, body: addressesObj);

  return response;
}

Future<http.Response> getAllAddressesFromServer(String customer, String authorization, {String perPage, String page} ) async{
  
  var params = new Map<String, String>();

  if (perPage != null && perPage!=''){
    params["per_page"]=perPage;
  }

  if (page != null && page!=''){
    params["page"]=page;
  }

  return await httpGet(customer, authorization, resourcePath, params: params);
}

Future<http.Response> getAddressFromServer(String id, String customer, String authorization) async{

  return await httpGet(customer, authorization, resourcePath, id: id);
}

Future<http.Response> createAddressFromServer(AddressModel addressObj, String customer, String authorization) async{

  var addressMapAux = addressObj.toMap();
  var addressMap = new Map<String, dynamic>();

  addressMapAux.forEach((key, value) {
    if (value != null) {
      addressMap[key] = value;
    }
  });

  var bodyJson = json.encode(addressMap);
  return await httpPost(bodyJson, customer, authorization, resourcePath);
}

Future<http.Response> updateAddressFromServer(String id, AddressModel addressObj, String customer, String authorization) async{
  
  var bodyJson = addressObj.toJson();

  return await httpPut(id, bodyJson, customer, authorization, resourcePath);
}

Future<http.Response> deleteAddressFromServer(String id, String customer, String authorization) async{
  
  return await httpDelete(id, customer, authorization, resourcePath, true);
}
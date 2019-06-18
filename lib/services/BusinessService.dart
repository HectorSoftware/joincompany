import 'dart:convert';

import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:joincompany/models/BusinessModel.dart';
import 'package:joincompany/services/BaseService.dart';

String resourcePath = '/businesses';

Future<http.Response> getAllBusinesses(String customer, String authorization, {String perPage, String page} ) async{
  
  var params = new Map<String, String>();

  if (perPage != null && perPage!=''){
    params["per_page"]=perPage;
  }

  if (page != null && page!=''){
    params["page"]=page;
  }

  return await httpGet(customer, authorization, resourcePath, params: params);
}

Future<http.Response> getBusiness(String id, String customer, String authorization) async{

  return await httpGet(customer, authorization, resourcePath, id: id);
}

Future<http.Response> createBusiness(BusinessModel businessObj, String customer, String authorization) async{

  var businessMapAux = businessObj.toMap();
  var businessMap = new Map<String, dynamic>();

  businessMapAux.forEach((key, value) {
    if (value != null) {
      businessMap[key] = value;
    }
  });

  var bodyJson = json.encode(businessMap);
  return await httpPost(bodyJson, customer, authorization, resourcePath);
}

Future<http.Response> updateBusiness(String id, BusinessModel businessObj, String customer, String authorization) async{
  
  var bodyJson = businessObj.toJson();

  return await httpPut(id, bodyJson, customer, authorization, resourcePath);
}

Future<http.Response> deleteBusiness(String id, String customer, String authorization) async{
  
  return await httpDelete(id, customer, authorization, resourcePath, false);
}
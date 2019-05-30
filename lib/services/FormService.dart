import 'package:http/http.dart' as http;
import 'dart:async';

import 'package:joincompany/services/BaseService.dart';

String resourcePath = '/forms';

Future<http.Response> getAllForms(String customer, String authorization, {String perPage, String page} ) async{
  
  var params = new Map<String, String>();

  if (perPage != null && perPage!=''){
    params["per_page"]=perPage;
  }

  if (page != null && page!=''){
    params["page"]=page;
  }

  return await httpGet(customer, authorization, resourcePath, params: params);
}

Future<http.Response> getForm(String id, String customer, String authorization) async{

  return await httpGet(customer, authorization, resourcePath, id: id);
}
import 'package:http/http.dart' as http;
import 'package:joincompany/async_database/Database.dart';
import 'package:joincompany/models/FormModel.dart';
import 'package:joincompany/models/FormsModel.dart';
import 'package:joincompany/models/ResponseModel.dart';
import 'dart:async';

import 'package:joincompany/services/BaseService.dart';
import 'package:joincompany/services/CustomerService.dart';

String resourcePath = '/forms';

Future<ResponseModel> getAllForms(String customer, String authorization, {String perPage, String page}) async {
  ResponseModel response = new ResponseModel();
  response.body = FormsModel(data: await DatabaseProvider.db.ListForms(), perPage: 0);
  response.statusCode = 200;
  return response;
}

Future<http.Response> getAllFormsFromServer(String customer, String authorization, {String perPage, String page} ) async{
  
  var params = new Map<String, String>();

  if (perPage != null && perPage!=''){
    params["per_page"]=perPage;
  }

  if (page != null && page!=''){
    params["page"]=page;
  }

  return await httpGet(customer, authorization, resourcePath, params: params);
}

Future<ResponseModel> getForm(String id, String customer, String authorization) async {
  ResponseModel response = new ResponseModel();
  response.body = await DatabaseProvider.db.ReadFormById(int.parse(id));
  response.statusCode = 200;
  return response;
}

Future<http.Response> getFormFromServer(String id, String customer, String authorization) async {

  return await httpGet(customer, authorization, resourcePath, id: id);
}
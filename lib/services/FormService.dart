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
  if (isOnline) {
    var getAllFormsResponse = await getAllFormsFromServer(customer, authorization, perPage: perPage, page: page);
    if (getAllFormsResponse.statusCode == 200 || getAllFormsResponse.statusCode == 201) {
      var formsFromResponse = FormsModel.fromJson(getAllFormsResponse.body);
      formsFromResponse.data.forEach((formModel) async => await DatabaseProvider.db.CreateForm(formModel, SyncState.synchronized));
    }
  }

  ResponseModel response = new ResponseModel();
  response.body = FormsModel(data: await DatabaseProvider.db.ListForms());
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
  if (isOnline) {
    var getFormFromServerResponse = await getForm(id, customer, authorization);
    if (getFormFromServerResponse.statusCode == 200 || getFormFromServerResponse.statusCode == 201)
      await DatabaseProvider.db.CreateForm(FormModel.fromJson(getFormFromServerResponse.body), SyncState.synchronized);
  }

  ResponseModel response = new ResponseModel();
  response.body = await DatabaseProvider.db.ReadFormById(int.parse(id));
  response.statusCode = 200;
  return response;
}

Future<http.Response> getFormFromServer(String id, String customer, String authorization) async {

  return await httpGet(customer, authorization, resourcePath, id: id);
}
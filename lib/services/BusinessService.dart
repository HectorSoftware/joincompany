import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:joincompany/async_database/Database.dart';
import 'package:joincompany/blocs/blocCheckConnectivity.dart';
import 'dart:async';
import 'package:joincompany/models/BusinessModel.dart';
import 'package:joincompany/models/BusinessesModel.dart';
import 'package:joincompany/models/ResponseModel.dart';
import 'package:joincompany/services/BaseService.dart';

String resourcePath = '/businesses';

ConnectionStatusSingleton connectionStatus = ConnectionStatusSingleton.getInstance();

Future<ResponseModel> getAllBusinesses(String customer, String authorization, {String perPage, String page, bool excludeDeleted = false} ) async {

  List<BusinessModel> businesses = await DatabaseProvider.db.RetrieveBusinessesByUserToken(authorization, excludeDeleted);

  BusinessesModel businessesObj = new BusinessesModel(data: businesses, perPage: 0);

  ResponseModel response = new ResponseModel(statusCode: 200, body: businessesObj);

  return response;
}

Future<http.Response> getAllBusinessesFromServer(String customer, String authorization, {String perPage, String page} ) async{
  
  var params = new Map<String, String>();

  if (perPage != null && perPage!=''){
    params["per_page"]=perPage;
  }

  if (page != null && page!=''){
    params["page"]=page;
  }

  return await httpGet(customer, authorization, resourcePath, params: params);
}

Future<ResponseModel> getBusiness(String id, String customer, String authorization) async {
  BusinessModel businessObj = await DatabaseProvider.db.ReadBusinessById(int.parse(id));

  ResponseModel response = new ResponseModel(statusCode: 200, body: businessObj);

  return response;
}

Future<http.Response> getBusinessFromServer(String id, String customer, String authorization) async{

  return await httpGet(customer, authorization, resourcePath, id: id);
}

Future<ResponseModel> createBusiness(BusinessModel businessObj, String customer, String authorization) async {
  var syncState = SyncState.created;

  if (await connectionStatus.checkConnection()) {
    var createBusinessResponse = await createBusinessFromServer(businessObj, customer, authorization);
    if ((createBusinessResponse.statusCode==200 || createBusinessResponse.statusCode==201) && createBusinessResponse.body != 'Negocio ya existe' && createBusinessResponse.body != 'Cliente no existe'){
      businessObj = BusinessModel.fromJson(createBusinessResponse.body);
      syncState = SyncState.synchronized;
    } else {
      return new ResponseModel(statusCode: 500, body: createBusinessResponse.body);
    }
  }
  
  BusinessModel businessCreated = await DatabaseProvider.db.CreateBusiness(businessObj, syncState);

  ResponseModel response = new ResponseModel(statusCode: 200, body: businessCreated);

  return response;
}

Future<http.Response> createBusinessFromServer(BusinessModel businessObj, String customer, String authorization) async{

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

Future<ResponseModel> updateBusiness(String id, BusinessModel businessObj, String customer, String authorization) async {
  var syncState = SyncState.updated;

  if (await connectionStatus.checkConnection()) {
    var updateBusinessResponse = await updateBusinessFromServer(businessObj.id.toString(), businessObj, customer, authorization);
    if ((updateBusinessResponse.statusCode==200 || updateBusinessResponse.statusCode==201) && updateBusinessResponse.body != 'Negocio ya existe') {
      businessObj = BusinessModel.fromJson(updateBusinessResponse.body);
      syncState = SyncState.synchronized;
    } else {
      return new ResponseModel(statusCode: 500, body: updateBusinessResponse.body);
    }
  }
  
  BusinessModel businessUpdated = await DatabaseProvider.db.UpdateBusiness(int.parse(id), businessObj, syncState);

  ResponseModel response = new ResponseModel(statusCode: 200, body: businessUpdated);

  return response;
}

Future<http.Response> updateBusinessFromServer(String id, BusinessModel businessObj, String customer, String authorization) async{
  
  String resourcePath = '/business/update';

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

Future<ResponseModel> deleteBusiness(String id, String customer, String authorization) async {

  bool deletedFromServer = false;

  if (await connectionStatus.checkConnection()) {
    var deleteBusinessResponse = await deleteBusinessFromServer(id, customer, authorization);
    if (deleteBusinessResponse.statusCode==200 || deleteBusinessResponse.statusCode==201) {
      deletedFromServer = true;
    } else {
      return new ResponseModel(statusCode: 500, body: deleteBusinessResponse.body);
    }
  }

  int responseDelete;

  if (deletedFromServer) {
    responseDelete = await DatabaseProvider.db.DeleteBusinessById(int.parse(id));
  } else {
    responseDelete = await DatabaseProvider.db.ChangeSyncStateBusiness(int.parse(id), SyncState.deleted);
  }

  ResponseModel response = new ResponseModel(statusCode: 200, body: responseDelete.toString());

  return response;
}

Future<http.Response> deleteBusinessFromServer(String id, String customer, String authorization) async {
  String resourcePath = '/businesses/delete';
  
  return await httpDelete(id, customer, authorization, resourcePath, false);
}
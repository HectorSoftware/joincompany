import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:joincompany/async_database/Database.dart';
import 'package:joincompany/models/ResponseModel.dart';
import 'dart:async';
import 'package:joincompany/models/TaskModel.dart';
import 'package:joincompany/services/BaseService.dart';
import 'package:joincompany/services/CustomerService.dart';

String resourcePath = '/tasks';

Future<ResponseModel> createTask(TaskModel task, String customer, String authorization) async {
  SyncState syncState = SyncState.created;

  if (isOnline) {
    http.Response createTaskFromServerResponse = await createTaskFromServer(task, customer, authorization);
    if (createTaskFromServerResponse.statusCode == 200 || createTaskFromServerResponse.statusCode == 201) {
      task = TaskModel.fromJson(createTaskFromServerResponse.body);
      syncState = SyncState.synchronized;
    }
  }

  ResponseModel response = new ResponseModel();
  response.body = await DatabaseProvider.db.CreateTask(task, syncState);
  response.statusCode = 200;
  return response;
}

Future<http.Response> createTaskFromServer(TaskModel taskObj, String customer, String authorization) async{
  var taskMapAux = taskObj.toMap();
  var taskMap = new Map<String, dynamic>();

  taskMapAux.forEach((key, value) {
    if (value != null) {
      taskMap[key] = value;
    }
  });

  var bodyJson = json.encode(taskMap);

  return await httpPost(bodyJson, customer, authorization, resourcePath);
}

Future<http.Response> getAllTasks(String customer, String authorization, {String beginDate, String endDate, String supervisorId, String responsibleId, String formId, String perPage, String page} ) async{

  String resourcePath = '/tasks2';

  var params = new Map<String, String>();

  if (beginDate != null && beginDate!=''){
    params["begin_date"]=beginDate;
  }

  if (endDate != null && endDate!=''){
    params["end_date"]=endDate;
  }

  if (supervisorId != null && supervisorId!=''){
    params["supervisor_id"]=supervisorId;
  }
  if (responsibleId != null && responsibleId!=''){
    params["responsible_id"]=responsibleId;
  }

  if (formId != null && formId!=''){
    params["form_id"]=formId;
  }

  if (perPage != null && perPage!=''){
    params["per_page"]=perPage;
  }

  if (page != null && page!=''){
    params["page"]=page;
  }

  return await httpGet(customer, authorization, resourcePath, params: params);
}

Future<http.Response> getTask(String id, String customer, String authorization) async{

  return await httpGet(customer, authorization, resourcePath, id: id);
}

Future<http.Response> updateTask(String id, TaskModel taskObj, String customer, String authorization) async{
  
  var bodyJson = taskObj.toJson();

  return await httpPut(id, bodyJson, customer, authorization, resourcePath);
}

Future<http.Response> deleteTask(String id, String customer, String authorization) async{
  
  return await httpDelete(id, customer, authorization, resourcePath, true);
}

Future<http.Response> checkInTask(String id, String customer, String authorization, String latitude, String longitude, String distance, { String date }) async{
  
  String path = resourcePath + '/$id/checkin';

  var params = {
    "task_id": id,
    "latitude": latitude,
    "longitude": longitude,
    "distance": distance,
  };

  if (date != null && date!=''){
    params["date"]=date;
  }

  String bodyjson = jsonEncode(params);

  return await httpPost(bodyjson, customer, authorization, path);
}

Future<http.Response> checkOutTask(String id, String customer, String authorization, String latitude, String longitude, String distance, { String date }) async{
  
  String path = resourcePath + '/$id/checkout';

  var params = {
    "task_id": id,
    "latitude": latitude,
    "longitude": longitude,
    "distance": distance,
  };

  if (date != null && date!=''){
    params["date"]=date;
  }

  String bodyjson = jsonEncode(params);

  return await httpPost(bodyjson, customer, authorization, path);
}
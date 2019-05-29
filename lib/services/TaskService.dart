import 'dart:convert';

import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:joincompany/models/TaskModel.dart';
import 'package:joincompany/services/BaseService.dart';

String resourcePath = '/tasks';

Future<http.Response> getAllTasks(String customer, String authorization, {String beginDate, String endDate, String supervisorId, String responsibleId, String formId, String perPage, String urlPage} ) async{
  
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

  return await httpGet(customer, authorization, resourcePath, params: params, urlPage: urlPage);
}

Future<http.Response> getTask(String id, String customer, String authorization) async{

  return await httpGet(customer, authorization, resourcePath, id: id);
}

Future<http.Response> createTask(TaskModel taskObj, String customer, String authorization) async{

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
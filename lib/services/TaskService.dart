import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:joincompany/async_database/Database.dart';
import 'package:joincompany/models/ResponseModel.dart';
import 'package:joincompany/models/TaskModel.dart';
import 'package:joincompany/models/TasksModel.dart';
import 'package:joincompany/services/BaseService.dart';
import 'package:joincompany/blocs/blocCheckConnectivity.dart';

String resourcePath = '/tasks';

ConnectionStatusSingleton connectionStatus = ConnectionStatusSingleton.getInstance(); 

String treatBodyRes(String body) {
  var test = body;
  if (body[0] == "[" && body[body.length - 1] == "]") {
   test = body.substring(1, (body.length - 1));
  }

  return test;
}

Future<ResponseModel> createTask(TaskModel task, String customer, String authorization) async {
  SyncState syncState = SyncState.created;

  if (await connectionStatus.checkConnection()) {
    http.Response createTaskFromServerResponse = await createTaskFromServer(task, customer, authorization);
    var a = createTaskFromServerResponse.body;
    if (createTaskFromServerResponse.statusCode == 200 || createTaskFromServerResponse.statusCode == 201) {
      var a = createTaskFromServerResponse.body;
      // task = TaskModel.fromJson(createTaskFromServerResponse.body);
      task = TaskModel.fromJson(treatBodyRes(createTaskFromServerResponse.body));
      http.Response taskWithInfoFromServerRes = await getTaskFromServer(task.id.toString(), customer, authorization);
      if (createTaskFromServerResponse.statusCode == 200 || createTaskFromServerResponse.statusCode == 201) {
        task = TaskModel.fromJson(taskWithInfoFromServerRes.body);
      }
      syncState = SyncState.synchronized;
    }
  }

  ResponseModel response = new ResponseModel();
  response.body = await DatabaseProvider.db.CreateTask(task, syncState);
  response.statusCode = 200;
  return response;
}

Future<http.Response> createTaskFromServer(TaskModel taskObj, String customer, String authorization) async {
  String resourcePath = '/tasks2_';

  // TODO: Check if the problem of the maps relies here.
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

Future<ResponseModel> getAllTasks(String customer, String authorization, {String beginDate, String endDate, String supervisorId, String responsibleId, String formId, String businessId, String perPage, String page}) async {
  ResponseModel response = new ResponseModel();

  QueryTasks query = new QueryTasks(
    beginDate: beginDate,
    endDate: endDate,
    supervisorId: supervisorId,
    responsibleId: responsibleId,
    formId: formId,
    perPage: perPage,
    page: page,
  );

  List<TaskModel> listOfTasks = await DatabaseProvider.db.QueryTaskForService(query);
  
  listOfTasks.sort((a,b) {
    var dateA = a.planningDate != null ? a.planningDate : a.createdAt;
    var dateB = b.planningDate != null ? b.planningDate : b.createdAt;

    return dateB.compareTo(dateA);
  });
  
  TasksModel tasks = new TasksModel(
    currentPage: 1,
    data: listOfTasks,
    firstPageUrl: null,
    from: 1,
    lastPage: 1,
    lastPageUrl: null,
    nextPageUrl: null,
    path: null,
    perPage: listOfTasks.length,
    prevPageUrl: null,
    to: listOfTasks.length,
    total: listOfTasks.length,
  );
  print("tasks.data length: " + tasks.data.length.toString());

  response.body = tasks;
  response.statusCode = 200;

  return response;
}

Future<http.Response> getAllTasksFromServer(String customer, String authorization, {String beginDate, String endDate, String supervisorId, String responsibleId, String formId, String businessId, String perPage, String page}) async {

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

  if (businessId != null && businessId!=''){
    params["business_id"]=businessId;
  }

  if (perPage != null && perPage!=''){
    params["per_page"]=perPage;
  }

  if (page != null && page!=''){
    params["page"]=page;
  }

  var output = await httpGet(customer, authorization, resourcePath, params: params);
  return output;
}

Future<ResponseModel> getTask(String id, String customer, String authorization) async {
  ResponseModel response = new ResponseModel();
  if (await connectionStatus.checkConnection()) {
    http.Response getTaskFromServerJSON = await getTaskFromServer(id, customer, authorization);
    if (getTaskFromServerJSON.statusCode == 200 || getTaskFromServerJSON.statusCode == 201) {
      TaskModel taskFromServer = TaskModel.fromJson(getTaskFromServerJSON.body);
      response.body = taskFromServer;
    }
    response.statusCode = getTaskFromServerJSON.statusCode;
  } else {
    response.body = await DatabaseProvider.db.ReadTaskById(int.parse(id));
    response.statusCode = 200;
  }

  return response;
}

Future<http.Response> getTaskFromServer(String id, String customer, String authorization) async {
  return await httpGet(customer, authorization, resourcePath, id: id);
}

Future<ResponseModel> updateTask(String id, TaskModel taskObj, String customer, String authorization) async {
  SyncState syncState = SyncState.updated;

  if (await connectionStatus.checkConnection()) {
    http.Response updateTaskFromServerResJSON = await updateTaskFromServer(id, taskObj, customer, authorization);
    if (updateTaskFromServerResJSON.statusCode == 200 || updateTaskFromServerResJSON.statusCode == 201) {
      taskObj = TaskModel.fromJson(updateTaskFromServerResJSON.body);
      syncState = SyncState.synchronized;
    }
  }

  ResponseModel response = new ResponseModel();
  response.body = await DatabaseProvider.db.UpdateTask(taskObj.id, taskObj, syncState);
  response.statusCode = 200;
  return response;
}

Future<http.Response> updateTaskFromServer(String id, TaskModel taskObj, String customer, String authorization) async {
  var bodyJson = taskObj.toJson();
  return await httpPut(id, bodyJson, customer, authorization, resourcePath);
}

Future<ResponseModel> deleteTask(String id, String customer, String authorization) async {
  bool deletedFromServer = false;

  if (await connectionStatus.checkConnection()) {
    http.Response deleteTaskRes = await deleteTaskFromServer(id, customer, authorization);
    if (deleteTaskRes.statusCode == 200 || deleteTaskRes.statusCode == 201) {
      deletedFromServer = true;
    }
  }

  int deleteFromLocalResponse;
  if (deletedFromServer) {
    deleteFromLocalResponse = await DatabaseProvider.db.DeleteTaskById(int.parse(id));
  } else {
    deleteFromLocalResponse = await DatabaseProvider.db.ChangeSyncStateTask(int.parse(id), SyncState.deleted);
  }

  ResponseModel response = new ResponseModel();
  response.body =  deleteFromLocalResponse.toString();
  response.statusCode = 200;
  return response;
}

Future<http.Response> deleteTaskFromServer(String id, String customer, String authorization) async {
  return await httpDelete(id, customer, authorization, resourcePath, true);
}

Future<ResponseModel> checkInTask(String id, String customer, String authorization, String latitude, String longitude, String distance, { String date }) async {
  SyncState syncState = SyncState.updated;

  if (await connectionStatus.checkConnection()) {
    http.Response checkInTaskResJSON = await checkInTaskFromServer(id, customer, authorization, latitude, longitude, distance, date: date);
    if (checkInTaskResJSON.statusCode == 200 || checkInTaskResJSON.statusCode == 201) {
      syncState = SyncState.synchronized;
    }
  }

  ResponseModel response = new ResponseModel();
  response.body = await DatabaseProvider.db.UpdateTaskCheckIn(int.parse(id), longitude, latitude, distance, syncState, date: date);
  response.statusCode = 200;
  return response;
}

Future<http.Response> checkInTaskFromServer(String id, String customer, String authorization, String latitude, String longitude, String distance, { String date }) async {
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

Future<ResponseModel> checkOutTask(String id, String customer, String authorization, String latitude, String longitude, String distance, { String date }) async {
  SyncState syncState = SyncState.updated;

  if (await connectionStatus.checkConnection()) {
    http.Response checkOutTaskResJSON = await checkOutTaskFromServer(id, customer, authorization, latitude, longitude, distance, date: date);
    if (checkOutTaskResJSON.statusCode == 200 || checkOutTaskResJSON.statusCode == 201) {
      syncState = SyncState.synchronized;
    }
  }

  ResponseModel response = new ResponseModel();
  response.body = await DatabaseProvider.db.UpdateTaskCheckOut(int.parse(id), longitude, latitude, distance, syncState, date: date);
  response.statusCode = 200;
  return response;
}

Future<http.Response> checkOutTaskFromServer(String id, String customer, String authorization, String latitude, String longitude, String distance, { String date }) async {
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

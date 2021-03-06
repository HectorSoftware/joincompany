import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:joincompany/async_database/Database.dart';
import 'package:joincompany/blocs/blocCheckConnectivity.dart';
import 'dart:async';
import 'package:joincompany/models/ContactModel.dart';
import 'package:joincompany/models/ContactsModel.dart';
import 'package:joincompany/models/ResponseModel.dart';
import 'package:joincompany/services/BaseService.dart';

String resourcePath = '/contacts';

ConnectionStatusSingleton connectionStatus = ConnectionStatusSingleton.getInstance(); 

Future<ResponseModel> getAllContacts(String customer, String authorization, {String perPage, String page, bool excludeDeleted = false} ) async {
  List<ContactModel> contacts = await DatabaseProvider.db.RetrieveContactsByUserToken(authorization, excludeDeleted);

  ContactsModel contactsObj = new ContactsModel(data: contacts, perPage: 0);

  ResponseModel response = new ResponseModel(statusCode: 200, body: contactsObj);

  return response;
}

Future<http.Response> getAllContactsFromServer(String customer, String authorization, {String perPage, String page} ) async {
  
  var params = new Map<String, String>();

  if (perPage != null && perPage!=''){
    params["per_page"]=perPage;
  }

  if (page != null && page!=''){
    params["page"]=page;
  }

  return await httpGet(customer, authorization, resourcePath, params: params);
}

Future<ResponseModel> getContact(String id, String customer, String authorization) async {
  ContactModel contactObj = await DatabaseProvider.db.ReadContactById(int.parse(id));

  ResponseModel response = new ResponseModel(statusCode: 200, body: contactObj);

  return response;
}

Future<http.Response> getContactFromServer(String id, String customer, String authorization) async {

  return await httpGet(customer, authorization, resourcePath, id: id);
}

Future<ResponseModel> createContact(ContactModel contactObj, String customer, String authorization) async {
  var syncState = SyncState.created;

  if (await connectionStatus.checkConnection()) {
    var createContactResponse = await createContactFromServer(contactObj, customer, authorization);
    if ((createContactResponse.statusCode==200 || createContactResponse.statusCode==201) && createContactResponse.body != 'Contacto ya existe') {
      contactObj = ContactModel.fromJson(createContactResponse.body);
      syncState = SyncState.synchronized;
    } else {
      return new ResponseModel(statusCode: 500, body: createContactResponse.body);
    }
  }
  
  ContactModel contactCreated = await DatabaseProvider.db.CreateContact(contactObj, syncState);

  ResponseModel response = new ResponseModel(statusCode: 200, body: contactCreated);

  return response;
}

Future<http.Response> createContactFromServer(ContactModel contactObj, String customer, String authorization) async {

  var contactMapAux = contactObj.toMap();
  var contactMap = new Map<String, dynamic>();

  contactMapAux.forEach((key, value) {
    if (value != null) {
      contactMap[key] = value;
    }
  });

  var bodyJson = json.encode(contactMap);

  return await httpPost(bodyJson, customer, authorization, resourcePath);
}

Future<ResponseModel> updateContact(String id, ContactModel contactObj, String customer, String authorization) async {
  var syncState = SyncState.updated;

  if (await connectionStatus.checkConnection()) {
    var updateContactResponse = await updateContactFromServer(contactObj.id.toString(), contactObj, customer, authorization);
    if ((updateContactResponse.statusCode==200 || updateContactResponse.statusCode==201) && updateContactResponse.body != 'Contacto ya existe') {
      contactObj = ContactModel.fromJson(updateContactResponse.body);
      syncState = SyncState.synchronized;
    } else {
      return new ResponseModel(statusCode: 500, body: updateContactResponse.body);
    }
  }
  
  ContactModel contactUpdated = await DatabaseProvider.db.UpdateContact(int.parse(id), contactObj, syncState);

  ResponseModel response = new ResponseModel(statusCode: 200, body: contactUpdated);

  return response;
}

Future<http.Response> updateContactFromServer(String id, ContactModel contactObj, String customer, String authorization) async {
  String resourcePath = '/contact/update';

  var contactMapAux = contactObj.toMap();
  var contactMap = new Map<String, dynamic>();

  contactMapAux.forEach((key, value) {
    if (value != null) {
      contactMap[key] = value;
    }
  });

  var bodyJson = json.encode(contactMap);

  return await httpPost(bodyJson, customer, authorization, resourcePath);
}

Future<ResponseModel> deleteContact(String id, String customer, String authorization) async {

  bool deletedFromServer = false;

  if (await connectionStatus.checkConnection()) {
    var deleteContactResponse = await deleteContactFromServer(id, customer, authorization);
    if (deleteContactResponse.statusCode==200 || deleteContactResponse.statusCode==201) {
      deletedFromServer = true;
    } else {
      return new ResponseModel(statusCode: 500, body: deleteContactResponse.body);
    }
  }

  int responseDelete;

  if (deletedFromServer) {
    responseDelete = await DatabaseProvider.db.DeleteContactById(int.parse(id));
  } else {
    responseDelete = await DatabaseProvider.db.ChangeSyncStateContact(int.parse(id), SyncState.deleted);
  }

  ResponseModel response = new ResponseModel(statusCode: 200, body: responseDelete.toString());

  return response;
}

Future<http.Response> deleteContactFromServer(String id, String customer, String authorization) async {
  String resourcePath = '/contacts/delete';
  
  return await httpDelete(id, customer, authorization, resourcePath, false);
}
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:joincompany/models/ContactModel.dart';
import 'package:joincompany/services/BaseService.dart';

String resourcePath = '/contacts';

Future<http.Response> getAllContacts(String customer, String authorization, {String perPage, String page} ) async{
  
  var params = new Map<String, String>();

  if (perPage != null && perPage!=''){
    params["per_page"]=perPage;
  }

  if (page != null && page!=''){
    params["page"]=page;
  }

  return await httpGet(customer, authorization, resourcePath, params: params);
}

Future<http.Response> getContact(String id, String customer, String authorization) async{

  return await httpGet(customer, authorization, resourcePath, id: id);
}

Future<http.Response> createContact(ContactModel contactObj, String customer, String authorization) async{

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

Future<http.Response> updateContact(String id, ContactModel contactObj, String customer, String authorization) async{
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

Future<http.Response> deleteContact(String id, String customer, String authorization) async {
  String resourcePath = '/contacts/delete';
  
  return await httpDelete(id, customer, authorization, resourcePath, false);
}
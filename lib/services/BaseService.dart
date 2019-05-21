import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:joincompany/main.dart';

Future<http.Response> httpGet(String customer, String authorization, String resourcePath, { String id, Map<String, String> params, String urlPage }) async{

  var uri = Uri.https(hostApi, versionApi + resourcePath + (id!=null && id!='' ? '/$id' : ''), params);
  var url = '';
  
  if (urlPage!=null && urlPage!='') {
    url = urlPage;
  }

  final response = await http.get(url!='' ? url : uri,
    headers: {
      'customer': customer,
      'Authorization': 'Bearer $authorization',
    }
  );

  return response;
}

Future<http.Response> httpPost(String bodyJson, String customer, String authorization, String resourcePath) async{
  var uri = Uri.https(hostApi, versionApi + resourcePath);

  final response = await http.post(uri,
    headers: {
      'customer': customer,
      'Authorization': 'Bearer $authorization',
      'Content-Type' : 'application/json',
    },
    body: bodyJson
  );

  return response;
}

Future<http.Response> httpPut(String id, String bodyJson, String customer, String authorization, String resourcePath) async{
  var uri = Uri.https(hostApi, versionApi + resourcePath + '/$id');

  final response = await http.put(uri,
    headers: {
      'customer': customer,
      'Authorization': 'Bearer $authorization',
      'Content-Type' : 'application/json',
    },
    body: bodyJson
  );

  return response;
}


Future<http.Response> httpDelete(String id, String customer, String authorization, String resourcePath) async{
  var uri = Uri.https(hostApi, versionApi + resourcePath + '/$id');

  final response = await http.delete(uri,
    headers: {
      'customer': customer,
      'Authorization': 'Bearer $authorization',
    }
  );

  return response;
}
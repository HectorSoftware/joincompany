import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:joincompany/main.dart';

Future<http.Response> httpGet(String customer, String authorization, String resourcePath, { String id, Map<String, String> params, String extraPath }) async{
  try{
    var uri = Uri.https(hostApi, versionApi + resourcePath + (id!=null && id!='' ? '/$id' : '') + (extraPath!=null && extraPath!='' ? '$extraPath' : ''), params);

    final response = await http.get(uri,
        headers: {
          'customer': customer,
          'Authorization': 'Bearer $authorization',
        }
    );

    return response;
  }on Exception{
    print("error get");
    return null;
  }

}

Future<http.Response> httpPost(String bodyJson, String customer, String authorization, String resourcePath) async{
  try{
    var uri = Uri.https(hostApi, versionApi + resourcePath);

    final response = await http.post(uri,
        headers: {
          'customer': customer,
          'Authorization': 'Bearer $authorization',
          'Content-Type' : 'application/json',
          'Accept': 'application/json',
        },
        body: bodyJson
    );

    return response;
  }on Exception{
    print("error post");
    return null;
  }

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


Future<http.Response> httpDelete(String id, String customer, String authorization, String resourcePath, bool standardCall) async{

  var response;
  var uri = Uri.https(hostApi, versionApi + resourcePath + '/$id');
  var headers = {
    'customer': customer,
    'Authorization': 'Bearer $authorization',
  };

  if (standardCall) {
    response = await http.delete(uri, headers: headers);
  } else {
    response = await http.get(uri, headers: headers);
  }
  
  return response;
}
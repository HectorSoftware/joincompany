import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:joincompany/main.dart';

String finalPath = '/forms';
String url = hostApi + versionApi + finalPath;

Future<http.Response> getAllForms(String customer, String authorization) async{
  final response = await http.get('$url',
    headers: {
      'customer': customer,
      'Authorization': 'Bearer $authorization',
    }
  );
  return response;
}

Future<http.Response> getForm(String id, String customer, String authorization) async{
  final response = await http.get('$url/$id',
    headers: {
      'customer': customer,
      'Authorization': 'Bearer $authorization',
    }
  );
  return response;
}
import 'package:http/http.dart' as http;
import 'dart:async';
// import 'package:joincompany/models/AuthModel.dart';
import 'dart:io';
import 'package:joincompany/main.dart';

String finalPath = '/auth';
String url = hostApi + versionApi + finalPath;

Future<http.Response> login(String email, String password, String customer) async{
  final response = await http.post('$url/login',
      headers: {
        'customer': customer,
      },
      body: {
        'email': email,
        'password': password,
      }
  );
  return response;
}

Future<http.Response> logout(String customer, String authorization) async{
  final response = await http.post('$url/logout',
      headers: {
        'customer': customer,
        'Authorization': 'Bearer $authorization',
      }
  );
  return response;
}

Future<http.Response> refreshToken(String customer, String authorization) async{
  final response = await http.post('$url/refresh',
      headers: {
        'customer': customer,
        'Authorization': 'Bearer $authorization',
      }
  );
  return response;
}
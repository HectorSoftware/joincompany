import 'dart:convert';

import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:joincompany/services/BaseService.dart';

Future<http.Response> login(String email, String password, String customer) async{
  String resourcePath = '/auth/login';

  var body = json.encode({
    'email': email,
    'password': password,
  });

  return await httpPost(body, customer, '', resourcePath);
}

Future<http.Response> logout(String customer, String authorization) async{
  String resourcePath = '/auth/logout';

  return await httpPost('', customer, authorization, resourcePath);
}

Future<http.Response> refreshToken(String customer, String authorization) async{
  String resourcePath = '/auth/refresh';
  
  return await httpPost('', customer, authorization, resourcePath);
}
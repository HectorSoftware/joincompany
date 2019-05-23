import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:joincompany/services/BaseService.dart';

String resourcePath = '/user';

Future<http.Response> getUser(String customer, String authorization) async{

  return await httpGet(customer, authorization, resourcePath);
}
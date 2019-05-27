import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:joincompany/services/BaseService.dart';

String resourcePath = '/account';

Future<http.Response> getAccount(String customer, String authorization) async{

  return await httpGet(customer, authorization, resourcePath);
}
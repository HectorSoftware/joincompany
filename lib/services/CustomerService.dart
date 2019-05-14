import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:joincompany/models/CustomerModel.dart';
import 'package:joincompany/models/CustomersModel.dart';
import 'dart:io';

String url = 'https://webapp.getkem.com/api/v1/customers';

Future<http.Response> getAllCustomers(String customer, String authorization) async{
  final response = await http.get('$url',
    headers: {
      'customer': customer,
      'Authorization': 'Bearer $authorization',
    }
  );
  return response;
}

Future<http.Response> getCustomer(String id, String customer, String authorization) async{
  final response = await http.get('$url/$id',
    headers: {
      'customer': customer,
      'Authorization': 'Bearer $authorization',
    }
  );
  return response;
}

Future<http.Response> createCustomer(Customer customerObj, String customer, String authorization) async{
  final response = await http.post('$url',
    headers: {
      'customer': customer,
      'Authorization': 'Bearer $authorization',
    },
    body: customerToJson(customerObj)
  );
  return response;
}

Future<http.Response> updateCustomer(String id, Customer customerObj, String customer, String authorization) async{
  final response = await http.put('$url/$id',
    headers: {
      'customer': customer,
      'Authorization': 'Bearer $authorization',
    },
    body: customerToJson(customerObj)
  );
  return response;
}

Future<http.Response> delteCustomer(String id, String customer, String authorization) async{
  final response = await http.delete('$url/$id',
    headers: {
      'customer': customer,
      'Authorization': 'Bearer $authorization',
    }
  );
  return response;
}



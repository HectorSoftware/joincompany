import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:joincompany/models/TaskModel.dart';
import 'package:joincompany/main.dart';

String finalPath = '/tasks';
String url = hostApi + versionApi + finalPath;

Future<http.Response> getAllTasks(String customer, String authorization) async{
  final response = await http.get('$url',
    headers: {
      'customer': customer,
      'Authorization': 'Bearer $authorization',
    }
  );
  return response;
}

Future<http.Response> getTask(String id, String customer, String authorization) async{
  final response = await http.get('$url/$id',
    headers: {
      'customer': customer,
      'Authorization': 'Bearer $authorization',
    }
  );
  return response;
}

// Future<http.Response> createCustomer(Customer customerObj, String customer, String authorization) async{
//   final response = await http.post('$url',
//     headers: {
//       'customer': customer,
//       'Authorization': 'Bearer $authorization',
//       'Content-Type' : 'application/json',
//     },
//   body: customerObj.toJson()
//   );
//   return response;
// }

// Future<http.Response> updateCustomer(String id, Customer customerObj, String customer, String authorization) async{
//   final response = await http.put('$url/$id',
//     headers: {
//       'customer': customer,
//       'Authorization': 'Bearer $authorization',
//       'Content-Type' : 'application/json',
//     },
//    body: customerObj.toJson()
//   );
//   return response;
// }

/*
Future<http.Response> delteCustomer(String id, String customer, String authorization) async{
  final response = await http.delete('$url/$id',
    headers: {
      'customer': customer,
      'Authorization': 'Bearer $authorization',
    }
  );
  return response;
}
*/


                        //LLAMAR CLIENTE
                         /*var b =   await  getCustomer('2',empresa,tokken);
                         print(b.body);
                         Customer c = customerFromJson(b.body);
                         //TODOS LOS CLIENTES
                         var muchosresponse = await getAllCustomers(empresa,tokken);
                         Customers muchos = customersFromJson(muchosresponse.body);
                         //ACTUALIZAR CLIENTES
                         c.name += '   rn';
                         var actualizarRespose = await updateCustomer(c.id.toString(), c,empresa, tokken);
                         print(actualizarRespose.statusCode);
                         muchos = customersFromJson(muchosresponse.body);
                         print(muchos.data[1].name);
                         //CREAR NUEVO
                         Customer nuevo = Customer(id: null, name: 'cl',code: '456',contactName: 'kn',createdAt: 'jn',createdById: null,deletedAt: 'p',deletedById: null,details: 'juhoji', email: '@g',phone: '5464', pivot: null, updatedAt: 'npk',updatedById: null);
                         var nuevoResponse = await createCustomer(nuevo,empresa,tokken);
                         print(nuevoResponse.statusCode);*/



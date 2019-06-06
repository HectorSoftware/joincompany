import 'dart:convert';

import 'package:joincompany/async_database/Database.dart';
import 'package:joincompany/models/CustomerModel.dart';
import 'package:joincompany/models/CustomersModel.dart';
import 'package:joincompany/models/UserModel.dart';
import 'package:joincompany/services/CustomerService.dart';

class CustomerAddressesChannel {
  
  CustomerAddressesChannel();
  
  static void _relateCustomerAddressesInBothLocalAndServer(String customer, String authorization) async {

    // Create Local To Server    
    List<Map> customerAddressesLocal = await DatabaseProvider.db.ReadCustomerAddressesBySyncState(SyncState.created);

    customerAddressesLocal.forEach((customerAddressLocal) async {
      var relateCustomerAddressResponseServer = await relateCustomerAddressFromServer(customerAddressLocal["customer_id"], customerAddressLocal["address_id"], customer, authorization);
      if (relateCustomerAddressResponseServer.statusCode==200) {
        Map<String, dynamic> jsonResponse = json.decode(relateCustomerAddressResponseServer.body);
        // Cambiar el SyncState Local
        // Actualizar el id local o usar otro campo para guardar el id del recurso en el servidor
        await DatabaseProvider.db.UpdateCustomerAddress(customerAddressLocal["id"], null, null, null, customerAddressLocal["customer_id"], customerAddressLocal["address_id"], true, SyncState.synchronized);
      }
    });

    // Create Server To Local
    var customersWithAddressResponse = await getAllCustomersWithAddressFromServer(customer, authorization);
    CustomersWithAddressModel customersWithAddress = CustomersWithAddressModel.fromJson(customersWithAddressResponse.body);

    Map<String, int> customersAddressesServerIds = new Map<String, int>();

    Set customersAddressesServer = new Set();
    customersWithAddress.data.forEach((customerWithAddress) async {
      String customerAddressIds = "${customerWithAddress.customerId}-${customerWithAddress.addressId}";
      customersAddressesServerIds[customerAddressIds] = customerWithAddress.id;
      customersAddressesServer.add(customerAddressIds);
    });

    Set customersAddressesLocal = new Set.from( await DatabaseProvider.db.RetrieveAllCustomerAddressRelations() ); //método de albert

    Set customersAddressesToCreate = customersAddressesServer.difference(customersAddressesLocal);

    customersAddressesToCreate.forEach((customerAddressToCreate) async {
      var customerAddressIds = customerAddressToCreate.split("-");
    	int customerId = customerAddressIds[0];
    	int addressId = customerAddressIds[1];
      // Cambiar el SyncState Local
      await DatabaseProvider.db.CreateCustomerAddress(customersAddressesServerIds[customerAddressToCreate], null, null, null, customerId, addressId, true, SyncState.synchronized);
    });
  }

  static void _unrelateCustomerAddressesInBothLocalAndServer(String customer, String authorization) async {

    //Delete Local To Server
    List<Map> customerAdressesLocal = await DatabaseProvider.db.ReadCustomerAddressesBySyncState(SyncState.deleted);

    customerAdressesLocal.forEach((customerAddressLocal) async {
      var unrelateCustomerAddressResponseServer = await unrelateCustomerAddressFromServer(customerAddressLocal["customer_id"], customerAddressLocal["address_id"], customer, authorization);
      if (unrelateCustomerAddressResponseServer.statusCode==200) {
        await DatabaseProvider.db.DeleteCustomerAddressById(customerAddressLocal["customer_id"], customerAddressLocal["address_id"]);
      }
    });

    // Delete Server To Local
    var customersWithAddressResponse = await getAllCustomersWithAddressFromServer(customer, authorization);
    CustomersWithAddressModel customersWithAddress = CustomersWithAddressModel.fromJson(customersWithAddressResponse.body);

    Set customersAddressesServer = new Set();
    customersWithAddress.data.forEach((customerWithAddress) async {
  	  // Set server = new Set.from([ "419-345", "419-346" ]);
      customersAddressesServer.add("${customerWithAddress.customerId}-${customerWithAddress.addressId}");
    });

    Set customersAddressesLocal = new Set.from( await DatabaseProvider.db.RetrieveAllCustomerAddressRelations() ); //método de albert

    Set customersAddressesToDelete = customersAddressesLocal.difference(customersAddressesServer);

    customersAddressesToDelete.forEach((customerAddressToDelete) async {
      var customerAddressIds = customerAddressToDelete.split("-");
    	int customerId = customerAddressIds[0];
    	int addressId = customerAddressIds[1];
      // sobrecargar método para eliminar con los parámetros customerId, addressId
      await DatabaseProvider.db.DeleteCustomerAddressById(customerId, addressId);
    });
  }

  static void syncEverything() async {

    UserModel user = await DatabaseProvider.db.RetrieveLastLoggedUser();

    String customer = user.company;
    String authorization = user.rememberToken;
    
    await CustomerAddressesChannel._unrelateCustomerAddressesInBothLocalAndServer(customer, authorization);
    await CustomerAddressesChannel._relateCustomerAddressesInBothLocalAndServer(customer, authorization);
  }
}
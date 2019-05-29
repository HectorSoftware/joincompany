
import 'package:joincompany/async_database/Database.dart';
import 'package:joincompany/models/FormsModel.dart';
import 'package:joincompany/services/FormService.dart';

class FormChannel {
  
  FormChannel();

  static void createFormsInBothLocalAndServer() async {

    String customer = '';
    String authorization = '';

    // Create Server To Local
    var formsServerResponse = await getAllForms(customer, authorization);
    FormsModel formsServer = FormsModel.fromJson(formsServerResponse.body);

    Set idsFormsServer = new Set();
    formsServer.data.forEach((formServer) async {
      idsFormsServer.add(formServer.id);
    });

    Set idsFormsLocal = new Set.from([1,2,3]); //método de albert

    Set idsToCreate = idsFormsServer.difference(idsFormsLocal);

    formsServer.data.forEach((formServer) async {
      if (idsToCreate.contains(formServer.id)) {
        var createFormResponseLocal = await DatabaseProvider.db.CreateForm(formServer);
        // Cambiar el SyncState Local
      }
    });
  }


}
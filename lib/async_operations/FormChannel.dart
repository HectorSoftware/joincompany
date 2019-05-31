
import 'package:joincompany/async_database/Database.dart';
import 'package:joincompany/models/FormModel.dart';
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

    Set idsFormsLocal = new Set.from(await DatabaseProvider.db.RetrieveAllFormIds()); //método de albert

    Set idsToCreate = idsFormsServer.difference(idsFormsLocal);

    formsServer.data.forEach((formServer) async {
      if (idsToCreate.contains(formServer.id)) {
        // Cambiar el SyncState Local
        DatabaseProvider.db.CreateForm(formServer, SyncState.synchronized);
      }
    });
  }

  static void deleteFormsInBothLocalAndServer() async {
    String customer = '';
    String authorization = '';

    // Delete Server To Local
    var formsServerResponse = await getAllForms(customer, authorization);
    FormsModel formsServer = FormsModel.fromJson(formsServerResponse.body);

    Set idsFormsServer = new Set();
    formsServer.data.forEach((formServer) async {
      idsFormsServer.add(formServer.id);
    });

    Set idsFormsLocal = new Set.from( await DatabaseProvider.db.RetrieveAllFormIds() ); //método de albert

    Set idsToDelete = idsFormsLocal.difference(idsFormsServer);

    idsToDelete.forEach((idToDelete) {
      DatabaseProvider.db.DeleteFormById(idToDelete);
    });
  }

  static void updateFormsInBothLocalAndServer() async {
    String customer = '';
    String authorization = '';
    
    var formsServerResponse = await getAllForms(customer, authorization);
    FormsModel formsServer = FormsModel.fromJson(formsServerResponse.body);

    formsServer.data.forEach((formServer) async {

      FormModel formLocal = await DatabaseProvider.db.ReadFormById(formServer.id);
      DateTime updateDateLocal  = DateTime.parse(formLocal.updatedAt); 
      DateTime updateDateServer = DateTime.parse(formServer.updatedAt);
      int  diffInMilliseconds = updateDateLocal.difference(updateDateServer).inMilliseconds;
      
      if ( diffInMilliseconds < 0 ) { // Actualizar Local
        // DatabaseProvider.db.UpdateForm(formServer.id, formServer, SyncState.synchronized);
      }
    });
  }


}
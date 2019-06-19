import 'package:joincompany/async_database/Database.dart';
import 'package:joincompany/models/FieldModel.dart';
import 'package:joincompany/models/FormModel.dart';
import 'package:joincompany/models/FormsModel.dart';
import 'package:joincompany/models/SectionModel.dart';
import 'package:joincompany/models/TaskModel.dart';
import 'package:joincompany/models/UserModel.dart';
import 'package:joincompany/services/FormService.dart';
import 'package:joincompany/services/Helper.dart';

class FormChannel {
  
  FormChannel();

  static Future _createFormsInBothLocalAndServer(String customer, String authorization) async {

    // Create Server To Local
    var formsServerResponse = await getAllFormsFromServer(customer, authorization);
    FormsModel formsServer = FormsModel.fromJson(formsServerResponse.body);

    Set idsFormsServer = new Set();
    await Future.forEach(formsServer.data, (formServer) async {
      idsFormsServer.add(formServer.id);
    });

    Set idsFormsLocal = new Set.from(await DatabaseProvider.db.RetrieveAllFormIds()); //método de albert

    Set idsToCreate = idsFormsServer.difference(idsFormsLocal);

    await Future.forEach(formsServer.data, (formServer) async {
      if (idsToCreate.contains(formServer.id)) {
        // Cambiar el SyncState Local
        var getFormResponse = await getFormFromServer(formServer.id.toString(), customer, authorization);
        FormModel form = FormModel.fromJson(getFormResponse.body);

        await DatabaseProvider.db.CreateForm(form, SyncState.synchronized);
      }
    });
  }

  static Future _deleteFormsInBothLocalAndServer(String customer, String authorization) async {

    // Delete Server To Local
    var formsServerResponse = await getAllFormsFromServer(customer, authorization);
    FormsModel formsServer = FormsModel.fromJson(formsServerResponse.body);

    Set idsFormsServer = new Set();
    await Future.forEach(formsServer.data, (formServer) async {
      idsFormsServer.add(formServer.id);
    });

    Set idsFormsLocal = new Set.from( await DatabaseProvider.db.RetrieveAllFormIds() ); //método de albert

    Set idsToDelete = idsFormsLocal.difference(idsFormsServer);

    await Future.forEach(idsToDelete, (idToDelete) async{
      await DatabaseProvider.db.DeleteFormById(idToDelete);
    });
  }

  static Future _updateFormsInBothLocalAndServer(String customer, String authorization) async {
    dynamic jsonFormsFromServer = await getAllFormsFromServer(customer, authorization);
    FormsModel formsFromServer = FormsModel.fromJson(jsonFormsFromServer.body);

    if(formsFromServer.data != null)
    await Future.forEach(formsFromServer.data, (formFromServerInList) async {
      var formFromServerResponse = await getFormFromServer(formFromServerInList.id.toString(), customer, authorization);
      FormModel formFromServer = FormModel.fromJson(formFromServerResponse.body);

      bool isFormUpdated = false;

      FormModel formFromLocal = await DatabaseProvider.db.ReadFormById(formFromServer.id);
      if (formFromLocal == null) {
        await DatabaseProvider.db.CreateForm(formFromServer, SyncState.synchronized);
        isFormUpdated = true;
        print("Created form at 1st level, form.id: " + formFromServer.id.toString());
      } else if (formFromLocal.updatedAt != formFromServer.updatedAt) {
        await DatabaseProvider.db.UpdateForm(formFromServer.id, formFromServer, SyncState.synchronized);
        isFormUpdated = true;
        print("Updated form at 1st level, form.id: " + formFromServer.id.toString());
      }

      if (formFromServer.sections != null)
      await Future.forEach(formFromServer.sections, (sectionFromServer) async {
        if (!isFormUpdated) {
          SectionModel sectionFromLocal = await DatabaseProvider.db.ReadSectionById(sectionFromServer.id);
          if (sectionFromLocal == null) {
            await DatabaseProvider.db.UpdateForm(formFromServer.id, formFromServer, SyncState.synchronized);
            isFormUpdated = true;
            print("object is null\nUpdated form at 2nd level in " + sectionFromServer.id.toString() + " at section " + sectionFromServer.id.toString());
          } else if (sectionFromLocal.updatedAt != sectionFromServer.updatedAt) {
            await DatabaseProvider.db.UpdateForm(formFromServer.id, formFromServer, SyncState.synchronized);
            isFormUpdated = true;
            print("difference between local and server\nUpdated form at 2nd level in " + sectionFromServer.id.toString() + " at section " + sectionFromServer.id.toString());
          }

          if (sectionFromServer.field != null)
          await Future.forEach(sectionFromServer.field, (fieldFromServer) async {
            if (!isFormUpdated) {
              FieldModel fieldFromLocal = await DatabaseProvider.db.ReadFieldById(fieldFromServer.id);
              if (fieldFromLocal == null) {
                await DatabaseProvider.db.UpdateForm(formFromServer.id, formFromServer, SyncState.synchronized);
                isFormUpdated = true;
                print("object is null\nUpdated form at 3rd level in " + sectionFromServer.id.toString() + " at section " + sectionFromServer.id.toString() + " at field " + fieldFromServer.id.toString());
              } else if (fieldFromLocal.updatedAt != fieldFromServer.updatedAt) {
                await DatabaseProvider.db.UpdateForm(formFromServer.id, formFromServer, SyncState.synchronized);
                isFormUpdated = true;
                print("difference between local and server\nUpdated form at 3rd level in " + sectionFromServer.id.toString() + " at section " + sectionFromServer.id.toString() + " at field " + fieldFromServer.id.toString());
              }
            }
          });
        }
      });
    });
  }

  static Future syncEverything() async {

    UserModel user = await DatabaseProvider.db.RetrieveLastLoggedUser();

    String customer = user.company;
    String authorization = user.rememberToken;

    await FormChannel._deleteFormsInBothLocalAndServer(customer, authorization);
    await FormChannel._updateFormsInBothLocalAndServer(customer, authorization);
    await FormChannel._createFormsInBothLocalAndServer(customer, authorization);
  }

  static String getFormsRaw() {

    return '''
        {
          "current_page": 1,
          "data": [
              {
                  "id": 3,
                  "created_at": "2018-10-21 20:06:29",
                  "updated_at": "2018-10-21 20:06:31",
                  "deleted_at": null,
                  "created_by_id": 1,
                  "updated_by_id": 1,
                  "deleted_by_id": null,
                  "name": "Enrolamiento eHuapi",
                  "with_checkinout": true,
                  "active": true
              },
              {
                  "id": 1,
                  "created_at": "2018-07-18 17:48:04",
                  "updated_at": "2018-07-18 17:48:04",
                  "deleted_at": null,
                  "created_by_id": 1,
                  "updated_by_id": 1,
                  "deleted_by_id": null,
                  "name": "Notas",
                  "with_checkinout": false,
                  "active": true
              },
              {
                  "id": 2,
                  "created_at": "2018-07-18 17:50:19",
                  "updated_at": "2018-07-18 17:50:19",
                  "deleted_at": null,
                  "created_by_id": 1,
                  "updated_by_id": 1,
                  "deleted_by_id": null,
                  "name": "Visitas",
                  "with_checkinout": true,
                  "active": true
              }
          ],
          "first_page_url": "https://webapp.getkem.com/api/v1/forms?page=1",
          "from": 1,
          "last_page": 1,
          "last_page_url": "https://webapp.getkem.com/api/v1/forms?page=1",
          "next_page_url": null,
          "path": "https://webapp.getkem.com/api/v1/forms",
          "per_page": 20,
          "prev_page_url": null,
          "to": 3,
          "total": 3
      }
    ''';

  }

  static getFormRaw(int id) {
    if(id==1){
      return '''
      {
    "id": 1,
    "created_at": "2018-07-18 17:48:04",
    "updated_at": "2018-07-18 17:48:04",
    "deleted_at": null,
    "created_by_id": 1,
    "updated_by_id": 1,
    "deleted_by_id": null,
    "name": "Notas",
    "with_checkinout": false,
    "active": true,
    "sections": [
        {
            "id": 1,
            "created_at": "2018-07-18 17:48:57",
            "updated_at": "2018-07-18 17:48:57",
            "deleted_at": null,
            "created_by_id": 1,
            "updated_by_id": 1,
            "deleted_by_id": null,
            "section_id": null,
            "entity_type": "Form",
            "entity_id": 1,
            "type": "section",
            "name": "Datos de la Nota",
            "code": "SECTION_1",
            "subtitle": null,
            "position": 1,
            "field_default_value": null,
            "field_type": null,
            "field_placeholder": null,
            "field_options": [],
            "field_collection": null,
            "field_required": false,
            "field_width": 3,
            "fields": [
                {
                    "id": 2,
                    "created_at": "2018-07-18 17:50:03",
                    "updated_at": "2018-07-18 17:50:03",
                    "deleted_at": null,
                    "created_by_id": 1,
                    "updated_by_id": 1,
                    "deleted_by_id": null,
                    "section_id": 1,
                    "entity_type": "Form",
                    "entity_id": 1,
                    "type": "field",
                    "name": "Comentarios",
                    "code": "FIELD_2",
                    "subtitle": null,
                    "position": 1,
                    "field_default_value": null,
                    "field_type": "TextArea",
                    "field_placeholder": null,
                    "field_options": [],
                    "field_collection": null,
                    "field_required": false,
                    "field_width": 3
                }
            ]
        }
    ]
}
      '''; 
    }

    if(id==2){
      return '''
        {
    "id": 2,
    "created_at": "2018-07-18 17:50:19",
    "updated_at": "2018-07-18 17:50:19",
    "deleted_at": null,
    "created_by_id": 1,
    "updated_by_id": 1,
    "deleted_by_id": null,
    "name": "Visitas",
    "with_checkinout": true,
    "active": true,
    "sections": [
        {
            "id": 3,
            "created_at": "2018-07-18 17:48:57",
            "updated_at": "2018-07-18 17:48:57",
            "deleted_at": null,
            "created_by_id": 1,
            "updated_by_id": 1,
            "deleted_by_id": null,
            "section_id": null,
            "entity_type": "Form",
            "entity_id": 2,
            "type": "section",
            "name": "Datos de Visita",
            "code": "SECTION_3",
            "subtitle": null,
            "position": 1,
            "field_default_value": null,
            "field_type": null,
            "field_placeholder": null,
            "field_options": [],
            "field_collection": null,
            "field_required": false,
            "field_width": 3,
            "fields": [
                {
                    "id": 4,
                    "created_at": "2018-07-18 17:50:03",
                    "updated_at": "2018-07-18 17:50:03",
                    "deleted_at": null,
                    "created_by_id": 1,
                    "updated_by_id": 1,
                    "deleted_by_id": null,
                    "section_id": 3,
                    "entity_type": "Form",
                    "entity_id": 2,
                    "type": "field",
                    "name": "Comentarios",
                    "code": "FIELD_4",
                    "subtitle": null,
                    "position": 1,
                    "field_default_value": null,
                    "field_type": "TextArea",
                    "field_placeholder": null,
                    "field_options": [],
                    "field_collection": null,
                    "field_required": false,
                    "field_width": 3
                },
                {
                    "id": 37,
                    "created_at": null,
                    "updated_at": null,
                    "deleted_at": null,
                    "created_by_id": null,
                    "updated_by_id": null,
                    "deleted_by_id": null,
                    "section_id": 3,
                    "entity_type": "Form",
                    "entity_id": 2,
                    "type": "field",
                    "name": "Checkout",
                    "code": "FIELD_35",
                    "subtitle": null,
                    "position": 1,
                    "field_default_value": null,
                    "field_type": "Button",
                    "field_placeholder": null,
                    "field_options": null,
                    "field_collection": null,
                    "field_required": false,
                    "field_width": 3
                },
                {
                    "id": 38,
                    "created_at": null,
                    "updated_at": null,
                    "deleted_at": null,
                    "created_by_id": null,
                    "updated_by_id": null,
                    "deleted_by_id": null,
                    "section_id": 3,
                    "entity_type": "Form",
                    "entity_id": 2,
                    "type": "field",
                    "name": "ComboSearch",
                    "code": "FIELD_36",
                    "subtitle": null,
                    "position": 1,
                    "field_default_value": null,
                    "field_type": "ComboSearch",
                    "field_placeholder": null,
                    "field_options": [
                        {
                            "value": 56,
                            "name": "Item1"
                        },
                        {
                            "value": 57,
                            "name": "Item2"
                        }
                    ],
                    "field_collection": "ComboSearch",
                    "field_required": false,
                    "field_width": 3
                },
                {
                    "id": 39,
                    "created_at": null,
                    "updated_at": null,
                    "deleted_at": null,
                    "created_by_id": null,
                    "updated_by_id": null,
                    "deleted_by_id": null,
                    "section_id": 3,
                    "entity_type": "Form",
                    "entity_id": 2,
                    "type": "field",
                    "name": "Table",
                    "code": "FIELD_37",
                    "subtitle": null,
                    "position": 1,
                    "field_default_value": "Columna1*Columna 2;Fila1*fila2",
                    "field_type": "Table",
                    "field_placeholder": null,
                    "field_options": [
                        {
                            "value": 58,
                            "name": "Item1x1"
                        },
                        {
                            "value": 59,
                            "name": "Item1x2"
                        },
                        {
                            "value": 60,
                            "name": "Item2x1"
                        },
                        {
                            "value": 61,
                            "name": "Item2x2"
                        }
                    ],
                    "field_collection": "Table",
                    "field_required": false,
                    "field_width": 3
                },
                {
                    "id": 40,
                    "created_at": null,
                    "updated_at": null,
                    "deleted_at": null,
                    "created_by_id": null,
                    "updated_by_id": null,
                    "deleted_by_id": null,
                    "section_id": 3,
                    "entity_type": "Form",
                    "entity_id": 2,
                    "type": "field",
                    "name": "Texto",
                    "code": "FIELD_38",
                    "subtitle": null,
                    "position": 1,
                    "field_default_value": null,
                    "field_type": "Text",
                    "field_placeholder": null,
                    "field_options": [],
                    "field_collection": null,
                    "field_required": false,
                    "field_width": 3
                },
                {
                    "id": 5,
                    "created_at": "2018-07-18 17:50:03",
                    "updated_at": "2018-07-18 17:50:03",
                    "deleted_at": null,
                    "created_by_id": 1,
                    "updated_by_id": 1,
                    "deleted_by_id": null,
                    "section_id": 3,
                    "entity_type": "Form",
                    "entity_id": 2,
                    "type": "field",
                    "name": "Fotografía",
                    "code": "FIELD_5",
                    "subtitle": null,
                    "position": 2,
                    "field_default_value": null,
                    "field_type": "Photo",
                    "field_placeholder": null,
                    "field_options": [],
                    "field_collection": null,
                    "field_required": false,
                    "field_width": 3
                },
                {
                    "id": 6,
                    "created_at": "2018-07-18 17:50:03",
                    "updated_at": "2018-07-18 17:50:03",
                    "deleted_at": null,
                    "created_by_id": 1,
                    "updated_by_id": 1,
                    "deleted_by_id": null,
                    "section_id": 3,
                    "entity_type": "Form",
                    "entity_id": 2,
                    "type": "field",
                    "name": "Tipo de vista (Seleccionador)",
                    "code": "FIELD_6",
                    "subtitle": null,
                    "position": 3,
                    "field_default_value": null,
                    "field_type": "Combo",
                    "field_placeholder": null,
                    "field_options": [
                        {
                            "value": 1,
                            "name": "Venta"
                        },
                        {
                            "value": 2,
                            "name": "Fidelización"
                        },
                        {
                            "value": 3,
                            "name": "Retención"
                        }
                    ],
                    "field_collection": "TipoVisitas",
                    "field_required": false,
                    "field_width": 3
                },
                {
                    "id": 7,
                    "created_at": "2018-07-18 17:53:38",
                    "updated_at": "2018-07-18 17:53:38",
                    "deleted_at": null,
                    "created_by_id": 1,
                    "updated_by_id": 1,
                    "deleted_by_id": null,
                    "section_id": 3,
                    "entity_type": "Form",
                    "entity_id": 2,
                    "type": "field",
                    "name": "Prioritario (Checklist)",
                    "code": "FIELD_7",
                    "subtitle": null,
                    "position": 4,
                    "field_default_value": null,
                    "field_type": "Boolean",
                    "field_placeholder": null,
                    "field_options": [],
                    "field_collection": null,
                    "field_required": false,
                    "field_width": 3
                },
                {
                    "id": 9,
                    "created_at": "2018-09-11 16:47:46",
                    "updated_at": "2018-09-11 16:47:49",
                    "deleted_at": null,
                    "created_by_id": 1,
                    "updated_by_id": 1,
                    "deleted_by_id": null,
                    "section_id": 3,
                    "entity_type": "Form",
                    "entity_id": 2,
                    "type": "field",
                    "name": "Firma cliente (Firma conformidad)",
                    "code": "FIELD_8",
                    "subtitle": null,
                    "position": 5,
                    "field_default_value": null,
                    "field_type": "CanvanSignature",
                    "field_placeholder": null,
                    "field_options": [],
                    "field_collection": null,
                    "field_required": false,
                    "field_width": 3
                },
                {
                    "id": 11,
                    "created_at": "2018-09-11 16:49:57",
                    "updated_at": "2018-09-11 16:50:00",
                    "deleted_at": null,
                    "created_by_id": 1,
                    "updated_by_id": 1,
                    "deleted_by_id": null,
                    "section_id": 3,
                    "entity_type": "Form",
                    "entity_id": 2,
                    "type": "field",
                    "name": "Indicador sobre imagen (Dibujo sobre imagen)",
                    "code": "FIELD_9",
                    "subtitle": null,
                    "position": 6,
                    "field_default_value": "https://previews.123rf.com/images/pandavector/pandavector1612/pandavector161200463/69448631-icono-de-ri%C3%B1ones-humanos-en-el-estilo-de-contorno-aislado-en-el-fondo-blanco-%C3%B3rganos-humanos-ilustraci%C3%B3n-s%C3%ADmbol.jpg",
                    "field_type": "CanvanImage",
                    "field_placeholder": null,
                    "field_options": [],
                    "field_collection": null,
                    "field_required": false,
                    "field_width": 3
                },
                {
                    "id": 12,
                    "created_at": "2018-09-11 16:51:55",
                    "updated_at": "2018-09-11 16:51:58",
                    "deleted_at": null,
                    "created_by_id": 1,
                    "updated_by_id": 1,
                    "deleted_by_id": null,
                    "section_id": 3,
                    "entity_type": "Form",
                    "entity_id": 2,
                    "type": "field",
                    "name": "Nota (Texto predefinido)",
                    "code": "FIELD_10",
                    "subtitle": null,
                    "position": 7,
                    "field_default_value": "Esto es un label",
                    "field_type": "Label",
                    "field_placeholder": null,
                    "field_options": [],
                    "field_collection": null,
                    "field_required": false,
                    "field_width": 3
                },
                {
                    "id": 13,
                    "created_at": "2018-09-11 16:53:16",
                    "updated_at": "2018-09-11 16:53:19",
                    "deleted_at": null,
                    "created_by_id": 1,
                    "updated_by_id": 1,
                    "deleted_by_id": null,
                    "section_id": 3,
                    "entity_type": "Form",
                    "entity_id": 2,
                    "type": "field",
                    "name": "Logo imagen (Imagen predefinida)",
                    "code": "FIELD_11",
                    "subtitle": null,
                    "position": 8,
                    "field_default_value": "http://www.brandemia.org/wp-content/uploads/2012/10/logo_principal.jpg",
                    "field_type": "Image",
                    "field_placeholder": null,
                    "field_options": [],
                    "field_collection": null,
                    "field_required": false,
                    "field_width": 3
                },
                {
                    "id": 14,
                    "created_at": "2018-09-11 16:54:31",
                    "updated_at": "2018-09-11 16:54:34",
                    "deleted_at": null,
                    "created_by_id": 1,
                    "updated_by_id": 1,
                    "deleted_by_id": null,
                    "section_id": 3,
                    "entity_type": "Form",
                    "entity_id": 2,
                    "type": "field",
                    "name": "Fecha",
                    "code": "FIELD_12",
                    "subtitle": null,
                    "position": 9,
                    "field_default_value": null,
                    "field_type": "Date",
                    "field_placeholder": null,
                    "field_options": [],
                    "field_collection": null,
                    "field_required": false,
                    "field_width": 3
                },
                {
                    "id": 15,
                    "created_at": "2018-09-11 16:55:25",
                    "updated_at": "2018-09-11 16:55:29",
                    "deleted_at": null,
                    "created_by_id": 1,
                    "updated_by_id": 1,
                    "deleted_by_id": null,
                    "section_id": 3,
                    "entity_type": "Form",
                    "entity_id": 2,
                    "type": "field",
                    "name": "Hora",
                    "code": "FIELD_13",
                    "subtitle": null,
                    "position": 10,
                    "field_default_value": null,
                    "field_type": "Time",
                    "field_placeholder": null,
                    "field_options": [],
                    "field_collection": null,
                    "field_required": false,
                    "field_width": 3
                },
                {
                    "id": 16,
                    "created_at": "2018-09-11 16:56:19",
                    "updated_at": "2018-09-11 16:56:26",
                    "deleted_at": null,
                    "created_by_id": 1,
                    "updated_by_id": 1,
                    "deleted_by_id": null,
                    "section_id": 3,
                    "entity_type": "Form",
                    "entity_id": 2,
                    "type": "field",
                    "name": "Fecha y hora",
                    "code": "FIELD_14",
                    "subtitle": null,
                    "position": 11,
                    "field_default_value": null,
                    "field_type": "DateTime",
                    "field_placeholder": null,
                    "field_options": [],
                    "field_collection": null,
                    "field_required": false,
                    "field_width": 3
                }
            ]
        }
    ]
}
      ''';
    }

    if(id==3){
      return '''
      {
    "id": 3,
    "created_at": "2018-10-21 20:06:29",
    "updated_at": "2018-10-21 20:06:31",
    "deleted_at": null,
    "created_by_id": 1,
    "updated_by_id": 1,
    "deleted_by_id": null,
    "name": "Enrolamiento eHuapi",
    "with_checkinout": true,
    "active": true,
    "sections": [
        {
            "id": 17,
            "created_at": null,
            "updated_at": null,
            "deleted_at": null,
            "created_by_id": 1,
            "updated_by_id": 1,
            "deleted_by_id": null,
            "section_id": null,
            "entity_type": "Form",
            "entity_id": 3,
            "type": "section",
            "name": "Datos persona que atiende",
            "code": "SECTION_15",
            "subtitle": null,
            "position": 12,
            "field_default_value": null,
            "field_type": "",
            "field_placeholder": null,
            "field_options": [],
            "field_collection": null,
            "field_required": false,
            "field_width": 3,
            "fields": [
                {
                    "id": 18,
                    "created_at": null,
                    "updated_at": null,
                    "deleted_at": null,
                    "created_by_id": 1,
                    "updated_by_id": 1,
                    "deleted_by_id": null,
                    "section_id": 17,
                    "entity_type": "Form",
                    "entity_id": 3,
                    "type": "field",
                    "name": "Nombre",
                    "code": "FIELD_16",
                    "subtitle": null,
                    "position": 13,
                    "field_default_value": null,
                    "field_type": "Text",
                    "field_placeholder": null,
                    "field_options": [],
                    "field_collection": null,
                    "field_required": false,
                    "field_width": 3
                },
                {
                    "id": 19,
                    "created_at": null,
                    "updated_at": null,
                    "deleted_at": null,
                    "created_by_id": 1,
                    "updated_by_id": 1,
                    "deleted_by_id": null,
                    "section_id": 17,
                    "entity_type": "Form",
                    "entity_id": 3,
                    "type": "field",
                    "name": "Teléfono",
                    "code": "FIELD_17",
                    "subtitle": null,
                    "position": 14,
                    "field_default_value": null,
                    "field_type": "Number",
                    "field_placeholder": null,
                    "field_options": [],
                    "field_collection": null,
                    "field_required": false,
                    "field_width": 3
                },
                {
                    "id": 20,
                    "created_at": null,
                    "updated_at": null,
                    "deleted_at": null,
                    "created_by_id": 1,
                    "updated_by_id": 1,
                    "deleted_by_id": null,
                    "section_id": 17,
                    "entity_type": "Form",
                    "entity_id": 3,
                    "type": "field",
                    "name": "E-mail",
                    "code": "FIELD_18",
                    "subtitle": null,
                    "position": 15,
                    "field_default_value": null,
                    "field_type": "Text",
                    "field_placeholder": null,
                    "field_options": [],
                    "field_collection": null,
                    "field_required": false,
                    "field_width": 3
                }
            ]
        },
        {
            "id": 21,
            "created_at": null,
            "updated_at": null,
            "deleted_at": null,
            "created_by_id": 1,
            "updated_by_id": 1,
            "deleted_by_id": null,
            "section_id": null,
            "entity_type": "Form",
            "entity_id": 3,
            "type": "section",
            "name": "Datos dueño",
            "code": "SECTION_19",
            "subtitle": null,
            "position": 16,
            "field_default_value": null,
            "field_type": "",
            "field_placeholder": null,
            "field_options": [],
            "field_collection": null,
            "field_required": false,
            "field_width": 3,
            "fields": [
                {
                    "id": 22,
                    "created_at": null,
                    "updated_at": null,
                    "deleted_at": null,
                    "created_by_id": null,
                    "updated_by_id": null,
                    "deleted_by_id": null,
                    "section_id": 21,
                    "entity_type": "Form",
                    "entity_id": 3,
                    "type": "field",
                    "name": "Nombre",
                    "code": "FIELD_20",
                    "subtitle": null,
                    "position": 17,
                    "field_default_value": null,
                    "field_type": "Text",
                    "field_placeholder": null,
                    "field_options": [],
                    "field_collection": null,
                    "field_required": false,
                    "field_width": 3
                },
                {
                    "id": 23,
                    "created_at": null,
                    "updated_at": null,
                    "deleted_at": null,
                    "created_by_id": null,
                    "updated_by_id": null,
                    "deleted_by_id": null,
                    "section_id": 21,
                    "entity_type": "Form",
                    "entity_id": 3,
                    "type": "field",
                    "name": "Rut",
                    "code": "FIELD_21",
                    "subtitle": null,
                    "position": 18,
                    "field_default_value": null,
                    "field_type": "Text",
                    "field_placeholder": null,
                    "field_options": [],
                    "field_collection": null,
                    "field_required": false,
                    "field_width": 3
                },
                {
                    "id": 24,
                    "created_at": null,
                    "updated_at": null,
                    "deleted_at": null,
                    "created_by_id": null,
                    "updated_by_id": null,
                    "deleted_by_id": null,
                    "section_id": 21,
                    "entity_type": "Form",
                    "entity_id": 3,
                    "type": "field",
                    "name": "Teléfono",
                    "code": "FIELD_22",
                    "subtitle": null,
                    "position": 19,
                    "field_default_value": null,
                    "field_type": "Text",
                    "field_placeholder": null,
                    "field_options": [],
                    "field_collection": null,
                    "field_required": false,
                    "field_width": 3
                },
                {
                    "id": 25,
                    "created_at": null,
                    "updated_at": null,
                    "deleted_at": null,
                    "created_by_id": null,
                    "updated_by_id": null,
                    "deleted_by_id": null,
                    "section_id": 21,
                    "entity_type": "Form",
                    "entity_id": 3,
                    "type": "field",
                    "name": "E-mail",
                    "code": "FIELD_23",
                    "subtitle": null,
                    "position": 20,
                    "field_default_value": null,
                    "field_type": "Text",
                    "field_placeholder": null,
                    "field_options": [],
                    "field_collection": null,
                    "field_required": false,
                    "field_width": 3
                }
            ]
        },
        {
            "id": 26,
            "created_at": null,
            "updated_at": null,
            "deleted_at": null,
            "created_by_id": null,
            "updated_by_id": null,
            "deleted_by_id": null,
            "section_id": null,
            "entity_type": "Form",
            "entity_id": 3,
            "type": "section",
            "name": "Datos empresa",
            "code": "SECTION_24",
            "subtitle": null,
            "position": 21,
            "field_default_value": null,
            "field_type": null,
            "field_placeholder": null,
            "field_options": [],
            "field_collection": null,
            "field_required": false,
            "field_width": 3,
            "fields": [
                {
                    "id": 27,
                    "created_at": null,
                    "updated_at": null,
                    "deleted_at": null,
                    "created_by_id": null,
                    "updated_by_id": null,
                    "deleted_by_id": null,
                    "section_id": 26,
                    "entity_type": "Form",
                    "entity_id": 3,
                    "type": "field",
                    "name": "Nombre",
                    "code": "FIELD_25",
                    "subtitle": null,
                    "position": 22,
                    "field_default_value": null,
                    "field_type": "Text",
                    "field_placeholder": null,
                    "field_options": [],
                    "field_collection": null,
                    "field_required": false,
                    "field_width": 3
                },
                {
                    "id": 28,
                    "created_at": null,
                    "updated_at": null,
                    "deleted_at": null,
                    "created_by_id": null,
                    "updated_by_id": null,
                    "deleted_by_id": null,
                    "section_id": 26,
                    "entity_type": "Form",
                    "entity_id": 3,
                    "type": "field",
                    "name": "Rut",
                    "code": "FIELD_26",
                    "subtitle": null,
                    "position": 23,
                    "field_default_value": null,
                    "field_type": "Text",
                    "field_placeholder": null,
                    "field_options": [],
                    "field_collection": null,
                    "field_required": false,
                    "field_width": 3
                },
                {
                    "id": 29,
                    "created_at": null,
                    "updated_at": null,
                    "deleted_at": null,
                    "created_by_id": null,
                    "updated_by_id": null,
                    "deleted_by_id": null,
                    "section_id": 26,
                    "entity_type": "Form",
                    "entity_id": 3,
                    "type": "field",
                    "name": "Tipo de cuenta",
                    "code": "FIELD_27",
                    "subtitle": null,
                    "position": 24,
                    "field_default_value": null,
                    "field_type": "Combo",
                    "field_placeholder": null,
                    "field_options": [
                        {
                            "value": 10,
                            "name": "Vista/Rut"
                        },
                        {
                            "value": 11,
                            "name": "Ahorro"
                        },
                        {
                            "value": 12,
                            "name": "Corriente"
                        }
                    ],
                    "field_collection": "TipoCuenta",
                    "field_required": false,
                    "field_width": 3
                },
                {
                    "id": 30,
                    "created_at": null,
                    "updated_at": null,
                    "deleted_at": null,
                    "created_by_id": null,
                    "updated_by_id": null,
                    "deleted_by_id": null,
                    "section_id": 26,
                    "entity_type": "Form",
                    "entity_id": 3,
                    "type": "field",
                    "name": "Banco",
                    "code": "FIELD_28",
                    "subtitle": null,
                    "position": 25,
                    "field_default_value": null,
                    "field_type": "Combo",
                    "field_placeholder": null,
                    "field_options": [],
                    "field_collection": "Banco",
                    "field_required": false,
                    "field_width": 3
                },
                {
                    "id": 31,
                    "created_at": null,
                    "updated_at": null,
                    "deleted_at": null,
                    "created_by_id": null,
                    "updated_by_id": null,
                    "deleted_by_id": null,
                    "section_id": 26,
                    "entity_type": "Form",
                    "entity_id": 3,
                    "type": "field",
                    "name": "Venta diaria",
                    "code": "FIELD_29",
                    "subtitle": null,
                    "position": 26,
                    "field_default_value": null,
                    "field_type": "Number",
                    "field_placeholder": null,
                    "field_options": [],
                    "field_collection": null,
                    "field_required": false,
                    "field_width": 3
                },
                {
                    "id": 32,
                    "created_at": null,
                    "updated_at": null,
                    "deleted_at": null,
                    "created_by_id": null,
                    "updated_by_id": null,
                    "deleted_by_id": null,
                    "section_id": 26,
                    "entity_type": "Form",
                    "entity_id": 3,
                    "type": "field",
                    "name": "Hora apertura",
                    "code": "FIELD_30",
                    "subtitle": null,
                    "position": 27,
                    "field_default_value": null,
                    "field_type": "Time",
                    "field_placeholder": null,
                    "field_options": [],
                    "field_collection": null,
                    "field_required": false,
                    "field_width": 3
                },
                {
                    "id": 33,
                    "created_at": null,
                    "updated_at": null,
                    "deleted_at": null,
                    "created_by_id": null,
                    "updated_by_id": null,
                    "deleted_by_id": null,
                    "section_id": 26,
                    "entity_type": "Form",
                    "entity_id": 3,
                    "type": "field",
                    "name": "Hora cierre",
                    "code": "FIELD_31",
                    "subtitle": null,
                    "position": 28,
                    "field_default_value": null,
                    "field_type": "Time",
                    "field_placeholder": null,
                    "field_options": [],
                    "field_collection": null,
                    "field_required": false,
                    "field_width": 3
                },
                {
                    "id": 34,
                    "created_at": null,
                    "updated_at": null,
                    "deleted_at": null,
                    "created_by_id": null,
                    "updated_by_id": null,
                    "deleted_by_id": null,
                    "section_id": 26,
                    "entity_type": "Form",
                    "entity_id": 3,
                    "type": "field",
                    "name": "Días de la semana abierto",
                    "code": "FIELD_32",
                    "subtitle": null,
                    "position": 29,
                    "field_default_value": null,
                    "field_type": "Combo",
                    "field_placeholder": null,
                    "field_options": [
                        {
                            "value": 13,
                            "name": "L-V"
                        },
                        {
                            "value": 14,
                            "name": "L-S"
                        },
                        {
                            "value": 15,
                            "name": "L-D"
                        }
                    ],
                    "field_collection": "DiasAbierto",
                    "field_required": false,
                    "field_width": 3
                },
                {
                    "id": 35,
                    "created_at": null,
                    "updated_at": null,
                    "deleted_at": null,
                    "created_by_id": null,
                    "updated_by_id": null,
                    "deleted_by_id": null,
                    "section_id": 26,
                    "entity_type": "Form",
                    "entity_id": 3,
                    "type": "field",
                    "name": "Giro",
                    "code": "FIELD_33",
                    "subtitle": null,
                    "position": 30,
                    "field_default_value": null,
                    "field_type": "Combo",
                    "field_placeholder": null,
                    "field_options": [
                        {
                            "value": 16,
                            "name": "Botillería"
                        },
                        {
                            "value": 17,
                            "name": "Roticería"
                        },
                        {
                            "value": 18,
                            "name": "Minimarket"
                        },
                        {
                            "value": 19,
                            "name": "Carnicería"
                        },
                        {
                            "value": 20,
                            "name": "Otro"
                        }
                    ],
                    "field_collection": "Giro",
                    "field_required": false,
                    "field_width": 3
                },
                {
                    "id": 36,
                    "created_at": null,
                    "updated_at": null,
                    "deleted_at": null,
                    "created_by_id": null,
                    "updated_by_id": null,
                    "deleted_by_id": null,
                    "section_id": 26,
                    "entity_type": "Form",
                    "entity_id": 3,
                    "type": "field",
                    "name": "Comentarios",
                    "code": "FIELD_34",
                    "subtitle": null,
                    "position": 31,
                    "field_default_value": null,
                    "field_type": "Textarea",
                    "field_placeholder": null,
                    "field_options": [],
                    "field_collection": null,
                    "field_required": false,
                    "field_width": 3
                }
            ]
        }
    ]
}
      ''';
    }
  }


}

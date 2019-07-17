// TODO: Comparar el ID en las relaciones y no el Id del registro.
// TODO: Agregar a todos los recursos (contactos, clientes...) los datos iniciales que se tengan (fecha de creacion, etc, etc...).

import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'package:joincompany/async_image_repository/ImageRepository.dart';
import 'package:joincompany/models/BusinessModel.dart';
import 'package:joincompany/models/ContactModel.dart';
import 'package:joincompany/models/CustomersModel.dart';
import 'package:joincompany/services/CustomerService.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'SQL_Instructions.dart';

import '../models/AddressModel.dart';
import '../models/CustomerModel.dart';
import '../models/FieldModel.dart';
import '../models/FormModel.dart';
import '../models/SectionModel.dart';
import '../models/TaskModel.dart';
import '../models/UserModel.dart';

enum Error {
  tooManyData,
}

final Map<Error, String> errorMessage = {
  Error.tooManyData: "[warning] data retrieved from the database for a given id shouldn't contain more than one object"
};

enum SyncState {
  synchronized,
  created,
  updated,
  deleted,
}

final Map<SyncState, List<int>> paramsBySyncState = {
  // [in_server, updated, deleted]
  SyncState.synchronized: [1, 0, 0],
  SyncState.created:      [0, 1, 0],
  SyncState.updated:      [1, 1, 0],
  SyncState.deleted:      [1, 0, 1],
};

final Map<bool, int> boolToBit = {
  false: 0,
  true:  1,
};

class DatabaseProvider {
  DatabaseProvider._();

  static final DatabaseProvider db = DatabaseProvider._();

  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await initDb();
    return _database;
  }

  initDb() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "db.db");
    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
          await Future.forEach(databaseInstructions.values, (value) async {
            await db.execute(value);
          });
        }
    );
  }

  // Operations on users
  Future<int> CreateUser(UserModel user, SyncState syncState) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT * FROM "users" WHERE id = ${user.id}
      '''
    );

    if (data.isNotEmpty)
      return null;

    return await db.rawInsert(
      '''
      INSERT INTO "users"(
        id,
        created_at,
        updated_at,
        deleted_at,
        created_by_id,
        updated_by_id,
        deleted_by_id,
        supervisor_id,
        name,
        code,
        email,
        phone,
        mobile,
        title,
        details,
        profile,
        password,
        remember_token,
        company,
        logged_at,
        in_server,
        updated,
        deleted
      )
      
      VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''',
      [...[user.id, user.createdAt, user.updatedAt == null ? DateTime.now().toString() : user.updatedAt, user.deletedAt,
    user.createdById, user.updatedById, user.deletedById,
    user.supervisorId, user.name, user.code, user.email,
    user.phone, user.mobile, user.title, user.details,
    user.profile, user.password, user.rememberToken, user.company, user.loggedAt == null ? DateTime.now().toString(): user.loggedAt],
    ...paramsBySyncState[syncState]],
    );
  }

  Future<UserModel> ReadUserById(int id) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT * FROM "users" WHERE id = $id
      '''
    );

    if (data.isNotEmpty)
      return UserModel(
        id: data.first["id"],
        createdAt: data.first["created_at"],
        updatedAt: data.first["updated_at"],
        deletedAt: data.first["deleted_at"],
        createdById: data.first["created_by_id"],
        updatedById: data.first["updated_by_id"],
        deletedById: data.first["deleted_by_id"],
        supervisorId: data.first["supervisor_id"],
        name: data.first["name"],
        code: data.first["code"],
        email: data.first["email"],
        phone: data.first["phone"],
        mobile: data.first["mobile"],
        title: data.first["title"],
        password: data.first["password"],
        details: data.first["details"],
        profile: data.first["profile"],
        rememberToken: data.first["remember_token"],
        loggedAt: data.first["logged_at"],
        company: data.first["company"],
      );
    else
      return null;
  }

  Future<UserModel> RetrieveLastLoggedUser() async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT * 
      FROM "users"
      ORDER BY logged_at DESC 
      '''
    );

    if (data.isNotEmpty)
      return UserModel(
        id: data.first["id"],
        createdAt: data.first["created_at"],
        updatedAt: data.first["updated_at"],
        deletedAt: data.first["deleted_at"],
        createdById: data.first["created_by_id"],
        updatedById: data.first["updated_by_id"],
        deletedById: data.first["deleted_by_id"],
        supervisorId: data.first["supervisor_id"],
        name: data.first["name"],
        code: data.first["code"],
        email: data.first["email"],
        phone: data.first["phone"],
        mobile: data.first["mobile"],
        title: data.first["title"],
        password: data.first["password"],
        details: data.first["details"],
        profile: data.first["profile"],
        rememberToken: data.first["remember_token"],
        loggedAt: data.first["logged_at"],
        company: data.first["company"],
      );
    else
      return null;
  }

  Future<List<UserModel>> QueryUser(UserModel query) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT * FROM "users"
      '''
    );

    List<UserModel> listOfUsers = new List<UserModel>();
    if (data.isNotEmpty) {
      data.forEach((userRetrieved) {
        if (query.id != null)
          if (query.id != userRetrieved["id"])
            return;
        if (query.createdAt != null)
          if (query.createdAt != userRetrieved["created_at"])
            return;
        if (query.updatedAt != null)
          if (query.updatedAt != userRetrieved["updated_at"])
            return;
        if (query.deletedAt != null)
          if (query.deletedAt != userRetrieved["deleted_at"])
            return;
        if (query.createdById != null)
          if (query.createdById != userRetrieved["created_by_id"])
            return;
        if (query.updatedById != null)
          if (query.updatedById != userRetrieved["updated_by_id"])
            return;
        if (query.deletedById != null)
          if (query.deletedById != userRetrieved["deleted_by_id"])
            return;
        if (query.supervisorId != null)
          if (query.supervisorId != userRetrieved["supervisor_id"])
            return;
        if (query.name != null)
          if (query.name != userRetrieved["name"])
            return;
        if (query.code != null)
          if (query.code != userRetrieved["code"])
            return;
        if (query.email != null)
          if (query.email != userRetrieved["email"])
            return;
        if (query.phone != null)
          if (query.phone != userRetrieved["phone"])
            return;
        if (query.mobile != null)
          if (query.mobile != userRetrieved["mobile"])
            return;
        if (query.title != null)
          if (query.title != userRetrieved["title"])
            return;
        if (query.password != null)
          if (query.password != userRetrieved["password"])
            return;
        if (query.details != null)
          if (query.details != userRetrieved["details"])
            return;
        if (query.profile != null)
          if (query.profile != userRetrieved["profile"])
            return;
        if (query.rememberToken != null)
          if (query.rememberToken != userRetrieved["remember_token"])
            return;
        if (query.loggedAt != null)
          if (query.loggedAt != userRetrieved["logged_at"])
            return;
        if (query.company != null)
          if (query.company != userRetrieved["company"])
            return;

        listOfUsers.add(UserModel(
          id: userRetrieved["id"],
          createdAt: userRetrieved["created_at"],
          updatedAt: userRetrieved["updated_at"],
          deletedAt: userRetrieved["deleted_at"],
          createdById: userRetrieved["created_by_id"],
          updatedById: userRetrieved["updated_by_id"],
          deletedById: userRetrieved["deleted_by_id"],
          supervisorId: userRetrieved["supervisor_id"],
          name: userRetrieved["name"],
          code: userRetrieved["code"],
          email: userRetrieved["email"],
          phone: userRetrieved["phone"],
          mobile: userRetrieved["mobile"],
          title: userRetrieved["title"],
          password: userRetrieved["password"],
          details: userRetrieved["details"],
          profile: userRetrieved["profile"],
          rememberToken: userRetrieved["remember_token"],
          loggedAt: userRetrieved["logged_at"],
          company: userRetrieved["company"],
        ));
      });
    }
    return listOfUsers;
  }

  Future<List<UserModel>> ReadUsersBySyncState(SyncState syncState) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT * FROM "users" WHERE 
      in_server = ? AND
      updated = ? AND
      deleted = ?
      ''',
      paramsBySyncState[syncState],
    );

    List<UserModel> users = new List<UserModel>();
    if (data.isNotEmpty) {
      data.forEach((userRetrieved) => users.add(UserModel(
        id: userRetrieved["id"],
        createdAt: userRetrieved["created_at"],
        updatedAt: userRetrieved["updated_at"],
        deletedAt: userRetrieved["deleted_at"],
        createdById: userRetrieved["created_by_id"],
        updatedById: userRetrieved["updated_by_id"],
        deletedById: userRetrieved["deleted_by_id"],
        supervisorId: userRetrieved["supervisor_id"],
        name: userRetrieved["name"],
        code: userRetrieved["code"],
        email: userRetrieved["email"],
        phone: userRetrieved["phone"],
        mobile: userRetrieved["mobile"],
        title: userRetrieved["title"],
        password: userRetrieved["password"],
        details: userRetrieved["details"],
        profile: userRetrieved["profile"],
        rememberToken: userRetrieved["remember_token"],
        loggedAt: userRetrieved["logged_at"],
        company: userRetrieved["company"],
      )));
    }
    return users;
  }

  Future<int> UpdateUser(int userId, UserModel user, SyncState syncState) async {
    final db = await database;
    return db.rawUpdate(
      '''
      UPDATE "users" SET
      id = ?,
      created_at = ?,
      updated_at = ?,
      deleted_at = ?,
      created_by_id = ?,
      updated_by_id = ?,
      deleted_by_id = ?,
      supervisor_id = ?,
      name = ?,
      code = ?,
      email = ?,
      phone = ?,
      mobile = ?,
      title = ?,
      details = ?,
      profile = ?,
      password = ?,
      remember_token = ?,
      logged_at = ?,
      company = ?,
      in_server = ?,
      updated = ?,
      deleted = ?
      WHERE id = ${userId}
      ''',
      [...[user.id, user.createdAt, user.updatedAt == null ? DateTime.now().toString() : user.updatedAt, user.deletedAt,
    user.createdById, user.updatedById, user.deletedById,
    user.supervisorId, user.name, user.code, user.email,
    user.phone, user.mobile, user.title, user.details,
    user.profile, user.password, user.rememberToken, user.loggedAt == null ? DateTime.now().toString(): user.loggedAt, user.company],
    ...paramsBySyncState[syncState]],
    );
  }

  Future<int> ChangeSyncStateUser(int id, SyncState syncState) async {
    final db = await database;
    return db.rawUpdate(
        '''
      UPDATE "users" SET
      in_server = ?,
      updated = ?,
      deleted = ?
      WHERE id = $id
      ''',
        paramsBySyncState[syncState],
      );
  }

  Future<int> DeleteUserById(int id) async {
    final db = await database;
    await db.rawDelete('DELETE FROM "customers_users" WHERE user_id = $id');
    return await db.rawDelete('DELETE FROM "users" WHERE id = $id');
  }

  Future<List<UserModel>> ListUsers() async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT * FROM "users"
      '''
    );

    List<UserModel> users = new List<UserModel>();
    if (data.isNotEmpty) {
      data.forEach((userRetrieved) => users.add(UserModel(
        id: userRetrieved["id"],
        createdAt: userRetrieved["created_at"],
        updatedAt: userRetrieved["updated_at"],
        deletedAt: userRetrieved["deleted_at"],
        createdById: userRetrieved["created_by_id"],
        updatedById: userRetrieved["updated_by_id"],
        deletedById: userRetrieved["deleted_by_id"],
        supervisorId: userRetrieved["supervisor_id"],
        name: userRetrieved["name"],
        code: userRetrieved["code"],
        email: userRetrieved["email"],
        phone: userRetrieved["phone"],
        mobile: userRetrieved["mobile"],
        title: userRetrieved["title"],
        password: userRetrieved["password"],
        details: userRetrieved["details"],
        profile: userRetrieved["profile"],
        rememberToken: userRetrieved["remember_token"],
        loggedAt: userRetrieved["logged_at"],
        company: userRetrieved["company"],
      )));
    }
    return users;
  }

  // Operations on forms
  Future<int> CreateForm(FormModel form, SyncState syncState) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT * FROM "forms" WHERE id = ${form.id}
      '''
    );

    if (data.isNotEmpty)
      return null;

    if (form != null)
      if (form.sections != null)
        await Future.forEach(form.sections, (section) async {
          await CreateSection(section, syncState);
        });

    return await db.rawInsert(
      '''
      INSERT INTO "forms"(
        id,
        created_at,
        updated_at,
        deleted_at,
        created_by_id,
        updated_by_id,
        deleted_by_id,
        name,
        with_checkinout,
        active,
        in_server,
        updated,
        deleted
      )
      
      VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''',
      [...[form.id, form.createdAt, form.updatedAt == null ? DateTime.now().toString() : form.updatedAt, form.deletedAt,
    form.createdById, form.updatedById, form.deletedById, form.name,
    form.withCheckinout, form.active],
    ...paramsBySyncState[syncState]],
    );
  }

  Future<FormModel> ReadFormById(int id) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
        '''
      SELECT * FROM "forms" WHERE id = $id
      '''
    );

    if (data.isNotEmpty) {
      List<SectionModel> sections = await GetSectionsByForm(id);

      return FormModel(
        id: data.first["id"],
        createdAt: data.first["created_at"],
        updatedAt: data.first["updated_at"],
        deletedAt: data.first["deleted_at"],
        createdById: data.first["created_by_id"],
        updatedById: data.first["updated_by_id"],
        deletedById: data.first["deleted_by_id"],
        name: data.first["name"],
        withCheckinout: data.first["with_checkinout"] == 1 ? true: false,
        active: data.first["active"] == 1 ? true: false,
        sections: sections,
      );
    }
    else
      return null;
  }

  Future<List<FormModel>> QueryForm(FormModel query) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
        '''
      SELECT * FROM "forms"
      '''
    );

    List<FormModel> listOfForms = new List<FormModel>();
    if (data.isNotEmpty) {
      await Future.forEach(data, (formRetrieved) async {
        if (query.id != null)
          if (query.id != formRetrieved["id"])
            return;
        if (query.createdAt != null)
          if (query.createdAt != formRetrieved["created_at"])
            return;
        if (query.updatedAt != null)
          if (query.updatedAt != formRetrieved["updated_at"])
            return;
        if (query.deletedAt != null)
          if (query.deletedAt != formRetrieved["deleted_at"])
            return;
        if (query.createdById != null)
          if (query.createdById != formRetrieved["created_by_id"])
            return;
        if (query.updatedById != null)
          if (query.updatedById != formRetrieved["updated_by_id"])
            return;
        if (query.deletedById != null)
          if (query.deletedById != formRetrieved["deleted_by_id"])
            return;
        if (query.name != null)
          if (query.name != formRetrieved["name"])
            return;
        if (query.withCheckinout != null)
          if (query.withCheckinout != formRetrieved["with_checkinout"])
            return;
        if (query.active != null)
          if (query.active != formRetrieved["active"])
            return;

        // Relations
        List<SectionModel> sections = await GetSectionsByForm(formRetrieved["id"]);

        listOfForms.add(FormModel(
          id: formRetrieved["id"],
          createdAt: formRetrieved["created_at"],
          updatedAt: formRetrieved["updated_at"],
          deletedAt: formRetrieved["deleted_at"],
          createdById: formRetrieved["created_by_id"],
          updatedById: formRetrieved["updated_by_id"],
          deletedById: formRetrieved["deleted_by_id"],
          name: formRetrieved["name"],
          withCheckinout: formRetrieved["with_checkinout"],
          active: formRetrieved["active"],
          sections: sections,
        ));
      });
    }
    return listOfForms;
  }

  Future<List<FormModel>> ReadFormsBySyncState(SyncState syncState) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT * FROM "forms" WHERE 
      in_server = ? AND
      updated = ? AND
      deleted = ?
      ''',
      paramsBySyncState[syncState],
    );

    List<FormModel> forms = new List<FormModel>();
    if (data.isNotEmpty) {
      await Future.forEach(data, (formRetrieved) async {
        List<SectionModel> sections = await GetSectionsByForm(formRetrieved["id"]);

        forms.add(FormModel(
          id: formRetrieved["id"],
          createdAt: formRetrieved["created_at"],
          updatedAt: formRetrieved["updated_at"],
          deletedAt: formRetrieved["deleted_at"],
          createdById: formRetrieved["created_by_id"],
          updatedById: formRetrieved["updated_by_id"],
          deletedById: formRetrieved["deleted_by_id"],
          name: formRetrieved["name"],
          withCheckinout: formRetrieved["with_checkinout"] == 1 ? true: false,
          active: formRetrieved["active"] == 1 ? true: false,
          sections: sections,
        ));
      });
    }
    return forms;
  }

  Future<int> UpdateForm(int formId, FormModel form, SyncState syncState) async {
    final db = await database;

    if (form.sections!= null) {
      await Future.forEach(form.sections, (section) async {
        List<Map<String, dynamic>> data;
        data = await db.rawQuery(
            '''
            SELECT id 
            FROM "custom_fields" 
            WHERE entity_id = ${section.entityId} 
              AND UPPER(entity_type) = UPPER("Form")
              AND UPPER(type) = UPPER("section") 
            '''
        );

        if (data.isNotEmpty)
          await UpdateSection(section.id, section, syncState);
        else
          await CreateSection(section, syncState);
      });
    }

    return await db.rawUpdate(
      '''
      UPDATE "forms" SET
      id = ?,
      created_at = ?,
      updated_at = ?,
      deleted_at = ?,
      created_by_id = ?,
      updated_by_id = ?,
      deleted_by_id = ?,
      name = ?,
      with_checkinout = ?,
      active = ?,
      in_server = ?,
      updated = ?,
      deleted = ?
      WHERE id = ${formId}
      ''',
      [...[form.id, form.createdAt, form.updatedAt == null ? DateTime.now().toString() : form.updatedAt, form.deletedAt,
    form.createdById, form.updatedById, form.deletedById, form.name,
    form.withCheckinout, form.active],
    ...paramsBySyncState[syncState]],
    );
  }

  Future<int> DeleteFormById(int id) async {
    final db = await database;
    await db.rawDelete(
      '''
      DELETE FROM "custom_fields" WHERE entity_id = $id 
      '''
    );

    await db.rawDelete(
      '''
      DELETE FROM "custom_values" WHERE form_id = $id
      '''
    );
    
    return await db.rawDelete(
      '''
      DELETE FROM "forms" WHERE id = $id
      '''
    );
  }

  Future<int> ChangeSyncStateForm(int id, SyncState syncState) async {
    final db = await database;
    return await db.rawUpdate(
      '''
      UPDATE "forms" SET
      in_server = ?,
      updated = ?,
      deleted = ?
      WHERE id = $id
      ''',
      paramsBySyncState[syncState],
    );
  }

  Future<List<FormModel>> ListForms() async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT * FROM "forms"
      '''
    );

    List<FormModel> forms = new List<FormModel>();
    if (data.isNotEmpty) {
      await Future.forEach(data, (formRetrieved) async {
        List<SectionModel> sections = await GetSectionsByForm(formRetrieved["id"]);

        forms.add(FormModel(
          id: formRetrieved["id"],
          createdAt: formRetrieved["created_at"],
          updatedAt: formRetrieved["updated_at"],
          deletedAt: formRetrieved["deleted_at"],
          createdById: formRetrieved["created_by_id"],
          updatedById: formRetrieved["updated_by_id"],
          deletedById: formRetrieved["deleted_by_id"],
          name: formRetrieved["name"],
          withCheckinout: formRetrieved["with_checkinout"] == 1 ? true: false,
          active: formRetrieved["active"] == 1 ? true: false,
          sections: sections,
        ));
      });
    }
    return forms;
  }

  Future<List<int>> RetrieveAllFormIds() async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
        '''
      SELECT id FROM "forms"
      '''
    );

    List<int> ids = new List<int>();
    if (data.isNotEmpty) {
      data.forEach((form) => ids.add(form["id"]));
    }
    return ids;
  }

  // Operations on localities
  Future<int> CreateLocality(LocalityModel locality, SyncState syncState) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
        '''
      SELECT * FROM "localities" WHERE id = ${locality.id}
      '''
    );

    if (data.isNotEmpty)
      return null;

    return await db.rawInsert(
      '''
        INSERT INTO "localities"(
          id,
          created_at,
          updated_at,
          deleted_at,
          created_by_id,
          updated_by_id,
          deleted_by_id,
          collection,
          name,
          value,
          in_server,
          updated,
          deleted
        )
        
        VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''',
      [...[locality.id, locality.createdAt, locality.updatedAt == null ? DateTime.now().toString() : locality.updatedAt,
    locality.deletedAt, locality.createdById, locality.updatedById,
    locality.deletedById, locality.collection, locality.name,
    locality.value], ...paramsBySyncState[syncState]],
    );
  }

  Future<LocalityModel> ReadLocalityById(int id) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
        '''
      SELECT * FROM "localities" WHERE id = $id
      '''
    );

    if (data.isNotEmpty)
      return LocalityModel(
        id: data.first["id"],
        createdAt: data.first["created_at"],
        updatedAt: data.first["updated_at"],
        deletedAt: data.first["deleted_at"],
        createdById: data.first["created_by_id"],
        updatedById: data.first["updated_by_id"],
        deletedById: data.first["deleted_by_id"],
        collection: data.first["collection"],
        name: data.first["name"],
        value: data.first["value"],
      );
    else
      return null;
  }

  Future<List<LocalityModel>> QueryLocality(LocalityModel query) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
        '''
      SELECT * FROM "localities"
      '''
    );

    List<LocalityModel> listOfLocalities = new List<LocalityModel>();
    if (data.isNotEmpty) {
      data.forEach((localityRetrieved) {
        if (query.id != null)
          if (query.id != localityRetrieved["id"])
            return;
        if (query.createdAt != null)
          if (query.createdAt != localityRetrieved["created_at"])
            return;
        if (query.updatedAt != null)
          if (query.updatedAt != localityRetrieved["updated_at"])
            return;
        if (query.deletedAt != null)
          if (query.deletedAt != localityRetrieved["deleted_at"])
            return;
        if (query.createdById != null)
          if (query.createdById != localityRetrieved["created_by_id"])
            return;
        if (query.updatedById != null)
          if (query.updatedById != localityRetrieved["updateb_by_id"])
            return;
        if (query.deletedById != null)
          if (query.deletedById != localityRetrieved["deleted_by_id"])
            return;
        if (query.collection != null)
          if (query.collection != localityRetrieved["collection"])
            return;
        if (query.name != null)
          if (query.name != localityRetrieved["name"])
            return;
        if (query.value != null)
          if (query.value != localityRetrieved["value"])
            return;

        listOfLocalities.add(LocalityModel(
          id: localityRetrieved["id"],
          createdAt: localityRetrieved["created_at"],
          updatedAt: localityRetrieved["updated_at"],
          deletedAt: localityRetrieved["deleted_at"],
          createdById: localityRetrieved["created_by_id"],
          updatedById: localityRetrieved["updated_by_id"],
          deletedById: localityRetrieved["deleted_by_id"],
          collection: localityRetrieved["collection"],
          name: localityRetrieved["name"],
          value: localityRetrieved["value"],
        ));
      });
    }
    return listOfLocalities;
  }

  Future<List<LocalityModel>> ReadLocalitiesBySyncState(SyncState syncState) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT * FROM "localities" WHERE 
      in_server = ? AND
      updated = ? AND
      deleted = ?
      ''',
      paramsBySyncState[syncState],
    );

    List<LocalityModel> listOfLocalities = new List<LocalityModel>();
    if (data.isNotEmpty) {
      data.forEach((localityRetrieved) {
        listOfLocalities.add(LocalityModel(
          id: localityRetrieved["id"],
          createdAt: localityRetrieved["created_at"],
          updatedAt: localityRetrieved["updated_at"],
          deletedAt: localityRetrieved["deleted_at"],
          createdById: localityRetrieved["created_by_id"],
          updatedById: localityRetrieved["updated_by_id"],
          deletedById: localityRetrieved["deleted_by_id"],
          collection: localityRetrieved["collection"],
          name: localityRetrieved["name"],
          value: localityRetrieved["value"],
        ));
      });
    }
    return listOfLocalities;
  }

  Future<int> UpdateLocality(int localityId, LocalityModel locality, SyncState syncState) async {
    final db = await database;
    return await db.rawUpdate(
      '''
      UPDATE "localities" SET
      id = ?,
      created_at,
      updated_at,
      deleted_at,
      created_by_id,
      updated_by_id,
      deleted_by_id,
      collection,
      name,
      value,
      in_server,
      updated,
      deleted
      WHERE id = ${localityId}
      ''',
      [...[locality.id, locality.createdAt, locality.updatedAt == null ? DateTime.now().toString() : locality.updatedAt, locality.deletedAt,
    locality.createdById, locality.updatedById, locality.deletedById,
    locality.collection, locality.name, locality.value],
    ...paramsBySyncState[syncState]],
    );
  }

  Future<int> DeleteLocalityById(int id) async {
    final db = await database;
    return await db.rawDelete(
      '''
      DELETE FROM "localities" WHERE id = $id
      '''
    );
  }

  Future<int> ChangeSyncStateLocality(int id, SyncState syncState) async {
    final db = await database;
    return await db.rawUpdate(
      '''
      UPDATE "localities" SET
      in_server = ?,
      updated = ?,
      deleted = ?
      WHERE id = $id
      ''',
      paramsBySyncState[syncState],
    );
  }

  Future<List<LocalityModel>> ListLocalities() async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
        '''
      SELECT * FROM "localities"
      '''
    );

    List<LocalityModel> listOfLocalities = new List<LocalityModel>();
    if (data.isNotEmpty) {
      data.forEach((localityRetrieved) {
        listOfLocalities.add(LocalityModel(
          id: localityRetrieved["id"],
          createdAt: localityRetrieved["created_at"],
          updatedAt: localityRetrieved["updated_at"],
          deletedAt: localityRetrieved["deleted_at"],
          createdById: localityRetrieved["created_by_id"],
          updatedById: localityRetrieved["updated_by_id"],
          deletedById: localityRetrieved["deleted_by_id"],
          collection: localityRetrieved["collection"],
          name: localityRetrieved["name"],
          value: localityRetrieved["value"],
        ));
      });
    }
    return listOfLocalities;
  }

  // Operations on responsibles
  Future<int> CreateResponsible(ResponsibleModel responsible, SyncState syncState) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT * FROM "responsibles" WHERE id = ${responsible.id}
      '''
    );

    if (data.isNotEmpty)
      return null;

    if (responsible.supervisor != null)
      await CreateResponsible(responsible.supervisor, syncState);

    return await db.rawInsert(
      '''
      INSERT INTO "responsibles"(
        id,
        created_at,
        updated_at,
        deleted_at,
        created_by_id,
        updated_by_id,
        deleted_by_id,
        supervisor_id,
        name,
        code,
        email,
        phone,
        mobile,
        title,
        details,
        profile,
        in_server,
        updated,
        deleted
      )
      
      VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''',
      [...[responsible.id, responsible.createdAt, responsible.updatedAt == null ? DateTime.now().toString() : responsible.updatedAt,
    responsible.deletedAt, responsible.createdById, responsible.updatedById,
    responsible.deletedById, responsible.supervisorId, responsible.name,
    responsible.code, responsible.email, responsible.phone,
    responsible.mobile, responsible.title, responsible.details,
    responsible.profile], ...paramsBySyncState[syncState]],
    );
  }

  Future<ResponsibleModel> ReadResponsibleById(int id) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
        '''
      SELECT * FROM "responsibles" WHERE id = $id
      '''
    );

    if (data.isNotEmpty) {
      ResponsibleModel supervisor = await ReadResponsibleById(data.first["supervisor_id"]);

      return ResponsibleModel(
        id: data.first["id"],
        createdAt: data.first["created_at"],
        updatedAt: data.first["updated_at"],
        deletedAt: data.first["deleted_at"],
        createdById: data.first["created_by_id"],
        updatedById: data.first["updated_by_id"],
        deletedById: data.first["deleted_by_id"],
        supervisorId: data.first["supervisor_id"],
        name: data.first["name"],
        code: data.first["code"],
        email: data.first["email"],
        phone: data.first["phone"],
        mobile: data.first["mobile"],
        title: data.first["title"],
        details: data.first["details"],
        profile: data.first["profile"],
        supervisor: supervisor,
      );
    }
    else
      return null;
  }

  Future<List<ResponsibleModel>> QueryResponsible(ResponsibleModel query) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
        '''
      SELECT * FROM "responsibles"
      '''
    );

    List<ResponsibleModel> listOfResponsibles = new List<ResponsibleModel>();
    if (data.isNotEmpty) {
      await Future.forEach(data, (responsibleRetrieved) async {
        if (query.id != null)
          if (query.id != responsibleRetrieved["id"])
            return;
        if (query.createdAt != null)
          if (query.createdAt != responsibleRetrieved["created_at"])
            return;
        if (query.updatedAt != null)
          if (query.updatedAt != responsibleRetrieved["updated_at"])
            return;
        if (query.deletedAt != null)
          if (query.deletedAt != responsibleRetrieved["deleted_at"])
            return;
        if (query.createdById != null)
          if (query.createdById != responsibleRetrieved["created_by_id"])
            return;
        if (query.updatedById != null)
          if (query.updatedById != responsibleRetrieved["updated_by_id"])
            return;
        if (query.deletedById != null)
          if (query.deletedById != responsibleRetrieved["deleted_by_id"])
            return;
        if (query.supervisorId != null)
          if (query.supervisorId != responsibleRetrieved["supervisor_id"])
            return;
        if (query.name != null)
          if (query.name != responsibleRetrieved["name"])
            return;
        if (query.code != null)
          if (query.code != responsibleRetrieved["code"])
            return;
        if (query.email != null)
          if (query.email != responsibleRetrieved["email"])
            return;
        if (query.phone != null)
          if (query.phone != responsibleRetrieved["phone"])
            return;
        if (query.mobile != null)
          if (query.mobile != responsibleRetrieved["mobile"])
            return;
        if (query.title != null)
          if (query.title != responsibleRetrieved["title"])
            return;
        if (query.details != null)
          if (query.details != responsibleRetrieved["details"])
            return;
        if (query.profile != null)
          if (query.profile != responsibleRetrieved["profile"])
            return;

        ResponsibleModel supervisor = await ReadResponsibleById(responsibleRetrieved["supervisor_id"]);
        listOfResponsibles.add(new ResponsibleModel(
          id: responsibleRetrieved["id"],
          createdAt: responsibleRetrieved["created_at"],
          updatedAt: responsibleRetrieved["updated_at"],
          deletedAt: responsibleRetrieved["deleted_at"],
          createdById: responsibleRetrieved["created_by_id"],
          updatedById: responsibleRetrieved["updated_by_id"],
          deletedById: responsibleRetrieved["deleted_by_id"],
          supervisorId: responsibleRetrieved["supervisor_id"],
          name: responsibleRetrieved["name"],
          code: responsibleRetrieved["code"],
          email: responsibleRetrieved["email"],
          phone: responsibleRetrieved["phone"],
          mobile: responsibleRetrieved["mobile"],
          title: responsibleRetrieved["title"],
          details: responsibleRetrieved["details"],
          profile: responsibleRetrieved["profile"],
          supervisor: supervisor,
        ));
      });
    }
    return listOfResponsibles;
  }

  Future<List<ResponsibleModel>> ReadResponsiblesBySyncState(SyncState syncState) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT * FROM "responsibles" WHERE 
      in_server = ? AND
      updated = ? AND
      deleted = ?
      ''',
      paramsBySyncState[syncState],
    );

    List<ResponsibleModel> listOfResponsibles = new List<ResponsibleModel>();
    if (data.isNotEmpty) {
      await Future.forEach(data, (responsibleRetrieved) async {
        ResponsibleModel supervisor = await ReadResponsibleById(responsibleRetrieved["supervisor_id"]);
        listOfResponsibles.add(new ResponsibleModel(
          id: responsibleRetrieved["id"],
          createdAt: responsibleRetrieved["created_at"],
          updatedAt: responsibleRetrieved["updated_at"],
          deletedAt: responsibleRetrieved["deleted_at"],
          createdById: responsibleRetrieved["created_by_id"],
          updatedById: responsibleRetrieved["updated_by_id"],
          deletedById: responsibleRetrieved["deleted_by_id"],
          supervisorId: responsibleRetrieved["supervisor_id"],
          name: responsibleRetrieved["name"],
          code: responsibleRetrieved["code"],
          email: responsibleRetrieved["email"],
          phone: responsibleRetrieved["phone"],
          mobile: responsibleRetrieved["mobile"],
          title: responsibleRetrieved["title"],
          details: responsibleRetrieved["details"],
          profile: responsibleRetrieved["profile"],
          supervisor: supervisor,
        ));
      });
    }
    return listOfResponsibles;
  }

  Future<int> UpdateResponsible(int responsibleId, ResponsibleModel responsible, SyncState syncState) async {
    final db = await database;

    if (responsible.supervisor != null ) {
      List<Map<String, dynamic>> data;
      data = await db.rawQuery(
          '''
          SELECT * FROM "responsibles" WHERE id = ${responsible.supervisor.id}
          '''
      );

      if (data.isNotEmpty)
        await UpdateResponsible(responsible.supervisor.id, responsible.supervisor, syncState);
      else
        await CreateResponsible(responsible.supervisor, syncState);
    }


    return await db.rawUpdate(
      '''
      UPDATE "responsibles" SET
      id = ?,
      created_at = ?,
      updated_at = ?,
      deleted_at = ?,
      created_by_id = ?,
      updated_by_id = ?,
      deleted_by_id = ?,
      supervisor_id = ?,
      name = ?,
      code = ?,
      email = ?,
      phone = ?,
      mobile = ?,
      title = ?,
      details = ?,
      profile = ?,
      in_server = ?,
      updated = ?,
      deleted = ?
      WHERE id = ${responsible.id}
      ''',
      [...[responsible.id, responsible.createdAt, responsible.updatedAt == null ? DateTime.now().toString() : responsible.updatedAt,
    responsible.deletedAt, responsible.createdById, responsible.updatedById,
    responsible.deletedById, responsible.supervisorId, responsible.name,
    responsible.code, responsible.email, responsible.phone,
    responsible.mobile, responsible.title, responsible.details,
    responsible.profile], ...paramsBySyncState[syncState]],
    );
  }

  Future<int> DeleteResponsibleById(int id) async {
    final db = await database;
    return await db.rawDelete(
        '''
      DELETE FROM "responsibles" WHERE id = $id
      '''
    );
  }

  Future<int> ChangeSyncStateResponsible(int id, SyncState syncState) async {
    final db = await database;
    return await db.rawUpdate(
      '''
      UPDATE "responsibles" SET
      in_server = ?,
      updated = ?,
      deleted = ?
      WHERE id = $id
      ''',
      paramsBySyncState[syncState],
    );
  }

  Future<List<ResponsibleModel>> ListResponsibles() async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
        '''
      SELECT * FROM "responsibles"
      '''
    );

    List<ResponsibleModel> listOfResponsibles = new List<ResponsibleModel>();
    if (data.isNotEmpty) {
      await Future.forEach(data, (responsibleRetrieved) async {
        ResponsibleModel supervisor = await ReadResponsibleById(responsibleRetrieved["supervisor_id"]);
        listOfResponsibles.add(new ResponsibleModel(
          id: responsibleRetrieved["id"],
          createdAt: responsibleRetrieved["created_at"],
          updatedAt: responsibleRetrieved["updated_at"],
          deletedAt: responsibleRetrieved["deleted_at"],
          createdById: responsibleRetrieved["created_by_id"],
          updatedById: responsibleRetrieved["updated_by_id"],
          deletedById: responsibleRetrieved["deleted_by_id"],
          supervisorId: responsibleRetrieved["supervisor_id"],
          name: responsibleRetrieved["name"],
          code: responsibleRetrieved["code"],
          email: responsibleRetrieved["email"],
          phone: responsibleRetrieved["phone"],
          mobile: responsibleRetrieved["mobile"],
          title: responsibleRetrieved["title"],
          details: responsibleRetrieved["details"],
          profile: responsibleRetrieved["profile"],
          supervisor: supervisor,
        ));
      });
    }
    return listOfResponsibles;
  }

  // Operations on custom_fields  
  // lookatmeplease1

  Future<int> CreateSection(SectionModel section, SyncState syncState) async {
    final db = await database;
    List<Map<String, dynamic>> data;

    await Future.forEach(section.fields, (field) async {
      await CreateField(field, syncState);
    });

    data = await db.rawQuery(
        '''
      SELECT * FROM "custom_fields" WHERE id = ${section.id}
      '''
    );

    if (data.isNotEmpty)
      return null;

    return await db.rawInsert(
      '''
      INSERT INTO "custom_fields"(
        id,
        created_at,
        updated_at,
        deleted_at,
        created_by_id,
        updated_by_id,
        deleted_by_id,
        section_id,
        entity_type,
        entity_id,
        type,
        name,
        code,
        subtitle,
        position,
        field_default_value,
        field_type,
        field_placeholder,
        field_options,
        field_collection,
        field_required,
        field_width,
        in_server,
        updated,
        deleted
      )
      
      VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''',

      [...[section.id, section.createdAt, section.updatedAt == null ? DateTime.now().toString() : section.updatedAt,
      section.deletedAt, section.createdById,
      section.updatedById, section.deletedById,
      section.sectionId, section.entityType,
      section.entityId, section.type, section.name,
      section.code, section.subtitle, section.position,
      section.fieldDefaultValue, section.fieldType,
      section.fieldPlaceholder, json.encode(section.fieldOptions).replaceAll("\\", "").replaceAll("\"{", "{").replaceAll("}\"", "}"),
      section.fieldCollection, section.fieldRequired,
      section.fieldWidth], ...paramsBySyncState[syncState]],
    );
  }

  // TODO: CHECK THIS
  Future<int> CreateField(FieldModel field, SyncState syncState) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT * FROM "custom_fields" WHERE id = ${field.id}
      '''
    );

    if (data.isNotEmpty) 
      return null;

    String fieldLocalValue;
    if (field.name == "Image" || field.name == "Image_canvan" || field.name == "Image canvan") {
      if (field.fieldDefaultValue != null) {
        fieldLocalValue = basename(field.fieldDefaultValue);
        await ImageRepository.handler.DownloadImage(fieldLocalValue, field.fieldDefaultValue);
      }
    }

    return await db.rawInsert(
      '''
      INSERT INTO "custom_fields"(
        id,
        created_at,
        updated_at,
        deleted_at,
        created_by_id,
        updated_by_id,
        deleted_by_id,
        section_id,
        entity_type,
        entity_id,
        type,
        name,
        code,
        subtitle,
        position,
        field_default_value,
        field_type,
        field_placeholder,
        field_options,
        field_collection,
        field_required,
        field_width,
        field_local_value,
        in_server,
        updated,
        deleted
      )
      
      VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''',

      [...[field.id, field.createdAt, field.updatedAt == null ? DateTime.now().toString() : field.updatedAt,
      field.deletedAt, field.createdById,
      field.updatedById, field.deletedById,
      field.sectionId, field.entityType,
      field.entityId, field.type, field.name,
      field.code, field.subtitle, field.position,
      field.fieldDefaultValue, field.fieldType,
      field.fieldPlaceholder, json.encode(field.fieldOptions).replaceAll("\\", "").replaceAll("\"{", "{").replaceAll("}\"", "}"),
      field.fieldCollection, field.fieldRequired,
      field.fieldWidth, fieldLocalValue], ...paramsBySyncState[syncState]],
    );
  }

  Future<FieldModel> ReadFieldById(int id) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery('SELECT * FROM "custom_fields" WHERE id = $id');
    
    if (data.isEmpty) return null;

    Map<String, dynamic> field = data.first;
    var output = new FieldModel(
      id: field["id"],
      createdAt: field["created_at"],
      updatedAt: field["updated_at"],
      deletedAt: field["deleted_at"],
      createdById: field["created_by_id"],
      updatedById: field["updated_by_id"],
      deletedById: field["deleted_by_id"],
      sectionId: field["section_id"],
      entityType: field["entity_type"],
      entityId: field["entity_id"],
      type: field["type"],
      name: field["name"],
      code: field["code"],
      subtitle: field["subtitle"],
      position: field["position"],
      fieldDefaultValue: field["field_default_value"],
      fieldType: field["field_type"],
      fieldPlaceholder: field["field_placeholder"],
      fieldOptions: field["field_options"] != "null" ? new List<FieldOptionModel>.from(json.decode(field["field_options"]).map((x) => new FieldOptionModel(value: x["value"], name: x["name"]))) : new List<FieldOptionModel>(),
      fieldCollection: field["field_collection"],
      fieldRequired: field["field_required"] == 1 ? true: false,
      image: field["field_local_value"] == null ? null : (await ImageRepository.handler.RetrieveImage(field["field_local_value"])),
    );

    if (field["field_local_value"] != null) {
      print(field["field_local_value"].toString() + "\n" + field["id"].toString() + "\n");
      print((await ImageRepository.handler.RetrieveImage(field["field_local_value"])).path + "\n");
    }

    return output;
  }
  
  Future<SectionModel> ReadSectionById(int id) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery('SELECT * FROM "custom_fields" WHERE id = $id');
    
    if (data.isEmpty) return null;

    Map<String, dynamic> section = data.first;
    List<FieldModel> listOfFields = await GetFieldsBySection(section["id"]);

    return new SectionModel(
      id: section["id"],
      createdAt: section["created_at"],
      updatedAt: section["updated_at"],
      deletedAt: section["deleted_at"],
      createdById: section["created_by_id"],
      updatedById: section["updated_by_id"],
      deletedById: section["deleted_by_id"],
      sectionId: section["section_id"],
      entityType: section["entity_type"],
      entityId: section["entity_id"],
      type: section["type"],
      name: section["name"],
      code: section["code"],
      subtitle: section["subtitle"],
      position: section["position"],
      fieldDefaultValue: section["field_default_value"],
      fieldType: section["field_type"],
      fieldPlaceholder: section["field_placeholder"],
      fieldOptions: section["field_options"] != "null" ? new List<FieldOptionModel>.from(json.decode(section["field_options"]).map((x) => new FieldOptionModel(value: x["value"], name: x["name"]))) : new List<FieldOptionModel>(),
      fieldCollection: section["field_collection"],
      fieldRequired: section["field_required"] == 1 ? true: false,
      fields: listOfFields,
    );
  }

  Future<List<FieldModel>> GetFieldsBySection(int id) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT * FROM "custom_fields" WHERE section_id = $id AND type = "field"
      '''
    );

    List<FieldModel> listOfFields = List<FieldModel>();
    if (data.isNotEmpty) {
      await Future.forEach(data, (field) async {
        listOfFields.add(new FieldModel(
          id: field["id"],
          createdAt: field["created_at"],
          updatedAt: field["updated_at"],
          deletedAt: field["deleted_at"],
          createdById: field["created_by_id"],
          updatedById: field["updated_by_id"],
          deletedById: field["deleted_by_id"],
          sectionId: field["section_id"],
          entityType: field["entity_type"],
          entityId: field["entity_id"],
          type: field["type"],
          name: field["name"],
          code: field["code"],
          subtitle: field["subtitle"],
          position: field["position"],
          fieldDefaultValue: field["field_default_value"],
          fieldType: field["field_type"],
          fieldPlaceholder: field["field_placeholder"],
          fieldOptions: field["field_options"] != "null" ? new List<FieldOptionModel>.from(json.decode(field["field_options"]).map((x) => new FieldOptionModel(value: x["value"], name: x["name"]))) : new List<FieldOptionModel>(),
          fieldCollection: field["field_collection"],
          fieldRequired: field["field_required"] == 1 ? true: false,
          fieldWidth: field["field_width"],
          image: field["field_local_value"] == null ? null : (await ImageRepository.handler.RetrieveImage(field["field_local_value"])),
        ));

        if (field["field_local_value"] != null) {
          print(field["field_local_value"].toString() + "\n" + field["id"].toString() + "\n");
          print((await ImageRepository.handler.RetrieveImage(field["field_local_value"])).path + "\n");
        }
      });
    }

    listOfFields.sort((a, b) => a.position.compareTo(b.position));
    return listOfFields;
  }

  Future<List<int>> ListSectionIdsByForm(int id) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery('SELECT id FROM "custom_fields" WHERE entity_id = $id AND type = "section"');

    List<int> listOfSectionIds = new List<int>();
    
    if (data.isNotEmpty) {
      data.forEach((section) => listOfSectionIds.add(section["id"])); 
    }

    return listOfSectionIds;
  }

  Future<List<int>> ListFieldIdsBySection(int id) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery('SELECT id FROM "custom_fields" WHERE section_id = $id AND type = "field"');

    List<int> listOfFieldIds = new List<int>();

    if (data.isNotEmpty) {
      data.forEach((field) => listOfFieldIds.add(field["id"]));
    }

    return listOfFieldIds;
  }

  Future<List<SectionModel>> ListSectionsByTask() async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery('SELECT * FROM "custom_fields" WHERE "type" = "section"');

    List<SectionModel> listOfSections = List<SectionModel>();
    if (data.isNotEmpty) {
      await Future.forEach(data, (section) async {
        List<FieldModel> listOfFields = await GetFieldsBySection(section["id"]);

        listOfSections.add(new SectionModel(
          id: section["id"],
          createdAt: section["created_at"],
          updatedAt: section["updated_at"],
          deletedAt: section["deleted_at"],
          createdById: section["created_by_id"],
          updatedById: section["updated_by_id"],
          deletedById: section["deleted_by_id"],
          sectionId: section["section_id"],
          entityType: section["entity_type"],
          entityId: section["entity_id"],
          type: section["type"],
          name: section["name"],
          code: section["code"],
          subtitle: section["subtitle"],
          position: section["position"],
          fieldDefaultValue: section["field_default_value"],
          fieldType: section["field_type"],
          fieldPlaceholder: section["field_placeholder"],
          fieldOptions: section["field_options"] != "null" ? new List<FieldOptionModel>.from(json.decode(section["field_options"]).map((x) => new FieldOptionModel(value: x["value"], name: x["name"]))) : new List<FieldOptionModel>(),
          fieldCollection: section["field_collection"],
          fieldRequired: section["field_required"] == 1 ? true: false,
          fieldWidth: section["field_width"],
          fields: listOfFields,
        ));
      });
    }
  }

  Future<List<SectionModel>> ListSections() async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
        '''
      SELECT * FROM "custom_fields" 
      '''
    );

    List<SectionModel> listOfSections = List<SectionModel>();
    if (data.isNotEmpty) {
      await Future.forEach(data, (section) async {
        List<FieldModel> listOfFields = await GetFieldsBySection(section["id"]);

        listOfSections.add(new SectionModel(
          id: section["id"],
          createdAt: section["created_at"],
          updatedAt: section["updated_at"],
          deletedAt: section["deleted_at"],
          createdById: section["created_by_id"],
          updatedById: section["updated_by_id"],
          deletedById: section["deleted_by_id"],
          sectionId: section["section_id"],
          entityType: section["entity_type"],
          entityId: section["entity_id"],
          type: section["type"],
          name: section["name"],
          code: section["code"],
          subtitle: section["subtitle"],
          position: section["position"],
          fieldDefaultValue: section["field_default_value"],
          fieldType: section["field_type"],
          fieldPlaceholder: section["field_placeholder"],
          fieldOptions: section["field_options"] != "null" ? new List<FieldOptionModel>.from(json.decode(section["field_options"]).map((x) => new FieldOptionModel(value: x["value"], name: x["name"]))) : new List<FieldOptionModel>(),
          fieldCollection: section["field_collection"],
          fieldRequired: section["field_required"] == 1 ? true: false,
          fieldWidth: section["field_width"],
          fields: listOfFields,
        ));
      });
    }

    return listOfSections;
  }

  Future<List<SectionModel>> GetSectionsByForm(int id) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT * FROM "custom_fields" WHERE entity_id = $id AND type = "section"
      '''
    );

    List<SectionModel> listOfSections = List<SectionModel>();
    if (data.isNotEmpty) {
      await Future.forEach(data, (section) async {
        List<FieldModel> listOfFields = await GetFieldsBySection(section["id"]);

        listOfSections.add(new SectionModel(
          id: section["id"],
          createdAt: section["created_at"],
          updatedAt: section["updated_at"],
          deletedAt: section["deleted_at"],
          createdById: section["created_by_id"],
          updatedById: section["updated_by_id"],
          deletedById: section["deleted_by_id"],
          sectionId: section["section_id"],
          entityType: section["entity_type"],
          entityId: section["entity_id"],
          type: section["type"],
          name: section["name"],
          code: section["code"],
          subtitle: section["subtitle"],
          position: section["position"],
          fieldDefaultValue: section["field_default_value"],
          fieldType: section["field_type"],
          fieldPlaceholder: section["field_placeholder"],
          fieldOptions: section["field_options"] != "null" ? new List<FieldOptionModel>.from(json.decode(section["field_options"]).map((x) => new FieldOptionModel(value: x["value"], name: x["name"]))) : new List<FieldOptionModel>(),
          fieldCollection: section["field_collection"],
          fieldRequired: section["field_required"] == 1 ? true: false,
          fieldWidth: section["field_width"],
          fields: listOfFields,
        ));
      });
    }

    return listOfSections; 
  }

  Future<int> UpdateSection(int id, SectionModel section, SyncState syncState) async {
    if (section.fields != null) {
      await Future.forEach(section.fields, (field) async => await UpdateField(field.id, field, syncState));
    }

    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT id FROM "custom_fields" WHERE id = $id
      '''
    );

    if (data.isNotEmpty) {
      return await db.rawUpdate(
        '''
        UPDATE "custom_fields" SET
        id = ?,
        created_at = ?,
        updated_at = ?,
        deleted_at = ?,
        created_by_id = ?,
        updated_by_id = ?,
        deleted_by_id = ?,
        section_id = ?,
        entity_type = ?,
        entity_id = ?,
        type = ?,
        name = ?,
        code = ?,
        subtitle = ?,
        position = ?,
        field_default_value = ?,
        field_type = ?,
        field_placeholder = ?,
        field_options = ?,
        field_collection = ?,
        field_required = ?,
        field_width = ?,
        in_server = ?,
        updated = ?,
        deleted = ?
        WHERE id = ${id}
        ''',
        [...[section.id, section.createdAt, section.updatedAt == null ? DateTime.now().toString() : section.updatedAt, section.deletedAt,
        section.createdById, section.updatedById, section.deletedById,
        section.sectionId, section.entityType, section.entityId, section.type,
        section.name, section.code, section.subtitle, section.position,
        section.fieldDefaultValue, section.fieldType, section.fieldPlaceholder,
        json.encode(section.fieldOptions).replaceAll("\\", "").replaceAll("\"{", "{").replaceAll("}\"", "}"), 
        section.fieldCollection, section.fieldRequired,
        section.fieldWidth], ...paramsBySyncState[syncState]],
      );
    } else
      return await CreateSection(section, syncState);
  }

  Future<int> UpdateField(int id, FieldModel field, SyncState syncState) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT id FROM "custom_fields" WHERE id = $id
      '''
    );

    if (data.isNotEmpty) {
      if (field.name == "Image" || field.name == "Image_canvan") {
        if (field.fieldDefaultValue != null) {
          if (field.fieldDefaultValue != data.first["field_default_value"]) {
            await ImageRepository.handler.DownloadImage(data.first["field_local_value"], field.fieldDefaultValue);
          }
        }
      }

      return await db.rawUpdate(
        '''
        UPDATE "custom_fields" SET
        id = ?,
        created_at = ?,
        updated_at = ?,
        deleted_at = ?,
        created_by_id = ?,
        updated_by_id = ?,
        deleted_by_id = ?,
        section_id = ?,
        entity_type = ?,
        entity_id = ?,
        type = ?,
        name = ?,
        code = ?,
        subtitle = ?,
        position = ?,
        field_default_value = ?,
        field_type = ?,
        field_placeholder = ?,
        field_options = ?,
        field_collection = ?,
        field_required = ?,
        field_width = ?,
        in_server = ?,
        updated = ?,
        deleted = ?
        WHERE id = ${id}
        ''',
        [...[field.id, field.createdAt, field.updatedAt == null ? DateTime.now().toString() : field.updatedAt, field.deletedAt,
        field.createdById, field.updatedById, field.deletedById,
        field.sectionId, field.entityType, field.entityId, field.type,
        field.name, field.code, field.subtitle, field.position,
        field.fieldDefaultValue, field.fieldType, field.fieldPlaceholder,
        json.encode(field.fieldOptions).replaceAll("\\", "").replaceAll("\"{", "{").replaceAll("}\"", "}"), 
        field.fieldCollection, field.fieldRequired,
        field.fieldWidth], ...paramsBySyncState[syncState]],
      );
    } else
      return await CreateField(field, syncState);
  }

  Future<int> DeleteSectionById(int id) async {
    final db = await database;
    await db.rawDelete(
      '''
      DELETE FROM "custom_fields" WHERE section_id = $id
      '''
    );

    await db.rawDelete(
      '''
      DELETE FROM "custom_fields" WHERE id = $id
      '''
    );
  }

  Future<int> DeleteFieldById(int id) async {
    final db = await database;

    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT "field_local_value" FROM "custom_fields" WHERE id = $id
      '''
    );

    ImageRepository.handler.DeleteImage(data.first["field_local_value"]);

    await db.rawDelete(
    '''
    DELETE FROM "custom_fields" WHERE id = $id
    '''
    );
  }

  Future<int> ChangeSyncStateCustomField(int id, SyncState syncState) async {
    final db = await database;
    return await db.rawUpdate(
      '''
      UPDATE "custom_fields" SET
      in_server = ?,
      updated = ?,
      deleted = ?
      WHERE id = $id
      ''',
      paramsBySyncState[syncState],
    );
  }

  // Operations on addresses
  Future<AddressModel> CreateAddress(AddressModel address, SyncState syncState) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT * FROM "addresses" WHERE id = ${address.id}
      '''
    );

    if (data.isNotEmpty)
      return null;

    if (address.locality != null){
      await CreateLocality(address.locality, syncState);
    }

    address.id = await db.rawInsert(
      '''
      INSERT INTO "addresses"(
        id,
        created_at,
        updated_at,
        deleted_at,
        created_by_id,
        updated_by_id,
        deleted_by_id,
        locality_id,
        address,
        details,
        reference,
        latitude,
        longitude,
        google_place_id,
        country,
        state,
        city,
        contact_name,
        contact_phone,
        contact_mobile,
        contact_email,
        in_server,
        updated,
        deleted
      )
        
      VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''',

      [...[address.id, address.createdAt, address.updatedAt == null ? DateTime.now().toString() : address.updatedAt,
    address.deletedAt, address.createdById, address.updatedById,
    address.deletedById, address.localityId, address.address,
    address.details, address.reference, address.latitude, address.longitude,
    address.googlePlaceId, address.country,address.state, address.city,
    address.contactName, address.contactPhone, address.contactMobile,
    address.contactEmail], ...paramsBySyncState[syncState]],
    );

    return address;
  }

  Future<AddressModel> ReadAddressById(int id) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
        '''
      SELECT * FROM "addresses" WHERE id = $id
      '''
    );

    if (data.isNotEmpty) {
      LocalityModel locality = await ReadLocalityById(data.first["locality_id"]);

      return AddressModel(
          id: data.first["id"],
          createdAt: data.first["created_at"],
          updatedAt: data.first["updated_at"],
          deletedAt: data.first["deleted_at"],
          createdById: data.first["created_by_id"],
          updatedById: data.first["updateb_by_id"],
          deletedById: data.first["deleted_by_id"],
          localityId: data.first["locality_id"],
          address: data.first["address"],
          details: data.first["details"],
          reference: data.first["reference"],
          latitude: data.first["latitude"],
          longitude: data.first["longitude"],
          googlePlaceId: data.first["google_place_id"],
          country: data.first["country"],
          state: data.first["state"],
          city: data.first["city"],
          contactName: data.first["name"],
          contactPhone: data.first["contact_phone"],
          contactMobile: data.first["contact_mobile"],
          contactEmail: data.first["contact_email"],
          locality: locality);
    }
    else
      return null;
  }

  Future<List<AddressModel>> QueryAddress(AddressModel query) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
        '''
      SELECT * FROM "addresses"
      '''
    );

    List<AddressModel> listOfAddresses = new List<AddressModel>();
    if (data.isNotEmpty) {
      await Future.forEach(data, (addressRetrieved) async {
        if (query.id != null)
          if (query.id != addressRetrieved["id"])
            return;
        if (query.createdAt != null)
          if (query.createdAt != addressRetrieved["created_at"])
            return;
        if (query.updatedAt != null)
          if (query.updatedAt != addressRetrieved["updated_at"])
            return;
        if (query.deletedAt != null)
          if (query.deletedAt != addressRetrieved["deleted_at"])
            return;
        if (query.createdById != null)
          if (query.createdById != addressRetrieved["created_by_id"])
            return;
        if (query.updatedById != null)
          if (query.updatedById != addressRetrieved["updated_by_id"])
            return;
        if (query.deletedById != null)
          if (query.deletedById != addressRetrieved["deleted_by_id"])
            return;
        if (query.localityId != null)
          if (query.localityId != addressRetrieved["locality_id"])
            return;
        if (query.address != null)
          if (query.address != addressRetrieved["address"])
            return;
        if (query.details != null)
          if (query.details != addressRetrieved["details"])
            return;
        if (query.reference != null)
          if (query.reference != addressRetrieved["reference"])
            return;
        if (query.latitude != null)
          if (query.latitude != addressRetrieved["latitude"])
            return;
        if (query.longitude != null)
          if (query.longitude != addressRetrieved["longitude"])
            return;
        if (query.googlePlaceId != null)
          if (query.googlePlaceId != addressRetrieved["google_place_id"])
            return;
        if (query.country != null)
          if (query.country != addressRetrieved["country"])
            return;
        if (query.state != null)
          if (query.state != addressRetrieved["state"])
            return;
        if (query.city != null)
          if (query.city != addressRetrieved["city"])
            return;
        if (query.contactName != null)
          if (query.contactName != addressRetrieved["contact_name"])
            return;
        if (query.contactPhone != null)
          if (query.contactPhone != addressRetrieved["contact_phone"])
            return;
        if (query.contactMobile != null)
          if (query.contactMobile != addressRetrieved["contact_mobile"])
            return;
        if (query.contactEmail != null)
          if (query.contactEmail != addressRetrieved["contact_email"])
            return;

        LocalityModel localityModel = await ReadLocalityById(addressRetrieved["locality_id"]);

        listOfAddresses.add(new AddressModel(
          id: addressRetrieved["id"],
          createdAt: addressRetrieved["created_at"],
          updatedAt: addressRetrieved["updated_at"],
          deletedAt: addressRetrieved["deleted_at"],
          createdById: addressRetrieved["created_by_id"],
          updatedById: addressRetrieved["updateb_by_id"],
          deletedById: addressRetrieved["deleted_by_id"],
          localityId: addressRetrieved["locality_id"],
          address: addressRetrieved["address"],
          details: addressRetrieved["details"],
          reference: addressRetrieved["reference"],
          latitude: addressRetrieved["latitude"],
          longitude: addressRetrieved["longitude"],
          googlePlaceId: addressRetrieved["google_place_id"],
          country: addressRetrieved["country"],
          state: addressRetrieved["state"],
          city: addressRetrieved["city"],
          contactName: addressRetrieved["name"],
          contactPhone: addressRetrieved["contact_phone"],
          contactMobile: addressRetrieved["contact_mobile"],
          contactEmail: addressRetrieved["contact_email"],
          locality: localityModel,
        ));
      });
    }
    return listOfAddresses;
  }

  Future<List<AddressModel>> ReadAddressesBySyncState(SyncState syncState) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT * FROM "addresses" WHERE 
      in_server = ? AND
      updated = ? AND
      deleted = ?
      ''',
      paramsBySyncState[syncState],
    );

    List<AddressModel> listOfAddresses = new List<AddressModel>();
    if (data.isNotEmpty) {
      await Future.forEach(data, (addressRetrieved) async {

        LocalityModel localityModel = await ReadLocalityById(addressRetrieved["locality_id"]);

        listOfAddresses.add(new AddressModel(
          id: addressRetrieved["id"],
          createdAt: addressRetrieved["created_at"],
          updatedAt: addressRetrieved["updated_at"],
          deletedAt: addressRetrieved["deleted_at"],
          createdById: addressRetrieved["created_by_id"],
          updatedById: addressRetrieved["updateb_by_id"],
          deletedById: addressRetrieved["deleted_by_id"],
          localityId: addressRetrieved["locality_id"],
          address: addressRetrieved["address"],
          details: addressRetrieved["details"],
          reference: addressRetrieved["reference"],
          latitude: addressRetrieved["latitude"],
          longitude: addressRetrieved["longitude"],
          googlePlaceId: addressRetrieved["google_place_id"],
          country: addressRetrieved["country"],
          state: addressRetrieved["state"],
          city: addressRetrieved["city"],
          contactName: addressRetrieved["name"],
          contactPhone: addressRetrieved["contact_phone"],
          contactMobile: addressRetrieved["contact_mobile"],
          contactEmail: addressRetrieved["contact_email"],
          locality: localityModel,
        ));
      });
    }
    return listOfAddresses;
  }

  Future<AddressModel> UpdateAddress(int addressId, AddressModel address, SyncState syncState) async {
    final db = await database;
    List<Map<String, dynamic>> data;

    if (address.locality != null) {

      data = await db.rawQuery(
          '''
          SELECT * FROM "localities" WHERE id = ${address.locality.id}
          '''
      );

      if (data.isNotEmpty)
        await UpdateLocality(address.locality.id, address.locality, syncState);
      else
        await CreateLocality(address.locality, syncState);
    }


    await db.rawUpdate(
      '''
      UPDATE "addresses" SET
      id = ?,
      created_at = ?,
      updated_at = ?,
      deleted_at = ?,
      created_by_id = ?,
      updated_by_id = ?,
      deleted_by_id = ?,
      locality_id = ?,
      address = ?,
      details = ?,
      reference = ?,
      latitude = ?,
      longitude = ?,
      google_place_id = ?,
      country = ?,
      state = ?,
      city = ?,
      contact_name = ?,
      contact_phone = ?,
      contact_mobile = ?,
      contact_email = ?,
      in_server = ?,
      updated = ?,
      deleted = ?
      WHERE id = ${addressId}
      ''',
      [...[address.id, address.createdAt, address.updatedAt == null ? DateTime.now().toString() : address.updatedAt, address.deletedAt,
    address.createdById, address.updatedById, address.deletedById,
    address.localityId, address.address, address.details, address.reference,
    address.latitude, address.longitude, address.googlePlaceId,
    address.country, address.state, address.city, address.contactName,
    address.contactPhone, address.contactMobile, address.contactEmail],
    ...paramsBySyncState[syncState]],
    );

    return address;
  }

  Future<int> DeleteAddressById(int id) async {
    final db = await database;
    await db.rawDelete('DELETE FROM "customers_addresses" WHERE address_id = $id');
    return await db.rawDelete(
        '''
      DELETE FROM "addresses" WHERE id = $id
      '''
    );
  }

  Future<int> ChangeSyncStateAddress(int id, SyncState syncState) async {
    final db = await database;
    return await db.rawUpdate(
      '''
      UPDATE "addresses" SET
      in_server = ?,
      updated = ?,
      deleted = ?
      WHERE id = $id
      ''',
      paramsBySyncState[syncState],
    );
  }

  Future<List<AddressModel>> ListAddresses() async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT * FROM "addresses"
      '''
    );

    List<AddressModel> listOfAddresses = new List<AddressModel>();
    if (data.isNotEmpty) {
      await Future.forEach(data, (addressRetrieved) async {
        LocalityModel localityModel = await ReadLocalityById(addressRetrieved["locality_id"]);
        listOfAddresses.add(new AddressModel(
          id: addressRetrieved["id"],
          createdAt: addressRetrieved["created_at"],
          updatedAt: addressRetrieved["updated_at"],
          deletedAt: addressRetrieved["deleted_at"],
          createdById: addressRetrieved["created_by_id"],
          updatedById: addressRetrieved["updateb_by_id"],
          deletedById: addressRetrieved["deleted_by_id"],
          localityId: addressRetrieved["locality_id"],
          address: addressRetrieved["address"],
          details: addressRetrieved["details"],
          reference: addressRetrieved["reference"],
          latitude: addressRetrieved["latitude"],
          longitude: addressRetrieved["longitude"],
          googlePlaceId: addressRetrieved["google_place_id"],
          country: addressRetrieved["country"],
          state: addressRetrieved["state"],
          city: addressRetrieved["city"],
          contactName: addressRetrieved["name"],
          contactPhone: addressRetrieved["contact_phone"],
          contactMobile: addressRetrieved["contact_mobile"],
          contactEmail: addressRetrieved["contact_email"],
          locality: localityModel,
        ));
      });
    }
    return listOfAddresses;
  }

  Future<List<int>> RetrieveAllAddressIds() async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT id FROM "addresses"
      '''
    );

    List<int> ids = new List<int>();
    if (data.isNotEmpty) {
      data.forEach((address) => ids.add(address["id"]));
    }
    return ids;
  }

  // Operations on customers
  Future<CustomerModel> CreateCustomer(CustomerModel customer, SyncState syncState) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
        '''
      SELECT * FROM "customers" WHERE id = ${customer.id}
      '''
    );

    if (data.isNotEmpty)
      return null;

    customer.id = await db.rawInsert(
      '''
      INSERT INTO "customers"(
        id,
        created_at,
        updated_at,
        deleted_at,
        created_by_id,
        updated_by_id,
        deleted_by_id,
        name,
        code,
        details,
        in_server,
        updated,
        deleted
      )
        
      VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''',
      [...[customer.id, customer.createdAt, customer.updatedAt == null ? DateTime.now().toString() : customer.updatedAt,
    customer.deletedAt, customer.createdById, customer.updatedById,
    customer.deletedById, customer.name, customer.code, customer.details],
    ...paramsBySyncState[syncState]],
    );

    return customer;
  }

  Future<CustomerModel> ReadCustomerById(int id) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
        '''
      SELECT * FROM "customers" WHERE id = $id
      '''
    );

    if (data.isNotEmpty)
      return CustomerModel(
        id: data.first["id"],
        createdAt: data.first["created_at"],
        updatedAt: data.first["updated_at"],
        deletedAt: data.first["deleted_at"],
        createdById: data.first["created_by_id"],
        updatedById: data.first["updated_by_id"],
        deletedById: data.first["deleted_by_id"],
        name: data.first["name"],
        code: data.first["code"],
        details: data.first["details"],
        pivot: null,
      );
    else
      return null;
  }

  Future<List<CustomerModel>> QueryCustomer(CustomerModel query) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
        '''
      SELECT * FROM "customers"
      '''
    );

    List<CustomerModel> listOfCustomers = new List<CustomerModel>();
    if (data.isNotEmpty) {
      await Future.forEach(data, (customerResponse) async {
        if (query.id != null)
          if (query.id != customerResponse["id"])
            return;
        if (query.createdAt != null)
          if (query.createdAt != customerResponse["created_at"])
            return;
        if (query.updatedAt != null)
          if (query.updatedAt != customerResponse["updated_at"])
            return;
        if (query.deletedAt != null)
          if (query.deletedAt != customerResponse["deleted_at"])
            return;
        if (query.createdById != null)
          if (query.createdById != customerResponse["created_by_id"])
            return;
        if (query.updatedById != null)
          if (query.updatedById != customerResponse["updated_by_id"])
            return;
        if (query.deletedById != null)
          if (query.deletedById != customerResponse["deleted_by_id"])
            return;
        if (query.name != null)
          if (query.name != customerResponse["name"])
            return;
        if (query.code != null)
          if (query.code != customerResponse["code"])
            return;
        if (query.details != null)
          if (query.details != customerResponse["details"])
            return;

        listOfCustomers.add(new CustomerModel(
          id: customerResponse["id"],
          createdAt: customerResponse["created_at"],
          updatedAt: customerResponse["updated_at"],
          deletedAt: customerResponse["deleted_at"],
          createdById: customerResponse["created_by_id"],
          updatedById: customerResponse["updated_by_id"],
          deletedById: customerResponse["deleted_by_id"],
          name: customerResponse["name"],
          code: customerResponse["code"],
          details: customerResponse["details"],
          pivot: null,
        ));
      });
    }
    return listOfCustomers;
  }

  Future<List<CustomerModel>> ReadCustomersBySyncState(SyncState syncState) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT * FROM "customers" WHERE 
      in_server = ? AND
      updated = ? AND
      deleted = ?
      ''',
      paramsBySyncState[syncState],
    );

    List<CustomerModel> listOfCustomers = new List<CustomerModel>();
    if (data.isNotEmpty) {
      await Future.forEach(data, (customerResponse) async {
        listOfCustomers.add(new CustomerModel(
          id: customerResponse["id"],
          createdAt: customerResponse["created_at"],
          updatedAt: customerResponse["updated_at"],
          deletedAt: customerResponse["deleted_at"],
          createdById: customerResponse["created_by_id"],
          updatedById: customerResponse["updated_by_id"],
          deletedById: customerResponse["deleted_by_id"],
          name: customerResponse["name"],
          code: customerResponse["code"],
          details: customerResponse["details"],
          pivot: null,
        ));
      });
    }
    return listOfCustomers;
  }

  Future<CustomerModel> UpdateCustomer(int customerId, CustomerModel customer, SyncState syncState) async {
    final db = await database;
    await db.rawUpdate(
      '''
      UPDATE "customers" SET
      id = ?,
      created_at = ?,
      updated_at = ?,
      deleted_at = ?,
      created_by_id = ?,
      updated_by_id = ?,
      deleted_by_id = ?,
      name = ?,
      code = ?,
      details = ?,
      in_server = ?,
      updated = ?,
      deleted = ?
      WHERE id = ${customerId}
      ''',
      [...[customer.id, customer.createdAt, customer.updatedAt == null ? DateTime.now().toString() : customer.updatedAt, customer.deletedAt,
    customer.createdById, customer.updatedById, customer.deletedById,
    customer.name, customer.code, customer.details],
    ...paramsBySyncState[syncState]],
    );

    return customer;
  }

  Future<int> DeleteCustomerById(int id) async {
    final db = await database;
    await db.rawDelete('DELETE FROM "customers_users" WHERE customer_id = $id');
    await db.rawDelete('DELETE FROM "customers_contacts" WHERE customer_id = $id');
    await db.rawDelete('DELETE FROM "customers_addresses" WHERE customer_id = $id');
    return await db.rawDelete(
      '''
      DELETE FROM "customers" WHERE id = $id
      '''
    );
  }

  Future<int> ChangeSyncStateCustomer(int id, SyncState syncState) async {
    final db = await database;
    return await db.rawUpdate(
      '''
      UPDATE "customers" SET
      in_server = ?,
      updated = ?,
      deleted = ?
      WHERE id = $id
      ''',
      paramsBySyncState[syncState],
    );
  }

  Future<List<CustomerModel>> ListCustomers() async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
        '''
      SELECT * FROM "customers"
      '''
    );

    List<CustomerModel> listOfCustomers = new List<CustomerModel>();
    if (data.isNotEmpty) {
      await Future.forEach(data, (customerResponse) async {
        listOfCustomers.add(new CustomerModel(
          id: customerResponse["id"],
          createdAt: customerResponse["created_at"],
          updatedAt: customerResponse["updated_at"],
          deletedAt: customerResponse["deleted_at"],
          createdById: customerResponse["created_by_id"],
          updatedById: customerResponse["updated_by_id"],
          deletedById: customerResponse["deleted_by_id"],
          name: customerResponse["name"],
          code: customerResponse["code"],
          details: customerResponse["details"],
          pivot: null,
        ));
      });
    }
    return listOfCustomers;
  }

  Future<List<int>> RetrieveAllCustomerIds() async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
        '''
      SELECT id FROM "customers"
      '''
    );

    List<int> ids = new List<int>();
    if (data.isNotEmpty) {
      data.forEach((customer) => ids.add(customer["id"]));
    }
    
    return ids;
  }

  Future<List<CustomerModel>> RetrieveCustomersByUserToken(String userToken, bool excludeDeleted) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      Select c.* 
      from "customers" as c
      inner join "customers_users" as cu on cu.customer_id = c.id
      inner join "users" as u on cu.user_id = u.id
      WHERE u.remember_token = '$userToken'
      ''' + (excludeDeleted ? " AND c.deleted = 0;" : ';')
    );

    List<CustomerModel> listOfCustomers = new List<CustomerModel>();
    if (data.isNotEmpty) {
      await Future.forEach(data, (customerResponse) async {
        listOfCustomers.add(new CustomerModel(
          id: customerResponse["id"],
          createdAt: customerResponse["created_at"],
          updatedAt: customerResponse["updated_at"],
          deletedAt: customerResponse["deleted_at"],
          createdById: customerResponse["created_by_id"],
          updatedById: customerResponse["updated_by_id"],
          deletedById: customerResponse["deleted_by_id"],
          name: customerResponse["name"],
          code: customerResponse["code"],
          details: customerResponse["details"],
          pivot: null,
        ));
      });
    }
    return listOfCustomers;
  }

  // Operations on tasks
  Future<TaskModel> CreateTask(TaskModel task, SyncState syncState) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT * FROM "tasks" WHERE id = ${task.id}
      '''
    );

    if (data.isNotEmpty)
      return null;

    task.id = await db.rawInsert(
      '''
      INSERT INTO "tasks"(
        id,
        created_at,
        updated_at,
        deleted_at,
        created_by_id,
        updated_by_id,
        deleted_by_id,
        form_id,
        responsible_id,
        customer_id,
        address_id,
        business_id,
        name,
        planning_date,
        checkin_date,
        checkin_latitude,
        checkin_longitude,
        checkin_distance,
        checkout_date,
        checkout_latitude,
        checkout_longitude,
        checkout_distance,
        status,
        in_server,
        updated,
        deleted
      )
        
      VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''',
      [...[task.id, task.createdAt == null ? DateTime.now().toString() : task.createdAt,
      task.updatedAt == null ? DateTime.now().toString() : task.updatedAt, 
      task.deletedAt == null ? task.deletedAt : fixStringDateIfBroken(task.deletedAt),
      task.createdById == null ? (await RetrieveLastLoggedUser()).id : task.createdById,
      task.updatedById == null ? (await RetrieveLastLoggedUser()).id : task.updatedById, 
      task.deletedById, task.formId, task.responsibleId, task.customerId, 
      task.addressId, task.businessId, task.name,
      task.planningDate == null ? task.planningDate : fixStringDateIfBroken(task.planningDate), 
      task.checkinDate == null ? task.checkinDate : fixStringDateIfBroken(task.checkinDate), 
      task.checkinLatitude,
      task.checkinLongitude, task.checkinDistance, 
      task.checkoutDate == null ? task.checkoutDate : fixStringDateIfBroken(task.checkoutDate),
      task.checkoutLatitude, task.checkoutLongitude, task.checkoutDistance,
      task.status == null ? "pending" : task.status], ...paramsBySyncState[syncState]],
    );

    if (task.customValuesMap == null)
      task.customValuesMap = new Map<String, String>();
    if (task.customValues == null)
      task.customValues = new List<CustomValueModel>();

    bool isCustomValueComingFromServer;
    if (task.customValues.length > task.customValuesMap.length) {
      isCustomValueComingFromServer = true;
      task.customValuesMap = new Map<String, String>();
      // for each custom value, create an entry in the map
      task.customValues.forEach((customValue) {
        task.customValuesMap[customValue.fieldId.toString()] = customValue.value;
      });
    } else {
      isCustomValueComingFromServer = false;
      task.customValuesMap.forEach((key, value) {
        task.customValues.add(new CustomValueModel(
          fieldId: int.parse(key.toString()),
          value: value,
        ));
      });
    }

    FormModel formForCustomValue = await DatabaseProvider.db.ReadFormById(task.formId);
    await Future.forEach(task.customValues, (customValue) async {
      if (!isCustomValueComingFromServer) {
        SectionModel foundSection = formForCustomValue.getSectionByFieldId(customValue.fieldId);
        customValue.formId = task.formId;
        customValue.sectionId = foundSection.id;
        customValue.customizableType = "Task";
        customValue.taskId = task.id;
        customValue.customizableId = task.id;

        FieldModel foundField = foundSection.findFieldById(customValue.fieldId);
        if (foundField.fieldType == "Photo" || foundField.fieldType == "CanvanImage" || foundField.fieldType == "CanvanSignature") {
          customValue.imageBase64 = "data:image/jpeg;base64," + customValue.value;
          customValue.value = "/tmp/";
        }
      }

      await DatabaseProvider.db.CreateCustomValue(customValue, syncState);
    });

    // individual items
    if (task.form != null)
      await CreateForm(task.form, syncState);
    if (task.address != null)
      await CreateAddress(task.address, syncState);
    if (task.customer != null)
      await CreateCustomer(task.customer, syncState);
    if (task.responsible != null)
      await CreateResponsible(task.responsible, syncState);

    return task;
  }

  Future<TaskModel> ReadTaskById(int id) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT * FROM "tasks" WHERE id = $id
      '''
    );

    if (data.isNotEmpty) {
      AddressModel address = await ReadAddressById(data.first["address_id"]);
      CustomerModel customer = await ReadCustomerById(data.first["customer_id"]);
      FormModel form = await ReadFormById(data.first["form_id"]);
      ResponsibleModel responsible = await ReadResponsibleById(data.first["responsible_id"]);

      List<CustomValueModel> listOfCustomValues = await DatabaseProvider.db.ListCustomValuesByTask(data.first["id"]);

      return TaskModel(
        id: data.first["id"],
        createdAt: data.first["created_at"],
        updatedAt: data.first["updated_at"],
        deletedAt: data.first["deleted_at"],
        createdById: data.first["created_by_id"],
        updatedById: data.first["updated_by_id"],
        deletedById: data.first["deleted_by_id"],
        formId: data.first["form_id"],
        responsibleId: data.first["responsible_id"],
        customerId: data.first["customer_id"],
        addressId: data.first["address_id"],
        businessId: data.first["business_id"],
        name: data.first["name"],
        planningDate: data.first["planning_date"],
        checkinDate: data.first["checkin_date"],
        checkinLatitude: data.first["checkin_latitude"],
        checkinLongitude: data.first["checkin_longitude"],
        checkinDistance: data.first["checkin_distance"],
        checkoutDate: data.first["checkout_date"],
        checkoutLatitude: data.first["checkout_latitude"],
        checkoutLongitude: data.first["checkout_longitude"],
        checkoutDistance: data.first["checkout_distance"],
        status: data.first["status"],
        address: address,
        customer: customer,
        form: form,
        responsible: responsible,
        customValues: listOfCustomValues,
        customValuesMap: customValuesFromListToMap(listOfCustomValues),
        customSections: null,
      );
    }
    else
      return null;
  }

  // TODO: Parse dates here.
  Future<List<TaskModel>> QueryTaskForService(QueryTasks query) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT * FROM "tasks" WHERE deleted <> 1
      ''',
    );

    List<TaskModel> listOfTasks = new List<TaskModel>();
    if (data.isNotEmpty) {
      await Future.forEach(data, (taskRetrieved) async {
        DateTime date;

        if (taskRetrieved["planning_date"] != null)
          date = DateTime.parse(taskRetrieved["planning_date"]);
        else if (taskRetrieved["created_at"] != null)
          date = DateTime.parse(taskRetrieved["created_at"]);

        if (query.beginDate != null)
          if (date != null)
            if (date.difference(DateTime.parse(fixStringDateIfBroken(query.beginDate))).inMilliseconds < 0)      
              return;
        
        if (query.endDate != null)
          if (date != null)
            if (date.difference(DateTime.parse(fixStringDateIfBroken(query.endDate))).inMilliseconds > 0)
              return;

        if (query.supervisorId != null)
          if (taskRetrieved["supervisor_id"] != query.supervisorId)
            return;

        if (query.responsibleId != null)
          if (taskRetrieved["responsible_id"].toString() != query.responsibleId.toString())
            return;

        if (query.formId != null)
          if (taskRetrieved["form_id"] != query.formId)
            return;
        
        List<CustomValueModel> listOfCustomValues = await DatabaseProvider.db.ListCustomValuesByTask(taskRetrieved["id"]);
        
        FormModel form = await DatabaseProvider.db.ReadFormById(taskRetrieved["form_id"]);
        AddressModel address = await DatabaseProvider.db.ReadAddressById(taskRetrieved["address_id"]);
        CustomerModel customer = await DatabaseProvider.db.ReadCustomerById(taskRetrieved["customer_id"]);
        ResponsibleModel responsible = await DatabaseProvider.db.ReadResponsibleById(taskRetrieved["responsible_id"]);

        listOfTasks.add(new TaskModel(
          id: taskRetrieved["id"],
          createdAt: taskRetrieved["created_at"],
          updatedAt: taskRetrieved["updated_at"],
          deletedAt: taskRetrieved["deleted_at"],
          createdById: taskRetrieved["created_by_id"],
          updatedById: taskRetrieved["updated_by_id"],
          deletedById: taskRetrieved["deleted_by_id"],
          formId: taskRetrieved["form_id"],
          responsibleId: taskRetrieved["responsible_id"],
          customerId: taskRetrieved["customer_id"],
          addressId: taskRetrieved["address_id"],
          businessId: taskRetrieved["business_id"],
          name: taskRetrieved["name"],
          planningDate: taskRetrieved["planning_date"],
          checkinDate: taskRetrieved["checkin_date"],
          checkinLatitude: taskRetrieved["checkin_latitude"],
          checkinLongitude: taskRetrieved["checkin_longitude"],
          checkinDistance: taskRetrieved["checkin_distance"],
          checkoutDate: taskRetrieved["checkout_date"],
          checkoutLatitude: taskRetrieved["checkout_latitude"],
          checkoutLongitude: taskRetrieved["checkout_longitude"],
          checkoutDistance: taskRetrieved["checkout_distance"],
          status: taskRetrieved["status"],
          customSections: new List<CustomSectionModel>(),
          customValues: listOfCustomValues,
          customValuesMap: customValuesFromListToMap(listOfCustomValues),
          form: form,
          address: address,
          customer: customer,
          responsible: responsible,
        ));
      });
    }



    return listOfTasks;
  }

  Future<List<TaskModel>> QueryTask(TaskModel query) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT * FROM "tasks"
      '''
    );

    List<TaskModel> listOfTasks = new List<TaskModel>();
    if (data.isNotEmpty) {
      await Future.forEach(data, (taskRetrieved) async {
        if (query.id != null)
          if (query.id != taskRetrieved["id"])
            return;
        if (query.createdAt != null)
          if (query.createdAt != taskRetrieved["created_at"])
            return;
        if (query.updatedAt != null)
          if (query.updatedAt != taskRetrieved["updated_at"])
            return;
        if (query.deletedAt != null)
          if (query.deletedAt != taskRetrieved["deleted_at"])
            return;
        if (query.createdById != null)
          if (query.createdById != taskRetrieved["created_by_id"])
            return;
        if (query.updatedById != null)
          if (query.updatedById != taskRetrieved["updated_by_id"])
            return;
        if (query.deletedById != null)
          if (query.deletedById != taskRetrieved["deleted_by_id"])
            return;
        if (query.formId != null)
          if (query.formId != taskRetrieved["form_id"])
            return;
        if (query.responsibleId != null)
          if (query.responsibleId != taskRetrieved["responsible_id"])
            return;
        if (query.customerId != null)
          if (query.customerId != taskRetrieved["customer_id"])
            return;
        if (query.addressId != null)
          if (query.addressId != taskRetrieved["address_id"])
            return;
        if (query.businessId != null)
          if (query.businessId != taskRetrieved["business_id"])
            return;
        if (query.name != null)
          if (query.name != taskRetrieved["name"])
            return;
        if (query.planningDate != null)
          if (query.planningDate != taskRetrieved["planning_date"])
            return;
        if (query.checkinDate != null)
          if (query.checkinDate != taskRetrieved["checkin_date"])
            return;
        if (query.checkinLatitude != null)
          if (query.checkinLatitude != taskRetrieved["checkin_latitude"])
            return;
        if (query.checkinLongitude != null)
          if (query.checkinLongitude != taskRetrieved["checkin_longitude"])
            return;
        if (query.checkinDistance != null)
          if (query.checkinDistance != taskRetrieved["checkin_distance"])
            return;
        if (query.checkoutDate != null)
          if (query.checkoutDate != taskRetrieved["checkout_date"])
            return;
        if (query.checkoutLatitude != null)
          if (query.checkoutLatitude != taskRetrieved["checkout_latitude"])
            return;
        if (query.checkoutLongitude != null)
          if (query.checkoutLongitude != taskRetrieved["checkout_longitude"])
            return;
        if (query.checkoutDistance != null)
          if (query.checkoutDistance != taskRetrieved["checkout_distance"])
            return;
        if (query.status != null)
          if (query.status != taskRetrieved["status"])
            return;

        AddressModel address = await ReadAddressById(taskRetrieved["address_id"]);
        CustomerModel customer = await ReadCustomerById(taskRetrieved["customer_id"]);
        FormModel form = await ReadFormById(taskRetrieved["form_id"]);
        ResponsibleModel responsible = await ReadResponsibleById(taskRetrieved["responsible_id"]);

        List<CustomValueModel> listOfCustomValues = await DatabaseProvider.db.ListCustomValuesByTask(taskRetrieved["id"]);

        listOfTasks.add(new TaskModel(
          id: taskRetrieved["id"],
          createdAt: taskRetrieved["created_at"],
          updatedAt: taskRetrieved["updated_at"],
          deletedAt: taskRetrieved["deleted_at"],
          createdById: taskRetrieved["created_by_id"],
          updatedById: taskRetrieved["updated_by_id"],
          deletedById: taskRetrieved["deleted_by_id"],
          formId: taskRetrieved["form_id"],
          responsibleId: taskRetrieved["responsible_id"],
          customerId: taskRetrieved["customer_id"],
          addressId: taskRetrieved["address_id"],
          businessId: taskRetrieved["business_id"],
          name: taskRetrieved["name"],
          planningDate: taskRetrieved["planning_date"],
          checkinDate: taskRetrieved["checkin_date"],
          checkinLatitude: taskRetrieved["checkin_latitude"],
          checkinLongitude: taskRetrieved["checkin_longitude"],
          checkinDistance: taskRetrieved["checkin_distance"],
          checkoutDate: taskRetrieved["checkout_date"],
          checkoutLatitude: taskRetrieved["checkout_latitude"],
          checkoutLongitude: taskRetrieved["checkout_longitude"],
          checkoutDistance: taskRetrieved["checkout_distance"],
          status: taskRetrieved["status"],
          address: address,
          customer: customer,
          form: form,
          responsible: responsible,
          customValues: listOfCustomValues,
          customSections: null,
        ));
      });
    }
    return listOfTasks;
  }

  Future<List<TaskModel>> ReadTasksBySyncState(SyncState syncState) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT * FROM "tasks" WHERE 
      in_server = ? AND
      updated = ? AND
      deleted = ?
      ''',
      paramsBySyncState[syncState],
    );

    List<TaskModel> listOfTasks = new List<TaskModel>();
    if (data.isNotEmpty) {
      await Future.forEach(data, (taskRetrieved) async {
        AddressModel address = await ReadAddressById(taskRetrieved["address_id"]);
        CustomerModel customer = await ReadCustomerById(taskRetrieved["customer_id"]);
        FormModel form = await ReadFormById(taskRetrieved["form_id"]);
        ResponsibleModel responsible = await ReadResponsibleById(taskRetrieved["responsible_id"]);

        List<CustomValueModel> listOfCustomValues = await DatabaseProvider.db.ListCustomValuesByTask(taskRetrieved["id"]);
        listOfTasks.add(new TaskModel(
          id: taskRetrieved["id"],
          createdAt: taskRetrieved["created_at"],
          updatedAt: taskRetrieved["updated_at"],
          deletedAt: taskRetrieved["deleted_at"],
          createdById: taskRetrieved["created_by_id"],
          updatedById: taskRetrieved["updated_by_id"],
          deletedById: taskRetrieved["deleted_by_id"],
          formId: taskRetrieved["form_id"],
          responsibleId: taskRetrieved["responsible_id"],
          customerId: taskRetrieved["customer_id"],
          addressId: taskRetrieved["address_id"],
          businessId: taskRetrieved["business_id"],
          name: taskRetrieved["name"],
          planningDate: taskRetrieved["planning_date"],
          checkinDate: taskRetrieved["checkin_date"],
          checkinLatitude: taskRetrieved["checkin_latitude"],
          checkinLongitude: taskRetrieved["checkin_longitude"],
          checkinDistance: taskRetrieved["checkin_distance"],
          checkoutDate: taskRetrieved["checkout_date"],
          checkoutLatitude: taskRetrieved["checkout_latitude"],
          checkoutLongitude: taskRetrieved["checkout_longitude"],
          checkoutDistance: taskRetrieved["checkout_distance"],
          status: taskRetrieved["status"],
          address: address,
          customer: customer,
          form: form,
          responsible: responsible,
          customValues: listOfCustomValues,
          customValuesMap: customValuesFromListToMap(listOfCustomValues),
          customSections: null,
        ));
      });
    }
    return listOfTasks;
  }

  Future<TaskModel> UpdateTask(int taskId, TaskModel task, SyncState syncState) async {
    final db = await database;
    List<Map<String, dynamic>> data;

    if (task.customValuesMap == null)
      task.customValuesMap = new Map<String, String>();
    if (task.customValues == null)
      task.customValues = new List<CustomValueModel>();

    bool isCustomValueComingFromServer;
    if (task.customValues.length > task.customValuesMap.length) {
      isCustomValueComingFromServer = true;
      task.customValuesMap = new Map<String, String>();
      // for each custom value, create an entry in the map
      task.customValues.forEach((customValue) {
        task.customValuesMap[customValue.fieldId.toString()] = customValue.value;
      });
    } else {
      isCustomValueComingFromServer = false;
      task.updatedAt = DateTime.now().toString();
      task.customValuesMap.forEach((key, value) {
        task.customValues.add(new CustomValueModel(
          fieldId: int.parse(key.toString()),
          value: value,
        ));
      });
    }

    FormModel formForCustomValue = await DatabaseProvider.db.ReadFormById(task.formId);
    await Future.forEach(task.customValues, (customValue) async {
      if (!isCustomValueComingFromServer) {
        SectionModel foundSection = formForCustomValue.getSectionByFieldId(customValue.fieldId);
        customValue.formId = task.formId;
        customValue.sectionId = foundSection.id;
        customValue.customizableType = "Task";
        customValue.taskId = task.id;
        customValue.customizableId = task.id;

        FieldModel foundField = foundSection.findFieldById(customValue.fieldId);
        if (foundField.fieldType == "Photo" || foundField.fieldType == "CanvanImage" || foundField.fieldType == "CanvanSignature") {
          customValue.imageBase64 = "data:image/jpeg;base64," + customValue.value;
          customValue.value = "/tmp/";
        }
      }

      data = await db.rawQuery(
        '''
        SELECT * FROM "custom_values" WHERE id = ${customValue.id}
        '''
      );

      if (data.isNotEmpty)
        await DatabaseProvider.db.UpdateCustomValue(customValue.id, customValue, syncState);
      else
        await DatabaseProvider.db.CreateCustomValue(customValue, syncState);
    });

    if (task.form != null) {
      data = await db.rawQuery('SELECT * FROM "forms" WHERE id = ${task.form.id}');
      if (data.isNotEmpty)
        await UpdateForm(task.form.id, task.form, syncState);
      else
        await CreateForm(task.form, syncState);
    }

    if (task.address != null) {
      data = await db.rawQuery('SELECT * FROM "addresses" WHERE id = ${task.address.id}');
      if (data.isNotEmpty)
        await UpdateAddress(task.address.id, task.address, syncState);
      else
        await CreateAddress(task.address, syncState);
    }

    if (task.customer != null) {
      data = await db.rawQuery('SELECT * FROM "customers" WHERE id = ${task.customer.id}');
      if (data.isNotEmpty)
        await UpdateCustomer(task.customer.id, task.customer, syncState);
      else
        await CreateCustomer(task.customer, syncState);
    }

    if (task.responsible != null) {
      data = await db.rawQuery('SELECT * FROM "responsibles" WHERE id = ${task.responsible.id}');
      if (data.isNotEmpty)
        await UpdateResponsible(task.responsible.id, task.responsible, syncState);
      else
        await CreateResponsible(task.responsible, syncState);
    }

    await db.rawUpdate(
      '''
      UPDATE "tasks" SET
      id = ?,
      created_at = ?,
      updated_at = ?,
      deleted_at = ?,
      created_by_id = ?,
      updated_by_id = ?,
      deleted_by_id = ?,
      form_id = ?,
      responsible_id = ?,
      customer_id = ?,
      address_id = ?,
      business_id = ?,
      name = ?,
      planning_date = ?,
      checkin_date = ?,
      checkin_latitude = ?,
      checkin_longitude = ?,
      checkin_distance = ?,
      checkout_date = ?,
      checkout_latitude = ?,
      checkout_longitude = ?,
      checkout_distance = ?,
      status = ?,
      in_server = ?,
      updated = ?,
      deleted = ?
      WHERE id = ${taskId}
      ''',
        [...[task.id, task.createdAt, task.updatedAt == null ? DateTime.now().toString() : task.updatedAt, task.deletedAt, task.createdById,
    task.updatedById == null ? (await RetrieveLastLoggedUser()).id : task.updatedById,
    task.deletedById, task.formId, task.responsibleId,
    task.customerId, task.addressId, task.businessId, task.name, task.planningDate,
    task.checkinDate, task.checkinLatitude, task.checkinLongitude,
    task.checkinDistance, task.checkoutDate, task.checkoutLatitude,
    task.checkoutLongitude, task.checkoutDistance, task.status],
    ...paramsBySyncState[syncState]],
    );

    return task;
  }

  Future<int> DeleteTaskById(int id) async {
    final db = await database;
    await db.rawDelete('DELETE FROM "custom_values" WHERE task_id = $id');
    var output = await db.rawDelete('DELETE FROM "tasks" WHERE id = $id');
    return output;
  }

  Future<TaskModel> UpdateTaskCheckOut(int id, String longitude, String latitude, String distance, SyncState syncState, {String date}) async {
    final db = await database;
    await db.rawUpdate(
      '''
      UPDATE "tasks" SET
      in_server = ?,
      updated = ?,
      deleted = ?,
      status = "done",
      checkout_longitude = ${longitude},
      checkout_latitude = ${latitude},
      checkout_distance = ${distance}
      ${date != null ? ", checkout_date = ?" : ""}
      
      WHERE id = $id
      ''',
      paramsBySyncState[syncState],
    );

    return await ReadTaskById(id);
  }

  Future<TaskModel> UpdateTaskCheckIn(int id, String longitude, String latitude, String distance, SyncState syncState, {String date}) async {
    final db = await database;
    await db.rawUpdate(
      '''
      UPDATE "tasks" SET
      in_server = ?,
      updated = ?,
      deleted = ?,
      status = "working",
      checkin_longitude = ${longitude},
      checkin_latitude = ${latitude},
      checkin_distance = ${distance}
      ${date != null ? ", checkin_date = ?" : ""}
      
      WHERE id = $id
      ''',
      paramsBySyncState[syncState],
    );

    return await ReadTaskById(id);
  }

  Future<int> ChangeSyncStateTask(int id, SyncState syncState) async {
    final db = await database;
    await db.rawUpdate(
      '''
      UPDATE "tasks" SET
      in_server = ?,
      updated = ?,
      deleted = ?
      WHERE id = $id
      ''',
      paramsBySyncState[syncState],
    );
  }

  Future<List<TaskModel>> ListTasks() async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery('SELECT * from "tasks"');

    List<TaskModel> listOfTasks = new List<TaskModel>();
    if (data.isNotEmpty) {
      await Future.forEach(data, (taskRetrieved) async {
        AddressModel address = await ReadAddressById(taskRetrieved["address_id"]);
        CustomerModel customer = await ReadCustomerById(taskRetrieved["customer_id"]);
        FormModel form = await ReadFormById(taskRetrieved["form_id"]);
        ResponsibleModel responsible = await ReadResponsibleById(taskRetrieved["responsible_id"]);

        List<CustomValueModel> customValues = await QueryCustomValue(CustomValueModel(
          formId: form.id,
        ));

        listOfTasks.add(new TaskModel(
          id: taskRetrieved["id"],
          createdAt: taskRetrieved["created_at"],
          updatedAt: taskRetrieved["updated_at"],
          deletedAt: taskRetrieved["deleted_at"],
          createdById: taskRetrieved["created_by_id"],
          updatedById: taskRetrieved["updated_by_id"],
          deletedById: taskRetrieved["deleted_by_id"],
          formId: taskRetrieved["form_id"],
          responsibleId: taskRetrieved["responsible_id"],
          customerId: taskRetrieved["customer_id"],
          addressId: taskRetrieved["address_id"],
          businessId: taskRetrieved["business_id"],
          name: taskRetrieved["name"],
          planningDate: taskRetrieved["planning_date"],
          checkinDate: taskRetrieved["checkin_date"],
          checkinLatitude: taskRetrieved["checkin_latitude"],
          checkinLongitude: taskRetrieved["checkin_longitude"],
          checkinDistance: taskRetrieved["checkin_distance"],
          checkoutDate: taskRetrieved["checkout_date"],
          checkoutLatitude: taskRetrieved["checkout_latitude"],
          checkoutLongitude: taskRetrieved["checkout_longitude"],
          checkoutDistance: taskRetrieved["checkout_distance"],
          status: taskRetrieved["status"],
          address: address,
          customer: customer,
          form: form,
          responsible: responsible,
          customValues: customValues,
          customValuesMap: customValuesFromListToMap(customValues),
          customSections: null,
        ));
      });
    }
    return listOfTasks;
  }

  Future<List<int>> RetrieveAllTaskIds() async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT id FROM "tasks"
      '''
    );

    List<int> ids = new List<int>();
    if (data.isNotEmpty) {
      data.forEach((task) => ids.add(task["id"]));
    }
    return ids;
  }

  // Operations on custom_users
  Future<int> CreateCustomerUser(int id, String createdAt, String updatedAt,
      String deletedAt, int customerId,
      int userId, SyncState syncState) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT * FROM "customers_users" WHERE id = $id
      '''
    );

    if (data.isNotEmpty)
      return null;

    return await db.rawInsert(
      '''
      INSERT INTO "customers_users"(
        id,
        created_at,
        updated_at,
        deleted_at,
        customer_id,
        user_id,
        in_server,
        updated,
        deleted
      )
      
      VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''',
      [...[id, createdAt, updatedAt == null ? DateTime.now().toString() : updatedAt, deletedAt, customerId, userId],
    ...paramsBySyncState[syncState]],
    );
  }

  Future<Map> ReadCustomerUserById(int id) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
        '''
      SELECT * FROM "customers_users" WHERE id = $id
      '''
    );

    if (data.isNotEmpty) {
      return({
        "id": data.first["id"],
        "created_at": data.first["created_at"],
        "updated_at": data.first["updated_at"],
        "deleted_at": data.first["deleted_at"],
        "customer_id": data.first["customer_id"],
        "user_id": data.first["user_id"],
      });
    }
    else
      return null;
  }

  Future<List<Map>> QueryCustomerUser(int id, String createdAt, String updatedAt,
      String deletedAt, int customerId,
      int userId) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
        '''
      SELECT * FROM "customers_users"
      '''
    );

    List<Map> listOfCustomerUsers = new List<Map>();
    if (data.isNotEmpty) {
      data.forEach((customerUser) {
        if (id != null)
          if (id != customerUser["id"])
            return;
        if (createdAt != null)
          if (createdAt != customerUser["created_at"])
            return;
        if (updatedAt != null)
          if (updatedAt != customerUser["updated_at"])
            return;
        if (deletedAt != null)
          if (deletedAt != customerUser["deleted_at"])
            return;
        if (customerId != null)
          if (customerId != customerUser["customer_id"])
            return;
        if (userId != null)
          if (userId != customerUser["user_id"])
            return;

        listOfCustomerUsers.add({
          "id": customerUser["id"],
          "created_at": customerUser["created_at"],
          "updated_at": customerUser["updated_at"],
          "deleted_at": customerUser["deleted_at"],
          "customer_id": customerUser["customer_id"],
          "user_id": customerUser["user_id"],
        });
      });
    }
    return listOfCustomerUsers;
  }

  Future<List<Map>> ReadCustomerUsersBySyncState(SyncState syncState) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT * FROM "customers_users" WHERE 
      in_server = ? AND
      updated = ? AND
      deleted = ?
      ''',
      paramsBySyncState[syncState],
    );

    List<Map> listOfCustomerUsers = new List<Map>();
    if (data.isNotEmpty) {
      data.forEach((customerUser) {
        listOfCustomerUsers.add({
          "id": customerUser["id"],
          "created_at": customerUser["created_at"],
          "updated_at": customerUser["updated_at"],
          "deleted_at": customerUser["deleted_at"],
          "customer_id": customerUser["customer_id"],
          "user_id": customerUser["user_id"],
        });
      });
    }
    return listOfCustomerUsers;
  }

  Future<int> UpdateCustomerUser(int customerUserId, int id, String createdAt, String updatedAt,
      String deletedAt, int customerId,
      int userId, SyncState syncState) async {
    final db = await database;
    return await db.rawUpdate(
      '''
      UPDATE "customers_users" SET
      id = ?,
      created_at = ?,
      updated_at = ?,
      deleted_at = ?,
      customer_id = ?,
      user_id = ?,
      in_server = ?,
      updated = ?,
      deleted = ?
      WHERE id = $customerUserId
      ''',
      [...[id, createdAt, updatedAt == null ? DateTime.now().toString() : updatedAt, deletedAt, customerId, userId],
    ...paramsBySyncState[syncState]],
    );
  }

  Future<int> DeleteCustomerUserById(int id) async {
    final db = await database;
    return await db.rawDelete(
        '''
      DELETE FROM "customers_users" WHERE id = $id
      '''
    );
  }

  Future<int> ChangeSyncStateCustomerUser(int id, SyncState syncState) async {
    final db = await database;
    return await db.rawUpdate(
      '''
      UPDATE "customers_users" SET
      in_server = ?,
      updated = ?,
      deleted = ?
      WHERE id = $id
      ''',
      paramsBySyncState[syncState],
    );
  }

  Future<List<Map>> ListCustomerUsers() async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
        '''
      SELECT * FROM "customers_users"
      '''
    );

    List<Map> listOfCustomerUsers = new List<Map>();
    if (data.isNotEmpty) {
      data.forEach((customerUser) {
        listOfCustomerUsers.add({
          "id": customerUser["id"],
          "created_at": customerUser["created_at"],
          "updated_at": customerUser["updated_at"],
          "deleted_at": customerUser["deleted_at"],
          "customer_id": customerUser["customer_id"],
          "user_id": customerUser["user_id"],
        });
      });
    }
    return listOfCustomerUsers;
  }

  // Operations on custom_values
  Future<int> CreateCustomValue(CustomValueModel customValue, SyncState syncState) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery('SELECT * FROM "custom_values" WHERE id = ${customValue.id}');

    if (data.isNotEmpty)
      return null;

    if (customValue.field != null) {
      await CreateField(new FieldModel(
        id: customValue.field.id,
        createdAt: customValue.field.createdAt,
        entityId: customValue.field.entityId,
        sectionId: customValue.field.sectionId,
        name: customValue.field.name,
        deletedById: customValue.field.deletedById,
        updatedById: customValue.field.updatedById,
        createdById: customValue.field.createdById,
        deletedAt: customValue.field.deletedAt,
        code: customValue.field.code,
        entityType: customValue.field.entityType,
        fieldCollection: customValue.field.fieldCollection,
        fieldDefaultValue: customValue.field.fieldDefaultValue,
        fieldOptions: customValue.field.fieldOptions,
        fieldPlaceholder: customValue.field.fieldPlaceholder,
        fieldRequired: customValue.field.fieldRequired,
        fieldType: customValue.field.fieldType,
        fieldWidth: customValue.field.fieldWidth,
        position: customValue.field.position,
        subtitle: customValue.field.subtitle,
        type: customValue.field.type,
        updatedAt: customValue.field.updatedAt,
      ), syncState);
    }

    var customValueCreated = await db.rawInsert(
      '''
      INSERT INTO "custom_values"(
        id,
        created_at,
        updated_at,
        form_id,
        section_id,
        field_id,
        customizable_type,
        customizable_id,
        value,
        image_base64,
        task_id,
        in_server,
        updated,
        deleted  
      )
        
      VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''',
      [...[customValue.id, customValue.createdAt == null ? DateTime.now().toString() : customValue.createdAt,
      customValue.updatedAt == null ? DateTime.now().toString() : customValue.updatedAt,
      customValue.formId, customValue.sectionId, customValue.fieldId,
      customValue.customizableType, customValue.customizableId,
      customValue.value, customValue.imageBase64, customValue.taskId == null ? customValue.customizableId : customValue.taskId], ...paramsBySyncState[syncState]],
    );

    return customValueCreated;
  }

  Future<List<CustomValueModel>> ListCustomValuesByTask(int id) async {
    final db = await database;
    List<Map<String, dynamic>> data;

    data = await db.rawQuery('SELECT * FROM "custom_values" WHERE task_id = $id');

    List<CustomValueModel> listOfCustomValues = List<CustomValueModel>();

    if (data.isNotEmpty) {
      await Future.forEach(data, (customValue) async {
        var fieldId = customValue["field_id"];
        FieldModel field = await ReadFieldById(fieldId);

        listOfCustomValues.add(new CustomValueModel(
          id: customValue["id"],
          createdAt: customValue["created_at"],
          updatedAt: customValue["updated_at"],
          formId: customValue["form_id"],
          sectionId: customValue["section_id"],
          fieldId: customValue["field_id"],
          customizableType: customValue["customizable_type"],
          customizableId: customValue["customizable_id"],
          value: customValue["value"],
          imageBase64: customValue["image_base64"],
          field: field,
        ));
      });
    }

    return listOfCustomValues;
  }

  Future<List<int>> ListCustomValueIdsByTask(int id) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery('SELECT id FROM "custom_values" WHERE task_id = $id');

    List<int> listOfCustomValueIds = List<int>();
    if (data.isNotEmpty) {
      data.forEach((data) {
        listOfCustomValueIds.add(data["id"]);
      });
    }

    return listOfCustomValueIds;
  }

  Future<CustomValueModel> ReadCustomValueById(int id) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
        '''
      SELECT * FROM "custom_values" WHERE id = $id
      '''
    );

    if (data.isNotEmpty) {
      FieldModel customField = await ReadFieldById(data.first["field_id"]);
      FieldModel field = FieldModel(
        id: customField.id,
        createdAt: customField.createdAt,
        entityId: customField.entityId,
        sectionId: customField.sectionId,
        name: customField.name,
        deletedById: customField.deletedById,
        updatedById: customField.updatedById,
        createdById: customField.createdById,
        deletedAt: customField.deletedAt,
        code: customField.code,
        entityType: customField.entityType,
        fieldCollection: customField.fieldCollection,
        fieldDefaultValue: customField.fieldDefaultValue,
        fieldOptions: customField.fieldOptions,
        fieldPlaceholder: customField.fieldPlaceholder,
        fieldRequired: customField.fieldRequired,
        fieldType: customField.fieldType,
        fieldWidth: customField.fieldWidth,
        position: customField.position,
        subtitle: customField.subtitle,
        type: customField.type,
        updatedAt: customField.updatedAt,
      );

      return CustomValueModel(
        id: data.first["id"],
        createdAt: data.first["created_at"],
        updatedAt: data.first["updated_at"],
        formId: data.first["form_id"],
        taskId: data.first["task_id"],
        sectionId: data.first["section_id"],
        fieldId: data.first["field_id"],
        customizableType: data.first["customizable_type"],
        customizableId: data.first["customizable_id"],
        value: data.first["value"],
        imageBase64: data.first["image_base64"],
        field: field,
      );
    }
    else
      return null;
  }

  Future<List<CustomValueModel>> QueryCustomValue(CustomValueModel query) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
        '''
      SELECT * FROM "custom_values"
      '''
    );

    List<CustomValueModel> listOfCustomValues = new List<CustomValueModel>();
    if (data.isNotEmpty) {
      await Future.forEach(data, (customValueRetrieved) async {
        if (query.id != null)
          if (query.id != customValueRetrieved["id"])
            return;
        if (query.createdAt != null)
          if (query.createdAt != customValueRetrieved["created_at"])
            return;
        if (query.updatedAt != null)
          if (query.updatedAt != customValueRetrieved["updated_at"])
            return;
        if (query.formId != null)
          if (query.formId != customValueRetrieved["form_id"])
            return;
        if (query.sectionId != null)
          if (query.sectionId != customValueRetrieved["section_id"])
            return;
        if (query.fieldId != null)
          if (query.fieldId != customValueRetrieved["field_id"])
            return;
        if (query.customizableType != null)
          if (query.customizableType != customValueRetrieved["customizable_type"])
            return;
        if (query.customizableId != null)
          if (query.customizableId != customValueRetrieved["customizable_id"])
            return;
        if (query.value != null)
          if (query.value != customValueRetrieved["value"])
            return;
        if (query.imageBase64 != null)
          if (query.imageBase64 != customValueRetrieved["image_base64"])
            return;

        FieldModel field = await ReadFieldById(customValueRetrieved["field_id"]);

        listOfCustomValues.add(new CustomValueModel(
          id: customValueRetrieved["id"],
          createdAt: customValueRetrieved["created_at"],
          updatedAt: customValueRetrieved["updated_at"],
          formId: customValueRetrieved["form_id"],
          sectionId: customValueRetrieved["section_id"],
          fieldId: customValueRetrieved["field_id"],
          customizableType: customValueRetrieved["customizable_type"],
          customizableId: customValueRetrieved["customizable_id"],
          value: customValueRetrieved["value"],
          taskId: customValueRetrieved["task_id"],
          imageBase64: customValueRetrieved["image_base64"],
          field: field,
        ));
      });
    }

    return listOfCustomValues;
  }

  Future<List<CustomValueModel>> ReadCustomValuesBySyncState(SyncState syncState) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT * FROM "custom_values" WHERE 
      in_server = ? AND
      updated = ? AND
      deleted = ?
      ''',
      paramsBySyncState[syncState],
    );

    List<CustomValueModel> listOfCustomValues = new List<CustomValueModel>();
    if (data.isNotEmpty) {
      await Future.forEach(data, (customValueRetrieved) async {
        FieldModel field = await ReadFieldById(customValueRetrieved["field_id"]);

        listOfCustomValues.add(new CustomValueModel(
          id: customValueRetrieved["id"],
          createdAt: customValueRetrieved["created_at"],
          updatedAt: customValueRetrieved["updated_at"],
          formId: customValueRetrieved["form_id"],
          sectionId: customValueRetrieved["section_id"],
          taskId: customValueRetrieved["task_id"],
          fieldId: customValueRetrieved["field_id"],
          customizableType: customValueRetrieved["customizable_type"],
          customizableId: customValueRetrieved["customizable_id"],
          value: customValueRetrieved["value"],
          imageBase64: customValueRetrieved["image_base64"],
          field: field,
        ));
      });
    }

    return listOfCustomValues;
  }

  Future<int> UpdateCustomValue(int customValueId, CustomValueModel customValue, SyncState syncState) async {
    final db = await database;

    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
        '''
      SELECT * FROM "custom_fields" WHERE id = ${customValue.field.id}
      '''
    );

    if (data.isNotEmpty)
      await UpdateField(
        customValue.field.id,
        FieldModel(
          id: customValue.field.id,
          createdAt: customValue.field.createdAt,
          entityId: customValue.field.entityId,
          sectionId: customValue.field.sectionId,
          name: customValue.field.name,
          deletedById: customValue.field.deletedById,
          updatedById: customValue.field.updatedById,
          createdById: customValue.field.createdById,
          deletedAt: customValue.field.deletedAt,
          code: customValue.field.code,
          entityType: customValue.field.entityType,
          fieldCollection: customValue.field.fieldCollection,
          fieldDefaultValue: customValue.field.fieldDefaultValue,
          fieldOptions: customValue.field.fieldOptions,
          fieldPlaceholder: customValue.field.fieldPlaceholder,
          fieldRequired: customValue.field.fieldRequired,
          fieldType: customValue.field.fieldType,
          fieldWidth: customValue.field.fieldWidth,
          position: customValue.field.position,
          subtitle: customValue.field.subtitle,
          type: customValue.field.type,
          updatedAt: customValue.field.updatedAt,
        ),
        syncState
      );
    else
      await CreateField(
        FieldModel(
          id: customValue.field.id,
          createdAt: customValue.field.createdAt,
          entityId: customValue.field.entityId,
          sectionId: customValue.field.sectionId,
          name: customValue.field.name,
          deletedById: customValue.field.deletedById,
          updatedById: customValue.field.updatedById,
          createdById: customValue.field.createdById,
          deletedAt: customValue.field.deletedAt,
          code: customValue.field.code,
          entityType: customValue.field.entityType,
          fieldCollection: customValue.field.fieldCollection,
          fieldDefaultValue: customValue.field.fieldDefaultValue,
          fieldOptions: customValue.field.fieldOptions,
          fieldPlaceholder: customValue.field.fieldPlaceholder,
          fieldRequired: customValue.field.fieldRequired,
          fieldType: customValue.field.fieldType,
          fieldWidth: customValue.field.fieldWidth,
          position: customValue.field.position,
          subtitle: customValue.field.subtitle,
          type: customValue.field.type,
          updatedAt: customValue.field.updatedAt
        ),
        syncState
      );

    return await db.rawUpdate(
      '''
      UPDATE "custom_values" SET
      id = ?,
      created_at = ?,
      updated_at = ?,
      form_id = ?,
      section_id = ?,
      field_id = ?,
      customizable_type = ?,
      customizable_id = ?,
      value = ?,
      image_base64 = ?,
      task_id = ?,
      in_server = ?,
      updated = ?,
      deleted = ? 
      WHERE id = ${customValueId}
      ''',
      [...[customValue.id, customValue.createdAt, customValue.updatedAt == null ? DateTime.now().toString() : customValue.updatedAt, customValue.formId,
    customValue.sectionId, customValue.fieldId,
    customValue.customizableType, customValue.customizableId,
    customValue.value, customValue.imageBase64, customValue.taskId], ...paramsBySyncState[syncState]],
    );
  }

  Future<int> DeleteCustomValueById(int id) async {
    final db = await database;
    return await db.rawDelete(
      '''
      DELETE FROM "custom_values" WHERE id = $id
      '''
    );
  }

  Future<int> ChangeSyncStateCustomValue(int id, SyncState syncState) async {
    final db = await database;
    return await db.rawUpdate(
      '''
      UPDATE "custom_values" SET
      in_server = ?,
      updated = ?,
      deleted = ?
      WHERE id = $id
      ''',
      paramsBySyncState[syncState],
    );
  }

  Future<List<CustomValueModel>> ListCustomValues() async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT * FROM "custom_values"
      '''
    );

    List<CustomValueModel> listOfCustomValues = new List<CustomValueModel>();
    if (data.isNotEmpty) {
      await Future.forEach(data, (customValueRetrieved) async {
        FieldModel field = await ReadFieldById(customValueRetrieved["field_id"]);

        listOfCustomValues.add(new CustomValueModel(
          id: customValueRetrieved["id"],
          createdAt: customValueRetrieved["created_at"],
          updatedAt: customValueRetrieved["updated_at"],
          formId: customValueRetrieved["form_id"],
          sectionId: customValueRetrieved["section_id"],
          fieldId: customValueRetrieved["field_id"],
          customizableType: customValueRetrieved["customizable_type"],
          customizableId: customValueRetrieved["customizable_id"],
          value: customValueRetrieved["value"],
          imageBase64: customValueRetrieved["image_base64"],
          field: field,
          taskId: customValueRetrieved["task_id"],
        ));
      });
    }

    return listOfCustomValues;
  }

  // Operations on customers_addresses
  Future<int> CreateCustomerAddress(int id, String createdAt,
      String updatedAt, String deletedAt,
      int customerId, int addressId,
      bool approved, SyncState syncState) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
        '''
      SELECT * FROM "customers_addresses" WHERE id = $id
      '''
    );

    if (data.isNotEmpty)
      return null;

    return await db.rawInsert(
      '''
      INSERT INTO "customers_addresses"(
        id,
        created_at,
        updated_at,
        deleted_at,
        customer_id,
        address_id,
        approved,
        in_server,
        updated,
        deleted
      )
      
      VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''',
      [...[id, createdAt, updatedAt == null ? DateTime.now().toString() : updatedAt, deletedAt, customerId, addressId,
    approved], ...paramsBySyncState[syncState]],
    );
  }

  Future<Map> ReadCustomerAddressById(int id) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
        '''
      SELECT * FROM "customers_addresses" WHERE id = $id
      '''
    );

    if (data.isNotEmpty) {
      return({
        "id": data.first["id"],
        "created_at": data.first["created_at"],
        "updated_at": data.first["updated_at"],
        "deleted_at": data.first["deleted_at"],
        "customer_id": data.first["customer_id"],
        "address_id": data.first["address_id"],
        "approved": data.first["approved"],
      });
    }
    else
      return null;
  }

  Future<List<Map>> QueryCustomerAddress(int id, String createdAt,
      String updatedAt, String deletedAt,
      int customerId, int addressId,
      bool approved,
      SyncState syncState) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
        '''
      SELECT * FROM "customers_addresses"
      '''
    );

    List<Map> listOfCustomerAddresses = new List<Map>();
    if (data.isNotEmpty) {
      data.forEach((customerAddressRetrieved) {
        if (id != null)
          if (id != customerAddressRetrieved["id"])
            return;
        if (createdAt != null)
          if (createdAt != customerAddressRetrieved["created_at"])
            return;
        if (updatedAt != null)
          if (updatedAt != customerAddressRetrieved["updated_at"])
            return;
        if (deletedAt != null)
          if (deletedAt != customerAddressRetrieved["deleted_at"])
            return;
        if (customerId != null)
          if (customerId != customerAddressRetrieved["customer_id"])
            return;
        if (addressId != null)
          if (addressId != customerAddressRetrieved["address_id"])
            return;
        if (approved != null)
          if (approved != customerAddressRetrieved["approved"])
            return;

        listOfCustomerAddresses.add({
          "id": customerAddressRetrieved["id"],
          "created_at": customerAddressRetrieved["created_at"],
          "updated_at": customerAddressRetrieved["updated_at"],
          "deleted_at": customerAddressRetrieved["deleted_at"],
          "customer_id": customerAddressRetrieved["customer_id"],
          "address_id": customerAddressRetrieved["address_id"],
          "approved": customerAddressRetrieved["approved"],
        });
      });
    }
    return listOfCustomerAddresses;
  }

  Future<List<Map>> ReadCustomerAddressesBySyncState(SyncState syncState) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT * FROM "customers_addresses" WHERE 
      in_server = ? AND
      updated = ? AND
      deleted = ?
      ''',
      paramsBySyncState[syncState],
    );

    List<Map> listOfCustomerAddresses = new List<Map>();
    if (data.isNotEmpty) {
      data.forEach((customerAddressRetrieved) {
        listOfCustomerAddresses.add({
          "id": customerAddressRetrieved["id"],
          "created_at": customerAddressRetrieved["created_at"],
          "updated_at": customerAddressRetrieved["updated_at"],
          "deleted_at": customerAddressRetrieved["deleted_at"],
          "customer_id": customerAddressRetrieved["customer_id"],
          "address_id": customerAddressRetrieved["address_id"],
          "approved": customerAddressRetrieved["approved"],
        });
      });
    }
    return listOfCustomerAddresses;
  }

  Future<int> UpdateCustomerAddress(int id, String createdAt,
      String updatedAt, String deletedAt,
      int customerId, int addressId,
      bool approved, SyncState syncState) async {
    final db = await database;
    return await db.rawUpdate(
      '''
      UPDATE "customers_addresses" SET
      id = ?,
      created_at = ?,
      updated_at = ?,
      deleted_at = ?,
      customer_id = ?,
      address_id = ?,
      approved = ?,
      in_server = ?,
      updated = ?,
      deleted = ?
      WHERE customer_id = $customerId AND address_id = $addressId
      ''',
      [...[id, createdAt, updatedAt == null ? DateTime.now().toString() : updatedAt, deletedAt, customerId, addressId,
    approved], ...paramsBySyncState[syncState]],
    );
  }

  Future<int> DeleteCustomerAddressById(int customerId, addressId) async {
    final db = await database;
    return await db.rawDelete(
        '''
      DELETE FROM "customers_addresses" WHERE customer_id = $customerId AND address_id = $addressId
      '''
    );
  }

  Future<int> ChangeSyncStateCustomerAddress(int customerId, int addressId, SyncState syncState) async {
    final db = await database;
    return await db.rawUpdate(
      '''
      UPDATE "customers_addresses" SET
      in_server = ?,
      updated = ?,
      deleted = ?
      WHERE customer_id = $customerId AND address_id = $addressId
      ''',
      paramsBySyncState[syncState],
    );
  }

  Future<List<Map>> ListCustomerAddresses() async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT * FROM "customers_addresses"
      '''
    );

    List<Map> listOfCustomerAddresses = new List<Map>();
    if (data.isNotEmpty) {
      data.forEach((customerAddressRetrieved) {
        listOfCustomerAddresses.add({
          "id": customerAddressRetrieved["id"],
          "created_at": customerAddressRetrieved["created_at"],
          "updated_at": customerAddressRetrieved["updated_at"],
          "deleted_at": customerAddressRetrieved["deleted_at"],
          "customer_id": customerAddressRetrieved["customer_id"],
          "address_id": customerAddressRetrieved["address_id"],
          "approved": customerAddressRetrieved["approved"],
        });
      });
    }
    return listOfCustomerAddresses;
  }

  Future<List<String>> RetrieveAllCustomerAddressRelations() async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT customer_id, address_id FROM "customers_addresses"
      '''
    );

    List<String> relations = new List<String>();
    if (data.isNotEmpty) 
      data.forEach((relation) => relations.add(
          relation["customer_id"].toString() + "-" + relation["address_id"].toString()
      ));
    return relations;
  }

  Future<List<CustomerWithAddressModel>> RetrieveCustomersWithAddressByUserToken(String userToken, bool excludeDeleted) async {
    final db = await database;
    List<Map<String, dynamic>> data;

    data = await db.rawQuery(
      '''
      SELECT DISTINCT c.*, a.address, a.reference, a.longitude, a.latitude, a.locality_id, a.google_place_id, a.country, a.state, a.city, a.contact_phone, a.contact_mobile, a.contact_email, ca.address_id, ca.approved, ca.customer_id
      from customers as c
      inner join customers_users as cu on cu.customer_id = c.id
      inner join users as u on cu.user_id = u.id
      left join customers_addresses as ca on ca.customer_id = c.id
      left join addresses as a on a.id = ca.address_id
      WHERE u.remember_token = '$userToken'
      ''' + (excludeDeleted ? " AND c.deleted = 0 AND ca.deleted = 0;" : ';')
    );

    List<CustomerWithAddressModel> listOfCustomersWithAddresses = new List<CustomerWithAddressModel>();
    if (data.isNotEmpty) {
      await Future.forEach(data, (customerWithAddressResponse) async {
        listOfCustomersWithAddresses.add(new CustomerWithAddressModel(
          id: customerWithAddressResponse["id"],
          createdAt: customerWithAddressResponse["created_at"],
          updatedAt: customerWithAddressResponse["updated_at"],
          deletedAt: customerWithAddressResponse["deleted_at"],
          createdById: customerWithAddressResponse["created_by_id"],
          updatedById: customerWithAddressResponse["updated_by_id"],
          deletedById: customerWithAddressResponse["deleted_by_id"],
          name: customerWithAddressResponse["name"],
          code: customerWithAddressResponse["code"],
          contactName: customerWithAddressResponse["contact_name"],
          details: customerWithAddressResponse["details"],
          address: customerWithAddressResponse["address"],
          locality: customerWithAddressResponse["locality"],
          reference: customerWithAddressResponse["reference"],
          longitude: customerWithAddressResponse["longitude"],
          latitude: customerWithAddressResponse["latitude"],
          localityId: customerWithAddressResponse["locality_id"],
          googlePlaceId: customerWithAddressResponse["google_place_id"],
          country: customerWithAddressResponse["country"],
          state: customerWithAddressResponse["state"],
          city: customerWithAddressResponse["city"],
          contactPhone: customerWithAddressResponse["contact_phone"],
          contactMobile: customerWithAddressResponse["contact_mobile"],
          contactEmail: customerWithAddressResponse["contact_email"],
          addressId: customerWithAddressResponse["address_id"],
          approved: customerWithAddressResponse["approved"],
          customerId: customerWithAddressResponse["customer_id"],
        ));
      });
    }

    data = await db.rawQuery(
        '''
      SELECT DISTINCT c.*
      from customers as c
      inner join customers_users as cu on cu.customer_id = c.id
      inner join users as u on cu.user_id = u.id
      WHERE u.remember_token = '$userToken'
      ''' + (excludeDeleted ? " AND c.deleted = 0;" : ';')
    );

    data.toList().forEach((customerWithAddressResponse){
      bool flag = true;

      listOfCustomersWithAddresses.forEach((customer){
        if(customerWithAddressResponse['id'] == customer.id){
          flag = false;
        }
      });

      if (flag) {
        listOfCustomersWithAddresses.add(new CustomerWithAddressModel(
          id: customerWithAddressResponse["id"],
          createdAt: customerWithAddressResponse["created_at"],
          updatedAt: customerWithAddressResponse["updated_at"],
          deletedAt: customerWithAddressResponse["deleted_at"],
          createdById: customerWithAddressResponse["created_by_id"],
          updatedById: customerWithAddressResponse["updated_by_id"],
          deletedById: customerWithAddressResponse["deleted_by_id"],
          name: customerWithAddressResponse["name"],
          code: customerWithAddressResponse["code"],
          contactName: customerWithAddressResponse["contact_name"],
          details: customerWithAddressResponse["details"],
        ));
      }

    });


    return listOfCustomersWithAddresses;
  }

  Future<List<AddressModel>> RetrieveAddressModelByCustomerId(int customerId, bool excludeDeleted) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT a.*
      from "addresses" as a
      inner join "customers_addresses" as ca on ca.address_id = a.id
      WHERE ca.customer_id = $customerId
      ''' + (excludeDeleted ? " AND ca.deleted = 0;" : ';')
    );

    List<AddressModel> listOfAddressModels = new List<AddressModel>();
    if (data.isNotEmpty) {
      await Future.forEach(data, (addressResponse) async {
        listOfAddressModels.add(new AddressModel(
          id: addressResponse["id"],
          createdAt: addressResponse["created_at"],
          updatedAt: addressResponse["updated_at"],
          deletedAt: addressResponse["deleted_at"],
          createdById: addressResponse["created_by_id"],
          updatedById: addressResponse["updated_by_id"],
          deletedById: addressResponse["deleted_by_id"],
          contactName: addressResponse["contact_name"],
          details: addressResponse["details"],
          address: addressResponse["address"],
          locality: addressResponse["locality"],
          reference: addressResponse["reference"],
          longitude: addressResponse["longitude"],
          latitude: addressResponse["latitude"],
          localityId: addressResponse["locality_id"],
          googlePlaceId: addressResponse["google_place_id"],
          country: addressResponse["country"],
          state: addressResponse["state"],
          city: addressResponse["city"],
          contactPhone: addressResponse["contact_phone"],
          contactMobile: addressResponse["contact_mobile"],
          contactEmail: addressResponse["contact_email"],
        ));
      });
    }
    return listOfAddressModels;
  }

  Future<List<ContactModel>> RetrieveContactModelByCustomerId (int customerId, bool excludeDeleted) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT co.*
      from "contacts" as co
      inner join "customers_contacts" as cc on cc.contact_id = co.id
      WHERE cc.customer_id = $customerId
      ''' + (excludeDeleted ? " AND cc.deleted = 0;" : ';')
    );

    List<ContactModel> listOfContacts = new List<ContactModel>();
    if (data.isNotEmpty) {
      await Future.forEach(data, (contact) async {
        listOfContacts.add(new ContactModel(
          id: contact["id"],
          createdAt: contact["created_at"],
          updatedAt: contact["updated_at"],
          deletedAt: contact["deleted_at"],
          createdById: contact["created_by_id"],
          updatedById: contact["updated_by_id"],
          deletedById: contact["deleted_by_id"],
          customerId: contact["customer_id"],
          customer: contact["customer"],
          code: contact["code"],
          name: contact["name"],
          phone: contact["phone"],
          email: contact["email"],
          details: contact["details"],
        ));
      });
    }
    return listOfContacts;
  }

  Future<ContactModel> CreateContact (ContactModel contact, SyncState syncState) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery('SELECT * FROM "contacts" WHERE id = ${contact.id}');

    if (data.isNotEmpty)
      return null;
    
    contact.id = await db.rawInsert(
      '''
      INSERT INTO "contacts" (
        id,
        created_at,
        updated_at,
        deleted_at,
        created_by_id,
        updated_by_id,
        deleted_by_id,
        name,
        code,
        phone,
        email,
        details,
        in_server,
        updated,
        deleted
      )

      VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''',
      [...[contact.id, contact.createdAt, contact.updatedAt,
      contact.deletedAt, contact.createdById, contact.updatedById,
      contact.deletedById, contact.name, contact.code, contact.phone,
      contact.email, contact.details], ...paramsBySyncState[syncState]],
    );

    return contact;
  }

  Future<int> CreateCustomerContact(int id, String createdAt, String updatedAt,
                                     String deletedAt, int customerId,
                                     int contactId, SyncState syncState) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT * FROM "customers_contacts" WHERE id = $id
      '''
    );

    if (data.isNotEmpty)
      return null;

    return await db.rawInsert(
      '''
      INSERT INTO "customers_contacts"(
        id,
        created_at,
        updated_at,
        deleted_at,
        customer_id,
        contact_id,
        in_server,
        updated,
        deleted
      )
      
      VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''',
      [...[id, createdAt, updatedAt == null ? DateTime.now().toString() : updatedAt, deletedAt, customerId, contactId],
    ...paramsBySyncState[syncState]],
    );
  }

  Future<ContactModel> UpdateContact (int id, ContactModel contact, SyncState syncState) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery('SELECT * FROM "contacts" WHERE id = $id');

    if (data.isEmpty)
      contact = await CreateContact(contact, syncState);
    else {
      await db.rawUpdate(
        '''
        UPDATE "contacts" SET
        id = ?,
        created_at = ?,
        updated_at = ?,
        deleted_at = ?,
        created_by_id = ?,
        updated_by_id = ?,
        deleted_by_id = ?,
        name = ?,
        code = ?,
        phone = ?,
        email = ?,
        details = ?,
        in_server = ?,
        updated = ?,
        deleted = ?
        WHERE id = $id
        ''',
        [...[contact.id, contact.createdAt, contact.updatedAt,
        contact.deletedAt, contact.createdById, contact.updatedById,
        contact.deletedById, contact.name, contact.code, contact.phone,
        contact.email, contact.details], ...paramsBySyncState[syncState]],
      );
    }

    return contact;
      
  }

  Future<int> ChangeSyncStateContact (int id, SyncState syncState) async {
    final db = await database;
    return await db.rawUpdate(
      '''
      UPDATE "contacts" SET
      in_server = ?,
      updated = ?,
      deleted = ?
      WHERE id = $id
      ''', 
      paramsBySyncState[syncState],
    );
  }

  Future<int> DeleteContactById (int id) async {
    final db = await database;
    await db.rawDelete('DELETE FROM "customers_contacts" WHERE contact_id = $id');
    return await db.rawDelete(
      '''
      DELETE FROM "contacts" WHERE id = $id
      '''
    );
  }

  Future<int> ChangeSyncStateCustomerContact(int customerId, int contactId, SyncState syncState) async {
    final db = await database;
    return await db.rawUpdate(
      '''
      UPDATE "customers_contacts" SET
      in_server = ?,
      updated = ?,
      deleted = ?
      WHERE 
      customer_id = $customerId AND
      contact_id = $contactId
      ''', 
      paramsBySyncState[syncState],
    );
  }

  Future<int> DeleteCustomerContactById(int customerId, int contactId) async {
    final db = await database;
    return await db.rawDelete(
      '''
      DELETE FROM "customers_contacts" WHERE customer_id = $customerId AND contact_id = $contactId
      '''
    );
  }

  Future<List<ContactModel>> RetrieveContactsByUserToken (String userToken, bool excludeDeleted) async {
    final db = await database;
    List<Map<String, dynamic>> data;

    data = await db.rawQuery(
        '''
      SELECT DISTINCT c.*, cu.name as customer, cu.id as customer_id, cc.deleted as customer_contact_deleted
      from "contacts" as c
      left join "customers_contacts" as cc on cc.contact_id = c.id
      left join "customers" as cu on cc.customer_id = cu.id
      inner join "users" as u on c.created_by_id = u.id
      WHERE u.remember_token = '$userToken'
      ''' + (excludeDeleted ? " AND c.deleted = 0 AND cu.deleted = 0 AND cc.deleted = 0;" : ';')
    );

    List<ContactModel> listOfContacts = new List<ContactModel>();

    if (data.isNotEmpty) {
      await Future.forEach(data, (contact) async {
        bool flag = true;
        int idCustomer = contact["customer_id"];
        int idContact = contact["id"];

        if(idCustomer == null) {
          data.toList().forEach((c){
            if(c["id"]==idContact && c["customer_id"] != null){
              flag = false;
            }
          });
        }

        if (flag) {
          listOfContacts.add(new ContactModel(
            id: contact["id"],
            createdAt: contact["created_at"],
            updatedAt: contact["updated_at"],
            deletedAt: contact["deleted_at"],
            createdById: contact["created_by_id"],
            updatedById: contact["updated_by_id"],
            deletedById: contact["deleted_by_id"],
            customerId: contact["customer_id"],
            customer: contact["customer"],
            code: contact["code"],
            name: contact["name"],
            phone: contact["phone"],
            email: contact["email"],
            details: contact["details"],
          ));
        }
      });
    }

    data = await db.rawQuery(
        '''
      SELECT DISTINCT c.*
      from "contacts" as c
      inner join "users" as u on c.created_by_id = u.id
      WHERE u.remember_token = '$userToken'
      ''' + (excludeDeleted ? " AND c.deleted = 0;" : ';')
    );

    data.toList().forEach((contactOutList){
      bool flag = true;

      listOfContacts.forEach((contactInList){
        if (contactOutList['id']==contactInList.id){
          flag = false;
        }
      });

      if (flag) {
        listOfContacts.add(new ContactModel(
          id: contactOutList["id"],
          createdAt: contactOutList["created_at"],
          updatedAt: contactOutList["updated_at"],
          deletedAt: contactOutList["deleted_at"],
          createdById: contactOutList["created_by_id"],
          updatedById: contactOutList["updated_by_id"],
          deletedById: contactOutList["deleted_by_id"],
          customerId: contactOutList["customer_id"],
          customer: contactOutList["customer"],
          code: contactOutList["code"],
          name: contactOutList["name"],
          phone: contactOutList["phone"],
          email: contactOutList["email"],
          details: contactOutList["details"],
        ));
      }


    });

    return listOfContacts;
  }
  
  Future<ContactModel> ReadContactById (int id) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT * FROM "contacts" WHERE id = $id
      '''
    );

    ContactModel contact;
    if (data.isNotEmpty)
      contact = new ContactModel(
        id: data.first["id"],
        createdAt: data.first["created_at"],
        updatedAt: data.first["updated_at"],
        deletedAt: data.first["deleted_at"],
        createdById: data.first["created_by_id"],
        updatedById: data.first["updated_by_id"],
        deletedById: data.first["deleted_by_id"],
        customerId: data.first["customer_id"],
        customer: data.first["customer"],
        code: data.first["code"],
        name: data.first["name"],
        phone: data.first["phone"],
        email: data.first["email"],
        details: data.first["details"],
      );
    return contact;
  }

  Future<List<ContactModel>> ReadContactsBySyncState(SyncState syncState) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT * FROM "customers" WHERE 
      in_server = ? AND
      updated = ? AND
      deleted = ?
      ''',
      paramsBySyncState[syncState],
    );

    List<ContactModel> listOfContacts = new List<ContactModel>();
    if (data.isNotEmpty) {
      await Future.forEach(data, (contact) async {
        listOfContacts.add(new ContactModel(
          id: contact["id"],
          createdAt: contact["created_at"],
          updatedAt: contact["updated_at"],
          deletedAt: contact["deleted_at"],
          createdById: contact["created_by_id"],
          updatedById: contact["updated_by_id"],
          deletedById: contact["deleted_by_id"],
          customerId: contact["customer_id"],
          customer: contact["customer"],
          code: contact["code"],
          name: contact["name"],
          phone: contact["phone"],
          email: contact["email"],
          details: contact["details"],
        ));
      });
    }
    return listOfContacts;
  }

  Future<List<int>> RetrieveAllContactIds() async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery('SELECT id FROM "contacts"');

    List<int> listOfContactIds = List<int>();
    if (data.isNotEmpty)
      await Future.forEach(data, (contact) {
        listOfContactIds.add(contact["id"]);
      });
    return listOfContactIds;
  }

  Future<BusinessModel> CreateBusiness(BusinessModel business, SyncState syncState) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery('SELECT * FROM "businesses" WHERE id = ${business.id}');

    if (data.isNotEmpty)
      return null;
    
    business.id = await db.rawInsert(
      '''
      INSERT INTO "businesses" (
        id,
        created_at,
        updated_at,
        deleted_at,
        created_by_id,
        updated_by_id,
        deleted_by_id,
        customer_id,
        name,
        stage,
        date,
        amount,
        in_server,
        updated,
        deleted
      )

      VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''',
      [...[business.id, business.createdAt == null ? DateTime.now().toString() : business.createdAt, business.updatedAt == null ? DateTime.now().toString() : business.updatedAt,
      business.deletedAt, business.createdById, business.updatedById, business.deletedById,
      business.customerId, business.name, business.stage, business.date,
      business.amount, ...paramsBySyncState[syncState]]],
    );

    return business;
  }

  Future<BusinessModel> UpdateBusiness(int businessId, BusinessModel business, SyncState syncState) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery('SELECT * FROM "businesses" WHERE id = ${business.id}');

    if (data.isEmpty)
      return await CreateBusiness(business, syncState);
    else {
      await db.rawUpdate(
      '''
      UPDATE "businesses" SET
        id = ?,
        created_at = ?,
        updated_at = ?,
        deleted_at = ?,
        created_by_id = ?,
        updated_by_id = ?,
        deleted_by_id = ?,
        customer_id = ?,
        name = ?,
        stage = ?,
        date = ?,
        amount = ?,
        in_server = ?,
        updated = ?,
        deleted = ?
      WHERE id = $businessId
      ''', 
      [...[business.id, business.createdAt, business.updatedAt == null ? DateTime.now().toString() : business.updatedAt, 
      business.deletedAt, business.createdById, business.updatedById, business.deletedById,
      business.customerId, business.name, business.stage, business.date,
      business.amount, ...paramsBySyncState[syncState]]],
      );
    }

    return business;
  }

  Future<List<BusinessModel>> ReadBusinessesBySyncState(SyncState syncState) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT * FROM "businesses" WHERE 
      in_server = ? AND
      updated = ? AND
      deleted = ?
      ''',
      paramsBySyncState[syncState],
    );

    List<BusinessModel> listOfBusinesses = new List<BusinessModel>();
    if (data.isNotEmpty) {
      await Future.forEach(data, (business) async {
        listOfBusinesses.add(new BusinessModel(
          id: business["id"],
          createdAt: business["created_at"],
          updatedAt: business["updated_at"],
          deletedAt: business["deleted_at"],
          createdById: business["created_by_id"],
          updatedById: business["updated_by_id"],
          deletedById: business["deleted_by_id"],
          customerId: business["customer_id"],
          name: business["name"],
          stage: business["stage"],
          date: business["date"],
          amount: business["amount"],
        ));
      });
    }

    return listOfBusinesses;
  }

  Future<List<int>> RetrieveAllBusinessIds() async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery('SELECT id FROM "businesses"');

    List<int> listOfBusinessIds = List<int>();
    if (data.isNotEmpty)
      await Future.forEach(data, (business) {
        listOfBusinessIds.add(business["id"]);
      });
    return listOfBusinessIds;
  }

  Future<int> DeleteBusinessById(int id) async {
    final db = await database;
    return await db.rawDelete(
      '''
      DELETE FROM "businesses" WHERE id = $id
      '''
    );
  }  

  Future<BusinessModel> ReadBusinessById(int id) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT * FROM "businesses" WHERE id = $id
      '''
    );

    if (data.isNotEmpty) {
      return new BusinessModel(
        id: data.first["id"],
        createdAt: data.first["created_at"],
        updatedAt: data.first["updated_at"],
        deletedAt: data.first["deleted_at"],
        createdById: data.first["created_by_id"],
        updatedById: data.first["updated_by_id"],
        deletedById: data.first["deleted_by_id"],
        customerId: data.first["customer_id"],
        name: data.first["name"],
        stage: data.first["stage"],
        date: data.first["date"],
        amount: data.first["amount"],
      );
    }
    else
      return null;
  }

  Future<List<BusinessModel>> RetrieveBusinessesByUserToken(String userToken, bool excludeDeleted) async {
    final db = await database;
    List<Map<String, dynamic>> data;

    data = await db.rawQuery(
        '''
      SELECT DISTINCT b.*, cu.name as customer, cu.id as customer_id
      from "businesses" as b
      inner join "customers" as cu on cu.id = b.customer_id
      inner join "users" as u on b.created_by_id = u.id
      WHERE u.remember_token = '$userToken'
      ''' + (excludeDeleted ? " AND b.deleted = 0 AND cu.deleted = 0;" : ';')
    );


    List<BusinessModel> listOfBusinesses = new List<BusinessModel>();
    if (data.isNotEmpty) {
      await Future.forEach(data, (business) async {
        listOfBusinesses.add(new BusinessModel(
          id: business["id"],
          createdAt: business["created_at"],
          updatedAt: business["updated_at"],
          deletedAt: business["deleted_at"],
          createdById: business["created_by_id"],
          updatedById: business["updated_by_id"],
          deletedById: business["deleted_by_id"],
          customerId: business["customer_id"],
          customer: business["customer"],
          name: business["name"],
          stage: business["stage"],
          date: business["date"],
          amount: business["amount"],
        ));
      });
    }

    return listOfBusinesses;
  }

  Future<int> ChangeSyncStateBusiness(int id, SyncState syncState) async {
    final db = await database;
    return await db.rawUpdate(
      '''
      UPDATE "businesses" SET
      in_server = ?,
      updated = ?,
      deleted = ?
      WHERE id = $id
      ''',
      paramsBySyncState[syncState],
    );
  }

  Future<List<BusinessModel>> RetrieveBusinessModelByCustomerId(int customerId, bool excludeDeleted) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT * 
      FROM "businesses" 
      WHERE customer_id = $customerId
      ''' + (excludeDeleted ? " AND deleted = 0;" : ';')
    );

    List<BusinessModel> listOfBusinesses = new List<BusinessModel>();
    if (data.isNotEmpty) {
      await Future.forEach(data, (business) async {
        listOfBusinesses.add(new BusinessModel(
          id: business["id"],
          createdAt: business["created_at"],
          updatedAt: business["updated_at"],
          deletedAt: business["deleted_at"],
          createdById: business["created_by_id"],
          updatedById: business["updated_by_id"],
          deletedById: business["deleted_by_id"],
          customerId: business["customer_id"],
          name: business["name"],
          stage: business["stage"],
          date: business["date"],
          amount: business["amount"],
        ));
      });
    }

    return listOfBusinesses;
  }

  Future<int> CreateCustomerBusiness(int id, String createdAt, 
                                               String updatedAt,
                                               String deletedAt, 
                                               int customerId,
                                               int businessId, 
                                               SyncState syncState) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery('SELECT * FROM "businesses" WHERE id = $businessId');

    if (data.isNotEmpty) {
      return await db.rawUpdate(
      '''
      UPDATE "businesses" SET
      customer_id = ?,
      in_server = ?,
      updated = ?,
      deleted = ?
      WHERE id = $businessId
      ''', 
      [...[customerId], ...paramsBySyncState[syncState]],
      );
    }

    return null;
  }

  Future<List<Map>> ReadCustomerContactsBySyncState(SyncState syncState) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT * FROM "customers_contacts" WHERE 
      in_server = ? AND
      updated = ? AND
      deleted = ?
      ''',
      paramsBySyncState[syncState],
    );

    List<Map> listOfCustomerContacts = new List<Map>();
    if (data.isNotEmpty) {
      data.forEach((customerContact) {
        listOfCustomerContacts.add({
          "id": customerContact["id"],
          "created_at": customerContact["created_at"],
          "updated_at": customerContact["updated_at"],
          "deleted_at": customerContact["deleted_at"],
          "customer_id": customerContact["customer_id"],
          "contact_id": customerContact["contact_id"],
        });
      });
    }
    return listOfCustomerContacts;
  }

  Future<int> UpdateCustomerContact(int id, String createdAt,
      String updatedAt, String deletedAt,
      int customerId, int contactId,
      SyncState syncState) async {
    final db = await database;
    return await db.rawUpdate(
      '''
      UPDATE "customers_contacts" SET
      id = ?,
      created_at = ?,
      updated_at = ?,
      deleted_at = ?,
      customer_id = ?,
      contact_id = ?,
      in_server = ?,
      updated = ?,
      deleted = ?
      WHERE customer_id = $customerId AND contact_id = $contactId
      ''',
      [...[id, createdAt, updatedAt == null ? DateTime.now().toString() : updatedAt, 
      deletedAt, customerId, contactId], ...paramsBySyncState[syncState]],
    );
  }

  Future<List<String>> RetrieveAllCustomerContactRelations() async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT customer_id, contact_id FROM "customers_contacts"
      '''
    );

    List<String> relations = new List<String>();
    if (data.isNotEmpty) 
      data.forEach((relation) => relations.add(
          relation["customer_id"].toString() + "-" + relation["contact_id"].toString()
      ));
    return relations;
  }
}

class QueryTasks {
  String beginDate;
  String endDate;
  String supervisorId;
  String responsibleId;
  String formId;
  String perPage;
  String page;

  QueryTasks({
    this.beginDate,
    this.endDate,
    this.supervisorId,
    this.responsibleId,
    this.formId,
    this.perPage,
    this.page,
  });
}

String fixStringDateIfBroken(String stringDate) {
  return stringDate.replaceFirst("-1-", "-01-")
                    .replaceFirst("-2-", "-02-")
                    .replaceFirst("-3-", "-03-")
                    .replaceFirst("-4-", "-04-")
                    .replaceFirst("-5-", "-05-")
                    .replaceFirst("-6-", "-06-")
                    .replaceFirst("-7-", "-07-")
                    .replaceFirst("-8-", "-08-")
                    .replaceFirst("-9-", "-09-")
                    .replaceFirst("-1 ", "-01 ")
                    .replaceFirst("-2 ", "-02 ")
                    .replaceFirst("-3 ", "-03 ")
                    .replaceFirst("-4 ", "-04 ")
                    .replaceFirst("-5 ", "-05 ")
                    .replaceFirst("-6 ", "-06 ")
                    .replaceFirst("-7 ", "-07 ")
                    .replaceFirst("-8 ", "-08 ")
                    .replaceFirst("-9 ", "-09 ")
                    .replaceFirst(" 1:", " 01:")
                    .replaceFirst(" 2:", " 02:")
                    .replaceFirst(" 3:", " 03:")
                    .replaceFirst(" 4:", " 04:")
                    .replaceFirst(" 5:", " 05:")
                    .replaceFirst(" 6:", " 06:")
                    .replaceFirst(" 7:", " 07:")
                    .replaceFirst(" 8:", " 08:")
                    .replaceFirst(" 9:", " 09:")
                    .replaceFirst(":1:", ":01:")
                    .replaceFirst(":2:", ":02:")
                    .replaceFirst(":3:", ":03:")
                    .replaceFirst(":4:", ":04:")
                    .replaceFirst(":5:", ":05:")
                    .replaceFirst(":6:", ":06:")
                    .replaceFirst(":7:", ":07:")
                    .replaceFirst(":8:", ":08:")
                    .replaceFirst(":9:", ":09:");
}

Map<String, String> customValuesFromListToMap(List<CustomValueModel> listOfCustomValues) {
  Map<String, String> mapOfCustomValues = Map<String, String>();
  listOfCustomValues.forEach((customValue) {
    if (customValue.field.fieldType == "Photo" || customValue.field.fieldType == "CanvanImage" || customValue.field.fieldType == "CanvanSignature") {
      var posComa = customValue.imageBase64.indexOf(",");
      mapOfCustomValues[customValue.fieldId.toString()] = customValue.imageBase64.substring(posComa+1);
    } else {
      mapOfCustomValues[customValue.fieldId.toString()] = customValue.value;
    }

  });
  return mapOfCustomValues;
}
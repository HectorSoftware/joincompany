import 'dart:core';
import 'dart:io';

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
          databaseInstructions.forEach((key, value) async {
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
        in_server,
        updated,
        deleted
      )
      
      VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''',
      [...[user.id, user.createdAt, user.updatedAt, user.deletedAt,
    user.createdById, user.updatedById, user.deletedById,
    user.supervisorId, user.name, user.code, user.email,
    user.phone, user.mobile, user.title, user.details,
    user.profile, user.password, user.rememberToken],
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

    if (data.isNotEmpty) {
      List<UserModel> listOfUsers = new List<UserModel>();
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
        ));
      });
      return listOfUsers;
    }
    else
      return null;
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

    if (data.isNotEmpty) {
      List<UserModel> users = new List<UserModel>();
      data.forEach((userRetrieved) => users.add(UserModel(
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
      )));

      return users;
    }
    else
      return null;
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
      in_server = ?,
      updated = ?,
      deleted = ?,
      WHERE id = ${userId}
      ''',
      [...[user.id, user.createdAt, user.updatedAt, user.deletedAt,
    user.createdById, user.updatedById, user.deletedById,
    user.supervisorId, user.name, user.code, user.email,
    user.phone, user.mobile, user.title, user.details,
    user.profile, user.password, user.rememberToken],
    ...paramsBySyncState[syncState]],
    );
  }

  Future<int> ChangeSyncStateUser(int id, SyncState syncState) async {
    final db = await database;return
      db.rawUpdate(
        '''
      UPDATE "users" SET
      in_server = ? AND
      updated = ? AND
      deleted = ? AND
      WHERE id = $id
      ''',
        paramsBySyncState[syncState],
      );
  }

  Future<int> DeleteUserById(int id) async {
    final db = await database;
    return await db.rawDelete(
        '''
      DELETE FROM "users" WHERE id = $id
      '''
    );
  }

  Future<List<UserModel>> ListUsers() async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
        '''
      SELECT * FROM "users"
      '''
    );

    if (data.isNotEmpty) {
      List<UserModel> users = new List<UserModel>();
      data.forEach((userRetrieved) => users.add(UserModel(
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
      )));

      return users;
    }
    else
      return null;
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

    form.sections.forEach((section) async {
      CreateCustomField(section, syncState);
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
      [...[form.id, form.createdAt, form.updatedAt, form.deletedAt,
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
      List<SectionModel> sections = await QueryCustomField(
        SectionModel(entityId: data.first["id"]),
      );

      return FormModel(
        id: data.first["id"],
        createdAt: data.first["created_at"],
        updatedAt: data.first["updated_at"],
        deletedAt: data.first["deleted_at"],
        createdById: data.first["created_by_id"],
        updatedById: data.first["updated_by_id"],
        deletedById: data.first["deleted_by_id"],
        name: data.first["name"],
        withCheckinout: data.first["with_checkinout"],
        active: data.first["active"],
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

    if (data.isNotEmpty) {
      List<FormModel> listOfForms = new List<FormModel>();
      data.forEach((formRetrieved) async {
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
        List<SectionModel> sections = await QueryCustomField(
          SectionModel(entityId: formRetrieved["id"]),
        );

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
      return listOfForms;
    }
    else
      return null;
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

    if (data.isNotEmpty) {
      List<FormModel> forms = new List<FormModel>();
      data.forEach((formRetrieved) async {
        List<SectionModel> sections = await QueryCustomField(
          SectionModel(entityId: data.first["id"]),
        );

        forms.add(FormModel(
          id: data.first["id"],
          createdAt: data.first["created_at"],
          updatedAt: data.first["updated_at"],
          deletedAt: data.first["deleted_at"],
          createdById: data.first["created_by_id"],
          updatedById: data.first["updated_by_id"],
          deletedById: data.first["deleted_by_id"],
          name: data.first["name"],
          withCheckinout: data.first["with_checkinout"],
          active: data.first["active"],
          sections: sections,
        ));
      });
    }
    else
      return null;
  }

  Future<int> UpdateForm(int formId, FormModel form, SyncState syncState) async {
    final db = await database;

    form.sections.forEach((section) async {
      List<Map<String, dynamic>> data;
      data = await db.rawQuery(
          '''
      SELECT * FROM "forms" WHERE id = ${section.id}
      '''
      );

      if (data.isNotEmpty)
        UpdateCustomField(section.id, section, syncState);
      else
        CreateCustomField(section, syncState);
    });

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
      deleted = ?,
      WHERE id = ${formId}
      ''',
      [...[form.id, form.createdAt, form.updatedAt, form.deletedAt,
    form.createdById, form.updatedById, form.deletedById, form.name,
    form.withCheckinout, form.active],
    ...paramsBySyncState[syncState]],
    );
  }

  Future<int> DeleteFormById(int id) async {
    final db = await database;
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
      in_server = ? AND
      updated = ? AND
      deleted = ? AND
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

    if (data.isNotEmpty) {
      List<FormModel> forms = new List<FormModel>();
      data.forEach((formRetrieved) async {
        List<SectionModel> sections = await QueryCustomField(
          SectionModel(entityId: data.first["id"]),
        );

        forms.add(FormModel(
          id: data.first["id"],
          createdAt: data.first["created_at"],
          updatedAt: data.first["updated_at"],
          deletedAt: data.first["deleted_at"],
          createdById: data.first["created_by_id"],
          updatedById: data.first["updated_by_id"],
          deletedById: data.first["deleted_by_id"],
          name: data.first["name"],
          withCheckinout: data.first["with_checkinout"],
          active: data.first["active"],
          sections: sections,
        ));
      });
    }
    else
      return null;
  }

  Future<List<int>> RetrieveAllFormIds() async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
        '''
      SELECT id FROM "forms"
      '''
    );

    if (data.isNotEmpty) {
      List<int> ids = new List<int>();
      data.forEach((form) => ids.add(form["id"]));
      return ids;
    }
    else
      return null;
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
      [...[locality.id, locality.createdAt, locality.updatedAt,
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

    if (data.isNotEmpty) {
      List<LocalityModel> listOfLocalities = new List<LocalityModel>();
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
      return listOfLocalities;
    }
    else
      return null;
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

    if (data.isNotEmpty) {
      List<LocalityModel> listOfLocalities = new List<LocalityModel>();
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
    else
      return null;
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
      deleted,
      WHERE id = ${localityId}
      ''',
      [...[locality.id, locality.createdAt, locality.updatedAt, locality.deletedAt,
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
      in_server = ? AND
      updated = ? AND
      deleted = ? AND
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

    if (data.isNotEmpty) {
      List<LocalityModel> listOfLocalities = new List<LocalityModel>();
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
    else
      return null;
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

    CreateResponsible(responsible.supervisor, syncState);

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
      [...[responsible.id, responsible.createdAt, responsible.updatedAt,
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

    if (data.isNotEmpty) {
      List<ResponsibleModel> listOfResponsibles = new List<ResponsibleModel>();
      data.forEach((responsibleRetrieved) async {
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
      return listOfResponsibles;
    }
    else
      return null;
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

    if (data.isNotEmpty) {
      List<ResponsibleModel> listOfResponsibles = new List<ResponsibleModel>();
      data.forEach((responsibleRetrieved) async {
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
    else
      return null;
  }

  Future<int> UpdateResponsible(int responsibleId, ResponsibleModel responsible, SyncState syncState) async {
    final db = await database;

    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
        '''
      SELECT * FROM "responsibles" WHERE id = ${responsible.supervisor.id}
      '''
    );

    if (data.isNotEmpty)
      UpdateResponsible(responsible.supervisor.id, responsible.supervisor, syncState);
    else
      CreateResponsible(responsible.supervisor, syncState);

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
      deleted = ?,
      WHERE id = ${responsible.id}
      ''',
      [...[responsible.id, responsible.createdAt, responsible.updatedAt,
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
      in_server = ? AND
      updated = ? AND
      deleted = ? AND
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

    if (data.isNotEmpty) {
      List<ResponsibleModel> listOfResponsibles = new List<ResponsibleModel>();
      data.forEach((responsibleRetrieved) async {
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
    else
      return null;
  }

  // Operations on custom_fields
  Future<int> CreateCustomField(SectionModel section, SyncState syncState) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
        '''
      SELECT * FROM "custom_fields" WHERE id = ${section.id}
      '''
    );

    if (data.isNotEmpty)
      return null;

    section.fields.forEach((field) async {
      List<FieldModel> fields = new List<FieldModel>();
      List<SectionModel> customFields = await QueryCustomField(
        SectionModel(id: field.sectionId),
      );

      customFields.forEach((customField) => fields.add(FieldModel(
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
      )));

      CreateCustomField(
          SectionModel(
            id: field.id,
            createdAt: field.createdAt,
            updatedAt: field.updatedAt,
            deletedAt: field.deletedAt,
            createdById: field.createdById,
            updatedById: field.updatedById,
            deletedById: field.deletedById,
            sectionId: field.sectionId,
            entityType: field.entityType,
            entityId: field.entityId,
            type: field.type,
            name: field.name,
            code: field.code,
            subtitle: field.subtitle,
            position: field.position,
            fieldDefaultValue: field.fieldDefaultValue,
            fieldType: field.fieldType,
            fieldPlaceholder: field.fieldPlaceholder,
            fieldOptions: field.fieldOptions,
            fieldCollection: field.fieldCollection,
            fieldRequired: field.fieldRequired,
            fieldWidth: field.fieldWidth,
            fields: fields,
          ),
          syncState
      );
    });

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
        [...[section.id, section.createdAt, section.updatedAt,
    section.deletedAt, section.createdById,
    section.updatedById, section.deletedById,
    section.sectionId, section.entityType,
    section.entityId, section.type, section.name,
    section.code, section.subtitle, section.position,
    section.fieldDefaultValue, section.fieldType,
    section.fieldPlaceholder, section.fieldOptions.toString(),
    section.fieldCollection, section.fieldRequired,
    section.fieldWidth], ...paramsBySyncState[syncState]],
    );
  }

  Future<SectionModel> ReadCustomFieldById(int id) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
        '''
      SELECT * FROM "custom_fields" WHERE id = $id
      '''
    );

    if (data.isNotEmpty) {
      List<FieldModel> fields = new List<FieldModel>();

      List<SectionModel> customFields = await QueryCustomField(
        SectionModel(id: data.first["id"]),
      );

      customFields.forEach((customField) => fields.add(FieldModel(
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
      )));

      return SectionModel(
        id: data.first["id"],
        createdAt: data.first["created_at"],
        updatedAt: data.first["updated_at"],
        deletedAt: data.first["deleted_at"],
        createdById: data.first["created_by_id"],
        updatedById: data.first["updated_by_id"],
        deletedById: data.first["deleted_by_id"],
        sectionId: data.first["section_id"],
        entityType: data.first["entity_type"],
        entityId: data.first["entity_id"],
        type: data.first["type"],
        name: data.first["name"],
        code: data.first["code"],
        subtitle: data.first["subtitle"],
        position: data.first["position"],
        fieldDefaultValue: data.first["field_default_value"],
        fieldType: data.first["field_type"],
        fieldPlaceholder: data.first["field_placeholder"],
        fieldOptions: data.first["field_options"],
        fieldCollection: data.first["field_collection"],
        fieldRequired: data.first["field_required"],
        fieldWidth: data.first["field_width"],
        fields: fields,
      );
    }
    else
      return null;
  }

  Future<List<SectionModel>> QueryCustomField(SectionModel query) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
        '''
      SELECT * FROM "custom_fields"
      '''
    );

    if (data.isNotEmpty) {
      List<SectionModel> listOfSections = new List<SectionModel>();
      data.forEach((sectionRetrieved) async {
        if (query.id != null)
          if (query.id != sectionRetrieved["id"])
            return;
        if (query.createdAt != null)
          if (query.createdAt != sectionRetrieved["created_at"])
            return;
        if (query.updatedAt != null)
          if (query.updatedAt != sectionRetrieved["updated_at"])
            return;
        if (query.deletedAt != null)
          if (query.deletedAt != sectionRetrieved["deleted_at"])
            return;
        if (query.createdById != null)
          if (query.createdById != sectionRetrieved["created_by_id"])
            return;
        if (query.updatedById != null)
          if (query.updatedById != sectionRetrieved["updated_by_id"])
            return;
        if (query.deletedById != null)
          if (query.deletedById != sectionRetrieved["deleted_by_id"])
            return;
        if (query.sectionId != null)
          if (query.sectionId != sectionRetrieved["section_id"])
            return;
        if (query.entityType != null)
          if (query.entityType != sectionRetrieved["entity_type"])
            return;
        if (query.entityId != null)
          if (query.entityId != sectionRetrieved["entity_id"])
            return;
        if (query.type != null)
          if (query.type != sectionRetrieved["type"])
            return;
        if (query.name != null)
          if (query.name != sectionRetrieved["name"])
            return;
        if (query.code != null)
          if (query.code != sectionRetrieved["code"])
            return;
        if (query.subtitle != null)
          if (query.subtitle != sectionRetrieved["subtitle"])
            return;
        if (query.position != null)
          if (query.position != sectionRetrieved["position"])
            return;
        if (query.fieldDefaultValue != null)
          if (query.fieldDefaultValue != sectionRetrieved["field_default_value"])
            return;
        if (query.fieldType != null)
          if (query.fieldType != sectionRetrieved["field_type"])
            return;
        if (query.fieldPlaceholder != null)
          if (query.fieldPlaceholder != sectionRetrieved["field_placeholder"])
            return;
        if (query.fieldOptions != null)
          if (query.fieldOptions != sectionRetrieved["field_options"])
            return;
        if (query.fieldCollection != null)
          if (query.fieldCollection != sectionRetrieved["field_collection"])
            return;
        if (query.fieldRequired != null)
          if (query.fieldRequired != sectionRetrieved["field_required"])
            return;
        if (query.fieldWidth != null)
          if (query.fieldWidth != sectionRetrieved["field_width"])
            return;


        List<FieldModel> fields = new List<FieldModel>();

        List<SectionModel> customFields = await QueryCustomField(
          SectionModel(id: sectionRetrieved["id"]),
        );

        customFields.forEach((customField) => fields.add(FieldModel(
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
        )));

        listOfSections.add(SectionModel(
          id: sectionRetrieved["id"],
          createdAt: sectionRetrieved["created_at"],
          updatedAt: sectionRetrieved["updated_at"],
          deletedAt: sectionRetrieved["deleted_at"],
          createdById: sectionRetrieved["created_by_id"],
          updatedById: sectionRetrieved["updated_by_id"],
          deletedById: sectionRetrieved["deleted_by_id"],
          sectionId: sectionRetrieved["section_id"],
          entityType: sectionRetrieved["entity_type"],
          entityId: sectionRetrieved["entity_id"],
          type: sectionRetrieved["type"],
          name: sectionRetrieved["name"],
          code: sectionRetrieved["code"],
          subtitle: sectionRetrieved["subtitle"],
          position: sectionRetrieved["position"],
          fieldDefaultValue: sectionRetrieved["field_default_value"],
          fieldType: sectionRetrieved["field_type"],
          fieldPlaceholder: sectionRetrieved["field_placeholder"],
          fieldOptions: sectionRetrieved["field_options"],
          fieldCollection: sectionRetrieved["field_collection"],
          fieldRequired: sectionRetrieved["field_required"],
          fieldWidth: sectionRetrieved["field_width"],
          fields: fields,
        ));
      });
      return listOfSections;
    }
    else
      return null;
  }

  Future<List<SectionModel>> ReadCustomFieldsBySyncState(SyncState syncState) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT * FROM "custom_fields" WHERE 
      in_server = ? AND
      updated = ? AND
      deleted = ?
      ''',
      paramsBySyncState[syncState],
    );

    if (data.isNotEmpty) {
      List<SectionModel> listOfSections = new List<SectionModel>();
      data.forEach((sectionRetrieved) async {
        List<FieldModel> fields = new List<FieldModel>();

        List<SectionModel> customFields = await QueryCustomField(
          SectionModel(id: sectionRetrieved["id"]),
        );

        customFields.forEach((customField) => fields.add(FieldModel(
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
        )));

        listOfSections.add(SectionModel(
          id: sectionRetrieved["id"],
          createdAt: sectionRetrieved["created_at"],
          updatedAt: sectionRetrieved["updated_at"],
          deletedAt: sectionRetrieved["deleted_at"],
          createdById: sectionRetrieved["created_by_id"],
          updatedById: sectionRetrieved["updated_by_id"],
          deletedById: sectionRetrieved["deleted_by_id"],
          sectionId: sectionRetrieved["section_id"],
          entityType: sectionRetrieved["entity_type"],
          entityId: sectionRetrieved["entity_id"],
          type: sectionRetrieved["type"],
          name: sectionRetrieved["name"],
          code: sectionRetrieved["code"],
          subtitle: sectionRetrieved["subtitle"],
          position: sectionRetrieved["position"],
          fieldDefaultValue: sectionRetrieved["field_default_value"],
          fieldType: sectionRetrieved["field_type"],
          fieldPlaceholder: sectionRetrieved["field_placeholder"],
          fieldOptions: sectionRetrieved["field_options"],
          fieldCollection: sectionRetrieved["field_collection"],
          fieldRequired: sectionRetrieved["field_required"],
          fieldWidth: sectionRetrieved["field_width"],
          fields: fields,
        ));
      });
      return listOfSections;
    }
    else
      return null;
  }

  Future<int> UpdateCustomField(int sectionId, SectionModel section, SyncState syncState) async {
    final db = await database;
    section.fields.forEach((field) async {
      List<FieldModel> fields = new List<FieldModel>();
      List<SectionModel> customFields = await QueryCustomField(
        SectionModel(id: field.sectionId),
      );

      customFields.forEach((customField) => fields.add(FieldModel(
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
      )));

      List<Map<String, dynamic>> data;
      data = await db.rawQuery(
          '''
      SELECT * FROM "custom_fields" WHERE id = ${field.id}
      '''
      );

      if (data.isNotEmpty)
        UpdateCustomField(
            field.id,
            SectionModel(
              id: field.id,
              createdAt: field.createdAt,
              updatedAt: field.updatedAt,
              deletedAt: field.deletedAt,
              createdById: field.createdById,
              updatedById: field.updatedById,
              deletedById: field.deletedById,
              sectionId: field.sectionId,
              entityType: field.entityType,
              entityId: field.entityId,
              type: field.type,
              name: field.name,
              code: field.code,
              subtitle: field.subtitle,
              position: field.position,
              fieldDefaultValue: field.fieldDefaultValue,
              fieldType: field.fieldType,
              fieldPlaceholder: field.fieldPlaceholder,
              fieldOptions: field.fieldOptions,
              fieldCollection: field.fieldCollection,
              fieldRequired: field.fieldRequired,
              fieldWidth: field.fieldWidth,
              fields: fields,
            ),
            syncState
        );
      else
        CreateCustomField(
            SectionModel(
              id: field.id,
              createdAt: field.createdAt,
              updatedAt: field.updatedAt,
              deletedAt: field.deletedAt,
              createdById: field.createdById,
              updatedById: field.updatedById,
              deletedById: field.deletedById,
              sectionId: field.sectionId,
              entityType: field.entityType,
              entityId: field.entityId,
              type: field.type,
              name: field.name,
              code: field.code,
              subtitle: field.subtitle,
              position: field.position,
              fieldDefaultValue: field.fieldDefaultValue,
              fieldType: field.fieldType,
              fieldPlaceholder: field.fieldPlaceholder,
              fieldOptions: field.fieldOptions,
              fieldCollection: field.fieldCollection,
              fieldRequired: field.fieldRequired,
              fieldWidth: field.fieldWidth,
              fields: fields,
            ),
            syncState
        );
    });

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
      deleted = ?,
      WHERE id = ${sectionId}
      ''',
        [...[section.id, section.createdAt,section.updatedAt, section.deletedAt,
    section.createdById, section.updatedById, section.deletedById,
    section.sectionId, section.entityType, section.entityId, section.type,
    section.name, section.code, section.subtitle, section.position,
    section.fieldDefaultValue, section.fieldType, section.fieldPlaceholder,
    section.fieldOptions.toString(), section.fieldCollection, section.fieldRequired,
    section.fieldWidth], ...paramsBySyncState[syncState]],
    );
  }

  Future<int> DeleteCustomFieldById(int id) async {
    final db = await database;
    return await db.rawDelete(
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
      in_server = ? AND
      updated = ? AND
      deleted = ? AND
      WHERE id = $id
      ''',
      paramsBySyncState[syncState],
    );
  }

  Future<List<SectionModel>> ListCustomFields() async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
        '''
      SELECT * FROM "custom_fields"
      '''
    );

    if (data.isNotEmpty) {
      List<SectionModel> listOfSections = new List<SectionModel>();
      data.forEach((sectionRetrieved) async {
        List<FieldModel> fields = new List<FieldModel>();

        List<SectionModel> customFields = await QueryCustomField(
          SectionModel(id: sectionRetrieved["id"]),
        );

        customFields.forEach((customField) => fields.add(FieldModel(
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
        )));

        listOfSections.add(SectionModel(
          id: sectionRetrieved["id"],
          createdAt: sectionRetrieved["created_at"],
          updatedAt: sectionRetrieved["updated_at"],
          deletedAt: sectionRetrieved["deleted_at"],
          createdById: sectionRetrieved["created_by_id"],
          updatedById: sectionRetrieved["updated_by_id"],
          deletedById: sectionRetrieved["deleted_by_id"],
          sectionId: sectionRetrieved["section_id"],
          entityType: sectionRetrieved["entity_type"],
          entityId: sectionRetrieved["entity_id"],
          type: sectionRetrieved["type"],
          name: sectionRetrieved["name"],
          code: sectionRetrieved["code"],
          subtitle: sectionRetrieved["subtitle"],
          position: sectionRetrieved["position"],
          fieldDefaultValue: sectionRetrieved["field_default_value"],
          fieldType: sectionRetrieved["field_type"],
          fieldPlaceholder: sectionRetrieved["field_placeholder"],
          fieldOptions: sectionRetrieved["field_options"],
          fieldCollection: sectionRetrieved["field_collection"],
          fieldRequired: sectionRetrieved["field_required"],
          fieldWidth: sectionRetrieved["field_width"],
          fields: fields,
        ));
      });
      return listOfSections;
    }
    else
      return null;
  }

  // Operations on addresses
  Future<int> CreateAddress(AddressModel address, SyncState syncState) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
        '''
      SELECT * FROM "addresses" WHERE id = ${address.id}
      '''
    );

    if (data.isNotEmpty)
      return null;

    CreateLocality(address.locality, syncState);

    return await db.rawInsert(
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

      [...[address.id, address.createdAt, address.updatedAt,
    address.deletedAt, address.createdById, address.updatedById,
    address.deletedById, address.localityId, address.address,
    address.details, address.reference, address.latitude, address.longitude,
    address.googlePlaceId, address.country,address.state, address.city,
    address.contactName, address.contactPhone, address.contactMobile,
    address.contactEmail], ...paramsBySyncState[syncState]],
    );
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
      LocalityModel localityModel = await ReadLocalityById(data.first["locality_id"]);

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
          locality: localityModel);
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

    if (data.isNotEmpty) {
      List<AddressModel> listOfAddresses = new List<AddressModel>();
      data.forEach((addressRetrieved) async {
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
      return listOfAddresses;
    }
    else
      return null;
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

    if (data.isNotEmpty) {
      List<AddressModel> listOfAddresses = new List<AddressModel>();
      data.forEach((addressRetrieved) async {

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
      return listOfAddresses;
    }
    else
      return null;
  }

  Future<int> UpdateAddress(int addressId, AddressModel address, SyncState syncState) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
        '''
      SELECT * FROM "localities" WHERE id = ${address.locality.id}
      '''
    );

    if (data.isNotEmpty)
      UpdateLocality(address.locality.id, address.locality, syncState);
    else
      CreateLocality(address.locality, syncState);

    return await db.rawUpdate(
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
      deleted = ?,
      WHERE id = ${addressId}
      ''',
      [...[address.id, address.createdAt, address.updatedAt, address.deletedAt,
    address.createdById, address.updatedById, address.deletedById,
    address.localityId, address.address, address.details, address.reference,
    address.latitude, address.longitude, address.googlePlaceId,
    address.country, address.state, address.city, address.contactName,
    address.contactPhone, address.contactMobile, address.contactEmail],
    ...paramsBySyncState[syncState]],
    );
  }

  Future<int> DeleteAddressById(int id) async {
    final db = await database;
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
      in_server = ? AND
      updated = ? AND
      deleted = ? AND
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

    if (data.isNotEmpty) {
      List<AddressModel> listOfAddresses = new List<AddressModel>();
      data.forEach((addressRetrieved) async {

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
      return listOfAddresses;
    }
    else
      return null;
  }

  Future<List<int>> RetrieveAllAddressIds() async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
        '''
      SELECT id FROM "addresses"
      '''
    );

    if (data.isNotEmpty) {
      List<int> ids = new List<int>();
      data.forEach((address) => ids.add(address["id"]));
      return ids;
    }
    else
      return null;
  }

  // Operations on customers
  Future<int> CreateCustomer(CustomerModel customer, SyncState syncState) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
        '''
      SELECT * FROM "customers" WHERE id = ${customer.id}
      '''
    );

    if (data.isNotEmpty)
      return null;

    return await db.rawInsert(
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
        phone,
        email,
        contact_name,
        details,
        in_server,
        updated,
        deleted
      )
        
      VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''',
      [...[customer.id, customer.createdAt, customer.updatedAt,
    customer.deletedAt, customer.createdById, customer.updatedById,
    customer.deletedById, customer.name, customer.code, customer.phone,
    customer.email, customer.contactName, customer.details],
    ...paramsBySyncState[syncState]],
    );
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
        phone: data.first["phone"],
        email: data.first["email"],
        contactName: data.first["contact_name"],
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

    if (data.isNotEmpty) {
      List<CustomerModel> listOfCustomers = new List<CustomerModel>();
      data.forEach((customerResponse) async {
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
        if (query.phone != null)
          if (query.phone != customerResponse["phone"])
            return;
        if (query.email != null)
          if (query.email != customerResponse["email"])
            return;
        if (query.contactName != null)
          if (query.contactName != customerResponse["contact_name"])
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
          phone: customerResponse["phone"],
          email: customerResponse["email"],
          contactName: customerResponse["contact_name"],
          details: customerResponse["details"],
          pivot: null,
        ));
      });
      return listOfCustomers;
    }
    else
      return null;
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

    if (data.isNotEmpty) {
      List<CustomerModel> listOfCustomers = new List<CustomerModel>();
      data.forEach((customerResponse) async {
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
          phone: customerResponse["phone"],
          email: customerResponse["email"],
          contactName: customerResponse["contact_name"],
          details: customerResponse["details"],
          pivot: null,
        ));
      });
      return listOfCustomers;
    }
    else
      return null;
  }

  Future<int> UpdateCustomer(int customerId, CustomerModel customer, SyncState syncState) async {
    final db = await database;
    return await db.rawUpdate(
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
      phone = ?,
      email = ?,
      contact_name = ?,
      details = ?,
      in_server = ?,
      updated = ?,
      deleted = ?,
      WHERE id = ${customerId}
      ''',
      [...[customer.id, customer.createdAt, customer.updatedAt, customer.deletedAt,
    customer.createdById, customer.updatedById, customer.deletedById,
    customer.name, customer.code, customer.phone, customer.email,
    customer.contactName, customer.details],
    ...paramsBySyncState[syncState]],
    );
  }

  Future<int> DeleteCustomerById(int id) async {
    final db = await database;
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
      in_server = ? AND
      updated = ? AND
      deleted = ? AND
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

    if (data.isNotEmpty) {
      List<CustomerModel> listOfCustomers = new List<CustomerModel>();
      data.forEach((customerResponse) async {
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
          phone: customerResponse["phone"],
          email: customerResponse["email"],
          contactName: customerResponse["contact_name"],
          details: customerResponse["details"],
          pivot: null,
        ));
      });
      return listOfCustomers;
    }
    else
      return null;
  }

  Future<List<int>> RetrieveAllCustomerIds() async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
        '''
      SELECT id FROM "customers"
      '''
    );

    if (data.isNotEmpty) {
      List<int> ids = new List<int>();
      data.forEach((customer) => ids.add(customer["id"]));
      return ids;
    }
    else
      return null;
  }

  // Operations on tasks
  Future<int> CreateTask(TaskModel task, SyncState syncState) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
        '''
      SELECT * FROM "tasks" WHERE id = ${task.id}
      '''
    );

    if (data.isNotEmpty)
      return null;

    // WARNING: customSection is always returned as null from the server
    // that's why I ain't using it here. Anyway, if it changes (as it's supposed to)
    // we will just have to modify this to add it to our database (but I think it
    // wouldn't be necessary).

    task.customValues.forEach((customValue) async {
      CreateCustomValue(customValue, syncState);
    });

    // individual items
    CreateForm(task.form, syncState);
    CreateAddress(task.address, syncState);
    CreateCustomer(task.customer, syncState);
    CreateResponsible(task.responsible, syncState);

    return await db.rawInsert(
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
        
      VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''',
        [...[task.id, task.createdAt, task.updatedAt, task.deletedAt,
    task.createdById, task.updatedById, task.deletedById, task.formId,
    task.responsibleId, task.customerId, task.addressId, task.name,
    task.planningDate, task.checkinDate, task.checkinLatitude,
    task.checkinLongitude, task.checkinDistance, task.checkoutDate,
    task.checkoutLatitude, task.checkoutLongitude, task.checkoutDistance,
    task.status], ...paramsBySyncState[syncState]],
    );
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

      List<CustomValueModel> customValues = await QueryCustomValue(CustomValueModel(
        formId: form.id,
      ));

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
        customValues: customValues,
        customSections: null,
      );
    }
    else
      return null;
  }

  Future<List<TaskModel>> QueryTask(TaskModel query) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
        '''
      SELECT * FROM "tasks"
      '''
    );

    if (data.isNotEmpty) {
      List<TaskModel> listOfTasks = new List<TaskModel>();
      data.forEach((taskRetrieved) async {
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
          customSections: null,
        ));
      });
      return listOfTasks;
    }
    else
      return null;
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

    if (data.isNotEmpty) {
      List<TaskModel> listOfTasks = new List<TaskModel>();
      data.forEach((taskRetrieved) async {
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
          customSections: null,
        ));
      });
    }
    else
      return null;
  }

  Future<int> UpdateTask(int taskId, TaskModel task, SyncState syncState) async {
    final db = await database;

    task.customValues.forEach((customValue) async {
      List<Map<String, dynamic>> data;
      data = await db.rawQuery(
          '''
      SELECT * FROM "custom_values" WHERE id = ${customValue.id}
      '''
      );

      if (data.isNotEmpty)
        UpdateCustomValue(customValue.id, customValue, syncState);
      else
        CreateCustomValue(customValue, syncState);
    });

    // individual items
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
        '''
      SELECT * FROM "forms" WHERE id = ${task.form.id}
      '''
    );

    if (data.isNotEmpty)
      UpdateForm(task.form.id, task.form, syncState);
    else
      CreateForm(task.form, syncState);

    data = await db.rawQuery(
        '''
      SELECT * FROM "addresses" WHERE id = ${task.address.id}
      '''
    );

    if (data.isNotEmpty)
      UpdateAddress(task.address.id, task.address, syncState);
    else
      CreateAddress(task.address, syncState);

    data = await db.rawQuery(
        '''
      SELECT * FROM "customers" WHERE id = ${task.customer.id}
      '''
    );

    if (data.isNotEmpty)
      UpdateCustomer(task.customer.id, task.customer, syncState);
    else
      CreateCustomer(task.customer, syncState);

    data = await db.rawQuery(
        '''
      SELECT * FROM "responsibles" WHERE id = ${task.responsible.id}
      '''
    );

    if (data.isNotEmpty)
      UpdateResponsible(task.responsible.id, task.responsible, syncState);
    else
      CreateResponsible(task.responsible, syncState);

    return await db.rawUpdate(
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
      deleted = ?,
      WHERE id = ${taskId}
      ''',
        [...[task.id, task.createdAt, task.updatedAt, task.deletedAt, task.createdById,
    task.updatedById, task.deletedById, task.formId, task.responsibleId,
    task.customerId, task.addressId, task.name, task.planningDate,
    task.checkinDate, task.checkinLatitude, task.checkinLongitude,
    task.checkinDistance, task.checkoutDate, task.checkoutLatitude,
    task.checkoutLongitude, task.checkoutDistance, task.status],
    ...paramsBySyncState[syncState]],
    );
  }

  Future<int> DeleteTaskById(int id) async {
    final db = await database;
    return await db.rawDelete(
        '''
      DELETE FROM "tasks" WHERE id = $id
      '''
    );
  }

  Future<int> ChangeSyncStateTaks(int id, SyncState syncState) async {
    final db = await database;
    return await db.rawUpdate(
      '''
      UPDATE "tasks" SET
      in_server = ? AND
      updated = ? AND
      deleted = ? AND
      WHERE id = $id
      ''',
      paramsBySyncState[syncState],
    );
  }

  Future<List<TaskModel>> ListTasks() async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
        '''
      SELECT * FROM "tasks"
      '''
    );

    if (data.isNotEmpty) {
      List<TaskModel> listOfTasks = new List<TaskModel>();
      data.forEach((taskRetrieved) async {
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
          customSections: null,
        ));
      });
    }
    else
      return null;
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
      [...[id, createdAt, updatedAt, deletedAt, customerId, userId],
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
      SELECT * FROM "customer_users"
      '''
    );

    if (data.isNotEmpty) {
      List<Map> listOfCustomerUsers = new List<Map>();
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
      return listOfCustomerUsers;
    }
    else
      return null;
  }

  Future<List<Map>> ReadCustomerUsersBySyncState(SyncState syncState) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT * FROM "customer_users" WHERE 
      in_server = ? AND
      updated = ? AND
      deleted = ?
      ''',
      paramsBySyncState[syncState],
    );

    if (data.isNotEmpty) {
      List<Map> listOfCustomerUsers = new List<Map>();
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
      return listOfCustomerUsers;
    }
    else
      return null;
  }

  Future<int> UpdateCustomerUser(int customerUserId, int id, String createdAt, String updatedAt,
      String deletedAt, int customerId,
      int userId, SyncState syncState) async {
    final db = await database;
    return await db.rawUpdate(
      '''
      UPDATE "customer_users" SET
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
      in_server = ?,
      updated = ?,
      deleted = ?,
      WHERE id = $customerUserId
      ''',
      [...[id, createdAt, updatedAt, deletedAt, customerId, userId],
    ...paramsBySyncState[syncState]],
    );
  }

  Future<int> DeleteCustomerUserById(int id) async {
    final db = await database;
    return await db.rawDelete(
        '''
      DELETE FROM "customer_users" WHERE id = $id
      '''
    );
  }

  Future<int> ChangeSyncStateCustomerUser(int id, SyncState syncState) async {
    final db = await database;
    return await db.rawUpdate(
      '''
      UPDATE "customer_users" SET
      in_server = ? AND
      updated = ? AND
      deleted = ? AND
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
      SELECT * FROM "customer_users"
      '''
    );

    if (data.isNotEmpty) {
      List<Map> listOfCustomerUsers = new List<Map>();
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
      return listOfCustomerUsers;
    }
    else
      return null;
  }

  // Operations on custom_values
  Future<int> CreateCustomValue(CustomValueModel customValue, SyncState syncState) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
        '''
      SELECT * FROM "custom_values" WHERE id = ${customValue.id}
      '''
    );

    if (data.isNotEmpty)
      return null;

    CreateCustomField(SectionModel(
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

    return await db.rawInsert(
      '''
      INSERT INTO "custom_values"(
        id,
        created_at,
        updated_at,
        deleted_at,
        forms_id,
        section_id,
        field_id,
        customizable_type,
        customizable_id,
        value,
        in_server,
        updated,
        deleted  
      )
        
      VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''',
      [...[customValue.id, customValue.createdAt, customValue.updatedAt,
    customValue.formId, customValue.sectionId, customValue.fieldId,
    customValue.customizableType, customValue.customizableId,
    customValue.value], ...paramsBySyncState[syncState]],
    );

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
      SectionModel customField = await ReadCustomFieldById(data.first["field_id"]);
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
        sectionId: data.first["section_id"],
        fieldId: data.first["field_id"],
        customizableType: data.first["customizable_type"],
        customizableId: data.first["customizable_id"],
        value: data.first["value"],
        imageBase64: null,
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

    if (data.isNotEmpty) {
      List<CustomValueModel> listOfCustomValues = new List<CustomValueModel>();
      data.forEach((responsibleRetrieved) async {
        if (query.id != null)
          if (query.id != responsibleRetrieved["id"])
            return;
        if (query.createdAt != null)
          if (query.createdAt != responsibleRetrieved["created_at"])
            return;
        if (query.updatedAt != null)
          if (query.updatedAt != responsibleRetrieved["updated_at"])
            return;
        if (query.formId != null)
          if (query.formId != responsibleRetrieved["form_id"])
            return;
        if (query.sectionId != null)
          if (query.sectionId != responsibleRetrieved["section_id"])
            return;
        if (query.fieldId != null)
          if (query.fieldId != responsibleRetrieved["field_id"])
            return;
        if (query.customizableType != null)
          if (query.customizableType != responsibleRetrieved["customizable_type"])
            return;
        if (query.customizableId != null)
          if (query.customizableId != responsibleRetrieved["customizable_id"])
            return;
        if (query.value != null)
          if (query.value != responsibleRetrieved["value"])
            return;

        SectionModel customField = await ReadCustomFieldById(responsibleRetrieved["field_id"]);

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

        listOfCustomValues.add(new CustomValueModel(
          id: responsibleRetrieved["id"],
          createdAt: responsibleRetrieved["created_at"],
          updatedAt: responsibleRetrieved["updated_at"],
          formId: responsibleRetrieved["form_id"],
          sectionId: responsibleRetrieved["section_id"],
          fieldId: responsibleRetrieved["field_id"],
          customizableType: responsibleRetrieved["customizable_type"],
          customizableId: responsibleRetrieved["customizable_id"],
          value: responsibleRetrieved["value"],
          imageBase64: null,
          field: field,
        ));
      });
      return listOfCustomValues;
    }
    else
      return null;
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

    if (data.isNotEmpty) {
      List<CustomValueModel> listOfCustomValues = new List<CustomValueModel>();
      data.forEach((responsibleRetrieved) async {
        SectionModel customField = await ReadCustomFieldById(responsibleRetrieved["field_id"]);

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

        listOfCustomValues.add(new CustomValueModel(
          id: responsibleRetrieved["id"],
          createdAt: responsibleRetrieved["created_at"],
          updatedAt: responsibleRetrieved["updated_at"],
          formId: responsibleRetrieved["form_id"],
          sectionId: responsibleRetrieved["section_id"],
          fieldId: responsibleRetrieved["field_id"],
          customizableType: responsibleRetrieved["customizable_type"],
          customizableId: responsibleRetrieved["customizable_id"],
          value: responsibleRetrieved["value"],
          imageBase64: null,
          field: field,
        ));
      });
      return listOfCustomValues;
    }
    else
      return null;
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
      UpdateCustomField(
          customValue.field.id,
          SectionModel(
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
          syncState);
    else
      CreateCustomField(SectionModel(
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

    return await db.rawUpdate(
      '''
      UPDATE "custom_values" SET
      id = ?,
      created_at = ?,
      updated_at = ?,
      deleted_at = ?,
      forms_id = ?,
      section_id = ?,
      field_id = ?,
      customizable_type = ?,
      customizable_id = ?,
      value = ?,
      in_server = ?,
      updated = ?,
      deleted = ?,  
      WHERE id = ${customValueId}
      ''',
      [...[customValue.id, customValue.createdAt, customValue.updatedAt, customValue.formId,
    customValue.sectionId, customValue.fieldId,
    customValue.customizableType, customValue.customizableId,
    customValue.value], ...paramsBySyncState[syncState]],
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
      in_server = ? AND
      updated = ? AND
      deleted = ? AND
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

    if (data.isNotEmpty) {
      List<CustomValueModel> listOfCustomValues = new List<CustomValueModel>();
      data.forEach((responsibleRetrieved) async {
        SectionModel customField = await ReadCustomFieldById(responsibleRetrieved["field_id"]);

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

        listOfCustomValues.add(new CustomValueModel(
          id: responsibleRetrieved["id"],
          createdAt: responsibleRetrieved["created_at"],
          updatedAt: responsibleRetrieved["updated_at"],
          formId: responsibleRetrieved["form_id"],
          sectionId: responsibleRetrieved["section_id"],
          fieldId: responsibleRetrieved["field_id"],
          customizableType: responsibleRetrieved["customizable_type"],
          customizableId: responsibleRetrieved["customizable_id"],
          value: responsibleRetrieved["value"],
          imageBase64: null,
          field: field,
        ));
      });
      return listOfCustomValues;
    }
    else
      return null;
  }

  // Operations on customer_addresses
  Future<int> CreateCustomerAddress(int id, String createdAt,
      String updatedAt, String deletedAt,
      int customerId, int addressId,
      bool approved, SyncState syncState) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
        '''
      SELECT * FROM "customer_addresses" WHERE id = $id
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
      
      VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''',
      [...[id, createdAt, updatedAt, deletedAt, customerId, addressId,
    approved], ...paramsBySyncState[syncState]],
    );
  }

  Future<Map> ReadCustomerAddressById(int id) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
        '''
      SELECT * FROM "customer_addresses" WHERE id = $id
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
      SELECT * FROM "customer_addresses"
      '''
    );

    if (data.isNotEmpty) {
      List<Map> listOfCustomerAddresses = new List<Map>();
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
      return listOfCustomerAddresses;
    }
    else
      return null;
  }

  Future<List<Map>> ReadCustomerAddressesBySyncState(SyncState syncState) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT * FROM "customer_addresses" WHERE 
      in_server = ? AND
      updated = ? AND
      deleted = ?
      ''',
      paramsBySyncState[syncState],
    );

    if (data.isNotEmpty) {
      List<Map> listOfCustomerAddresses = new List<Map>();
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
      return listOfCustomerAddresses;
    }
    else
      return null;
  }

  Future<int> UpdateCustomerAddress(int id, String createdAt,
      String updatedAt, String deletedAt,
      int customerId, int addressId,
      bool approved, SyncState syncState) async {
    final db = await database;
    return await db.rawUpdate(
      '''
      UPDATE "customer_addresses" SET
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
      in_server = ?,
      updated = ?,
      deleted = ?,
      WHERE customer_id = $customerId AND address_id = $addressId
      ''',
      [...[id, createdAt, updatedAt, deletedAt, customerId, addressId,
    approved], ...paramsBySyncState[syncState]],
    );
  }

  Future<int> DeleteCustomerAddressById(int customerId, addressId) async {
    final db = await database;
    return await db.rawDelete(
        '''
      DELETE FROM "customer_addresses" WHERE customer_id = $customerId AND address_id = $addressId
      '''
    );
  }

  Future<int> ChangeSyncStateCustomerAddress(int customerId, int addressId, SyncState syncState) async {
    final db = await database;
    return await db.rawUpdate(
      '''
      UPDATE "customer_addresses" SET
      in_server = ? AND
      updated = ? AND
      deleted = ? AND
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
      SELECT * FROM "customer_addresses"
      '''
    );

    if (data.isNotEmpty) {
      List<Map> listOfCustomerAddresses = new List<Map>();
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
      return listOfCustomerAddresses;
    }
    else
      return null;
  }

  Future<List<String>> RetrieveAllCustomerAddressRelations() async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT customer_id, address_id FROM "customer_addresses"
      '''
    );

    if (data.isNotEmpty) {
      List<String> relations = new List<String>();
      data.forEach((relation) => relations.add(
          relation["customer_id"] + "-" + relation["address_id"]
      )
      );
      return relations;
    }
    else
      return null;
  }
}
import 'dart:core';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'SQL_Instructions.dart';

import '../models/AddressModel.dart';
import '../models/CustomerModel.dart';
import '../models/FormModel.dart';
import '../models/SectionModel.dart';
import '../models/TaskModel.dart';
import '../models/UserModel.dart';

enum SyncState {
  none,
  created,
  updated,
  deleted,
}

final Map<SyncState, List<dynamic>> paramsBySyncState = {
  // [in_server, updated, deleted]
  SyncState.none: [],
  SyncState.created: [false, true, false],
  SyncState.updated: [true, true, false],
  SyncState.deleted: [true, false, true],
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
  Future<int> CreateUser(UserModel user) async {
    final db = await database;
    return await db.rawInsert(
      '''
      INSERT INTO "mydb"."users"(
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
        deleted,
      )
      
      VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''',
      [...[user.id, user.createdAt, user.updatedAt, user.deletedAt,
      user.createdById, user.updatedById, user.deletedById,
      user.supervisorId, user.name, user.code, user.email,
      user.phone, user.mobile, user.title, user.details,
      user.profile, user.password, user.rememberToken],
      ...paramsBySyncState[SyncState.created]],
    );
  }

  Future<UserModel> ReadUser(int id) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT * FROM "mydb"."users" WHERE id = ${id}
      '''
    );
    return data;
  }

  Future<List<UserModel>> ReadUsersBySyncState(SyncState syncState) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT * FROM "mydb"."users" WHERE 
      in_server = ?,
      updated = ?,
      deleted = ?,
      ''',
      paramsBySyncState[syncState],
    );
    return data;
  }

  Future<int> UpdateUser(UserModel user) async {
    final db = await database;
    db.rawUpdate(
      '''
      UPDATE "mydb"."users" SET
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
      WHERE id = ${user.id}
      ''',
      [...[user.createdAt, user.updatedAt, user.deletedAt,
      user.createdById, user.updatedById, user.deletedById,
      user.supervisorId, user.name, user.code, user.email,
      user.phone, user.mobile, user.title, user.details,
      user.profile, user.password, user.rememberToken],
      ...paramsBySyncState[SyncState.updated]],
    );
  }

  Future<int> SoftDeleteUser(int id) async {
    final db = await database;
    db.rawUpdate(
      '''
      UPDATE "mydb"."users" SET
      in_server = ?,
      updated = ?,
      deleted = ?,
      WHERE id = ${id}
      ''',
      paramsBySyncState[SyncState.deleted],
    );
  }

  Future<int> DeleteUser(int id) async {
    final db = await database;
    await db.rawDelete(
      '''
      DELETE FROM "mydb"."users" WHERE id = ${id}
      '''
    );
  }

  Future<List<UserModel>> ListUsers() async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT * FROM "mydb"."users"
      '''
    );

    return data;
  }

  // Operations on forms
  Future<int> CreateForm(FormModel form) async {
    final db = await database;
    return await db.rawInsert(
      '''
      INSERT INTO "mydb"."forms"(
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
        deleted,
      )
      
      VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''',
      [...[form.id, form.createdAt, form.updatedAt, form.deletedAt,
      form.createdById, form.updatedById, form.deletedById, form.name,
      form.withCheckinout, form.active],
      ...paramsBySyncState[SyncState.created]],
    );
  }

  Future<FormModel> ReadForm(int id) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT * FROM "mydb"."forms" WHERE id = ${id}
      '''
    );

    return data;
  }

  Future<List<FormModel>> ReadFormsBySyncState(SyncState syncState) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT * FROM "mydb"."forms" WHERE 
      in_server = ?,
      updated = ?,
      deleted = ?,
      ''',
      paramsBySyncState[syncState],
    );

    return data;
  }

  Future<int> UpdateForm(FormModel form) async {
    final db = await database;
    await db.rawUpdate(
      '''
      UPDATE "mydb"."forms" SET
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
      WHERE id = ${form.id}
      ''',
      [...[form.id, form.createdAt, form.updatedAt, form.deletedAt,
      form.createdById, form.updatedById, form.deletedById, form.name,
      form.withCheckinout, form.active],
      ...paramsBySyncState[SyncState.updated]],
    );
  }

  Future<int> DeleteForm(int id) async {
    final db = await database;
    await db.rawDelete(
      '''
      DELETE FROM "mydb"."forms" WHERE id = ${id}
      '''
    );
  }

  Future<int> SoftDeleteForm(int id) async {
    final db = await database;
    await db.rawUpdate(
      '''
      UPDATE "mydb"."forms" SET
      in_server = ?,
      updated = ?,
      deleted = ?,
      WHERE id = ${id}
      ''',
      paramsBySyncState[SyncState.deleted],
    );
  }

  Future<List<FormModel>> ListForms() async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
        '''
        SELECT * FROM "mydb"."forms"
        '''
      );

    return data;
  }

  // Operations on localities
  Future<int> CreateLocality(LocalityModel locality) async {
    final db = await database;
    return await db.rawInsert(
      '''
        INSERT INTO "mydb"."localities"(
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
          deleted,
        );
        
        VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''',
      [...[locality.id, locality.createdAt, locality.updatedAt,
      locality.deletedAt, locality.createdById, locality.updatedById,
      locality.deletedById, locality.collection, locality.name,
      locality.value], ...paramsBySyncState[SyncState.created]],
    );
  }

  Future<LocalityModel> ReadLocality(int id) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT * FROM "mydb"."localities" WHERE id = ${id}
      '''
    );

    return data;
  }

  Future<List<LocalityModel>> ReadLocalitiesBySyncState(SyncState syncState) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT * FROM "mydb"."localities" WHERE 
      in_server = ?,
      updated = ?,
      deleted = ?,
      ''',
      paramsBySyncState[syncState],
    );

    return data;
  }

  Future<int> UpdateLocality(LocalityModel locality) async {
    final db = await database;
    await db.rawUpdate(
      '''
      UPDATE "mydb"."localities" SET
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
      WHERE id = ${locality.id}
      ''',
      [...[locality.createdAt, locality.updatedAt, locality.deletedAt,
      locality.createdById, locality.updatedById, locality.deletedById,
      locality.collection, locality.name, locality.value],
      ...paramsBySyncState[SyncState.updated]],
    );
  }

  Future<int> DeleteLocality(int id) async {
    final db = await database;
    await db.rawDelete(
      '''
      DELETE FROM "mydb"."localities" WHERE id = ${id}
      '''
    );
  }

  Future<int> SoftDeleteLocality(int id) async {
    final db = await database;
    await db.rawUpdate(
      '''
      UPDATE "mydb"."localities" SET
      in_server = ?,
      updated = ?,
      deleted = ?,
      WHERE id = ${id}
      ''',
      paramsBySyncState[SyncState.deleted],
    );
  }

  Future<List<LocalityModel>> ListLocalities() async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT * FROM "mydb"."localities"
      '''
    );

    return data;
  }

  // Operations on responsibles
  Future<int> CreateResponsible(ResponsibleModel responsible) async {
    final db = await database;
    return await db.rawInsert(
      '''
      INSERT INTO "mydb"."responsibles"(
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
        deleted,
      );
      
      VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''',
      [...[responsible.id, responsible.createdAt, responsible.updatedAt,
      responsible.deletedAt, responsible.createdById, responsible.updatedById,
      responsible.deletedById, responsible.supervisorId, responsible.name,
      responsible.code, responsible.email, responsible.phone,
      responsible.mobile, responsible.title, responsible.details,
      responsible.profile], ...paramsBySyncState[SyncState.created]],
    );
  }

  Future<ResponsibleModel> ReadResponsible(int id) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT * FROM "mydb"."responsibles" WHERE id = ${id}
      '''
    );

    return data;
  }

  Future<List<ResponsibleModel>> ReadResponsiblesBySyncState(SyncState syncState) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT * FROM "mydb"."responsibles" WHERE 
      in_server = ?,
      updated = ?,
      deleted = ?,
      ''',
      paramsBySyncState[syncState],
    );

    return data;
  }

  Future<int> UpdateResponsible(ResponsibleModel responsible) async {
    final db = await database;
    await db.rawUpdate(
      '''
      UPDATE "mydb"."responsibles" SET
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
      responsible.profile], ...paramsBySyncState[SyncState.updated]],
    );
  }

  Future<int> DeleteResponsible(int id) async {
    final db = await database;
    await db.rawDelete(
      '''
      DELETE FROM "mydb"."responsibles" WHERE id = ${id}
      '''
    );
  }

  Future<int> SoftDeleteResponsible(int id) async {
    final db = await database;
    await db.rawUpdate(
      '''
      UPDATE "mydb"."responsibles" SET
      in_server = ?,
      updated = ?,
      deleted = ?,
      WHERE id = ${id}
      ''',
      paramsBySyncState[SyncState.deleted],
    );
  }

  Future<List<ResponsibleModel>> ListResponsibles() async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT * FROM "mydb"."responsibles"
      '''
    );

    return data;
  }

  // Operations on custom_fields
  Future<int> CreateCustomField(SectionModel section) async {
    final db = await database;
    return await db.rawInsert(
      '''
      INSERT INTO "mydb"."custom_fields"(
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
        deleted,
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
      section.fieldPlaceholder, section.fieldOptions,
      section.fieldCollection, section.fieldRequired,
      section.fieldWidth], ...paramsBySyncState[SyncState.created]],
    );
  }

  Future<SectionModel> ReadCustomField(int id) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT * FROM "mydb"."custom_fields" WHERE id = ${id}
      '''
    );

    return data;
  }

  Future<List<SectionModel>> ReadCustomFieldsBySyncState(SyncState syncState) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT * FROM "mydb"."custom_fields" WHERE 
      in_server = ?,
      updated = ?,
      deleted = ?,
      ''',
      paramsBySyncState[syncState],
    );

    return data;
  }

  Future<int> UpdateCustomField(SectionModel section) async {
    final db = await database;
    await db.rawUpdate(
      '''
      UPDATE "mydb"."custom_fields" SET
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
      WHERE id = ${section.id}
      ''',
      [...[section.createdAt,section.updatedAt, section.deletedAt,
      section.createdById, section.updatedById, section.deletedById,
      section.sectionId, section.entityType, section.entityId, section.type,
      section.name, section.code, section.subtitle, section.position,
      section.fieldDefaultValue, section.fieldType, section.fieldPlaceholder,
      section.fieldOptions, section.fieldCollection, section.fieldRequired,
      section.fieldWidth], ...paramsBySyncState[SyncState.updated]],
    );
  }

  Future<int> DeleteCustomField(int id) async {
    final db = await database;
    await db.rawDelete(
      '''
      DELETE FROM "mydb"."custom_fields" WHERE id = ${id}
      '''
    );
  }

  Future<int> SoftDeleteCustomField(int id) async {
    final db = await database;
    await db.rawUpdate(
      '''
      UPDATE "mydb"."custom_fields" SET
      in_server = ?,
      updated = ?,
      deleted = ?,
      WHERE id = ${id}
      ''',
      paramsBySyncState[SyncState.deleted],
    );
  }

  Future<List<SectionModel>> ListCustomFields() async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT * FROM "mydb"."custom_fields"
      '''
    );

    return data;
  }

  // Operations on addresses
  Future<int> CreateAddress(AddressModel address) async {
    final db = await database;
    return await db.rawInsert(
      '''
      INSERT INTO "mydb"."addresses"(
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
        deleted,
      );
        
      VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''',

      [...[address.id, address.createdAt, address.updatedAt,
      address.deletedAt, address.createdById, address.updatedById,
      address.deletedById, address.localityId, address.address,
      address.details, address.reference, address.latitude, address.longitude,
      address.googlePlaceId, address.country,address.state, address.city,
      address.contactName, address.contactPhone, address.contactMobile,
      address.contactEmail], ...paramsBySyncState[SyncState.created]],
    );

  }

  Future<AddressModel> ReadAddress(int id) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT * FROM "mydb"."addresses" WHERE id = ${id}
      '''
    );

    return data;
  }

  Future<List<AddressModel>> ReadAddressesBySyncState(SyncState syncState) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT * FROM "mydb"."addresses" WHERE 
      in_server = ?,
      updated = ?,
      deleted = ?,
      ''',
      paramsBySyncState[syncState],
    );

    return data;
  }

  Future<int> UpdateAddress(AddressModel address) async {
    final db = await database;
    await db.rawUpdate(
      '''
      UPDATE "mydb"."addresses" SET
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
      WHERE id = ${address.id}
      ''',
      [...[address.createdAt, address.updatedAt, address.deletedAt,
      address.createdById, address.updatedById, address.deletedById,
      address.localityId, address.address, address.details, address.reference,
      address.latitude, address.longitude, address.googlePlaceId,
      address.country, address.state, address.city, address.contactName,
      address.contactPhone, address.contactMobile, address.contactEmail],
      ...paramsBySyncState[SyncState.updated]],
    );
  }

  Future<int> DeleteAddress(int id) async {
    final db = await database;
    await db.rawDelete(
      '''
      DELETE FROM "mydb"."addresses" WHERE id = ${id}
      '''
    );
  }

  Future<int> SoftDeleteAddress(int id) async {
    final db = await database;
    await db.rawUpdate(
      '''
      UPDATE "mydb"."addresses" SET
      in_server = ?,
      updated = ?,
      deleted = ?,
      WHERE id = ${id}
      ''',
      paramsBySyncState[SyncState.deleted],
    );
  }

  Future<List<AddressModel>> ListAddresses() async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT * FROM "mydb"."addresses"
      '''
    );

    return data;
  }

  // Operations on customers
  Future<int> CreateCustomer(CustomerModel customer) async {
    final db = await database;
    return await db.rawInsert(
      '''
      INSERT INTO "mydb"."customers"(
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
        deleted,
      );
        
      VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''',
      [...[customer.id, customer.createdAt, customer.updatedAt,
      customer.deletedAt, customer.createdById, customer.updatedById,
      customer.deletedById, customer.name, customer.code, customer.phone,
      customer.email, customer.contactName, customer.details],
      ...paramsBySyncState[SyncState.created]],
    );
  }

  Future<CustomerModel> ReadCustomer(int id) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT * FROM "mydb"."customers" WHERE id = ${id}
      '''
    );

    return data;
  }

  Future<List<CustomerModel>> ReadCustomersBySyncState(SyncState syncState) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT * FROM "mydb"."customers" WHERE 
      in_server = ?,
      updated = ?,
      deleted = ?,
      ''',
      paramsBySyncState[syncState],
    );

    return data;
  }

  Future<int> UpdateCustomer(CustomerModel customer) async {
    final db = await database;
    await db.rawUpdate(
      '''
      UPDATE "mydb"."customers" SET
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
      WHERE id = ${customer.id}
      ''',
      [...[customer.createdAt, customer.updatedAt, customer.deletedAt,
      customer.createdById, customer.updatedById, customer.deletedById,
      customer.name, customer.code, customer.phone, customer.email,
      customer.contactName, customer.details],
      ...paramsBySyncState[SyncState.updated]],
    );
  }

  Future<int> DeleteCustomer(int id) async {
    final db = await database;
    await db.rawDelete(
      '''
      DELETE FROM "mydb"."customers" WHERE id = ${id}
      '''
    );
  }

  Future<int> SoftDeleteCustomer(int id) async {
    final db = await database;
    await db.rawUpdate(
      '''
      UPDATE "mydb"."customers" SET
      in_server = ?,
      updated = ?,
      deleted = ?,
      WHERE id = ${id}
      ''',
      paramsBySyncState[SyncState.deleted],
    );
  }

  Future<List<CustomerModel>> ListCustomers() async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT * FROM "mydb"."customers"
      '''
    );

    return data;
  }

  // Operations on tasks
  Future<int> CreateTask(TaskModel task) async {
    final db = await database;
    return await db.rawInsert(
      '''
      INSERT INTO "mydb"."tasks"(
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
        deleted,
      );
        
      VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''',
      [...[task.id, task.createdAt, task.updatedAt, task.deletedAt,
      task.createdById, task.updatedById, task.deletedById, task.formId,
      task.responsibleId, task.customerId, task.addressId, task.name,
      task.planningDate, task.checkinDate, task.checkinLatitude,
      task.checkinLongitude, task.checkinDistance, task.checkoutDate,
      task.checkoutLatitude, task.checkoutLongitude, task.checkoutDistance,
      task.status], ...paramsBySyncState[SyncState.created]],
    );
  }

  Future<TaskModel> ReadTask(int id) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT * FROM "mydb"."tasks" WHERE id = ${id}
      '''
    );

    return data;
  }

  Future<List<TaskModel>> ReadTasksBySyncState(SyncState syncState) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT * FROM "mydb"."tasks" WHERE 
      in_server = ?,
      updated = ?,
      deleted = ?,
      ''',
      paramsBySyncState[syncState],
    );

    return data;
  }

  Future<int> UpdateTask(TaskModel task) async {
    final db = await database;
    await db.rawUpdate(
      '''
      UPDATE "mydb"."tasks" SET
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
      WHERE id = ${task.id}
      ''',
      [...[task.createdAt, task.updatedAt, task.deletedAt, task.createdById,
      task.updatedById, task.deletedById, task.formId, task.responsibleId,
      task.customerId, task.addressId, task.name, task.planningDate,
      task.checkinDate, task.checkinLatitude, task.checkinLongitude,
      task.checkinDistance, task.checkoutDate, task.checkoutLatitude,
      task.checkoutLongitude, task.checkoutDistance, task.status],
      ...paramsBySyncState[SyncState.updated]],
    );
  }

  Future<int> DeleteTask(int id) async {
    final db = await database;
    await db.rawDelete(
      '''
      DELETE FROM "mydb"."tasks" WHERE id = ${id}
      '''
    );
  }

  Future<int> SoftDeleteTaks(int id) async {
    final db = await database;
    await db.rawUpdate(
      '''
      UPDATE "mydb"."tasks" SET
      in_server = ?,
      updated = ?,
      deleted = ?,
      WHERE id = ${id}
      ''',
      paramsBySyncState[SyncState.deleted],
    );
  }

  Future<List<TaskModel>> ListTasks() async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT * FROM "mydb"."tasks"
      '''
    );

    return data;
  }

  // Operations on custom_users
  Future<int> CreateCustomerUser(int id, String createdAt, String updatedAt,
                                     String deletedAt, int customerId,
                                     int userId) async {
    final db = await database;
    return await db.rawInsert(
      '''
      INSERT INTO "mydb"."customers_users"(
        id,
        created_at,
        updated_at,
        deleted_at,
        customer_id,
        user_id,
        in_server,
        updated,
        deleted,
      );
      
      VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''',
      [...[id, createdAt, updatedAt, deletedAt, customerId, userId],
      ...paramsBySyncState[SyncState.created]],
    );
  }

  Future<Map> ReadCustomerUser(int id) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT * FROM "mydb"."customers_users" WHERE id = ${id}
      '''
    );

    return data;
  }

  Future<List<Map>> ReadCustomerUsersBySyncState(SyncState syncState) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT * FROM "mydb"."customer_users" WHERE 
      in_server = ?,
      updated = ?,
      deleted = ?,
      ''',
      paramsBySyncState[syncState],
    );

    return data;
  }

  Future<int> UpdateCustomerUser(int id, String createdAt, String updatedAt,
                                     String deletedAt, int customerId,
                                     int userId) async {
    final db = await database;
    await db.rawUpdate(
      '''
      UPDATE "mydb"."customer_users" SET
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
      WHERE id = ${id}
      ''',
      [...[createdAt, updatedAt, deletedAt, customerId, userId],
      ...paramsBySyncState[SyncState.updated]],
    );
  }

  Future<int> DeleteCustomerUser(int id) async {
    final db = await database;
    await db.rawDelete(
      '''
      DELETE FROM "mydb"."customer_users" WHERE id = ${id}
      '''
    );
  }

  Future<int> SoftDeleteCustomerUser(int id) async {
    final db = await database;
    await db.rawUpdate(
      '''
      UPDATE "mydb"."customer_users" SET
      in_server = ?,
      updated = ?,
      deleted = ?,
      WHERE id = ${id}
      ''',
      paramsBySyncState[SyncState.deleted],
    );
  }

  Future<List<Map>> ListCustomerUsers() async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT * FROM "mydb"."customer_users"
      '''
    );

    return data;
  }

  // Operations on custom_values
  Future<int> CreateCustomValue(CustomValueModel customValue) async {
    final db = await database;
    return await db.rawInsert(
      '''
      INSERT INTO "mydb"."custom_values"(
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
        deleted,  
      );
        
      VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''',
      [...[customValue.id, customValue.createdAt, customValue.updatedAt,
      customValue.formId, customValue.sectionId, customValue.fieldId,
      customValue.customizableType, customValue.customizableId,
      customValue.value], ...paramsBySyncState[SyncState.created]],
    );

  }

  Future<CustomValueModel> ReadCustomValue(int id) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT * FROM "mydb"."custom_values" WHERE id = ${id}
      '''
    );

    return data;
  }

  Future<List<CustomValueModel>> ReadCustomValuesBySyncState(SyncState syncState) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT * FROM "mydb"."custom_values" WHERE 
      in_server = ?,
      updated = ?,
      deleted = ?,
      ''',
      paramsBySyncState[syncState],
    );

    return data;
  }

  Future<int> UpdateCustomValue(CustomValueModel customValue) async {
    final db = await database;
    await db.rawUpdate(
      '''
      UPDATE "mydb"."custom_values" SET
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
      WHERE id = ${customValue.id}
      ''',
      [...[customValue.createdAt, customValue.updatedAt, customValue.formId,
      customValue.sectionId, customValue.fieldId,
      customValue.customizableType, customValue.customizableId,
      customValue.value], ...paramsBySyncState[SyncState.updated]],
    );
  }

  Future<int> DeleteCustomValue(int id) async {
    final db = await database;
    await db.rawDelete(
      '''
      DELETE FROM "mydb"."custom_values" WHERE id = ${id}
      '''
    );
  }

  Future<int> SoftDeleteCustomValue(int id) async {
    final db = await database;
    await db.rawUpdate(
      '''
      UPDATE "mydb"."custom_values" SET
      in_server = ?,
      updated = ?,
      deleted = ?,
      WHERE id = ${id}
      ''',
      paramsBySyncState[SyncState.deleted],
    );
  }

  Future<List<CustomValueModel>> ListCustomValues() async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT * FROM "mydb"."custom_values"
      '''
    );

    return data;
  }

  // Operations on customer_addresses
  Future<int> CreateCustomerAdress(int id, String createdAt,
                                       String updatedAt, String deletedAt,
                                       int customerId, int addressId,
                                       bool approved) async {
    final db = await database;
    return await db.rawInsert(
      '''
      INSERT INTO "mydb"."customers_addresses"(
        id,
        created_at,
        updated_at,
        deleted_at,
        customer_id,
        address_id,
        approved,
        in_server,
        updated,
        deleted,
      )
      
      VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''',
      [...[id, createdAt, updatedAt, deletedAt, customerId, addressId,
      approved], ...paramsBySyncState[SyncState.created]],
    );
  }

  Future<Map> ReadCustomerAdress(int id) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT * FROM "mydb"."customer_addresses" WHERE id = ${id}
      '''
    );

    return data;
  }

  Future<List<Map>> ReadCustomerAddressesBySyncState(SyncState syncState) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT * FROM "mydb"."customer_addresses" WHERE 
      in_server = ?,
      updated = ?,
      deleted = ?,
      ''',
      paramsBySyncState[syncState],
    );

    return data;
  }

  Future<int> UpdateCustomerAdress(int id, String createdAt,
                                       String updatedAt, String deletedAt,
                                       int customerId, int addressId,
                                       bool approved) async {
    final db = await database;
    await db.rawUpdate(
      '''
      UPDATE "mydb"."customer_addresses" SET
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
      WHERE id = ${id}
      ''',
      [...[createdAt, updatedAt, deletedAt, customerId, addressId,
      approved], ...paramsBySyncState[SyncState.updated]],
    );
  }

  Future<int> DeleteCustomerAdress(int id) async {
    final db = await database;
    await db.rawDelete(
      '''
      DELETE FROM "mydb"."customer_addresses" WHERE id = ${id}
      '''
    );
  }

  Future<int> SoftDeleteCustomerAddress(int id) async {
    final db = await database;
    await db.rawUpdate(
      '''
      UPDATE "mydb"."customer_addresses" SET
      in_server = ?,
      updated = ?,
      deleted = ?,
      WHERE id = ${id}
      ''',
      paramsBySyncState[SyncState.deleted],
    );
  }

  Future<List<Map>> ListCustomerAdresses() async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT * FROM "mydb"."customer_addresses"
      '''
    );

    return data;
  }

}
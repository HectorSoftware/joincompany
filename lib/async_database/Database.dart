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
      ...paramsBySyncState[SyncState.created]],
    );
  }

  Future/*Type: <UserModel>*/ ReadUser(int id) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT * FROM "users" WHERE id = ${id}
      '''
    );
    return data;
  }

  Future/*Type: <List<UserModel>>*/ ReadUsersBySyncState(SyncState syncState) async {
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

    return data;
  }

  Future<int> UpdateUser(UserModel user) async {
    final db = await database;
    return db.rawUpdate(
      '''
      UPDATE "users" SET
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

  Future<int> ChangeSyncStateUser(int id, SyncState syncState) async {
    final db = await database;return
    db.rawUpdate(
      '''
      UPDATE "users" SET
      in_server = ? AND
      updated = ? AND
      deleted = ? AND
      WHERE id = ${id}
      ''',
      paramsBySyncState[syncState],
    );
  }

  Future<int> DeleteUser(int id) async {
    final db = await database;
    await db.rawDelete(
      '''
      DELETE FROM "users" WHERE id = ${id}
      '''
    );
  }

  Future/*Type: <List<UserModel>>*/ ListUsers() async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT * FROM "users"
      '''
    );

    return data;
  }

  // Operations on forms
  Future<int> CreateForm(FormModel form) async {
    final db = await database;
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
      ...paramsBySyncState[SyncState.created]],
    );
  }

  Future/*Type: <FormModel>*/ ReadForm(int id) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT * FROM "forms" WHERE id = ${id}
      '''
    );

    return data;
  }

  Future/*Type: <List<FormModel>>*/ ReadFormsBySyncState(SyncState syncState) async {
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

    return data;
  }

  Future<int> UpdateForm(FormModel form) async {
    final db = await database;
    return await db.rawUpdate(
      '''
      UPDATE "forms" SET
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
      DELETE FROM "forms" WHERE id = ${id}
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
      WHERE id = ${id}
      ''',
      paramsBySyncState[syncState],
    );
  }

  Future/*Type: <List<FormModel>>*/ ListForms() async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
        '''
        SELECT * FROM "forms"
        '''
      );

    return data;
  }

  // Operations on localities
  Future<int> CreateLocality(LocalityModel locality) async {
    final db = await database;
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
      locality.value], ...paramsBySyncState[SyncState.created]],
    );
  }

  Future/*Type: <LocalityModel>*/ ReadLocality(int id) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT * FROM "localities" WHERE id = ${id}
      '''
    );

    return data;
  }

  Future/*Type: <List<LocalityModel>>*/ ReadLocalitiesBySyncState(SyncState syncState) async {
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

    return data;
  }

  Future<int> UpdateLocality(LocalityModel locality) async {
    final db = await database;
    return await db.rawUpdate(
      '''
      UPDATE "localities" SET
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
      DELETE FROM "localities" WHERE id = ${id}
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
      WHERE id = ${id}
      ''',
      paramsBySyncState[syncState],
    );
  }

  Future/*Type: <List<LocalityModel>>*/ ListLocalities() async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT * FROM "localities"
      '''
    );

    return data;
  }

  // Operations on responsibles
  Future<int> CreateResponsible(ResponsibleModel responsible) async {
    final db = await database;
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
      responsible.profile], ...paramsBySyncState[SyncState.created]],
    );
  }

  Future/*Type: <ResponsibleModel>*/ ReadResponsible(int id) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT * FROM "responsibles" WHERE id = ${id}
      '''
    );

    return data;
  }

  Future/*Type: <List<ResponsibleModel>>*/ ReadResponsiblesBySyncState(SyncState syncState) async {
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

    return data;
  }

  Future<int> UpdateResponsible(ResponsibleModel responsible) async {
    final db = await database;
    return await db.rawUpdate(
      '''
      UPDATE "responsibles" SET
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
      DELETE FROM "responsibles" WHERE id = ${id}
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
      WHERE id = ${id}
      ''',
      paramsBySyncState[syncState],
    );
  }

  Future/*Type: <List<ResponsibleModel>>*/ ListResponsibles() async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT * FROM "responsibles"
      '''
    );

    return data;
  }

  // Operations on custom_fields
  Future<int> CreateCustomField(SectionModel section) async {
    final db = await database;
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
      section.fieldPlaceholder, section.fieldOptions,
      section.fieldCollection, section.fieldRequired,
      section.fieldWidth], ...paramsBySyncState[SyncState.created]],
    );
  }

  Future/*Type: <SectionModel>*/ ReadCustomField(int id) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT * FROM "custom_fields" WHERE id = ${id}
      '''
    );

    return data;
  }

  Future/*Type: <List<SectionModel>>*/ ReadCustomFieldsBySyncState(SyncState syncState) async {
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

    return data;
  }

  Future<int> UpdateCustomField(SectionModel section) async {
    final db = await database;
    return await db.rawUpdate(
      '''
      UPDATE "custom_fields" SET
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
      DELETE FROM "custom_fields" WHERE id = ${id}
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
      WHERE id = ${id}
      ''',
      paramsBySyncState[syncState],
    );
  }

  Future/*Type: <List<SectionModel>>*/ ListCustomFields() async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT * FROM "custom_fields"
      '''
    );

    return data;
  }

  // Operations on addresses
  Future<int> CreateAddress(AddressModel address) async {
    final db = await database;
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
      address.contactEmail], ...paramsBySyncState[SyncState.created]],
    );

  }

  Future/*Type: <AddressModel>*/ ReadAddress(int id) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT * FROM "addresses" WHERE id = ${id}
      '''
    );

    return data;
  }

  Future/*Type: <List<AddressModel>>*/ ReadAddressesBySyncState(SyncState syncState) async {
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

    return data;
  }

  Future<int> UpdateAddress(AddressModel address) async {
    final db = await database;
    return await db.rawUpdate(
      '''
      UPDATE "addresses" SET
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
      DELETE FROM "addresses" WHERE id = ${id}
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
      WHERE id = ${id}
      ''',
      paramsBySyncState[syncState],
    );
  }

  Future/*Type: <List<AddressModel>>*/ ListAddresses() async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT * FROM "addresses"
      '''
    );

    return data;
  }

  // Operations on customers
  Future<int> CreateCustomer(CustomerModel customer) async {
    final db = await database;
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
      ...paramsBySyncState[SyncState.created]],
    );
  }

  Future/*Type: <CustomerModel>*/ ReadCustomer(int id) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT * FROM "customers" WHERE id = ${id}
      '''
    );

    return data;
  }

  Future/*Type: <List<CustomerModel>>*/ ReadCustomersBySyncState(SyncState syncState) async {
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

    return data;
  }

  Future<int> UpdateCustomer(CustomerModel customer) async {
    final db = await database;
    return await db.rawUpdate(
      '''
      UPDATE "customers" SET
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
      DELETE FROM "customers" WHERE id = ${id}
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
      WHERE id = ${id}
      ''',
      paramsBySyncState[syncState],
    );
  }

  Future/*Type: <List<CustomerModel>>*/ ListCustomers() async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT * FROM "customers"
      '''
    );

    return data;
  }

  // Operations on tasks
  Future<int> CreateTask(TaskModel task) async {
    final db = await database;
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
      task.status], ...paramsBySyncState[SyncState.created]],
    );
  }

  Future/*Type: <TaskModel>*/ ReadTask(int id) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT * FROM "tasks" WHERE id = ${id}
      '''
    );

    return data;
  }

  Future/*Type: <List<TaskModel>>*/ ReadTasksBySyncState(SyncState syncState) async {
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

    return data;
  }

  Future<int> UpdateTask(TaskModel task) async {
    final db = await database;
    return await db.rawUpdate(
      '''
      UPDATE "tasks" SET
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
      DELETE FROM "tasks" WHERE id = ${id}
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
      WHERE id = ${id}
      ''',
      paramsBySyncState[syncState],
    );
  }

  Future/*Type: <List<TaskModel>>*/ ListTasks() async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT * FROM "tasks"
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
      ...paramsBySyncState[SyncState.created]],
    );
  }

  Future/*Type: <Map>*/ ReadCustomerUser(int id) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT * FROM "customers_users" WHERE id = ${id}
      '''
    );

    return data;
  }

  Future/*Type: <List<Map>>*/ ReadCustomerUsersBySyncState(SyncState syncState) async {
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

    return data;
  }

  Future<int> UpdateCustomerUser(int id, String createdAt, String updatedAt,
                                 String deletedAt, int customerId,
                                 int userId) async {
    final db = await database;
    return await db.rawUpdate(
      '''
      UPDATE "customer_users" SET
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
      DELETE FROM "customer_users" WHERE id = ${id}
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
      WHERE id = ${id}
      ''',
      paramsBySyncState[syncState],
    );
  }

  Future/*Type: <List<Map>>*/ ListCustomerUsers() async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT * FROM "customer_users"
      '''
    );

    return data;
  }

  // Operations on custom_values
  Future<int> CreateCustomValue(CustomValueModel customValue) async {
    final db = await database;
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
      customValue.value], ...paramsBySyncState[SyncState.created]],
    );

  }

  Future/*Type: <CustomValueModel>*/ ReadCustomValue(int id) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT * FROM "custom_values" WHERE id = ${id}
      '''
    );

    return data;
  }

  Future/*Type: <List<CustomValueModel>>*/ ReadCustomValuesBySyncState(SyncState syncState) async {
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

    return data;
  }

  Future<int> UpdateCustomValue(CustomValueModel customValue) async {
    final db = await database;
    return await db.rawUpdate(
      '''
      UPDATE "custom_values" SET
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
      DELETE FROM "custom_values" WHERE id = ${id}
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
      WHERE id = ${id}
      ''',
      paramsBySyncState[syncState],
    );
  }

  Future/*Type: <List<CustomValueModel>>*/ ListCustomValues() async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT * FROM "custom_values"
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
      approved], ...paramsBySyncState[SyncState.created]],
    );
  }

  Future/*Type: <Map>*/ ReadCustomerAdress(int id) async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT * FROM "customer_addresses" WHERE id = ${id}
      '''
    );

    return data;
  }

  Future/*Type: <List<Map>>*/ ReadCustomerAddressesBySyncState(SyncState syncState) async {
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

    return data;
  }

  Future<int> UpdateCustomerAdress(int id, String createdAt,
                                   String updatedAt, String deletedAt,
                                   int customerId, int addressId,
                                   bool approved) async {
    final db = await database;
    return await db.rawUpdate(
      '''
      UPDATE "customer_addresses" SET
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
      DELETE FROM "customer_addresses" WHERE id = ${id}
      '''
    );
  }

  Future<int> ChangeSyncStateCustomerAddress(int id, SyncState syncState) async {
    final db = await database;
    return await db.rawUpdate(
      '''
      UPDATE "customer_addresses" SET
      in_server = ? AND
      updated = ? AND
      deleted = ? AND
      WHERE id = ${id}
      ''',
      paramsBySyncState[syncState],
    );
  }

  Future/*Type: <List<Map>>*/ ListCustomerAdresses() async {
    final db = await database;
    List<Map<String, dynamic>> data;
    data = await db.rawQuery(
      '''
      SELECT * FROM "customer_addresses"
      '''
    );

    return data;
  }

}
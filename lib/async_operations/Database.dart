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

enum AsyncOperation {
  none,
  create,
  update,
  delete,
}

final Map<AsyncOperation, List<dynamic>> operations = {
  // [in_server, updated, deleted]
  AsyncOperation.none: [],
  AsyncOperation.create: [false, true, false],
  AsyncOperation.update: [true, true, false],
  AsyncOperation.delete: [true, false, true],
};

class AsyncOperationsDatabase {
  Database _database;

  Future<Database> get database async {
    if (_database != null)
      return _database;
    _database = await getDatabaseInstance();
    return _database;
  }

  Future<Database> getDatabaseInstance() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path, "Async.db");
    return await openDatabase(
        path,
        version: 1,
        onCreate: (Database db, int version) async {
          await db.execute(asyncSQLInstructionsOnCreate);
        }
    );
  }

  // Operations on users
  Future<dynamic> CreateUser(UserModel user) async {
    await _database.transaction((transaction) async {
      await transaction.rawInsert(
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
        ...operations[AsyncOperation.create]],
      );
    });
  }

  Future<dynamic> ReadUser(int id) async {
    List<Map<String, dynamic>> data;
    await _database.transaction((transaction) async {
      data = await transaction.rawQuery(
        '''
        SELECT * FROM "mydb"."users" WHERE id = ${id}
        '''
      );
    });
    return data;
  }

  Future<dynamic> UpdateUser(UserModel user) async {
    await _database.transaction((transaction) async {
      await transaction.rawUpdate(
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
        ...operations[AsyncOperation.update]],
      );
    });
  }

  Future<dynamic> SoftDeleteUser(int id) async {
    await _database.transaction((transaction) async {
      await transaction.rawUpdate(
        '''
        UPDATE "mydb"."users" SET
        in_server = ?,
        updated = ?,
        deleted = ?,
        WHERE id = ${id}
        ''',
        operations[AsyncOperation.delete],
      );
    });
  }

  Future<dynamic> DeleteUser(int id) async {
    await _database.transaction((transaction) async {
      await transaction.rawDelete(
        '''
        DELETE FROM "mydb"."users" WHERE id = ${id}
        '''
      );
    });
  }

  Future<dynamic> ListUsers() async {
    List<Map<String, dynamic>> data;
    await _database.transaction((transaction) async {
      data = await transaction.rawQuery(
        '''
        SELECT * FROM "mydb"."users"
        '''
      );
    });
    return data;
  }

  // Operations on forms
  Future<dynamic> CreateForm(FormModel form) async {
    await _database.transaction((transaction) async {
      await transaction.rawInsert(
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
        ...operations[AsyncOperation.create]],
      );
    });
  }

  Future<dynamic> ReadForm(int id) async {
    List<Map<String, dynamic>> data;
    await _database.transaction((transaction) async {
      data = await transaction.rawQuery(
        '''
        SELECT * FROM "mydb"."forms" WHERE id = ${id}
        '''
      );
    });
    return data;
  }

  Future<dynamic> UpdateForm(FormModel form) async {
    await _database.transaction((transaction) async {
      await transaction.rawUpdate(
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
        ...operations[AsyncOperation.update]],
      );
    });
  }

  Future<dynamic> DeleteForm(int id) async {
    await _database.transaction((transaction) async {
      await transaction.rawDelete(
        '''
        DELETE FROM "mydb"."forms" WHERE id = ${id}
        '''
      );
    });
  }

  Future<dynamic> SoftDeleteForm(int id) async {
    await _database.transaction((transaction) async {
      await transaction.rawUpdate(
        '''
        UPDATE "mydb"."forms" SET
        in_server = ?,
        updated = ?,
        deleted = ?,
        WHERE id = ${id}
        ''',
        operations[AsyncOperation.delete],
      );
    });
  }

  Future<dynamic> ListForms() async {
    List<Map<String, dynamic>> data;
    await _database.transaction((transaction) async {
      data = await transaction.rawQuery(
          '''
        SELECT * FROM "mydb"."forms"
        '''
      );
    });
    return data;
  }

  // Operations on localities
  Future<dynamic> CreateLocality(LocalityModel locality) async {
    await _database.transaction((transaction) async {
      await transaction.rawInsert(
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
        locality.value], ...operations[AsyncOperation.create]],
      );
    });
  }

  Future<dynamic> ReadLocality(int id) async {
    List<Map<String, dynamic>> data;
    await _database.transaction((transaction) async {
      data = await transaction.rawQuery(
          '''
        SELECT * FROM "mydb"."localities" WHERE id = ${id}
        '''
      );
    });
    return data;
  }

  Future<dynamic> UpdateLocality(LocalityModel locality) async {
    await _database.transaction((transaction) async {
      await transaction.rawUpdate(
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
        ...operations[AsyncOperation.update]],
      );
    });
  }

  Future<dynamic> DeleteLocality(int id) async {
    await _database.transaction((transaction) async {
      await transaction.rawDelete(
        '''
        DELETE FROM "mydb"."localities" WHERE id = ${id}
        '''
      );
    });
  }

  Future<dynamic> SoftDeleteLocality(int id) async {
    await _database.transaction((transaction) async {
      await transaction.rawUpdate(
        '''
        UPDATE "mydb"."localities" SET
        in_server = ?,
        updated = ?,
        deleted = ?,
        WHERE id = ${id}
        ''',
        operations[AsyncOperation.delete],
      );
    });
  }

  Future<dynamic> ListLocalities() async {
    List<Map<String, dynamic>> data;
    await _database.transaction((transaction) async {
      data = await transaction.rawQuery(
        '''
        SELECT * FROM "mydb"."localities"
        '''
      );
    });
    return data;
  }

  // Operations on responsibles
  Future<dynamic> CreateResponsible(ResponsibleModel responsible) async {
    await _database.transaction((transaction) async {
      await transaction.rawInsert(
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
        responsible.profile], ...operations[AsyncOperation.create]],
      );
    });
  }

  Future<dynamic> ReadResponsible(int id) async {
    List<Map<String, dynamic>> data;
    await _database.transaction((transaction) async {
      data = await transaction.rawQuery(
        '''
        SELECT * FROM "mydb"."responsibles" WHERE id = ${id}
        '''
      );
    });
    return data;
  }

  Future<dynamic> UpdateResponsible(ResponsibleModel responsible) async {
    await _database.transaction((transaction) async {
      await transaction.rawUpdate(
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
        responsible.profile], ...operations[AsyncOperation.update]],
      );
    });
  }

  Future<dynamic> DeleteResponsible(int id) async {
    await _database.transaction((transaction) async {
      await transaction.rawDelete(
        '''
        DELETE FROM "mydb"."responsibles" WHERE id = ${id}
        '''
      );
    });
  }

  Future<dynamic> SoftDeleteResponsible(int id) async {
    await _database.transaction((transaction) async {
      await transaction.rawUpdate(
        '''
        UPDATE "mydb"."responsibles" SET
        in_server = ?,
        updated = ?,
        deleted = ?,
        WHERE id = ${id}
        ''',
        operations[AsyncOperation.delete],
      );
    });
  }

  Future<dynamic> ListResponsibles() async {
    List<Map<String, dynamic>> data;
    await _database.transaction((transaction) async {
      data = await transaction.rawQuery(
        '''
        SELECT * FROM "mydb"."responsibles"
        '''
      );
    });
    return data;
  }

  // Operations on custom_fields
  Future<dynamic> CreateCustomField(SectionModel section) async {
    await _database.transaction((transaction) async {
      await transaction.rawInsert(
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
        section.fieldWidth], ...operations[AsyncOperation.create]],
      );
    });
  }

  Future<dynamic> ReadCustomField(int id) async {
    List<Map<String, dynamic>> data;
    await _database.transaction((transaction) async {
      data = await transaction.rawQuery(
        '''
        SELECT * FROM "mydb"."custom_fields" WHERE id = ${id}
        '''
      );
    });
    return data;
  }

  Future<dynamic> UpdateCustomField(SectionModel section) async {
    await _database.transaction((transaction) async {
      await transaction.rawUpdate(
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
        section.fieldWidth], ...operations[AsyncOperation.update]],
      );
    });
  }

  Future<dynamic> DeleteCustomField(int id) async {
    await _database.transaction((transaction) async {
      await transaction.rawDelete(
        '''
        DELETE FROM "mydb"."custom_fields" WHERE id = ${id}
        '''
      );
    });
  }

  Future<dynamic> SoftDeleteCustomField(int id) async {
    await _database.transaction((transaction) async {
      await transaction.rawUpdate(
        '''
        UPDATE "mydb"."custom_fields" SET
        in_server = ?,
        updated = ?,
        deleted = ?,
        WHERE id = ${id}
        ''',
        operations[AsyncOperation.delete],
      );
    });
  }

  Future<dynamic> ListCustomFields() async {
    List<Map<String, dynamic>> data;
    await _database.transaction((transaction) async {
      data = await transaction.rawQuery(
        '''
        SELECT * FROM "mydb"."custom_fields"
        '''
      );
    });
    return data;
  }

  // Operations on addresses
  Future<dynamic> CreateAddress(AddressModel address) async {
    await _database.transaction((transaction) async {
      await transaction.rawInsert(
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
        address.contactEmail], ...operations[AsyncOperation.create]],
      );
    });
  }

  Future<dynamic> ReadAddress(int id) async {
    List<Map<String, dynamic>> data;
    await _database.transaction((transaction) async {
      data = await transaction.rawQuery(
        '''
        SELECT * FROM "mydb"."addresses" WHERE id = ${id}
        '''
      );
    });
    return data;
  }

  Future<dynamic> UpdateAddress(AddressModel address) async {
    await _database.transaction((transaction) async {
      await transaction.rawUpdate(
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
        ...operations[AsyncOperation.update]],
      );
    });
  }

  Future<dynamic> DeleteAddress(int id) async {
    await _database.transaction((transaction) async {
      await transaction.rawUpdate(
        '''
        UPDATE "mydb"."addresses" SET
        in_server = ?,
        updated = ?,
        deleted = ?,
        WHERE id = ${id}
        ''',
        operations[AsyncOperation.delete],
      );
    });
  }

  Future<dynamic> SoftDeleteAddress(int id) async {
    await _database.transaction((transaction) async {
      await transaction.rawUpdate(
        '''
        UPDATE "mydb"."addresses" SET
        in_server = ?,
        updated = ?,
        deleted = ?,
        WHERE id = ${id}
        ''',
        operations[AsyncOperation.delete],
      );
    });
  }

  Future<dynamic> ListAddresses() async {
    List<Map<String, dynamic>> data;
    await _database.transaction((transaction) async {
      data = await transaction.rawQuery(
        '''
        SELECT * FROM "mydb"."addresses"
        '''
      );
    });
    return data;
  }

  // Operations on customers
  Future<dynamic> CreateCustomer(CustomerModel customer) async {
    await _database.transaction((transaction) async {
      await transaction.rawInsert(
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
        ...operations[AsyncOperation.create]],
      );
    });
  }

  Future<dynamic> ReadCustomer(int id) async {
    List<Map<String, dynamic>> data;
    await _database.transaction((transaction) async {
      data = await transaction.rawQuery(
        '''
        SELECT * FROM "mydb"."customers" WHERE id = ${id}
        '''
      );
    });
    return data;
  }

  Future<dynamic> UpdateCustomer(CustomerModel customer) async {
    await _database.transaction((transaction) async {
      await transaction.rawUpdate(
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
        ...operations[AsyncOperation.update]],
      );
    });
  }

  Future<dynamic> DeleteCustomer(int id) async {
    await _database.transaction((transaction) async {
      await transaction.rawDelete(
        '''
        DELETE FROM "mydb"."customers" WHERE id = ${id}
        '''
      );
    });
  }

  Future<dynamic> SoftDeleteCustomer(int id) async {
    await _database.transaction((transaction) async {
      await transaction.rawUpdate(
        '''
        UPDATE "mydb"."customers" SET
        in_server = ?,
        updated = ?,
        deleted = ?,
        WHERE id = ${id}
        ''',
        operations[AsyncOperation.delete],
      );
    });
  }

  Future<dynamic> ListCustomers() async {
    List<Map<String, dynamic>> data;
    await _database.transaction((transaction) async {
      data = await transaction.rawQuery(
        '''
        SELECT * FROM "mydb"."customers"
        '''
      );
    });
    return data;
  }

  // Operations on tasks
  Future<dynamic> CreateTask(TaskModel task) async {
    await _database.transaction((transaction) async {
      await transaction.rawInsert(
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
        task.status], ...operations[AsyncOperation.create]],
      );
    });
  }

  Future<dynamic> ReadTask(int id) async {
    List<Map<String, dynamic>> data;
    await _database.transaction((transaction) async {
      data = await transaction.rawQuery(
        '''
        SELECT * FROM "mydb"."tasks" WHERE id = ${id}
        '''
      );
    });
    return data;
  }

  Future<dynamic> UpdateTask(TaskModel task) async {
    await _database.transaction((transaction) async {
      await transaction.rawUpdate(
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
        ...operations[AsyncOperation.update]],
      );
    });
  }

  Future<dynamic> DeleteTask(int id) async {
    await _database.transaction((transaction) async {
      await transaction.rawDelete(
          '''
        DELETE FROM "mydb"."tasks" WHERE id = ${id}
        '''
      );
    });
  }

  Future<dynamic> SoftDeleteTaks(int id) async {
    await _database.transaction((transaction) async {
      await transaction.rawUpdate(
        '''
        UPDATE "mydb"."tasks" SET
        in_server = ?,
        updated = ?,
        deleted = ?,
        WHERE id = ${id}
        ''',
        operations[AsyncOperation.delete],
      );
    });
  }

  Future<dynamic> ListTasks() async {
    List<Map<String, dynamic>> data;
    await _database.transaction((transaction) async {
      data = await transaction.rawQuery(
        '''
        SELECT * FROM "mydb"."tasks"
        '''
      );
    });
    return data;
  }

  // Operations on custom_users
  Future<dynamic> CreateCustomerUser(int id, String createdAt, String updatedAt,
                                     String deletedAt, int customerId,
                                     int userId) async {
    await _database.transaction((transaction) async {
      await transaction.rawInsert(
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
        ...operations[AsyncOperation.create]],
      );
    });
  }

  Future<dynamic> ReadCustomerUser(int id) async {
    List<Map<String, dynamic>> data;
    await _database.transaction((transaction) async {
      data = await transaction.rawQuery(
        '''
        SELECT * FROM "mydb"."customers_users" WHERE id = ${id}
        '''
      );
    });
    return data;
  }

  Future<dynamic> UpdateCustomerUser(int id, String createdAt, String updatedAt,
                                     String deletedAt, int customerId,
                                     int userId) async {
    await _database.transaction((transaction) async {
      await transaction.rawUpdate(
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
        ...operations[AsyncOperation.update]],
      );
    });
  }

  Future<dynamic> DeleteCustomerUser(int id) async {
    await _database.transaction((transaction) async {
      await transaction.rawDelete(
        '''
        DELETE FROM "mydb"."customer_users" WHERE id = ${id}
        '''
      );
    });
  }

  Future<dynamic> SoftDeleteCustomerUser(int id) async {
    await _database.transaction((transaction) async {
      await transaction.rawUpdate(
        '''
        UPDATE "mydb"."customer_users" SET
        in_server = ?,
        updated = ?,
        deleted = ?,
        WHERE id = ${id}
        ''',
        operations[AsyncOperation.delete],
      );
    });
  }

  Future<dynamic> ListCustomerUsers() async {
    List<Map<String, dynamic>> data;
    await _database.transaction((transaction) async {
      data = await transaction.rawQuery(
        '''
        SELECT * FROM "mydb"."customer_users"
        '''
      );
    });
    return data;
  }

  // Operations on custom_values
  Future<dynamic> CreateCustomValue(CustomValueModel customValue) async {
    await _database.transaction((transaction) async {
      await transaction.rawInsert(
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
        customValue.value], ...operations[AsyncOperation.create]],
      );
    });
  }

  Future<dynamic> ReadCustomValue(int id) async {
    List<Map<String, dynamic>> data;
    await _database.transaction((transaction) async {
      data = await transaction.rawQuery(
        '''
        SELECT * FROM "mydb"."custom_values" WHERE id = ${id}
        '''
      );
    });
    return data;
  }

  Future<dynamic> UpdateCustomValue(CustomValueModel customValue) async {
    await _database.transaction((transaction) async {
      await transaction.rawUpdate(
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
        customValue.value], ...operations[AsyncOperation.update]],
      );
    });
  }

  Future<dynamic> DeleteCustomValue(int id) async {
    await _database.transaction((transaction) async {
      await transaction.rawDelete(
        '''
        DELETE FROM "mydb"."custom_values" WHERE id = ${id}
        '''
      );
    });
  }

  Future<dynamic> SoftDeleteCustomValue(int id) async {
    await _database.transaction((transaction) async {
      await transaction.rawUpdate(
        '''
        UPDATE "mydb"."custom_values" SET
        in_server = ?,
        updated = ?,
        deleted = ?,
        WHERE id = ${id}
        ''',
        operations[AsyncOperation.delete],
      );
    });
  }

  Future<dynamic> ListCustomValues() async {
    List<Map<String, dynamic>> data;
    await _database.transaction((transaction) async {
      data = await transaction.rawQuery(
        '''
        SELECT * FROM "mydb"."custom_values"
        '''
      );
    });
    return data;
  }

  // Operations on customer_addresses
  Future<dynamic> CreateCustomerAdress(int id, String createdAt,
                                       String updatedAt, String deletedAt,
                                       int customerId, int addressId,
                                       bool approved) async {
    await _database.transaction((transaction) async {
      await transaction.rawInsert(
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
        approved], ...operations[AsyncOperation.create]],
      );
    });
  }

  Future<dynamic> ReadCustomerAdress(int id) async {
    List<Map<String, dynamic>> data;
    await _database.transaction((transaction) async {
      data = await transaction.rawQuery(
        '''
        SELECT * FROM "mydb"."customer_addresses" WHERE id = ${id}
        '''
      );
    });
    return data;
  }

  Future<dynamic> UpdateCustomerAdress(int id, String createdAt,
                                       String updatedAt, String deletedAt,
                                       int customerId, int addressId,
                                       bool approved) async {
    await _database.transaction((transaction) async {
      await transaction.rawUpdate(
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
        approved], ...operations[AsyncOperation.update]],
      );
    });
  }

  Future<dynamic> DeleteCustomerAdress(int id) async {
    await _database.transaction((transaction) async {
      await transaction.rawDelete(
        '''
        DELETE FROM "mydb"."customer_addresses" WHERE id = ${id}
        '''
      );
    });
  }

  Future<dynamic> SoftDeleteCustomerAddress(int id) async {
    await _database.transaction((transaction) async {
      await transaction.rawUpdate(
        '''
        UPDATE "mydb"."customer_addresses" SET
        in_server = ?,
        updated = ?,
        deleted = ?,
        WHERE id = ${id}
        ''',
        operations[AsyncOperation.delete],
      );
    });
  }

  Future<dynamic> ListCustomerAdresses() async {
    List<Map<String, dynamic>> data;
    await _database.transaction((transaction) async {
      data = await transaction.rawQuery(
        '''
        SELECT * FROM "mydb"."customer_addresses"
        '''
      );
    });
    return data;
  }

}
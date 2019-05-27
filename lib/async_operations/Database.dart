import 'dart:core';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'SQL_Instructions.dart';

import '../models/AccountModel.dart';
import '../models/AddressesModel.dart';
import '../models/AddressModel.dart';
import '../models/AuthModel.dart';
import '../models/CustomerModel.dart';
import '../models/CustomersModel.dart';
import '../models/FieldModel.dart';
import '../models/FormModel.dart';
import '../models/FormsModel.dart';
import '../models/SectionModel.dart';
import '../models/TaskModel.dart';
import '../models/TasksModel.dart';
import '../models/UserModel.dart';
import '../models/UserDataBase.dart';
import '../models/Marker.dart';

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
      int id = await transaction.rawInsert(
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
      int id = await transaction.rawInsert(
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
      int id = await transaction.rawInsert(
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
      int id = await transaction.rawInsert(
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
        responsible.profile], ...operations[AsyncOperation.create]],
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
  Future<dynamic> CreateCustomField() async {

  }

  Future<dynamic> ReadCustomField(int id) async {

  }
  Future<dynamic> UpdateCustomField() async {

  }
  Future<dynamic> DeleteCustomField(int id) async {

  }
  Future<dynamic> ListCustomFields() async {

  }

  // Operations on addresses
  Future<dynamic> CreateAddress(AddressModel address) async {
    await _database.transaction((transaction) async {
      int id = await transaction.rawInsert(
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
        UPDATE "mydb"."users" SET
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
      int id = await transaction.rawInsert(
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
      int id = await transaction.rawInsert(
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
  Future<dynamic> CreateCustomUser() async {
    await _database.transaction((transaction) async {
      int id = await transaction.rawInsert(
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

        [...[],
      ...operations[AsyncOperation.create]],
      );
    });
  }

  Future<dynamic> ReadCustomUser(int id) async {

  }
  Future<dynamic> UpdateCustomUser() async {

  }
  Future<dynamic> DeleteCustomUser(int id) async {

  }
  Future<dynamic> ListCustomUsers() async {

  }

  // Operations on custom_values
  Future<dynamic> CreateCustomValue(CustomValueModel customValue) async {
    await _database.transaction((transaction) async {
      int id = await transaction.rawInsert(
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
        customValue.deletedAt, customValue.formsId, customValue.sectionId,
        customValue.fieldId, customValue.customizableType,
        customValue.customizableId, customValue.value],
        ...operations[AsyncOperation.create]],
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
        [...[customValue.createdAt, customValue.updatedAt, customValue.deletedAt,
        customValue.formsId, customValue.sectionId, customValue.fieldId,
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
  Future<dynamic> CreateCustomerAdress() async {
    await _database.transaction((transaction) async {
      int id = await transaction.rawInsert(
        '''
          INSERT INTO
            
          );
          
          VALUES()
          ''',
        [...[locality.id, locality.createdAt, locality.updatedAt, locality.deletedAt,
      locality.createdById, locality.updatedById, locality.deletedById, ],
      ...operations[AsyncOperation.create]],
      );
    });
  }

  Future<dynamic> ReadCustomerAdress(int id) async {

  }
  Future<dynamic> UpdateCustomerAdress() async {

  }
  Future<dynamic> DeleteCustomerAdress(int id) async {

  }
  Future<dynamic> ListCustomerAdresses() async {

  }

}
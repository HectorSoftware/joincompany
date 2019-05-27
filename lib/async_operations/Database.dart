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
        ...operations[AsyncOperation.create]],
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

  Future<dynamic> ReadForm() async {
    await _database.transaction((transaction) async {

    });
  }
  Future<dynamic> UpdateForm() async {
    await _database.transaction((transaction) async {

    });
  }
  Future<dynamic> DeleteForm() async {
    await _database.transaction((transaction) async {

    });
  }
  Future<dynamic> ListForms() async {
    await _database.transaction((transaction) async {

    });
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

  Future<dynamic> ReadLocality() async {
    await _database.transaction((transaction) async {

    });
  }
  Future<dynamic> UpdateLocality() async {
    await _database.transaction((transaction) async {

    });
  }
  Future<dynamic> DeleteLocality() async {
    await _database.transaction((transaction) async {

    });
  }
  Future<dynamic> ListLocalities() async {
    await _database.transaction((transaction) async {

    });
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
        responsible.deletedById, responsible.supervisorId],
      ...operations[AsyncOperation.create]],
      );
    });
  }

  Future<dynamic> ReadResponsible() async {
    await _database.transaction((transaction) async {

    });
  }
  Future<dynamic> UpdateResponsible() async {
    await _database.transaction((transaction) async {

    });
  }
  Future<dynamic> DeleteResponsible() async {
    await _database.transaction((transaction) async {

    });
  }
  Future<dynamic> ListResponsibles() async {
    await _database.transaction((transaction) async {

    });
  }

  // Operations on custom_fields
  Future<dynamic> CreateCustomField() async {
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

  Future<dynamic> ReadCustomField() async {
    await _database.transaction((transaction) async {

    });
  }
  Future<dynamic> UpdateCustomField() async {
    await _database.transaction((transaction) async {

    });
  }
  Future<dynamic> DeleteCustomField() async {
    await _database.transaction((transaction) async {

    });
  }
  Future<dynamic> ListCustomFields() async {
    await _database.transaction((transaction) async {

    });
  }

  // Operations on addresses
  Future<dynamic> CreateAddress() async {
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

  Future<dynamic> ReadAddress() async {
    await _database.transaction((transaction) async {

    });
  }
  Future<dynamic> UpdateAddress() async {
    await _database.transaction((transaction) async {

    });
  }
  Future<dynamic> DeleteAddress() async {
    await _database.transaction((transaction) async {

    });
  }
  Future<dynamic> ListAddresses() async {
    await _database.transaction((transaction) async {

    });
  }

  // Operations on customers
  Future<dynamic> CreateCustomer() async {
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

  Future<dynamic> ReadCustomer() async {
    await _database.transaction((transaction) async {

    });
  }
  Future<dynamic> UpdateCustomer() async {
    await _database.transaction((transaction) async {

    });
  }
  Future<dynamic> DeleteCustomer() async {
    await _database.transaction((transaction) async {

    });
  }
  Future<dynamic> ListCustomers() async {
    await _database.transaction((transaction) async {

    });
  }

  // Operations on tasks
  Future<dynamic> CreateTask() async {
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

  Future<dynamic> ReadTask() async {
    await _database.transaction((transaction) async {

    });
  }
  Future<dynamic> UpdateTask() async {
    await _database.transaction((transaction) async {

    });
  }
  Future<dynamic> DeleteTask() async {
    await _database.transaction((transaction) async {

    });
  }
  Future<dynamic> ListTasks() async {
    await _database.transaction((transaction) async {

    });
  }

  // Operations on custom_users
  Future<dynamic> CreateCustomUser() async {
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

  Future<dynamic> ReadCustomUser() async {
    await _database.transaction((transaction) async {

    });
  }
  Future<dynamic> UpdateCustomUser() async {
    await _database.transaction((transaction) async {

    });
  }
  Future<dynamic> DeleteCustomUser() async {
    await _database.transaction((transaction) async {

    });
  }
  Future<dynamic> ListCustomUsers() async {
    await _database.transaction((transaction) async {

    });
  }

  // Operations on custom_values
  Future<dynamic> CreateCustomValue() async {
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

  Future<dynamic> ReadCustomValue() async {
    await _database.transaction((transaction) async {

    });
  }
  Future<dynamic> UpdateCustomValue() async {
    await _database.transaction((transaction) async {

    });
  }
  Future<dynamic> DeleteCustomValue() async {
    await _database.transaction((transaction) async {

    });
  }
  Future<dynamic> ListCustomValues() async {
    await _database.transaction((transaction) async {

    });
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

  Future<dynamic> ReadCustomerAdress() async {
    await _database.transaction((transaction) async {

    });
  }
  Future<dynamic> UpdateCustomerAdress() async {
    await _database.transaction((transaction) async {

    });
  }
  Future<dynamic> DeleteCustomerAdress() async {
    await _database.transaction((transaction) async {

    });
  }
  Future<dynamic> ListCustomerAdresses() async {
    await _database.transaction((transaction) async {

    });
  }

}
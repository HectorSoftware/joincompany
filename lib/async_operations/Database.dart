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
           user.profile, null, null], ...operations[AsyncOperation.create]],
      );
    });
  }

  Future<dynamic> ReadUser() async {}
  Future<dynamic> UpdateUser() async {}
  Future<dynamic> DeleteUser() async {}
  Future<dynamic> ListUsers() async {}

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

  Future<dynamic> ReadForm() async {}
  Future<dynamic> UpdateForm() async {}
  Future<dynamic> DeleteForm() async {}
  Future<dynamic> ListForms() async {}

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

  Future<dynamic> ReadLocality() async {}
  Future<dynamic> UpdateLocality() async {}
  Future<dynamic> DeleteLocality() async {}
  Future<dynamic> ListLocalities() async {}

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

  Future<dynamic> ReadResponsible() async {}
  Future<dynamic> UpdateResponsible() async {}
  Future<dynamic> DeleteResponsible() async {}
  Future<dynamic> ListResponsibles() async {}

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

  Future<dynamic> ReadCustomField() async {}
  Future<dynamic> UpdateCustomField() async {}
  Future<dynamic> DeleteCustomField() async {}
  Future<dynamic> ListCustomFields() async {}

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

  Future<dynamic> ReadAddress() async {}
  Future<dynamic> UpdateAddress() async {}
  Future<dynamic> DeleteAddress() async {}
  Future<dynamic> ListAddresses() async {}

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

  Future<dynamic> ReadCustomer() async {}
  Future<dynamic> UpdateCustomer() async {}
  Future<dynamic> DeleteCustomer() async {}
  Future<dynamic> ListCustomers() async {}

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

  Future<dynamic> ReadTask() async {}
  Future<dynamic> UpdateTask() async {}
  Future<dynamic> DeleteTask() async {}
  Future<dynamic> ListTasks() async {}

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

  Future<dynamic> ReadCustomUser() async {}
  Future<dynamic> UpdateCustomUser() async {}
  Future<dynamic> DeleteCustomUser() async {}
  Future<dynamic> ListCustomUsers() async {}

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

  Future<dynamic> ReadCustomValue() async {}
  Future<dynamic> UpdateCustomValue() async {}
  Future<dynamic> DeleteCustomValue() async {}
  Future<dynamic> ListCustomValues() async {}

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

  Future<dynamic> ReadCustomerAdress() async {}
  Future<dynamic> UpdateCustomerAdress() async {}
  Future<dynamic> DeleteCustomerAdress() async {}
  Future<dynamic> ListCustomerAdresses() async {}

}
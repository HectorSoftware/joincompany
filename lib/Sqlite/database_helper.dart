import 'dart:io';
import 'package:joincompany/models/UserDataBase.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sql.dart';
import 'package:sqflite/sqlite_api.dart';

class ClientDatabaseProvider{
  ClientDatabaseProvider._();

  static final  ClientDatabaseProvider db = ClientDatabaseProvider._();
  Database _database;

  //para evitar que abra varias conexciones una y otra vez podemos usar algo como esto..
  Future<Database> get database async {
    if(_database != null) return _database;
    _database = await getDatabaseInstanace();
    return _database;
  }

  Future<Database> getDatabaseInstanace() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path, "JoinCompany.db");
    return await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
          await db.execute(
              "CREATE TABLE User(idTable INT PRIMARY KEY, name TEXT, password TEXT , company TEXT, token TEXT)");


    });
  }

  //muestra un solo cliente por el id la base de datos
  Future<UserDataBase> getCodeId(String codigo) async {
    final db = await database;
    var response = await db.query("User", where: "idTable = ?", whereArgs: [codigo]);
    return response.isNotEmpty ? UserDataBase.fromMap(response.first) : null;
  }

  //Insert

  Future<int> saveUser(UserDataBase user) async {
    var dbClient = await database;
    int res = await dbClient.insert("User", user.toMap());
    return res;
  }

}
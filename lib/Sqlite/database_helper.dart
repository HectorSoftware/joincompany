import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

class ClientDatabaseProvider{
  ClientDatabaseProvider._();

  static final  ClientDatabaseProvider db = ClientDatabaseProvider._();
  Database _database;


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
              "CREATE TABLE User(idTable INT PRIMARY KEY,idUserCompany INT, name TEXT, password TEXT , company TEXT, token TEXT)");
        });
  }

  Future deleteDatabaseInstance() async {
    final db = await database;
    db.delete('User');
  }

//  //  UserModel user = await DatabaseProvider.db.RetrieveLastLoggedUser();
//  Future<UserDataBase> getCodeId(String codigo) async {
//    try{
//      final db = await database;
//      var response = await db.query("User", where: "idTable = ?", whereArgs: [codigo]);
//      return response.isNotEmpty ? UserDataBase.fromMap(response.first) : null;
//    }catch(e){
//      return null;
//    }
//  }

//  //Insert
//  Future<int> saveUser(UserDataBase user) async {
//    var dbClient = await database;
//    int res = await dbClient.insert("User", user.toMap());
//    return res;
//  }

  Future<int> updatetoken(String token) async {
    var dbClient = await  database;
    return await dbClient.rawUpdate(
        'UPDATE User SET token = \'$token\' WHERE idTable = 1');
  }
  Future<int> updateUser(String idUser, String emil, String pwd, String token) async {
    var dbClient = await  database;
    return await dbClient.rawUpdate('UPDATE User SET idUserCompany = $idUser, name = \'$emil\', password = \'$pwd\', token = \'$token\' WHERE idTable = 1');
  }

}
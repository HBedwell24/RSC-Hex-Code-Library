import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:rsc_hex_code_library/models/hex_code.dart';

class DatabaseHelper {
  static DatabaseHelper _databaseHelper;
  static Database _database;

  String hexCodeTable = 'hex_code_table';
  String colId = 'id';
  String colColorName = 'colorName';
  String colHexCode = 'hexCode';
  String colPearlescent = 'pearlescent';

  DatabaseHelper._createInstance();

  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._createInstance();
    }
    return _databaseHelper;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'hexCode11.db';

    var notesDatabase = await openDatabase(path, version: 1, onCreate: _createDb);
    return notesDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute('CREATE TABLE $hexCodeTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colColorName TEXT, $colHexCode TEXT, $colPearlescent TEXT)');
  }

  // Fetch operation
  Future<List<Map<String, dynamic>>> getHexCodeMapList() async {
    Database db = await this.database;

    var result = await db.query(hexCodeTable);
    return result;
  }

  // Insert operation
  Future<int> insertHexCode(HexCode hexCode) async {
    Database db = await this.database;
    var result = await db.insert(hexCodeTable, hexCode.convertToMap());
    return result;
  }

  // Update operation
  Future<int> updateHexCode(HexCode hexCode) async {
    var db = await this.database;
    var result = await db.update(hexCodeTable, hexCode.convertToMap(), where: '$colId = ?', whereArgs: [hexCode.id]);
    return result;
  }

  // Delete operation
  Future<int> deleteHexCode(int id) async {
    var db = await this.database;
    var result = await db.rawDelete('DELETE FROM $hexCodeTable WHERE $colId = $id');
    return result;
  }

  // Get # of hex code objects in database
  Future<int> getCount() async {
    var db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery('SELECT COUNT (*) from $hexCodeTable');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  // Get the map list
  Future<List<HexCode>> getHexCodeList() async {

    var hexCodeMapList = await getHexCodeMapList();
    int count = hexCodeMapList.length;

    List<HexCode> hexCodeList = List<HexCode>();
    for (int i = 0; i < count; i++) {
      hexCodeList.add(HexCode.fromMapObject(hexCodeMapList[i]));
    }
    return hexCodeList;
  }
}
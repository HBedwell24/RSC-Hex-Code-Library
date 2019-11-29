import 'package:rsc_hex_code_library/models/category.dart';
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

  String categoryTable = 'category_table';
  String colCategoryName = 'categoryName';

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
    String path = directory.path + 'hexCode64.db';

    var notesDatabase = await openDatabase(path, version: 1, onCreate: _createDb);
    return notesDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute('CREATE TABLE $hexCodeTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colColorName TEXT, $colHexCode TEXT, $colPearlescent TEXT, $colCategoryName TEXT, FOREIGN KEY($colCategoryName) REFERENCES hexCodeTable($colCategoryName))');
    await db.execute('CREATE TABLE $categoryTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colCategoryName TEXT)');
  }

  // Fetch operation for hexCodeTable
  Future<List<Map<String, dynamic>>> getHexCodeMapList() async {
    Database db = await this.database;

    var result = await db.query(hexCodeTable);
    return result;
  }

  // Fetch operation for categoryTable
  Future<List<Map<String, dynamic>>> getCategoryMapList() async {
    Database db = await this.database;

    var result = await db.query(categoryTable);
    return result;
  }

  // Insert operation
  Future<int> insertHexCode(HexCode hexCode) async {
    Database db = await this.database;
    var result = await db.insert(hexCodeTable, hexCode.convertToMap());
    return result;
  }

  // Insert operation
  Future<int> insertCategory(Category category) async {
    Database db = await this.database;
    var result = await db.insert(categoryTable, category.convertToMap());
    return result;
  }

  // Update operation
  Future<int> updateHexCode(HexCode hexCode) async {
    var db = await this.database;
    var result = await db.update(hexCodeTable, hexCode.convertToMap(), where: '$colId = ?', whereArgs: [hexCode.id]);
    return result;
  }

  // Update operation
  Future<int> updateCategory(Category category) async {
    var db = await this.database;
    var result = await db.update(categoryTable, category.convertToMap(), where: '$colId = ?', whereArgs: [category.id]);
    return result;
  }

  // Delete operation
  Future<int> deleteHexCode(int id) async {
    var db = await this.database;
    var result = await db.rawDelete('DELETE FROM $hexCodeTable WHERE $colId = $id');
    return result;
  }

  // Delete operation
  Future<int> deleteCategory(int id) async {
    var db = await this.database;
    var result = await db.rawDelete('DELETE FROM $categoryTable WHERE $colId = $id');
    return result;
  }

  // Get # of hex code objects in database
  Future<int> getHexCodeCount() async {
    var db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery('SELECT COUNT (*) from $hexCodeTable');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  // Get # of category objects in database
  Future<int> getCategoryCount() async {
    var db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery('SELECT COUNT (*) from $categoryTable');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<List<HexCode>> getHexCodesFromCategory(String name) async {
    var db = await this.database;
    var result = await db.rawQuery('SELECT * FROM $hexCodeTable WHERE $colCategoryName = $name');
    int count = result.length;

    List<HexCode> hexCodeList = List<HexCode>();
    for (int i = 0; i < count; i++) {
      hexCodeList.add(HexCode.fromMapObject(result[i]));
    }
    return hexCodeList;
  }

  Future<int> getHexCodeCountFromCategory(String name) async {
    var db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery('SELECT COUNT (*) FROM $hexCodeTable WHERE $colCategoryName = $name');
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

  // Get the map list
  Future<List<Category>> getCategoryList() async {

    var categoryMapList = await getCategoryMapList();
    int count = categoryMapList.length;

    List<Category> categoryList = List<Category>();
    for (int i = 0; i < count; i++) {
      categoryList.add(Category.fromMapObject(categoryMapList[i]));
    }
    return categoryList;
  }
}
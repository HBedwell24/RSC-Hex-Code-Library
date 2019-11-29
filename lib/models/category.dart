import 'hex_code.dart';

class Category {
  // member variables
  int _id;
  String _name;
  List<HexCode> _records;

  // HexCode constructor without id
  Category(this._name, this._records);

  // HexCode constructor with id
  Category.withId(this._id, this._name, this._records);

  // getters for member variables
  int get id => _id;
  String get name => _name;
  List get records => _records;

  // setter for category name
  set name(String newName) {
    this._name = newName;
  }

  // setter for category records
  set records(List<HexCode> recordList) {
    if (recordList != null) {
      this._records = recordList;
    }
  }

  Map<String, dynamic> convertToMap() {
    var map = Map<String, dynamic>();
    if (id != null) {
      map['id'] = _id;
    }
    map['name'] = _name;
    map['records'] = _records;
    return map;
  }

  Category.fromMapObject(Map<String, dynamic> map) {
    this._id = map['id'];
    this._name = map['name'];
    this._records = map['records'];
  }
}

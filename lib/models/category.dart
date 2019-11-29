import 'hex_code.dart';

class Category {
  // member variables
  int _id;
  String _name;

  // HexCode constructor without id
  Category(this._name);

  // HexCode constructor with id
  Category.withId(this._id, this._name);

  // getters for member variables
  int get id => _id;
  String get name => _name;

  // setter for category name
  set name(String newName) {
    this._name = newName;
  }

  Map<String, dynamic> convertToMap() {
    var map = Map<String, dynamic>();
    if (id != null) {
      map['id'] = _id;
    }
    map['categoryName'] = _name;
    return map;
  }

  Category.fromMapObject(Map<String, dynamic> map) {
    this._id = map['id'];
    this._name = map['categoryName'];
  }
}

class HexCode {
  int _id;
  String _colorName;
  String _hexCode;

  HexCode(this._colorName, [this._hexCode]);

  HexCode.withId(this._id, this._colorName, [this._hexCode]);

  int get id => _id;
  String get colorName => _colorName;
  String get hexCode => _hexCode;

  set colorName(String newTitle) {
    if (newTitle.length <= 255) {
      this._colorName = newTitle;
    }
  }

  set hexCode(String newDescription) {
    if (newDescription.length <= 255) {
      this._hexCode = newDescription;
    }
  }

  Map<String, dynamic> convertToMap() {
    var map = Map<String, dynamic>();
    if (id != null) {
      map['id'] = _id;
    }
    map['colorName'] = _colorName;
    map['hexCode'] = _hexCode;
    return map;
  }

  HexCode.fromMapObject(Map<String, dynamic> map) {
    this._id = map['id'];
    this._colorName = map['colorName'];
    this._hexCode = map['hexCode'];
  }
}

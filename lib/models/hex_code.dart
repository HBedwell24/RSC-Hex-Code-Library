class HexCode {
  // member variables
  int _id;
  String _colorName;
  String _hexCode;
  String _pearlescent;
  bool _checkBoxSelected = false;

  // HexCode constructor without id
  HexCode(this._colorName, this._pearlescent, this._checkBoxSelected, [this._hexCode]);

  // HexCode constructor with id
  HexCode.withId(this._id, this._colorName, this._pearlescent, this._checkBoxSelected, [this._hexCode]);

  // getters for member variables
  int get id => _id;
  String get colorName => _colorName;
  String get hexCode => _hexCode;
  String get pearlescent => _pearlescent;
  bool get isSelected => _checkBoxSelected;

  // setter for color name
  set colorName(String newColorName) {
    if (newColorName.length <= 255 && newColorName.isNotEmpty) {
      this._colorName = newColorName;
    }
  }

  // setter for hex code
  set hexCode(String newHexCode) {
    if (newHexCode.length <= 255 && newHexCode.isNotEmpty) {
      this._hexCode = newHexCode;
    }
  }

  // setter for pearlescent
  set pearlescent(String newPearlescent) {
    if (newPearlescent.isNotEmpty) {
      this._pearlescent = newPearlescent;
    }
  }

  // setter for check box selection state
  set isSelected(bool isSelected) {
    this._checkBoxSelected = isSelected;
  }

  Map<String, dynamic> convertToMap() {
    var map = Map<String, dynamic>();
    if (id != null) {
      map['id'] = _id;
    }
    map['colorName'] = _colorName;
    map['hexCode'] = _hexCode;
    map['pearlescent'] = _pearlescent;
    return map;
  }

  HexCode.fromMapObject(Map<String, dynamic> map) {
    this._id = map['id'];
    this._colorName = map['colorName'];
    this._hexCode = map['hexCode'];
    this._pearlescent = map['pearlescent'];
  }
}

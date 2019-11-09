import 'package:flutter/material.dart';
import 'package:rsc_hex_code_library/models/hex_code.dart';
import 'package:rsc_hex_code_library/utils/database_helper.dart';
import 'package:string_validator/string_validator.dart';

class HexCodeDetail extends StatefulWidget {
  final String appBarTitle;
  final HexCode hexCode;
  final String buttonText;
  final bool isDisabled;

  HexCodeDetail(this.hexCode, this.appBarTitle, this.buttonText, this.isDisabled);

  @override
  State<StatefulWidget> createState() {
    return HexCodeDetailState(this.hexCode, this.appBarTitle, this.buttonText, this.isDisabled);
  }
}

class HexCodeDetailState extends State<HexCodeDetail> {

  static var _pearlescents = ['Black', 'Carbon Black', 'Graphite', 'Anthracite Black',
    'Black Steel', 'Dark Steel', 'Silver', 'Bluish Silver', 'Rolled Steel', 'Shadow Silver',
    'Stoner Silver', 'Midnight Silver', 'Cast Iron Silver', 'Red', 'Torino Red', 'Formula Red',
    'Lava Red', 'Blaze Red', 'Grace Red', 'Garnet Red', 'Sunset Red', 'Cabernet Red'];

  DatabaseHelper helper = DatabaseHelper();

  String appBarTitle;
  HexCode hexCode;
  String buttonText;
  bool isDisabled;

  TextEditingController colorNameController = TextEditingController();
  TextEditingController hexCodeController = TextEditingController();

  HexCodeDetailState(this.hexCode, this.appBarTitle, this.buttonText, this.isDisabled);
  var currentSelectedValue;

  @override
  Widget build(BuildContext context) {

    TextStyle textStyle = Theme.of(context).textTheme.title;

    colorNameController.text = hexCode.colorName;
    hexCodeController.text = hexCode.hexCode;

    if (hexCode.pearlescent.isNotEmpty) {
      currentSelectedValue = hexCode.pearlescent;
    }

    return WillPopScope(
        onWillPop: () {
          moveToLastScreen();
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(appBarTitle),
            leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  moveToLastScreen();
                }),
          ),
          body: Padding(
            padding: EdgeInsets.only(top: 10.0, left: 20.0, right: 20.0),
            child: ListView(
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                    child: TextFormField(
                      controller: colorNameController,
                      style: textStyle,
                      onChanged: (value) {
                        debugPrint('Something changed in Color Name Text Field');
                        updateColorName();
                      },
                      decoration: InputDecoration(
                          labelText: 'Color*',
                          errorText: validateColor(colorNameController.text),
                          labelStyle: textStyle,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0))),
                    )),
                Padding(
                    padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                    child: TextFormField(
                      controller: hexCodeController,
                      style: textStyle,
                      onChanged: (value) {
                        debugPrint(
                            'Something changed in Hex Code Text Field');
                        updateHexCode();
                      },
                      decoration: InputDecoration(
                          labelText: 'Hex Code*',
                          errorText: validateHexColor(hexCodeController.text),
                          labelStyle: textStyle,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0))),
                    )
                ),
                Container(
                    padding: EdgeInsets.only(top: 15.0),
                    height: 80.0,
                    child: FormField<String>(
                        builder: (FormFieldState<String> state) {
                          return InputDecorator(
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0))),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                  hint: Text('Pearlescent'),
                                  style: textStyle,
                                  value: currentSelectedValue,
                                  onChanged: (valueSelectedByUser) {
                                    setState(() {
                                      updatePearlescent(valueSelectedByUser);
                                      currentSelectedValue = valueSelectedByUser;
                                      debugPrint(
                                          'User selected $valueSelectedByUser');
                                    });
                                  },
                                  items: _pearlescents.map((String dropDownStringItem) {
                                    return DropdownMenuItem<String>(
                                      value: dropDownStringItem,
                                      child: Text(dropDownStringItem),
                                    );
                                  }).toList(),
                              ),
                            ),
                          );
                        },
                    ),
                ),
                Padding(
                    padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: RaisedButton(
                            color: Theme
                                .of(context)
                                .primaryColorDark,
                            textColor: Theme
                                .of(context)
                                .primaryColorLight,
                            child: Text(
                              buttonText,
                              textScaleFactor: 1.5,
                            ),
                            onPressed: () {
                              setState(() {
                                debugPrint('Save button clicked');
                                if (validateColor(colorNameController.text) == null && validateHexColor(hexCodeController.text) == null) {
                                  _save();
                                }
                              });
                            },
                          ),
                        ),
                        Container(
                          width: 5.0,
                        ),
                        Expanded(
                          child: RaisedButton(
                            color: Theme
                                .of(context)
                                .primaryColorDark,
                            textColor: Theme
                                .of(context)
                                .primaryColorLight,
                            child: Text(
                              'Delete',
                              textScaleFactor: 1.5,
                            ),
                            onPressed: () {
                              isDisabled ? null : () =>
                              setState(() {
                                debugPrint('Delete button clicked');
                                _delete();
                              });
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ]
              ),
            ),
          ),
        );
  }

  void _showDialog(BuildContext context) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Are you sure you want to delete the following item?"),
          content: new Text("This action cannot be undone."),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("NO"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new FlatButton(
              child: new Text("YES"),
              onPressed: () {
                _delete();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }

  void updateColorName() {
    hexCode.colorName = colorNameController.text;
  }

  void updateHexCode() {
    hexCode.hexCode = hexCodeController.text;
  }

  void updatePearlescent(String pearlescent) {
    if (pearlescent != 'No Selection') {
      hexCode.pearlescent = pearlescent;
    }
  }

  void _save() async {

    moveToLastScreen();
    int result;

    if (hexCode.id != null) {
      result = await helper.updateHexCode(hexCode);
    }
    else {
      result = await helper.insertHexCode(hexCode);
    }

    if (result != 0) {
      _showAlertDialog('Status', 'Hex Code Saved Successfully!');
    }
    else {
      _showAlertDialog('Status', 'Something went wrong! Please try again!');
    }
  }

  String validateColor(String color) {

    if (color.isEmpty) {
      return "Field 'Color' is empty.";
    }

    else if (!(isAlpha(color))) {
      return "Non-alphanumeric characters were found in field 'Color'.";
    }
    else {
      return null;
    }
  }

  String validateHexColor(String hexCode) {

    if (hexCode.isEmpty) {
      return "Field 'Hex Code' is empty.";
    }

    else if (!(isHexColor(hexCode))) {
      return "Invalid Hex color found in field 'Hex Code'.";
    }
  }

  void _delete() async {
    moveToLastScreen();

    if (hexCode.id == null) {
      _showAlertDialog('Status', 'No Note Was Deleted!');
      return;
    }

    int result = await helper.deleteHexCode(hexCode.id);
    if (result != 0) {
      _showAlertDialog('Status', 'Hex Code Was Deleted Successfully!');
    }
    else {
      _showAlertDialog('Status', 'Deletion Unsuccessful!');
    }
  }

  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }
}

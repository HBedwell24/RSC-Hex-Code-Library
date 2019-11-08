import 'package:flutter/material.dart';
import 'package:rsc_hex_code_library/models/hex_code.dart';
import 'package:rsc_hex_code_library/utils/database_helper.dart';
import 'package:intl/intl.dart';

class HexCodeDetail extends StatefulWidget {
  final String appBarTitle;
  final HexCode hexCode;

  HexCodeDetail(this.hexCode, this.appBarTitle);

  @override
  State<StatefulWidget> createState() {
    return HexCodeDetailState(this.hexCode, this.appBarTitle);
  }
}

class HexCodeDetailState extends State<HexCodeDetail> {
  static var _pearlescents = ['No Selection', 'Black', 'Carbon Black', 'Graphite', 'Anthracite Black',
    'Black Steel', 'Dark Steel', 'Silver', 'Bluish Silver', 'Rolled Steel', 'Shadow Silver',
    'Stoner Silver', 'Midnight Silver', 'Cast Iron Silver', 'Red', 'Torino Red', 'Formula Red',
    'Lava Red', 'Blaze Red', 'Grace Red', 'Garnet Red', 'Sunset Red', 'Cabernet Red'];

  DatabaseHelper helper = DatabaseHelper();

  String appBarTitle;
  HexCode hexCode;

  TextEditingController colorNameController = TextEditingController();
  TextEditingController hexCodeController = TextEditingController();

  HexCodeDetailState(this.hexCode, this.appBarTitle);

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.title;

    colorNameController.text = hexCode.colorName;
    hexCodeController.text = hexCode.hexCode;

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
            padding: EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
            child: ListView(
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                    child: TextField(
                      controller: colorNameController,
                      style: textStyle,
                      onChanged: (value) {
                        debugPrint('Something changed in Color Name Text Field');
                        updateColorName();
                      },
                      decoration: InputDecoration(
                          labelText: 'Color',
                          labelStyle: textStyle,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0))),
                    )),
                Padding(
                    padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                    child: TextField(
                      controller: hexCodeController,
                      style: textStyle,
                      onChanged: (value) {
                        debugPrint(
                            'Something changed in Hex Code Text Field');
                        updateHexCode();
                      },
                      decoration: InputDecoration(
                          labelText: 'Hex Code',
                          labelStyle: textStyle,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0))),
                    )),
                ListTile(
                  title: DropdownButton(
                      items: _pearlescents.map((String dropDownStringItem) {
                        return DropdownMenuItem<String>(
                          value: dropDownStringItem,
                          child: Text(dropDownStringItem),
                        );
                      }).toList(),
                      style: textStyle,
                      value: _pearlescents[0],
                      onChanged: (valueSelectedByUser) {
                        setState(() {
                          updatePearlescent(valueSelectedByUser);
                          debugPrint('User selected $valueSelectedByUser');
                        });
                      }),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: RaisedButton(
                          color: Theme.of(context).primaryColorDark,
                          textColor: Theme.of(context).primaryColorLight,
                          child: Text(
                            'Save',
                            textScaleFactor: 1.5,
                          ),
                          onPressed: () {
                            setState(() {
                              debugPrint('Save button clicked');
                              _save();
                            });
                          },
                        ),
                      ),
                      Container(
                        width: 5.0,
                      ),
                      Expanded(
                        child: RaisedButton(
                          color: Theme.of(context).primaryColorDark,
                          textColor: Theme.of(context).primaryColorLight,
                          child: Text(
                            'Delete',
                            textScaleFactor: 1.5,
                          ),
                          onPressed: () {
                            setState(() {
                              debugPrint('Delete button clicked');
                              _delete();
                            });
                          },
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ));
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
    hexCode.pearlescent = pearlescent;
  }

  void _save() async {

    moveToLastScreen();
    int result;

    if (hexCode.id != null) {
      result = await helper.updateHexCode(hexCode);
    } else {
      result = await helper.insertHexCode(hexCode);
    }

    if (result != 0) {
      _showAlertDialog('Status', 'Hex Code Saved Successfully!');
    } else {
      _showAlertDialog('Status', 'Something went wrong! Please try again!');
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
    } else {
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

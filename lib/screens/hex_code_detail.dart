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
    'Lava Red', 'Blaze Red', 'Grace Red', 'Garnet Red', 'Sunset Red', 'Cabernet Red', 'Cabernet',
    'Wine Red', 'Candy Red', 'Hot Pink', 'Pfister Pink', 'Salmon Pink', 'Sunrise Orange',
    'Orange', 'Bright Orange', 'Gold', 'Bronze', 'Yellow', 'Race Yellow', 'Dew Yellow', 'Dark Green',
    'Racing Green', 'Sea Green', 'Olive Green', 'Bright Green', 'Gasoline Green', 'Lime Green',
    'Midnight Blue', 'Galaxy Blue', 'Dark Blue', 'Saxon Blue', 'Blue', 'Mariner Blue', 'Harbor Blue',
    'Diamond Blue', 'Surf Blue', 'Nautical Blue', 'Racing Blue', 'Ultra Blue', 'Light Blue',
    'Chocolate Brown', 'Bison Brown', 'Creek Brown', 'Feltzer Brown', 'Maple Brown', 'Beechwood Brown',
    'Sienna Brown', 'Saddle Brown', 'Moss Brown', 'Woodbeech Brown', 'Straw Brown', 'Sandy Brown',
    'Bleached Brown', 'Schafter Purple', 'Spinnaker Purple', 'Midnight Purple', 'Bright Purple',
    'Cream', 'Ice White', 'Frost White', 'Worn Blue Silver', 'Worn Golden Red', 'Worn Shadow Silver',
    'Worn Green', 'Worn Sea Wash', 'Worn Baby Blue', 'Util Silver', 'MP100'
    ];

  DatabaseHelper helper = DatabaseHelper();

  final _formKey = GlobalKey<FormState>();
  final FocusNode _colorNameFocusNode = new FocusNode();
  final FocusNode _hexCodeFocusNode = new FocusNode();

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
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(appBarTitle),
          // up navigation to parent activity
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              moveToLastScreen();
            }
          ),
        ),
        body: Padding(
          padding: EdgeInsets.only(top: 10.0, left: 20.0, right: 20.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: TextFormField(
                    focusNode: _colorNameFocusNode,
                    textInputAction: TextInputAction.next,
                    onEditingComplete: () =>
                        FocusScope.of(context).requestFocus(_hexCodeFocusNode),
                    validator: (color) {
                      // if color field is empty, prompt error
                      if (color.isEmpty) {
                        return "Field 'Color' is empty.";
                      }
                      // if color field is not empty
                      else {
                        // loop through color string
                        for(int i = 0; i < color.length; i++) {
                          // if color field contains alpha characters or a space, valid color name
                          if(isAlpha(color[i]) || color[i].contains(' ')) {
                            return null;
                          }
                          // if color field contains non-numeric characters, prompt error
                          else {
                            return "Non-alphanumeric characters were found in field 'Color'.";
                          }
                        }
                      }
                      return null;
                    },
                    controller: colorNameController,
                    style: textStyle,
                    onChanged: (value) {
                      debugPrint("Something changed in 'Color' text field.");
                      updateColorName();
                    },
                    decoration: InputDecoration(
                      labelText: 'Color*',
                      labelStyle: textStyle,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0)
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: TextFormField(
                    focusNode: _hexCodeFocusNode,
                    validator: (hexColor) {
                      // if hex field is empty, prompt error
                      if (hexColor.isEmpty) {
                        return "Field 'Hex Code' is empty.";
                      }
                      // if hex field is not empty
                      else {
                        // if hex field is not a valid color, prompt error
                        if (!(isHexColor(hexColor))) {
                          return "Invalid Hex color found in field 'Hex Code'.";
                        }
                        // if hex field is valid color
                        else {
                          return null;
                        }
                      }
                    },
                    controller: hexCodeController,
                    style: textStyle,
                    onChanged: (value) {
                      debugPrint("Something changed in 'Hex Code' text field.");
                      updateHexCode();
                    },
                    decoration: InputDecoration(
                      labelText: 'Hex Code*',
                      labelStyle: textStyle,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0)
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top: 15.0),
                  height: 80.0,
                  child: FormField<String>(
                    builder: (FormFieldState<String> state) {
                      return InputDecorator(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0)
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            hint: Text('Pearlescent'),
                            style: textStyle,
                            value: currentSelectedValue,
                            onChanged: (valueSelectedByUser) {
                              setState(() {
                                updatePearlescent(valueSelectedByUser);
                                currentSelectedValue = valueSelectedByUser;
                                debugPrint('User selected $valueSelectedByUser');
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Flexible(
                        child: RaisedButton(
                          padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                          color: Theme
                            .of(context)
                            .primaryColorDark,
                          textColor: Theme
                            .of(context)
                            .primaryColorLight,
                          child: Text(
                            buttonText.toUpperCase(),
                            style: new TextStyle(fontWeight: FontWeight.bold),
                          ),
                          onPressed: () {
                            setState(() {
                              debugPrint('Save button clicked');
                              if (_formKey.currentState.validate()) {
                                _save();
                              }
                            });
                          },
                        ),
                      ),
                      Container(
                        width: 10.0,
                      ),
                      Flexible(
                        child: Visibility(
                          visible: isDisabled ? true : false,
                          child: RaisedButton(
                            padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                            color: Colors.black,
                            textColor: Theme
                              .of(context)
                              .primaryColorLight,
                            child: Text(
                              'Delete'.toUpperCase(),
                              style: new TextStyle(fontWeight: FontWeight.bold),
                            ),
                            onPressed: () {
                              setState(() {
                                debugPrint('Delete button clicked');
                                _showDialog(context);
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
          title: new Text("Are you sure you want to delete the following item? This action cannot be undone."),
          content: new Text(this.hexCode.colorName.toString()),
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
                Navigator.of(context).pop();
                _delete();
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
      hexCode.pearlescent = pearlescent;
  }

  void _save() async {

    moveToLastScreen();
    int result;
    String verb;
    isDisabled ? verb = 'updated' : verb = 'saved';

    if (hexCode.id != null) {
      result = await helper.updateHexCode(hexCode);
    }
    else {
      result = await helper.insertHexCode(hexCode);
    }

    if (result != 0) {
      _showAlertDialog('Status', 'Hex code ' + verb + ' successfully!');
    }
    else {
      _showAlertDialog('Status', 'Something went wrong! Please try again!');
    }
  }

  void _delete() async {
    moveToLastScreen();

    if (hexCode.id == null) {
      _showAlertDialog('Status', 'No Hex code was deleted!');
      return;
    }

    int result = await helper.deleteHexCode(hexCode.id);
    if (result != 0) {
      _showAlertDialog('Status', 'Hex code was deleted successfully!');
    }
    else {
      _showAlertDialog('Status', 'Deletion unsuccessful!');
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

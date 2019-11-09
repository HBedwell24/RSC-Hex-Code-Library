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
    'Cream', 'Ice White', 'Frost White'
    ];

  DatabaseHelper helper = DatabaseHelper();

  final _formKey = GlobalKey<FormState>();

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
            child: Form(
              key: _formKey,
              child: ListView(
                children: <Widget>[
                  Padding(
                      padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                      child: TextFormField(
                        validator: (color) {
                          if (color.isEmpty) {
                            return "Field 'Color' is empty.";
                          }
                          else if (!(isAlpha(color))) {
                            return "Non-alphanumeric characters were found in field 'Color'.";
                          }
                          else {
                            return null;
                          }
                        },
                        controller: colorNameController,
                        style: textStyle,
                        onChanged: (value) {
                          debugPrint('Something changed in Color Name Text Field');
                          updateColorName();
                        },
                        decoration: InputDecoration(
                            labelText: 'Color*',
                            labelStyle: textStyle,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0))),
                      )),
                  Padding(
                      padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                      child: TextFormField(
                        validator: (hexColor) {
                          if (hexColor.isEmpty) {
                            return "Field 'Hex Code' is empty.";
                          }
                          else if (!(isHexColor(hexColor))) {
                            return "Invalid Hex color found in field 'Hex Code'.";
                          }
                          else {
                            return null;
                          }
                        },
                        controller: hexCodeController,
                        style: textStyle,
                        onChanged: (value) {
                          debugPrint(
                              'Something changed in Hex Code Text Field');
                          updateHexCode();
                        },
                        decoration: InputDecoration(
                            labelText: 'Hex Code*',
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
                              padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                              color: Theme
                                  .of(context)
                                  .primaryColorDark,
                              textColor: Theme
                                  .of(context)
                                  .primaryColorLight,
                              child: Text(
                                buttonText.toUpperCase(),
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
                            width: 5.0,
                          ),
                          Expanded(
                            child: Opacity(
                              //wrap our button in an `Opacity` Widget
                              opacity: isDisabled ? 1.0 : 0.0, //with 50% opacity
                              child: RaisedButton(
                                padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                                color: Theme
                                    .of(context)
                                    .primaryColorDark,
                                textColor: Theme
                                    .of(context)
                                    .primaryColorLight,
                                child: Text(
                                  'Delete'.toUpperCase(),
                                ),
                                onPressed: isDisabled ? _delete : null
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]
                ),
              ),
            ),
          ));
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

  String validateColor(String color) {


  }

  String validateHexColor(String hexCode) {
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

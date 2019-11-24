import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rsc_hex_code_library/models/hex_code.dart';
import 'package:rsc_hex_code_library/utils/database_helper.dart';
import 'package:rsc_hex_code_library/screens/hex_code_detail.dart';
import 'package:sqflite/sqflite.dart';

import 'hex_code_share.dart';

class HexCodeList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HexCodeState();
  }
}

class HexCodeState extends State<HexCodeList> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<HexCode> hexCodeList;
  int count = 0;

  TextEditingController controller = new TextEditingController();

  List<HexCode> _newData = [];
  int _newCount;

  _onChanged(String value) {
    setState(() {
      _newData = hexCodeList
          .where((hexCode) => hexCode.colorName.toString().toLowerCase().contains(value.toLowerCase()))
          .toList();
      _newCount = _newData.length;
      print(_newData);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (hexCodeList == null) {
      hexCodeList = List<HexCode>();
      updateListView();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Hex Codes'),
        elevation: 0.0,
        actions: <Widget>[
          new IconButton(
            icon: new Icon(Icons.add),
            color: Colors.white,
            tooltip: 'Add Hex Code',
            onPressed: () {
              navigateToDetailView(HexCode('', '', false), 'Add Hex Code', 'Submit', false);
            }
          ),
          new IconButton(
            icon: new Icon(Icons.share),
            color: Colors.white,
            tooltip: 'Share Hex Code(s)',
            onPressed: () {
              decideShareClickAction();
            }
          )
        ],
      ),
      body: new Column(
        children: <Widget>[
          new Container(
            color: Theme.of(context).primaryColor,
            child: new Padding(
              padding: const EdgeInsets.all(8.0),
              child: new Card(
                child: new ListTile(
                  leading: new Icon(Icons.search),
                  title: new TextField(
                    controller: controller,
                    decoration: new InputDecoration(
                        hintText: 'Search', border: InputBorder.none),
                    onChanged: _onChanged,
                  ),
                  trailing: new IconButton(
                    icon: new Icon(Icons.clear),
                    onPressed: () {
                      controller.clear();
                    },
                  ),
                ),
              ),
            ),
          ),
          new Expanded(
            child: ListView.builder(
              itemCount: decideCount(),
              itemBuilder: (BuildContext context, int position) {
                return Center(
                  child: Card(
                    color: Colors.white,
                    elevation: 2.0,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        ListTile(
                          leading: Container(
                            width: 42.0,
                            height: 42.0,
                            decoration: BoxDecoration(
                              color: Color(
                                convertHexCode(decideHexCode(context, position))
                              )
                            ),
                          ),
                          trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                IconButton(
                                  icon: new Icon(Icons.edit),
                                  tooltip: "Edit Hex Code",
                                  onPressed: () => navigateToDetailView(this.hexCodeList[position], 'Edit Hex Code', 'Update', true),
                                ),
                                IconButton(
                                  icon: new Icon(Icons.delete),
                                  tooltip: "Delete Hex Code",
                                  onPressed: () => _showDialog(context, position),
                                ),
                              ]
                          ),
                          title: Text(decideColorName(context, position)),
                          subtitle: decideSubtitle(context, position),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  int decideCount() {
    if (_newData.length > 0) {
      return _newCount;
    }
    else {
      return count;
    }
  }

  decideColorName(BuildContext context, int position) {
    if (_newData.length > 0) {
      return _newData[position].colorName;
    }
    else {
      return hexCodeList[position].colorName;
    }
  }

  decideHexCode(BuildContext context, int position) {
    if (_newData.length > 0) {
      return _newData[position].hexCode;
    }
    else {
      return hexCodeList[position].hexCode;
    }
  }

  decideShareClickAction() {
    if (hexCodeList.length > 0) {
      navigateToShareView(false);
    }
    else {
      return null;
    }
  }

  MaterialColor decideShareColor() {
    if (hexCodeList.length > 0) {
      return Colors.blue;
    }
    else {
      return Colors.lightGreen;
    }
  }

  void _showDialog(BuildContext context, int position) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title:
              new Text("Are you sure you want to delete the following item? This action cannot be undone."),
          content: new Text(this.hexCodeList[position].colorName + "(" + this.hexCodeList[position].colorName + ")"),
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
                _delete(context, hexCodeList[position]);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget decideSubtitle(BuildContext context, int position) {
    if (this.hexCodeList[position].pearlescent.isEmpty) {
      return Text(decideHexCode(context, position));
    } else {
      return Text(decideHexCode(context, position) +
          ' w/ ' +
          this.hexCodeList[position].pearlescent +
          ' pearlescent');
    }
  }

  int convertHexCode(String hexCode) {
    hexCode = hexCode.toUpperCase().replaceAll("#", "");
    if (hexCode.length == 6) {
      hexCode = "FF" + hexCode;
    }
    return int.parse(hexCode, radix: 16);
  }

  void _delete(BuildContext context, HexCode hexCode) async {
    int result = await databaseHelper.deleteHexCode(hexCode.id);
    if (result != 0) {
      //_showSnackBar(context, 'Hex Code Deleted Successfully!');
      updateListView();
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    Scaffold.of(context).showSnackBar(snackBar);
  }

  void navigateToDetailView(HexCode hexCode, String title,
      String buttonText, bool isDisabled) async {
      bool result = await Navigator.push(context, MaterialPageRoute(builder: (context) {
        return HexCodeDetail(hexCode, title, buttonText, isDisabled);
      }));

    if (result == true) {
      updateListView();
    }
  }

  void navigateToShareView(bool checkBoxSelected) async {
    bool result = await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return HexCodeShare(checkBoxSelected);
    }));

    if (result == true) {
      updateListView();
    }
  }

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<HexCode>> hexCodeListFuture = databaseHelper.getHexCodeList();
      hexCodeListFuture.then((hexCodeList) {
        setState(() {
          this.hexCodeList = hexCodeList;
          this.count = hexCodeList.length;
        });
      });
    });
  }
}

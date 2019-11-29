import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rsc_hex_code_library/models/category.dart';
import 'package:rsc_hex_code_library/models/hex_code.dart';
import 'package:rsc_hex_code_library/utils/database_helper.dart';
import 'package:rsc_hex_code_library/screens/hex_code/hex_code_detail.dart';
import 'package:sqflite/sqflite.dart';

import 'hex_code_share.dart';

class HexCodeList extends StatefulWidget {
  final Category category;

  HexCodeList(this.category);

  @override
  State<StatefulWidget> createState() {
    return HexCodeState(this.category);
  }
}

class HexCodeState extends State<HexCodeList> {

  DatabaseHelper databaseHelper = DatabaseHelper();
  List<HexCode> hexCodeList;
  int count = 0;

  TextEditingController controller = new TextEditingController();
  Category category;

  List<HexCode> _newData = [];
  int _newCount;

  HexCodeState(this.category);

  _onChanged(String value) {
    setState(() {
      if (value.isEmpty) {
        _newData.clear();
      }
      else {
        _newData = hexCodeList
            .where((hexCode) => hexCode.colorName.toString().toLowerCase().contains(value.toLowerCase()))
            .toList();
        _newCount = _newData.length;
      }
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
        title: Text(category.name),
        actions: <Widget>[
          new IconButton(
            icon: new Icon(Icons.add),
            color: Colors.white,
            tooltip: 'Add Hex Code',
            onPressed: () {
              _newData.clear();
              controller.clear();
              navigateToHexCodeDetailView(HexCode('', '', category.name, false), 'Add Hex Code', 'Submit', false);
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
                              shape: BoxShape.circle,
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
                                  onPressed: () => navigateToHexCodeDetailView(decidePosition(context, position), 'Edit Hex Code', 'Update', true),
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

  decidePosition(BuildContext context, int position) {
    if (_newData.length > 0) {
      return this._newData[position];
    }
    else {
      return this.hexCodeList[position];
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
      if (_newData[position].hexCode[0].contains('#')) {
        return _newData[position].hexCode;
      }
      else {
        return '#' + _newData[position].hexCode;
      }
    }
    else {
      if (hexCodeList[position].hexCode[0].contains('#')) {
        return hexCodeList[position].hexCode;
      }
      else {
        return '#' + hexCodeList[position].hexCode;
      }
    }
  }

  void decideShareClickAction() {
    if (hexCodeList.length > 0) {
      navigateToShareView();
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
          content: new Text(decideColorName(context, position) + " (" + decideHexCode(context, position) + ")"),
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
                _delete(context, decidePosition(context, position));
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget decideSubtitle(BuildContext context, int position) {
    if (decidePearlescent(context, position).isEmpty) {
      return Text(decideHexCode(context, position));
    }
    else {
      return Text(decideHexCode(context, position) +
        ' w/ ' +
        this.hexCodeList[position].pearlescent +
        ' pearlescent');
    }
  }

  decidePearlescent(BuildContext context, int position) {
    if (_newData.length > 0) {
      return _newData[position].pearlescent;
    }
    else {
      return hexCodeList[position].pearlescent;
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
    _newData.remove(hexCode);
    if (result != 0) {
      updateListView();
    }
  }

  void navigateToHexCodeDetailView(HexCode hexCode, String title, String buttonText, bool isDisabled) async {
      bool result = await Navigator.push(context, MaterialPageRoute(builder: (context) {
        return HexCodeDetail(hexCode, title, buttonText, isDisabled);
      }));

    if (result == true) {
      updateListView();
    }
  }

  void navigateToShareView() async {
    bool result = await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return HexCodeShare();
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

          this._newData = _newData;
          this._newCount = _newData.length;
        });
      });
    });
  }
}

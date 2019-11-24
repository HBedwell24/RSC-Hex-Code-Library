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

List<HexCode> _searchResult = [];
List<HexCode> _hexCodeDetails = [];

onSearchTextChanged(String text) async {
  _searchResult.clear();
  if (text.isEmpty) {
    //setState(() {});
    return;
  }
  _hexCodeDetails.forEach((userDetail) {
    if (userDetail.colorName.contains(text) || userDetail.hexCode.contains(text))
      _searchResult.add(userDetail);
  });
  //setState(() {});
}

class HexCodeState extends State<HexCodeList> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<HexCode> hexCodeList;
  int count = 0;

  TextEditingController controller = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (hexCodeList == null) {
      hexCodeList = List<HexCode>();
      updateListView();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Hex Codes'),
        actions: <Widget>[
          new IconButton(
              icon: new Icon(Icons.add),
              color: Colors.white,
              tooltip: 'Add Hex Code',
              onPressed: () {
                navigateToDetailView(HexCode('', '', false), 'Add Hex Code', 'Submit', false);
              }),
          new IconButton(
              icon: new Icon(Icons.share),
              color: Colors.white,
              tooltip: 'Share Hex Code(s)',
              onPressed: () {
                decideShareClickAction();
              })
        ],
      ),
      body: new Column(
          children: <Widget>[
            new Container(
              color: Theme.of(context).primaryColorDark,
              child: new Padding(
                padding: const EdgeInsets.all(8.0),
                child: new Card(
                  child: new ListTile(
                    leading: new Icon(Icons.search),
                    title: new TextField(
                      controller: controller,
                      decoration: new InputDecoration(
                          hintText: 'Search', border: InputBorder.none),
                      onChanged: onSearchTextChanged,
                    ),
                    trailing: new IconButton(icon: new Icon(Icons.clear), onPressed: () {
                      controller.clear();
                      onSearchTextChanged('');
                    },),
                  ),
                ),
              ),
            ),
            new Expanded(
            child: ListView.builder(
              itemCount: count,
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
                            convertHexCode(this.hexCodeList[position]
                            .hexCode))),
                          ),
                          title: Text(this.hexCodeList[position].colorName),
                          subtitle: decideSubtitle(context, position),
                        ),
                        ButtonTheme.bar(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              FlatButton(
                                child: const Text('EDIT'),
                                onPressed: () {
                                navigateToDetailView(this.hexCodeList[position],
                                  'Edit Hex Code', 'Update', true);},
                              ),
                              FlatButton(
                                child: const Text('DELETE'),
                                onPressed: () {
                                  _showDialog(context, position);
                                },
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                );},
            )
            )]),
    );
  }

  Function decideShareClickAction() {
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

  // adapter for hex code list tile
  ListView getHexCodeListView() {

    return ListView.builder(
      itemCount: count,
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
                            convertHexCode(this.hexCodeList[position]
                                .hexCode))),
                  ),
                  title: Text(
                    this.hexCodeList[position].colorName,
                  ),
                  subtitle: decideSubtitle(context, position),
                ),
                ButtonTheme.bar(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      FlatButton(
                        child: const Text('EDIT'),
                        onPressed: () {
                          navigateToDetailView(this.hexCodeList[position],
                              'Edit Hex Code', 'Update', true);
                        },
                      ),
                      FlatButton(
                        child: const Text('DELETE'),
                        onPressed: () {
                          _showDialog(context, position);
                        },
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDialog(BuildContext context, int position) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title:
              new Text("Are you sure you want to delete the following item?"),
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
      return Text(this.hexCodeList[position].hexCode);
    } else {
      return Text(this.hexCodeList[position].hexCode +
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

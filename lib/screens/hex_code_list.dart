import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rsc_hex_code_library/models/hex_code.dart';
import 'package:rsc_hex_code_library/utils/database_helper.dart';
import 'package:rsc_hex_code_library/screens/hex_code_detail.dart';
import 'package:sqflite/sqflite.dart';

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

  @override
  Widget build(BuildContext context) {
    if (hexCodeList == null) {
      hexCodeList = List<HexCode>();
      updateListView();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Hex Codes'),
      ),
      body: getHexCodeListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          debugPrint('FAB clicked');
          navigateToDetailView(HexCode('', ''), 'Add Hex Code');
        },
        tooltip: 'Add Note',
        child: Icon(Icons.add),
      ),
    );
  }

  ListView getHexCodeListView() {
    TextStyle titleStyle = Theme.of(context).textTheme.subhead;

    return ListView.builder(
      itemCount: count,
      itemBuilder: (BuildContext context, int position) {
        return Center(
            child: Card(
                color: Colors.white, elevation: 2.0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTile(
                    leading: Container(
                      width: 42.0,
                      height: 42.0,
                      decoration: BoxDecoration(
                          color: Color(
                              convertHexCode(this.hexCodeList[position].hexCode))),
                    ),
                    title: Text(
                      this.hexCodeList[position].colorName,
                    ),
                    subtitle: decideSubtitle(context, position),
                  ),
                    ButtonTheme.bar(
                      child: ButtonBar(
                        children: <Widget>[
                          FlatButton(
                            child: const Text('EDIT'),
                            onPressed: () {
                              navigateToDetailView(this.hexCodeList[position], 'Edit Hex Code');
                            },
                          ),
                          FlatButton(
                            child: const Text('DELETE'),
                            onPressed: () {
                              _delete(context, hexCodeList[position]);
                            },
                          )
                        ],
                      ),
                    )
                  ]),
              ));
            },
    );
  }

  Widget decideSubtitle(BuildContext context, int position) {
    if (this.hexCodeList[position].pearlescent != null) {
      return Text(this.hexCodeList[position].hexCode + ' w/ ' + this.hexCodeList[position].pearlescent + ' pearlescent');
    }
    else {
      return Text(this.hexCodeList[position].hexCode);
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
      _showSnackBar(context, 'Hex Code Deleted Successfully!');
      updateListView();
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    Scaffold.of(context).showSnackBar(snackBar);
  }

  void navigateToDetailView(HexCode hexCode, String title) async {
    bool result = await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return HexCodeDetail(hexCode, title);
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

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rsc_hex_code_library/models/hex_code.dart';
import 'package:rsc_hex_code_library/utils/database_helper.dart';
import 'package:share/share.dart';
import 'package:sqflite/sqflite.dart';

class HexCodeShare extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return HexCodeState();
  }
}

class HexCodeState extends State<HexCodeShare> {
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
        title: Text('Share Hex Code(s)'),
      ),
      body: getHexCodeListView(),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(4.0, 0.0, 4.0, 0.0),
        child: RaisedButton(
          onPressed: () {
            setState(() {
              debugPrint('Share button clicked');
              Share.share('Share button clicked!');
            });
          },
          color: Colors.blue,
          textColor: Colors.white,
          child: Text('Share'),
        ),
      ),
    );
  }

  ListView getHexCodeListView() {

    bool _selected = false;

    return ListView.builder(
      itemCount: count,
      itemBuilder: (BuildContext context, int position) {
        return Center(
            child: Card(
              color: Colors.white,
              elevation: 2.0,
              child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
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
                  trailing: Checkbox(
                      value: _selected,
                      onChanged: null),
                ),
              ]),
            ));
      },
    );
  }

  Widget decideSubtitle(BuildContext context, int position) {
    if (this.hexCodeList[position].pearlescent.isEmpty) {
      return Text(this.hexCodeList[position].hexCode);
    }
    else {
      return Text(this.hexCodeList[position].hexCode +
          ' w/ ' + this.hexCodeList[position].pearlescent +
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

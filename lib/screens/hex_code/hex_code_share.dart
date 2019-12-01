import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rsc_hex_code_library/models/category.dart';
import 'package:rsc_hex_code_library/models/hex_code.dart';
import 'package:rsc_hex_code_library/utils/database_helper.dart';
import 'package:share/share.dart';
import 'package:sqflite/sqflite.dart';

List<String> shareList = List<String>();

class HexCodeShare extends StatefulWidget {

  final Category category;

  HexCodeShare(this.category);

  @override
  State<StatefulWidget> createState() {
    return HexCodeState(this.category);
  }
}

class HexCodeState extends State<HexCodeShare> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<HexCode> hexCodeList;
  Category category;
  int count = 0;
  bool isSelected = false;

  HexCodeState(this.category);

  @override
  Widget build(BuildContext context) {
    if (hexCodeList == null) {
      hexCodeList = List<HexCode>();
      updateListView();
    }
    return WillPopScope(
      onWillPop: () {
        moveToLastScreen();
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Share Hex Code(s)'),
        ),
        body: Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              getSelectAllCard(),
              Expanded(
                child: getHexCodeListView(),
              )
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.fromLTRB(4.0, 4.0, 4.0, 4.0),
          child: Visibility(
            visible: shareList.length > 0 ? true : false,
            child: RaisedButton(
              padding: EdgeInsets.only(top: 15, bottom: 15),
              color: Theme
                  .of(context)
                  .primaryColor,
              textColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(5.0),
              ),
              child: Text(
                'Share'.toUpperCase(),
                style: new TextStyle(
                  fontSize: 16,
                ),
              ),
              onPressed: () {
                setState(() {
                  debugPrint('Share button clicked');
                  StringBuffer stringBuffer = new StringBuffer();
                  for (int i = 0; i < shareList.length; i++) {
                    int counter = i + 1;
                    stringBuffer.write(counter.toString() + ". " + shareList[i] + "\n");
                  }
                  Share.share(stringBuffer.toString());
                });
              },
            ),
          ),
        ),
      ),
    );
  }

  // adapter for hex code list view
  ListView getHexCodeListView() {
    return ListView.builder(
      shrinkWrap: true,
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
                      shape: BoxShape.circle,
                      color: Color(
                        convertHexCode(this.hexCodeList[position].hexCode)
                      )
                    ),
                  ),
                  title: Text(
                    this.hexCodeList[position].colorName,
                  ),
                  subtitle: decideSubtitle(context, position),
                  trailing: Checkbox(
                    value: this.hexCodeList[position].isSelected == true,
                    onChanged: (bool value) {
                      setState(() {
                        this.hexCodeList[position].isSelected = value;
                        if (this.hexCodeList[position].isSelected == true) {
                          if (this.hexCodeList[position].pearlescent.isNotEmpty) {
                            if(this.hexCodeList[position].hexCode[0].contains('#')) {
                              shareList.add(this.hexCodeList[position].colorName + " (" + this.hexCodeList[position].hexCode.toUpperCase() + ") w/ " +
                                  this.hexCodeList[position].pearlescent + " Pearlescent");
                              print("ShareList: " + shareList.toString());
                            }
                            else {
                              shareList.add(this.hexCodeList[position].colorName + " (#" + this.hexCodeList[position].hexCode.toUpperCase() + ") w/ " +
                                  this.hexCodeList[position].pearlescent + " Pearlescent");
                              print("ShareList: " + shareList.toString());
                            }
                          }
                          else {
                            if(this.hexCodeList[position].hexCode[0].contains('#')) {
                              shareList.add(this.hexCodeList[position].colorName + " (" + this.hexCodeList[position].hexCode.toUpperCase() + ")");
                              print("ShareList: " + shareList.toString());
                            }
                            else {
                              shareList.add(this.hexCodeList[position].colorName + " (#" + this.hexCodeList[position].hexCode.toUpperCase() + ")");
                              print("ShareList: " + shareList.toString());
                            }
                          }
                        }
                        else {
                          if (this.hexCodeList[position].pearlescent.isNotEmpty) {
                            if(this.hexCodeList[position].hexCode[0].contains('#')) {
                              shareList.remove(this.hexCodeList[position].colorName + " (" + this.hexCodeList[position].hexCode.toUpperCase() + ") w/ " +
                                  this.hexCodeList[position].pearlescent + " Pearlescent");
                              print("ShareList: " + shareList.toString());
                            }
                            else {
                              shareList.remove(this.hexCodeList[position].colorName + " (#" + this.hexCodeList[position].hexCode.toUpperCase() + ") w/ " +
                                  this.hexCodeList[position].pearlescent + " Pearlescent");
                              print("ShareList: " + shareList.toString());
                            }
                          }
                          else {
                            if(this.hexCodeList[position].hexCode[0].contains('#')) {
                              shareList.remove(this.hexCodeList[position].colorName + " (" + this.hexCodeList[position].hexCode.toUpperCase() + ")");
                              print("ShareList: " + shareList.toString());
                            }
                            else  {
                              shareList.remove(this.hexCodeList[position].colorName + " (#" + this.hexCodeList[position].hexCode.toUpperCase() + ")");
                              print("ShareList: " + shareList.toString());
                            }
                          }
                        }
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Card getSelectAllCard() {
    return Card(
      color: Colors.white,
      elevation: 2.0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            title: Text(
              "Select All" + " (" + (hexCodeList.length).toString() + ")",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: Checkbox(
              value: isSelected,
              onChanged: (bool value) {
                setState(() {
                  isSelected = value;

                  // if select all checkbox is enabled, check all items
                  if(isSelected == true) {
                    for(int i = 0; i < hexCodeList.length; i++) {
                      if(hexCodeList[i].isSelected == false) {
                        hexCodeList[i].isSelected = true;

                        if(this.hexCodeList[i].pearlescent.isNotEmpty) {
                          if(this.hexCodeList[i].hexCode[0].contains('#')) {
                            shareList.add(this.hexCodeList[i].colorName + " (" + this.hexCodeList[i].hexCode.toUpperCase() + ") w/ " +
                              this.hexCodeList[i].pearlescent + " Pearlescent");
                            print("ShareList: " + shareList.toString());
                          }
                          else {
                            shareList.add(this.hexCodeList[i].colorName + " (#" + this.hexCodeList[i].hexCode.toUpperCase() + ") w/ " +
                              this.hexCodeList[i].pearlescent + " Pearlescent");
                            print("ShareList: " + shareList.toString());
                          }
                        }
                        else {
                          if(this.hexCodeList[i].hexCode[0].contains('#')) {
                            shareList.add(this.hexCodeList[i].colorName + " (" + this.hexCodeList[i].hexCode.toUpperCase() + ")");
                            print("ShareList: " + shareList.toString());
                          }
                          else {
                            shareList.add(this.hexCodeList[i].colorName + " (#" + this.hexCodeList[i].hexCode.toUpperCase() + ")");
                            print("ShareList: " + shareList.toString());
                          }
                        }
                      }
                    }
                  }
                  // if select all checkbox is disabled, uncheck all items
                  else {
                    for(int i = 0; i < hexCodeList.length; i++) {
                      hexCodeList[i].isSelected = false;

                      shareList.clear();
                      print("ShareList: " + shareList.toString());
                    }
                  }
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  // up navigation to parent screen
  void moveToLastScreen() {
    shareList.clear();
    Navigator.pop(context, true);
  }

  // decides contents of subtitle based on presence of optional parameters
  Widget decideSubtitle(BuildContext context, int position) {
    if (hexCodeList[position].hexCode[0].contains('#')) {
      if (this.hexCodeList[position].pearlescent.isEmpty || this.hexCodeList[position].pearlescent.contains('No Selection')) {
        return Text(this.hexCodeList[position].hexCode.toUpperCase());
      }
      else {
        return Text(this.hexCodeList[position].hexCode.toUpperCase() +
          ' w/ ' + this.hexCodeList[position].pearlescent +
          ' Pearlescent');
      }
    }
    else {
      if (this.hexCodeList[position].pearlescent.isEmpty || this.hexCodeList[position].pearlescent.contains('No Selection')) {
        return Text('#' + this.hexCodeList[position].hexCode.toUpperCase());
      }
      else {
        return Text('#' + this.hexCodeList[position].hexCode.toUpperCase() +
          ' w/ ' + this.hexCodeList[position].pearlescent +
          ' Pearlescent');
      }
    }
  }

  // converts a string to hexadecimal format
  int convertHexCode(String hexCode) {
    hexCode = hexCode.toUpperCase().replaceAll("#", "");
    if (hexCode.length == 6) {
      hexCode = "FF" + hexCode;
    }
    return int.parse(hexCode, radix: 16);
  }

  // updates list view content
  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<HexCode>> hexCodeListFuture = databaseHelper.getHexCodesFromCategory(category.name);
      hexCodeListFuture.then((hexCodeList) {
        setState(() {
          this.hexCodeList = hexCodeList;
          this.count = hexCodeList.length;
        });
      });
    });
  }
}

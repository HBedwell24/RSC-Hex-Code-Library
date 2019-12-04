import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rsc_hex_code_library/models/category.dart';
import 'package:rsc_hex_code_library/screens/hex_code/hex_code_list.dart';
import 'package:rsc_hex_code_library/utils/database_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'category_detail.dart';

class CategoryList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return CategoryState();
  }
}

class CategoryState extends State<CategoryList> {

  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Category> categoryList;
  Future<int> future;
  int count = 0;

  @override
  Widget build(BuildContext context) {
    if (categoryList == null) {
      categoryList = List<Category>();
      updateListView();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Categories'),
        actions: <Widget>[
          new IconButton(
              icon: new Icon(Icons.add),
              color: Colors.white,
              tooltip: 'Add Category',
              onPressed: () {
                navigateToCategoryDetailView(Category(''), 'Add Category', 'Submit', false);
              }
          ),
        ],
      ),
      body: new Column(
        children: <Widget>[
          new Expanded(
            child: FutureBuilder<List<int>>(
              future: databaseHelper.getHexCodeCountsFromCategories(categoryList),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.none ||
                    snapshot.connectionState == ConnectionState.waiting ||
                    snapshot.connectionState == ConnectionState.active) {
                  return Container(
                    alignment: Alignment.center,
                    child: Text("Loading"),
                  );
                }
                else if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError) {
                    // return whatever you'd do for this case, probably an error
                    return Container(
                      alignment: Alignment.center,
                      child: Text("Error: ${snapshot.error}"),
                    );
                  }
                  else {
                    var data = snapshot.data;
                    return new ListView.builder(
                      itemCount: count,
                      itemBuilder: (BuildContext context, int position) {
                        return Center(
                          child: Card(
                            color: Colors.white,
                            elevation: 2.0,
                            child: new InkWell(
                              onTap: () {
                                navigateToHexCodeListView(categoryList[position]);
                              },
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  ListTile(
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        IconButton(
                                          icon: new Icon(Icons.edit),
                                          tooltip: "Edit Category",
                                          onPressed: () =>
                                              navigateToCategoryDetailView(categoryList[position],
                                                  'Edit Category', 'Update', true),
                                        ),
                                        IconButton(
                                          icon: new Icon(
                                              Icons.delete),
                                          tooltip: "Delete Category",
                                          onPressed: () => _showDialog(context, position),
                                        ),
                                      ],
                                    ),
                                    title: Text(
                                        categoryList[position].name + " (" + data[position].toString() + ")"),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                }
                return Container();
              },
            ),
          ),
        ],
      ),
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
          new Text("Are you sure you want to delete the following category? This action will delete all associated colors and cannot be undone."),
          content: new Text(categoryList[position].name),
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
                // delete hex codes from category and remove category from list view
                databaseHelper.deleteHexCodesFromCategory(categoryList[position].name);
                _delete(context, categoryList[position]);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _delete(BuildContext context, Category category) async {
    int result = await databaseHelper.deleteCategory(category.id);
    if (result != 0) {
      updateListView();
    }
  }

  void navigateToHexCodeListView(Category category) async {
    bool result = await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return HexCodeList(category);
    }));
  }

  void navigateToCategoryDetailView(Category category, String title, String buttonText, bool isDisabled) async {
    bool result = await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return CategoryDetail(category, title, buttonText, isDisabled);
    }));

    if (result == true) {
      updateListView();
    }
  }

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Category>> categoryListFuture = databaseHelper.getCategoryList();
      categoryListFuture.then((categoryList) {
        setState(() {
          this.categoryList = categoryList;
          this.count = categoryList.length;
        });
      });
    });
  }
}
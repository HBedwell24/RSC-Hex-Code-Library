import 'package:flutter/material.dart';
import 'package:rsc_hex_code_library/models/category.dart';
import 'package:rsc_hex_code_library/utils/database_helper.dart';

class CategoryDetail extends StatefulWidget {

  final String appBarTitle;
  final Category category;
  final String buttonText;
  final bool isDisabled;

  CategoryDetail(this.category, this.appBarTitle, this.buttonText, this.isDisabled);

  @override
  State<StatefulWidget> createState() {
    return CategoryDetailState(this.category, this.appBarTitle, this.buttonText, this.isDisabled);
  }
}

class CategoryDetailState extends State<CategoryDetail> {

  DatabaseHelper helper = DatabaseHelper();

  final _formKey = GlobalKey<FormState>();

  String appBarTitle;
  Category category;
  String buttonText;
  bool isDisabled;
  String oldCategoryName;

  TextEditingController categoryNameController = TextEditingController();

  CategoryDetailState(this.category, this.appBarTitle, this.buttonText, this.isDisabled);
  var currentSelectedValue;

  @override
  Widget build(BuildContext context) {

    TextStyle textStyle = Theme.of(context).textTheme.title;

    categoryNameController.text = category.name;
    if(category.name != null) {
      oldCategoryName = category.name;
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
                  padding: EdgeInsets.only(top: 15.0),
                  child: TextFormField(
                    textInputAction: TextInputAction.next,
                    validator: (name) {
                      // if color field is empty, prompt error
                      if (name.isEmpty) {
                        return "Field 'Category Name' is empty.";
                      }
                      // if color field is not empty
                      else {
                        final regex = RegExp(r"^[A-Za-z0-9 _]*[A-Za-z0-9][A-Za-z0-9 _]*$");
                        // check entered color name against a regex for spaces, numbers, or letters
                        if(!(regex.hasMatch(name))) {
                          return "Invalid characters were found in field 'Category Name'.";
                        }
                        else {
                          return null;
                        }
                      }
                    },
                    controller: categoryNameController,
                    style: textStyle,
                    onChanged: (value) {
                      debugPrint("Something changed in 'Category Name' text field.");
                      updateCategoryName();
                    },
                    decoration: InputDecoration(
                      labelText: 'Category Name*',
                      labelStyle: textStyle,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0)
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 30.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
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
                            buttonText.toUpperCase(),
                            style: new TextStyle(
                              fontSize: 18,
                            ),
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

  void updateCategoryName() {
    category.name = categoryNameController.text;
  }

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }

  void _save() async {

    moveToLastScreen();
    int result;
    String verb;
    isDisabled ? verb = 'updated' : verb = 'saved';

    if (category.id != null) {
      result = await helper.updateCategory(category);
      helper.updateHexCodesFromCategory(oldCategoryName, category.name);
    }
    else {
      result = await helper.insertCategory(category);
    }

    if (result != 0) {
      _showAlertDialog('Status', 'Category ' + verb + ' successfully!');
    }
    else {
      _showAlertDialog('Status', 'Something went wrong! Please try again!');
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

import 'package:flutter/material.dart';
import 'package:rsc_hex_code_library/screens/category/category_list.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hex Code Library',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: CategoryList(),
    );
  }
}

# RSC Hex Code Library
A cross platform mobile application built in Flutter, that possesses the capability of storing Hex code color pairs in an SQLite database, all which updates the items in a list view. The user may add a new Hex code, edit an existing Hex code, or delete a Hex code from the database, all which updates the items in the list view. In addition, the user may select one or many of the Hex code pairs to share with an imported contact.

![Category Management](images/categories.jpg?raw=true "Creating, Editing, and Deleting Categories")
![Hex Code Management](images/hex_codes.jpg?raw=true "Creating, Editing, and Deleting Hex Codes")
![Hex Code Sharing](images/sharing.jpg?raw=true "Sharing Hex Codes")

## Technologies Used
* **path_provider** - a Flutter plugin for finding commonly used locations on the filesystem
* **share** - a Flutter plugin to share content from your Flutter app via the platform's share dialog
* **sqflite** - a database engine which is embedded into the application and is used to create, read, update, and delete Category/Hex Code records
* **string_validator** - string validation and sanitization for Dart

![Database Schema](images/schema.png?raw=true "Database Schema")

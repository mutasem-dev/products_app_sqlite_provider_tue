import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'product.dart';

class DatabaseProvider extends ChangeNotifier {
  DatabaseProvider._privateConstructor();

  static final DatabaseProvider instance =
      DatabaseProvider._privateConstructor();
  static Database? _database;
  static const int version = 2;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await initDB();
    return _database!;
  }

  Future<Database> initDB() async {
    String path = join(await getDatabasesPath(), 'uniDB.db');
    return openDatabase(path, version: version,
        onCreate: (Database db, int version) async {
      await db.execute('''
          CREATE TABLE product (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          quantity int,
          price REAL
          )
          ''');
    }, onUpgrade: (Database db, int oldversion, int newversion) {});
  }

  Future<int> add(Product p) async {
    final db = await database;
    int rawId = await db.insert('product', p.toMap());
    notifyListeners();
    return rawId;
  }

  // add(Student student) async {
  //   final db = await database;
  //   // db.rawInsert("INSERT INTO student (name, major, avg) VALUES('ahmed', 'IT', 90)");
  //   db.insert('student', student.toMap());
  //   notifyListeners();
  // }
  Future<int> delete(int id) async {
    final db = await database;
    int cnt = await db.delete('product', where: 'id = ?', whereArgs: [id]);
    notifyListeners();
    return cnt;
  }

  Future<List<Product>> getAllProduct() async {
    final db = await database;
    List<Map<String, dynamic>> map = await db.query('product');
    List<Product> prds = [];
    for (var element in map) {
      prds.add(Product.fromMap(element));
    }
    return prds;
  }
  // delete(int id) async {
  //   final db = await database;

  //   db.delete('student', where: 'id=?', whereArgs: [id]);
  //   // DELETE FROM student WHERE id=id
  //   notifyListeners();
  // }

  // Future<List<Student>> getAllStudents() async {
  //   final db = await database;
  //   List<Map<String, dynamic>> records = await db.query('student');

  //   List<Student> students = [];
  //   for (var record in records) {
  //     Student student = Student.fromMap(record);
  //     students.add(student);
  //   }

  //   return students;
  // }
}

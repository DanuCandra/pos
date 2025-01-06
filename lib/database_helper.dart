import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';

class DatabaseHelper {
  static String formatHarga(int harga) {
    return NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0)
        .format(harga);
  }

  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initializeDatabase();
    return _database!;
  }

  Future<Database> _initializeDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'r.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        db.execute(''' 
          CREATE TABLE menus(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            price INTEGER,
            description TEXT,
            category TEXT
          )
        ''');

        db.execute(''' 
          CREATE TABLE transactions(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT,
            total INTEGER,
            payment_method TEXT, 
            change INTEGER       
          )
        ''');
      },
    );
  }

  // Menu-related functions
  Future<int> insertMenu(Map<String, dynamic> menu) async {
    final db = await database;
    return await db.insert('menus', menu);
  }

  Future<List<Map<String, dynamic>>> getMenus() async {
    final db = await database;
    return await db.query('menus');
  }

  Future<int> updateMenu(int id, Map<String, dynamic> menu) async {
    final db = await database;
    return await db.update('menus', menu, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteMenu(int id) async {
    final db = await database;
    return await db.delete('menus', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> insertTransaction(Map<String, dynamic> transaction) async {
    final db = await database;
    return await db.insert('transactions', transaction);
  }

  Future<List<Map<String, dynamic>>> getTransactions() async {
    final db = await database;
    return await db.query('transactions');
  }

  Future<List<Map<String, dynamic>>> getTransactionsSorted() async {
    final db = await database;
    return await db.query(
      'transactions',
      orderBy: 'date DESC',
    );
  }

  String formatDate(String isoDate) {
    final dateTime = DateTime.parse(isoDate);
    return DateFormat('dd-MM-yyyy HH:mm').format(dateTime);
  }
}

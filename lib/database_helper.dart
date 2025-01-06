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
    final path = join(dbPath, 'kasir.db'); 

    return await openDatabase(
      path,
      version: 4,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE menus(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            price INTEGER,
            description TEXT,
            category TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE transactions(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT,
            total INTEGER,
            payment_method TEXT,
            change INTEGER,
            customer_cash INTEGER
          )
        ''');

        await db.execute('''
          CREATE TABLE transaction_items(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            transaction_id INTEGER,
            menu_id INTEGER,
            quantity INTEGER,
            FOREIGN KEY(transaction_id) REFERENCES transactions(id),
            FOREIGN KEY(menu_id) REFERENCES menus(id)
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 3) {
          await db.execute('''
            CREATE TABLE transaction_items(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              transaction_id INTEGER,
              menu_id INTEGER,
              quantity INTEGER,
              FOREIGN KEY(transaction_id) REFERENCES transactions(id),
              FOREIGN KEY(menu_id) REFERENCES menus(id)
            )
          ''');
        }
      },
    );
  }

  // Menu-related functions
  Future<List<Map<String, dynamic>>> getAllTransactions() async {
    final db = await instance.database;
    return await db.query('transactions', orderBy: 'date DESC');
  }

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

  // Transaction-related functions
  Future<int> insertTransaction(Map<String, dynamic> transaction) async {
    final db = await database;
    return await db.insert('transactions', transaction);
  }

  Future<List<Map<String, dynamic>>> getTransactions() async {
    final db = await database;
    return await db.query('transactions');
  }

  // Transaction Items-related functions
  Future<int> insertTransactionItem(Map<String, dynamic> item) async {
    final db = await database;
    return await db.insert('transaction_items', item);
  }

  Future<List<Map<String, dynamic>>> getTransactionItems(
      int transactionId) async {
    final db = await database;
    return await db.query(
      'transaction_items',
      where: 'transaction_id = ?',
      whereArgs: [transactionId],
    );
  }

  String formatDate(String isoDate) {
    final dateTime = DateTime.parse(isoDate);
    return DateFormat('dd-MM-yyyy HH:mm').format(dateTime);
  }
}

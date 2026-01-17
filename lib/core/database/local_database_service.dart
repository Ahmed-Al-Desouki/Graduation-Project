import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDatabaseService {
  static final LocalDatabaseService instance = LocalDatabaseService._init();
  static Database? _database;

  LocalDatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('reminders_v2.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE occurrences (
        id INTEGER PRIMARY KEY AUTOINCREMENT, 
        reminderId INTEGER NOT NULL,    
        patientId INTEGER NOT NULL,
        title TEXT NOT NULL,
        message TEXT,
        dueDateTime TEXT NOT NULL,      
        status INTEGER NOT NULL,         
        type TEXT NOT NULL,             
        syncStatus INTEGER DEFAULT 0,    
        actionTime TEXT,                 
        canSnooze INTEGER,               
        canConfirm INTEGER              
      )
    ''');
  }

  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('occurrences');
    print("🧹 SQLite: Occurrences table cleared.");
  }
}

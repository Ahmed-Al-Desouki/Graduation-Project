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
        id INTEGER PRIMARY KEY AUTOINCREMENT,        -- هو الـ ID اللي جاي من السيرفر [cite: 32]
        reminderId INTEGER NOT NULL,     -- لربطه بالريمندر الأساسي
        patientId INTEGER NOT NULL,
        title TEXT NOT NULL,
        message TEXT,
        dueDateTime TEXT NOT NULL,       -- الوقت المحلي ISO [cite: 32]
        status INTEGER NOT NULL,         -- (0=Pending, 2=Taken, إلخ) [cite: 140]
        type TEXT NOT NULL,              -- (Medication, Appointment, Custom)
        syncStatus INTEGER DEFAULT 0,    -- (0 = Synced, 1 = Pending Update)
        actionTime TEXT,                 -- الوقت اللي المريض داس فيه فعلياً [cite: 162]
        canSnooze INTEGER,               -- Flag جاي من الباك [cite: 213]
        canConfirm INTEGER               -- Flag جاي من الباك [cite: 212]
      )
    ''');
  }

  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('occurrences');
    print("🧹 SQLite: Occurrences table cleared.");
  }
}

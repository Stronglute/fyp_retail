import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/chat_message.dart';

class LocalChatService {
  static final LocalChatService _instance = LocalChatService._internal();
  factory LocalChatService() => _instance;
  LocalChatService._internal();

  Database? _db;

  Future<Database> get _database async {
    if (_db != null) return _db!;
    final path = join(await getDatabasesPath(), 'chat_history.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, _) {
        return db.execute('''
          CREATE TABLE messages(
            id TEXT PRIMARY KEY,
            chatId TEXT,
            senderId TEXT,
            message TEXT,
            timestamp INTEGER
          )
        ''');
      },
    );
    return _db!;
  }

  Future<void> insertMessage(ChatMessage msg) async {
    final db = await _database;
    await db.insert('messages', {
      'id': msg.id,
      'chatId': msg.chatId,
      'senderId': msg.senderId,
      'message': msg.message,
      'timestamp': msg.timestamp.millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<ChatMessage>> getAllMessages(String chatId) async {
    final db = await _database;
    final rows = await db.query(
      'messages',
      where: 'chatId = ?',
      whereArgs: [chatId],
      orderBy: 'timestamp ASC',
    );
    return rows
        .map(
          (r) => ChatMessage(
            id: r['id'] as String,
            chatId: r['chatId'] as String,
            senderId: r['senderId'] as String,
            message: r['message'] as String,
            timestamp: DateTime.fromMillisecondsSinceEpoch(
              r['timestamp'] as int,
            ),
          ),
        )
        .toList();
  }
}

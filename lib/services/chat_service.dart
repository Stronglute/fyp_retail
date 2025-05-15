import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_message.dart';
import 'local_chat_service.dart';

class ChatService {
  final _firestore = FirebaseFirestore.instance;
  final _local = LocalChatService();

  /// Generates a consistent chatId for buyer-seller pair
  static String getChatId(String buyerId, String sellerId) {
    final ids = [buyerId, sellerId]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  /// Stream of the last 10 messages for this buyer-seller chat
  Stream<List<ChatMessage>> getChatMessages(String chatId) {
    final coll = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(10);

    return coll.snapshots().map((snap) {
      final msgs =
          snap.docs.map((d) {
              final m = ChatMessage.fromFirestore(d.id, d.data(), chatId);
              _local.insertMessage(m);
              return m;
            }).toList()
            ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
      return msgs;
    });
  }

  /// Send a message, then trim history in Firestore to last 10
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String message,
  }) async {
    final ts = DateTime.now();
    final docRef = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
          'senderId': senderId,
          'message': message,
          'timestamp': Timestamp.fromDate(ts),
        });

    final chatMsg = ChatMessage(
      id: docRef.id,
      chatId: chatId,
      senderId: senderId,
      message: message,
      timestamp: ts,
    );

    await _local.insertMessage(chatMsg);

    final all =
        await _firestore
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .orderBy('timestamp', descending: false)
            .get();

    if (all.docs.length > 10) {
      final toDelete = all.docs.take(all.docs.length - 10);
      for (var d in toDelete) await d.reference.delete();
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  final String chatId;
  final String senderId;
  final String message;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.message,
    required this.timestamp,
  });

  factory ChatMessage.fromFirestore(
    String id,
    Map<String, dynamic> data,
    String chatId,
  ) {
    return ChatMessage(
      id: id,
      chatId: chatId,
      senderId: data['senderId'] as String,
      message: data['message'] as String,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    'senderId': senderId,
    'message': message,
    'timestamp': Timestamp.fromDate(timestamp),
  };
}

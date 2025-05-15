import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_message.dart';
import '../services/chat_service.dart';

final chatServiceProvider = Provider<ChatService>((_) => ChatService());

final chatMessagesProvider = StreamProvider.family<List<ChatMessage>, String>((
  ref,
  chatId,
) {
  return ref.read(chatServiceProvider).getChatMessages(chatId);
});

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_message.dart';
import '../providers/chat_provider.dart';
import '../services/chat_service.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String buyerId;
  final String sellerId;
  final String currentUserId;

  const ChatScreen({
    Key? key,
    required this.buyerId,
    required this.sellerId,
    required this.currentUserId,
  }) : super(key: key);

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  late final String chatId;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    chatId = ChatService.getChatId(widget.buyerId, widget.sellerId);
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    await ref
        .read(chatServiceProvider)
        .sendMessage(
          chatId: chatId,
          senderId: widget.currentUserId,
          message: text,
        );
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent + 60,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatAsync = ref.watch(chatMessagesProvider(chatId));

    return Scaffold(
      appBar: AppBar(title: const Text('Buyer–Seller Chat')),
      body: Column(
        children: [
          Expanded(
            child: chatAsync.when(
              data:
                  (messages) => ListView.builder(
                    controller: _scrollController,
                    itemCount: messages.length,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final isMe = msg.senderId == widget.currentUserId;
                      return Align(
                        alignment:
                            isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 12,
                          ),
                          padding: const EdgeInsets.all(12),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.7,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isMe
                                    ? Colors.blue.shade100
                                    : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            msg.message,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      );
                    },
                  ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: \$err')),
            ),
          ),
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      minLines: 1,
                      maxLines: 4,
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    radius: 24,
                    child: IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

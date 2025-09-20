import 'package:flutter/material.dart';

class ChatBox extends StatefulWidget {
  const ChatBox({
    super.key,
    required this.isProcessing,
    required this.onSend,
    required this.onCancel,
  });

  final ValueNotifier<bool> isProcessing;
  final ValueChanged<String> onSend;
  final VoidCallback onCancel;

  @override
  State<ChatBox> createState() => _ChatBoxState();
}

class _ChatBoxState extends State<ChatBox> {
  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.isProcessing,
      builder: (context, isProcessing, child) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textController,
                  decoration: const InputDecoration(
                    hintText: 'Type your message...',
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              if (isProcessing)
                CircularProgressIndicator()
              else
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: isProcessing ? null : _sendMessage,
                ),
              IconButton(
                icon: const Icon(Icons.clear),
                onPressed: isProcessing ? widget.onCancel : null,
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _sendMessage() async {
    final text = _textController.text;
    if (text.isEmpty) return;
    _textController.text = '';
    widget.onSend(text);
  }
}

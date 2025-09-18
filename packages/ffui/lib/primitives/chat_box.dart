import 'package:flutter/material.dart';

class ChatBox extends StatefulWidget {
  const ChatBox({super.key, required this.isProcessing, required this.onSend});

  final ValueNotifier<bool> isProcessing;
  final ValueChanged<String> onSend;

  @override
  State<ChatBox> createState() => _ChatBoxState();
}

class _ChatBoxState extends State<ChatBox> {
  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ValueListenableBuilder(
          valueListenable: widget.isProcessing,
          builder: (_, isProcessing, _) {
            if (!isProcessing) return Container();
            return const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            );
          },
        ),

        Padding(
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
              IconButton(icon: const Icon(Icons.send), onPressed: _sendMessage),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _sendMessage() async {
    final text = _textController.text;
    if (text.isEmpty) return;
    _textController.text = '';
    widget.onSend(text);
  }
}

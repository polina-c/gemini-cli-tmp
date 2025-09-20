import 'dart:async';

import 'package:ffui/primitives/chat_box.dart';
import 'package:ffui/with_a2a/a2a.dart';
import 'package:flutter/material.dart';

import '../with_process/process.dart';

class ChatWithA2A extends StatefulWidget {
  const ChatWithA2A({super.key, required this.title});

  final String title;

  @override
  State<ChatWithA2A> createState() => _ChatWithA2AState();
}

class _ChatWithA2AState extends State<ChatWithA2A> {
  late final _gcli = A2aToGeminiCli(
    _updateStatus,
    _onUserMessage,
    baseUrl: 'http://localhost:41242',
    agentCardUrl: 'http://localhost:41242/.well-known/agent-card.json',
  );
  final _status = ValueNotifier<String>('');
  final _scrollController = ScrollController();

  void _updateStatus(String update) {
    _status.value += '\n$update';
  }

  void _sendMessage(String message) {
    _onUserMessage.sink.add('$message\r\n\r\n');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            tooltip: 'Clear',
            onPressed: () {
              _status.value = '';
              setState(() {});
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SelectionArea(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: ValueListenableBuilder<String>(
                  valueListenable: _status,
                  builder: (context, value, child) {
                    unawaited(_scheduleScrollToBottom(_scrollController));
                    return Text(
                      value,
                      // style: Theme.of(context).textTheme.headlineMedium,
                    );
                  },
                ),
              ),
            ),
          ),
          ChatBox(
            isProcessing: ValueNotifier<bool>(false),
            onSend: _sendMessage,
          ),
        ],
      ),
    );
  }
}

Future<void> _scheduleScrollToBottom(ScrollController controller) async {
  await Future.delayed(const Duration(milliseconds: 100));
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (controller.hasClients) {
      controller.animateTo(
        controller.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  });
}

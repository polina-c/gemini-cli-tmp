import 'dart:async';

import 'package:ffui/primitives/chat_box.dart';
import 'package:flutter/material.dart';

import 'process.dart';

class ChatWithProcess extends StatefulWidget {
  const ChatWithProcess({super.key, required this.title});

  final String title;

  @override
  State<ChatWithProcess> createState() => _ChatWithProcessState();
}

class _ChatWithProcessState extends State<ChatWithProcess> {
  late final _gcli = GeminiCliProcess(_updateStatus, _onUserMessage.stream);
  final _status = ValueNotifier<String>('');
  final _scrollController = ScrollController();
  final _onUserMessage = StreamController<String>.broadcast();

  @override
  void initState() {
    super.initState();
    _start();
  }

  void _updateStatus(String update) {
    _status.value += '\n$update';
  }

  Future<void> _start() async {
    await _gcli.start();
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

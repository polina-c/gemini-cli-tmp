import 'dart:async';

import 'package:a2a/a2a.dart';
import 'package:flutter/widgets.dart';

class GeminiClient {
  GeminiClient(this.onResponse);

  final ValueChanged<String> onResponse;
  final ValueNotifier<bool> isProcessing = ValueNotifier(false);

  final _configuration = A2AMessageSendConfiguration()
    ..acceptedOutputModes = ['text', 'text/event-stream']
    ..blocking = true;
  StreamSubscription<A2ASendStreamMessageResponse>? _subscription;

  late final A2AClient _client = A2AClient(
    'http://localhost:41242',
    'http://localhost:41242/.well-known/agent-card.json',
  );

  Future<String> card() async {
    try {
      final agentCard = await _client.getAgentCard();
      final streaming = agentCard.capabilities.streaming! ? 'Yes' : 'No';
      return '''
Agent name: ${agentCard.name}
Agent description: ${agentCard.description}
Agent version: ${agentCard.version}
Is the agent streaming capable: $streaming
Default input modes: ${agentCard.defaultInputModes}
Default output modes: ${agentCard.defaultOutputModes}
Service endpoint: ${agentCard.url}''';
    } catch (e) {
      return 'Failed to fetch the agent card, ${e.runtimeType}: $e';
    }
  }

  void sendMessage(String message) {
    print('sendMessage: $message');
    if (isProcessing.value) {
      print('Already processing a message, please wait.');
      return;
    }
    isProcessing.value = true;

    final a2aMessage = A2AMessage()
      ..role = 'user'
      ..messageId = '12345'
      ..parts = [A2ATextPart()..text = message];

    final payload = A2AMessageSendParams()
      ..message = a2aMessage
      ..configuration = _configuration;

    final Stream<A2ASendStreamMessageResponse> rpcResponse = _client
        .sendMessageStream(payload);

    _subscription = rpcResponse.listen(
      (A2ASendStreamMessageResponse data) {
        if (data.isError) {
          final error = data as A2AJSONRPCErrorResponseSSM;
          onResponse('Received response error: ${error.error}');
          return;
        }
        final response = data as A2ASendStreamMessageSuccessResponse;
        final result = response.result;
        if (result is A2ATask) {
          if (result.artifacts != null && result.artifacts!.isNotEmpty) {
            final artifact = result.artifacts!.first;
            if (artifact.parts.isNotEmpty) {
              final part = artifact.parts.first;
              if (part is A2ATextPart) {
                onResponse('A2A task received: ${part.text ?? ''}');
              }
            }
          }
        } else if (result is A2ATaskStatusUpdateEvent) {
          final message = result.status?.message;
          if (message != null &&
              message.parts != null &&
              message.parts!.isNotEmpty) {
            final part = message.parts!.first;
            if (part is A2ATextPart) {
              onResponse(part.text);
            }
          }
        }
      },
      onError: (error) {
        print('onError: ${error.runtimeType}: $error');
        // cancel();
      },
      onDone: () {
        print('onDone: cancelling for $message');
        cancel();
      },
      // cancelOnError: true,
    );
  }

  void cancel() {
    _subscription?.cancel();
    _subscription = null;
    isProcessing.value = false;
    print('cancelled');
  }
}

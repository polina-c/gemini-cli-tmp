import 'dart:async';

import 'package:a2a/a2a.dart';
import 'package:flutter/widgets.dart';

class A2aToGeminiCli {
  A2aToGeminiCli(
    this.onResponse, {
    required this.baseUrl,
    required this.agentCardUrl,
  });

  final String baseUrl;
  final String agentCardUrl;
  final ValueChanged<String> onResponse;
  final ValueNotifier<StreamSubscription<A2ASendStreamMessageResponse>?>
  response = ValueNotifier(null);

  late final A2AClient _client = A2AClient(baseUrl, agentCardUrl);

  Future<void> sendMessage(String message) async {
    final a2aMessage = A2AMessage()
      ..role = 'user'
      ..messageId = DateTime.now().millisecondsSinceEpoch.toString()
      ..parts = [A2ATextPart()..text = message];

    final configuration = A2AMessageSendConfiguration()
      ..acceptedOutputModes = ['text', 'text/event-stream']
      ..blocking = true;

    final payload = A2AMessageSendParams()
      ..message = a2aMessage
      ..configuration = configuration;

    final Stream<A2ASendStreamMessageResponse> rpcResponse = _client
        .sendMessageStream(payload);

    response.value = rpcResponse.listen(
      (A2ASendStreamMessageResponse data) {
        if (data.isError) {
          final error = data as A2AJSONRPCErrorResponseSSM;
          onResponse('Received error: ${(error.error as dynamic)?.message}');
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
                onResponse('A2A task received: {part.text}');
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
        print('Received error: $error');
        cancel();
      },
      onDone: () {
        cancel();
      },
      cancelOnError: true,
    );
  }

  void cancel() {
    response.value?.cancel();
    response.value = null;
  }
}

Future<void> spikeStreaming() async {
  const baseUrl = 'http://localhost:41242';

  /// Construct the client, needs the base URL of the agent.
  /// This will also prefetch and cache the agents agent card.
  A2AClient? client = A2AClient(
    baseUrl,
    'http://localhost:41242/.well-known/agent-card.json',
  );

  /// Get the agent card.
  /// If a baseUrl parameter is provided the agent card will be fetched from the agent
  /// at the location specified, otherwise the cached agent card will be returned.
  try {
    final agentCard = await client.getAgentCard();

    /// Print some details of the Agent card
    print('');
    print('Agent card details for the CLI test agent');
    print('');
    print('The agent name is "${agentCard.name}"');
    print('The agent description is "${agentCard.description}"');
    print('The agent version is "${agentCard.version}"');
    final streaming = agentCard.capabilities.streaming! ? 'Yes' : 'No';
    print('Is the agent streaming capable "$streaming"');
    print('Default input modes "${agentCard.defaultInputModes}"');
    print('Default output modes "${agentCard.defaultOutputModes}"');
    print('Service endpoint "${agentCard.url}"');
  } catch (e) {
    print('');
    print(
      'Failed to fetch the agent card, maybe the agent is busy, please try again',
    );
  }

  /// Send a message to the agent to ask it a fact
  const prompt = 'What is the total area of New York state?';

  print('');
  print('Asking the agent "$prompt"');

  /// Build the parameters for the prompt and use the [client.sendMessage] method to
  /// get the response.
  final message = A2AMessage()
    ..role = 'user'
    ..messageId = '12345'
    ..parts = [A2ATextPart()..text = prompt];

  final configuration = A2AMessageSendConfiguration()
    ..acceptedOutputModes = ['text', 'text/event-stream']
    ..blocking = true;

  final payload = A2AMessageSendParams()
    ..message = message
    ..configuration = configuration;

  final Stream<A2ASendStreamMessageResponse> rpcResponse = client
      .sendMessageStream(payload);

  final completer = Completer<void>();
  late final StreamSubscription<A2ASendStreamMessageResponse> subscription;
  subscription = rpcResponse.listen(
    (A2ASendStreamMessageResponse data) {
      if (data.isError) {
        final error = data as A2AJSONRPCErrorResponseSSM;
        print('!!!! Received error: ${(error.error as dynamic)?.message}');
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
              print(part.text);
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
            print(part.text);
          }
        }
      }
    },
    onError: (error) {
      print('!!!! Received error: $error');
      if (error is FormatException) {
        print('!!!! Source of FormatException: ${error.source}');
      }
      if (!completer.isCompleted) {
        completer.complete();
      }
    },
    onDone: () {
      print('!!!! Stream is done.');
      if (!completer.isCompleted) {
        completer.complete();
      }
    },
    cancelOnError: true, // Optional: cancels subscription on error
  );

  await completer.future;
  await subscription.cancel();
}

import 'dart:async';

import 'package:a2a/a2a.dart';
import 'package:flutter/widgets.dart';

class A2aToGeminiCli {
  A2aToGeminiCli(this.onStatusChange, this.userMessages);

  final ValueChanged<String> onStatusChange;
  final Stream<String> userMessages;

  Future<int> start() async {
    return _spike();
  }
}

Future<int> _spike() async {
  const baseUrl = 'http://localhost:41242';

  print('A2AClient Example');

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
    ..parts = [A2ATextPart()..text = prompt];

  final configuration = A2AMessageSendConfiguration()
    ..acceptedOutputModes = ['text']
    ..blocking = true;

  final payload = A2AMessageSendParams()
    ..message = message
    ..configuration = configuration;

  final rpcResponse = await client.sendMessage(payload);

  /// Check for an error
  if (rpcResponse.isError) {
    final errorResponse = rpcResponse as A2AJSONRPCErrorResponseS;
    final code = errorResponse.error?.rpcErrorCode;
    print('');
    print(
      '${('An error has occurred, the RPC error code is $code, ${A2AError.asString(code!)}')}',
    );
    print('');
    print('A2AClient Example Complete with error');
    return -1;
  }

  /// No error so we have a success response
  final response = rpcResponse as A2ASendMessageSuccessResponse;

  /// The result is an A2ATask for this agent, it may be a message for others.
  final result = response.result as A2ATask;

  /// Get the artifacts
  A2AArtifact artifact;
  if (result.artifacts != null) {
    artifact = result.artifacts!.first;
  } else {
    print('');
    print('No artifacts have been returned by the agent');
    print('');
    print('A2AClient Example Complete with no response');
    return -1;
  }

  /// Get the part, we know its a text part
  final part = artifact.parts.first as A2ATextPart;

  /// Get the textual response
  final text = part.text;

  print('');
  print('The agent has returned the following response ....');
  print('');
  print('--------------->');
  print(text);

  /// Complete
  print('A2AClient Example Complete');

  return 0;
}

Future<void> _spikeStreaming() async {
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
    ..parts = [A2ATextPart()..text = prompt];

  final configuration = A2AMessageSendConfiguration()
    ..acceptedOutputModes = ['text', 'text/event-stream']
    ..blocking = true;

  final payload = A2AMessageSendParams()
    ..message = message
    ..configuration = configuration;

  final Stream<A2ASendStreamMessageResponse> rpcResponse = await client
      .sendMessageStream(payload);
  // final rpcResponse = await client.sendMessage(payload);

  late final StreamSubscription<A2ASendStreamMessageResponse> subscription;
  subscription = rpcResponse.listen(
    (A2ASendStreamMessageResponse data) {
      if (data.isError) {
        final errorResponse = rpcResponse as A2AJSONRPCErrorResponseS;
        final code = errorResponse.error?.rpcErrorCode;
        print('');
        print(
          '${('An error has occurred, the RPC error code is $code, ${A2AError.asString(code!)}')}',
        );
        print('');
        print('A2AClient Example Complete with error');
        return;
      }

      final response = data as A2ASendStreamMessageSuccessResponse;
      final result = response.result as A2ATask;
      print('!!!! Received response part: ${result.artifacts}');

      print(result.toJson());
    },
    onError: (error) {
      print('!!!! Received error: $error');
    },
    onDone: () {
      subscription.cancel();
      print('!!!! Stream is done.');
    },
    cancelOnError: true, // Optional: cancels subscription on error
  );

  // /// Check for an error
  // if (rpcResponse.isError) {
  //   final errorResponse = rpcResponse as A2AJSONRPCErrorResponseS;
  //   final code = errorResponse.error?.rpcErrorCode;
  //   print('');
  //   print(
  //     '${('An error has occurred, the RPC error code is $code, ${A2AError.asString(code!)}')}',
  //   );
  //   print('');
  //   print('A2AClient Example Complete with error');
  //   return -1;
  // }

  // /// No error so we have a success response
  // final response = rpcResponse as A2ASendMessageSuccessResponse;

  // /// The result is an A2ATask for this agent, it may be a message for others.
  // final result = response.result as A2ATask;

  // /// Get the artifacts
  // A2AArtifact artifact;
  // if (result.artifacts != null) {
  //   artifact = result.artifacts!.first;
  // } else {
  //   print('');
  //   print('No artifacts have been returned by the agent');
  //   print('');
  //   print('A2AClient Example Complete with no response');
  //   return -1;
  // }

  // /// Get the part, we know its a text part
  // final part = artifact.parts.first as A2ATextPart;

  // /// Get the textual response
  // final text = part.text;

  // print('');
  // print('The agent has returned the following response ....');
  // print('');
  // print('--------------->');
  // print(text);

  // /// Complete
  // print('A2AClient Example Complete');

  // return 0;
}

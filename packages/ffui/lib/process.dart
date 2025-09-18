import 'dart:io';
import 'dart:convert';

import 'package:flutter/foundation.dart';

const geminiCliPath = 'gemini';
const geminiCliPathDev =
    '/Users/polinach/_/gemini-cli/packages/cli/dist/index.js';

class GeminiCliProcess {
  final ValueChanged<String> onStatusChange;
  final Stream<String> userMessages;

  GeminiCliProcess(this.onStatusChange, this.userMessages);

  Future<void> start() async {
    try {
      final process = await Process.start(
        includeParentEnvironment: true,
        // environment: envToPass,
        mode: ProcessStartMode.normal,
        runInShell: true,
        geminiCliPathDev,
        [],
      );

      onStatusChange('started pid: ${process.pid}');

      process.stdin.writeln('input to stdin');

      // Read output from the tool
      _subscribe(process.stdout, (message) {
        onStatusChange('stdout: $message');
      });

      // Handle errors from the tool
      _subscribe(process.stderr, (message) {
        onStatusChange('stderr: $message');
        print('stderr: $message');
      });

      userMessages.listen((message) {
        process.stdin.writeln(message);
      });

      final code = await process.exitCode;

      onStatusChange('Process exited with code $code');
    } catch (e) {
      onStatusChange('Failed to start process: $e');
    }
  }

  static void _subscribe(
    Stream<List<int>> stream,
    void Function(String) onMessage,
  ) {
    stream
        .transform(utf8.decoder) // Decode bytes to UTF-8 strings
        .transform(const LineSplitter()) // Split the string stream into lines
        .listen(onMessage);
  }
}

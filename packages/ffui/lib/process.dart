import 'dart:io';
import 'dart:convert';

import 'package:flutter/foundation.dart';

const geminiCliPath = 'gemini';
const geminiCliPathDev =
    '/Users/polinach/_/gemini-cli/packages/cli/dist/index.js';

class GCliProcess {
  final ValueChanged<String> update;

  GCliProcess(this.update);

  Future<void> start() async {
    final envToPass = {
      ...Platform.environment,
      'TERM': 'xterm-256color',
      'GEMINI_CLI_CONTEXT': 'electron',
      'GEMINI_SESSION_ID': 'a4473c35-7849-4e13-bb51-52b865c21048',
      'ELECTRON_RUN_AS_NODE': '1',
      'ITERM_PROFILE': 'Default',
      'ITERM_SESSION_ID': 'w1t2p0:9B5F9DEB-0160-4D0C-B2DA-0FA87ED54185',
    };

    try {
      final process = await Process.start(
        includeParentEnvironment: true,
        // environment: envToPass,
        mode: ProcessStartMode.normal,
        runInShell: true,
        geminiCliPathDev,
        [],
      );

      update('started pid: ${process.pid}');

      process.stdin.writeln('input to stdin');

      // Read output from the tool
      _subscribe(process.stdout, (message) {
        update('Stdout: $message');
      });

      // Handle errors from the tool
      _subscribe(process.stderr, (message) {
        update('Stderr: $message');
      });

      final code = await process.exitCode;

      update('Process exited with code $code');
    } catch (e) {
      update('Failed to start process: $e');
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

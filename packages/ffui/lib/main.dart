import 'dart:async';

import 'package:ffui/primitives/chat_box.dart';
import 'package:flutter/material.dart';

import 'screen.dart';

void main() {
  runApp(const MyApp());
}

const _title = 'Gemini CLI with Flutter Framework Gen UI';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const ChatWithA2A(title: _title),
      debugShowCheckedModeBanner: false,
    );
  }
}

import 'dart:convert';

import 'package:f_llama/pages/settings.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

bool emptyChat = true;
String chatName = DateTime.now().toIso8601String();
Map<String, List> chatHistory = SettingsPage.box.read('chatHistory') ?? {};
List chat = [];

Future<void> queryAI(
  String msg,
  Function(Function()) setState,
  ScrollController chatCtrl,
) async {
  setState(
    () => chat.insert(0, {
      'role': 'user',
      'content': msg,
    }),
  );

  var httpRes = await http.post(
    Uri.parse('${SettingsPage.ollamaApiURL}/chat'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      'model': SettingsPage.ollamaModel,
      'messages': chat,
      'stream': false,
      'thinking': false,
    }),
  );

  var response = json.decode(httpRes.body)['message'] as Map;
  response['model'] = json.decode(httpRes.body)['model'] as String;

  setState(
    () => chat.insert(0, response),
  );

  chatHistory[chatName] = chat;
  SettingsPage.box.write('chatHistory', chatHistory);
}

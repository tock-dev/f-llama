import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  static final box = GetStorage();

  static String ollamaIp = box.read<String>('ollamaIp') ?? '127.0.0.1';
  static String ollamaPort = box.read<String>('ollamaPort') ?? '11434';
  static String ollamaModel = box.read<String>('ollamaModel') ?? '';
  static String get ollamaApiURL =>
      'http://${SettingsPage.ollamaIp}:${SettingsPage.ollamaPort}/api';

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    SettingsPage.box.write('ollamaIp', SettingsPage.ollamaIp);
    SettingsPage.box.write('ollamaPort', SettingsPage.ollamaPort);
    SettingsPage.box.write('ollamaModel', SettingsPage.ollamaModel);
    return FutureBuilder(
      future: http.get(Uri.parse('${SettingsPage.ollamaApiURL}/tags')),
      builder: (context, asyncSnapshot) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Settings'),
            leading: IconButton(
              onPressed: () => context.pop(),
              icon: Icon(Icons.arrow_back),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              spacing: 15,
              children: [
                TextField(
                  decoration: InputDecoration(
                    label: Text('Ollama server IP address'),
                  ),
                  controller: TextEditingController.fromValue(
                    TextEditingValue(text: SettingsPage.ollamaIp),
                  ),
                  onChanged: (value) =>
                      setState(() => SettingsPage.ollamaIp = value),
                ),
                TextField(
                  decoration: InputDecoration(
                    label: Text('Ollama server port'),
                  ),
                  controller: TextEditingController.fromValue(
                    TextEditingValue(text: SettingsPage.ollamaPort),
                  ),
                  onChanged: (value) =>
                      setState(() => SettingsPage.ollamaPort = value),
                ),
                DropdownMenu(
                  width: double.infinity,
                  onSelected: (value) =>
                      setState(() => SettingsPage.ollamaModel = value ?? ''),
                  controller: TextEditingController.fromValue(
                    TextEditingValue(text: SettingsPage.ollamaModel),
                  ),
                  dropdownMenuEntries: decodeModels(
                    asyncSnapshot.data?.body,
                  ).map((m) => DropdownMenuEntry(value: m, label: m)).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<String> decodeModels(String? stringified) {
    var map = json.decode(stringified ?? '{"models":[]}') as Map;
    var models = map['models'] as List;
    var names = models.map((m) => m['name'] as String).toList();
    return names;
  }
}

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:go_router/go_router.dart';

import 'pages/home.dart';
import 'pages/settings.dart';

Future<void> main() async {
  await GetStorage.init();
  if (!(SettingsPage.box.read<bool>('initialized') ?? false)) {
    SettingsPage.box.erase();
    SettingsPage.box.write('initialized', true);
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Material App',
      routerConfig: GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => HomePage(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => SettingsPage(),
          ),
        ],
      ),
    );
  }
}

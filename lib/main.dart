import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app/di.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupDI();
  runApp(const GenUiPocApp());
}

class GenUiPocApp extends StatelessWidget {
  const GenUiPocApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'GenUI POC',
      debugShowCheckedModeBanner: false,
      routerConfig: getIt<GoRouter>(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
    );
  }
}

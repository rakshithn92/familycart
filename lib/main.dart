import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme.dart';
import 'screens/auth_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: FamilyCartApp()));
}

class FamilyCartApp extends StatelessWidget {
  const FamilyCartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FamilyCart',
      theme: appTheme,
      home: const AuthGate(),
      debugShowCheckedModeBanner: false,
    );
  }
}

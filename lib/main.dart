import 'package:expensee/app.dart';
import 'package:expensee/providers/board_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import "package:flutter_dotenv/flutter_dotenv.dart";
import "package:resend/resend.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: "https://${dotenv.env['SUPABASE_PROJECT_ID']!}.supabase.co",
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    authFlowType: AuthFlowType.pkce,
  );

  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<BoardProvider>(
        child: const ExpenseeApp(), create: (_) => BoardProvider());
  }
}

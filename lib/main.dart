import 'package:expensee/app.dart';
import 'package:expensee/providers/board_provider.dart';
import 'package:expensee/providers/g_member_provider.dart';
import 'package:expensee/services/deeplink_service.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import "package:flutter_dotenv/flutter_dotenv.dart";

var logger = Logger(
  printer: PrettyPrinter(), // Use the PrettyPrinter for easy-to-read logging
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  try {
    await Supabase.initialize(
      url: "https://${dotenv.env['PROJECT_ID']}.supabase.co",
      anonKey: dotenv.env['ANON_KEY']!,
      authFlowType: AuthFlowType.pkce,
    ).timeout(const Duration(seconds: 10));
  } catch (e) {
    logger.e("Failed to initialize supabase: $e");
  }

  runApp(const AppInitializer());
}

final supabase = Supabase.instance.client;

class AppInitializer extends StatefulWidget {
  const AppInitializer({Key? key}) : super(key: key);

  @override
  createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  @override
  void initState() {
    super.initState();
    DeepLinkHandler().initDeepLinkListener(context);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => BoardProvider(),
        ),
        ChangeNotifierProvider(create: (_) => GroupMemberProvider())
      ],
      child: const ExpenseeApp(),
    );
  }
}

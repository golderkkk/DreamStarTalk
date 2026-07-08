import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app/app.dart';
import 'core/utils/logger.dart';

/// 全局 Hive Box
Box? boxCharacters;
Box? boxWorlds;
Box? boxConversations;
Box? boxAIProviders;
Box? boxNPCLibrary;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  boxCharacters = await Hive.openBox('characters');
  boxWorlds = await Hive.openBox('worlds');
  boxConversations = await Hive.openBox('conversations');
  boxAIProviders = await Hive.openBox('ai_providers');
  boxNPCLibrary = await Hive.openBox('npc_library');

  Logger.init();

  runApp(const ProviderScope(child: AIChatStudioApp()));
}

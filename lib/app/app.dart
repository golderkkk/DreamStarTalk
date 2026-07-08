import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dream_startalk/core/theme/theme_manager.dart';
import 'router.dart';

class AIChatStudioApp extends ConsumerWidget {
  const AIChatStudioApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeNotifier = ref.read(themeProvider.notifier);

    return MaterialApp.router(
      title: '拾梦·星语',
      debugShowCheckedModeBanner: false,
      theme: themeNotifier.themeData,
      darkTheme: themeNotifier.themeData,
      themeMode: ThemeMode.dark,
      routerConfig: router,
    );
  }
}

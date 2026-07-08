import 'package:go_router/go_router.dart';
import '../features/character/presentation/pages/character_list_page.dart';
import '../features/character/presentation/pages/character_edit_page.dart';
import '../features/chat/presentation/pages/chat_page.dart';
import '../features/chat/presentation/pages/conversation_list_page.dart';
import '../features/chat/presentation/pages/create_conversation_page.dart';
import '../features/world/presentation/pages/world_list_page.dart';
import '../features/world/presentation/pages/world_edit_page.dart';
import '../features/world/presentation/pages/npc_library_page.dart';
import '../features/settings/presentation/pages/settings_page.dart';
import '../features/settings/presentation/pages/theme_selection_page.dart';
import '../features/settings/presentation/pages/custom_theme_page.dart';
import '../features/ai_provider/presentation/pages/ai_service_page.dart';
import '../features/ai_provider/presentation/pages/provider_list_page.dart';
import '../features/ai_provider/presentation/pages/model_config_page.dart';
import 'shell.dart';

final router = GoRouter(
  initialLocation: '/chat',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => AppShell(shell: shell),
      branches: [
        // index 0: 对话（最常用，放第一位）
        StatefulShellBranch(routes: [
          GoRoute(path: '/chat', pageBuilder: (_, __) => const NoTransitionPage(child: ConversationListPage()),
            routes: [
              GoRoute(path: 'new', builder: (_, __) => const CreateConversationPage()),
              GoRoute(path: ':id', builder: (_, state) => ChatPage(conversationId: state.pathParameters['id'])),
            ],
          ),
        ]),
        // index 1: 角色
        StatefulShellBranch(routes: [
          GoRoute(path: '/characters', pageBuilder: (_, __) => const NoTransitionPage(child: CharacterListPage()),
            routes: [
              GoRoute(path: 'new', builder: (_, __) => const CharacterEditPage()),
              GoRoute(path: ':id', builder: (_, state) => CharacterEditPage(characterId: state.pathParameters['id'])),
            ],
          ),
        ]),
        // index 2: 世界观
        StatefulShellBranch(routes: [
          GoRoute(path: '/worlds', pageBuilder: (_, __) => const NoTransitionPage(child: WorldListPage()),
            routes: [
              GoRoute(path: 'new', builder: (_, __) => const WorldEditPage()),
              GoRoute(path: ':id', builder: (_, state) => WorldEditPage(worldId: state.pathParameters['id'])),
              GoRoute(path: 'npc-library', builder: (_, __) => const NPCLibraryPage()),
              GoRoute(path: 'npc-library-select', builder: (_, __) => const NPCLibraryPage(selectionMode: true)),
            ],
          ),
        ]),
        // index 3: 设置
        StatefulShellBranch(routes: [
          GoRoute(path: '/settings', pageBuilder: (_, __) => const NoTransitionPage(child: SettingsPage()),
            routes: [
              GoRoute(path: 'ai-service', builder: (_, __) => const AIServicePage()),
              GoRoute(path: 'providers', builder: (_, __) => const ProviderListPage()),
              GoRoute(path: 'model-config', builder: (_, __) => const ModelConfigPage()),
              GoRoute(path: 'theme', builder: (_, __) => const ThemeSelectionPage()),
              GoRoute(path: 'custom-theme', builder: (_, __) => const CustomThemePage()),
            ],
          ),
        ]),
      ],
    ),
  ],
);

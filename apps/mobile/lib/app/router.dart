import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/scaffold/scaffold_page.dart';

const _tabs = [
  (path: '/today', title: 'Hôm nay', icon: Icons.today_outlined),
  (path: '/library', title: 'Kho từ', icon: Icons.menu_book_outlined),
  (path: '/practice', title: 'Luyện câu', icon: Icons.edit_note_outlined),
  (path: '/garden', title: 'Khu vườn', icon: Icons.local_florist_outlined),
];

GoRouter createRouter() => GoRouter(
  initialLocation: '/today',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => _AppShell(shell: shell),
      branches: [
        for (final tab in _tabs)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: tab.path,
                builder: (context, state) => ScaffoldPage(
                  key: ValueKey(tab.path),
                  title: tab.title,
                  icon: tab.icon,
                ),
              ),
            ],
          ),
      ],
    ),
  ],
);

class _AppShell extends StatelessWidget {
  const _AppShell({required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: shell.currentIndex == 0,
    onPopInvokedWithResult: (didPop, result) {
      if (!didPop && shell.currentIndex != 0) shell.goBranch(0);
    },
    child: Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (index) => shell.goBranch(index),
        destinations: [
          for (final tab in _tabs)
            NavigationDestination(
              key: ValueKey('tab${tab.path}'),
              icon: Icon(tab.icon),
              label: tab.title,
            ),
        ],
      ),
    ),
  );
}

import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import 'auth/profile_screen.dart';
import 'character/create_character_screen.dart';
import 'character/explore_screen.dart';
import 'chat/chat_list_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      ExploreScreen(
        onTapCreateTab: () => setState(() => _selectedIndex = 1),
      ),
      const CreateCharacterScreen(),
      const ChatListScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(color: AppColors.cardBorder, width: 1),
          ),
        ),
        child: NavigationBar(
          backgroundColor: AppColors.surface,
          indicatorColor: AppColors.primaryPink.withValues(alpha: 0.2),
          selectedIndex: _selectedIndex,
          onDestinationSelected: (idx) => setState(() => _selectedIndex = idx),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.explore_outlined),
              selectedIcon: Icon(
                Icons.explore_rounded,
                color: AppColors.primaryPink,
              ),
              label: 'Explore',
            ),
            NavigationDestination(
              icon: Icon(Icons.auto_awesome_outlined),
              selectedIcon: Icon(
                Icons.auto_awesome_rounded,
                color: AppColors.primaryPink,
              ),
              label: 'Create AI',
            ),
            NavigationDestination(
              icon: Icon(Icons.chat_bubble_outline_rounded),
              selectedIcon: Icon(
                Icons.chat_bubble_rounded,
                color: AppColors.primaryPink,
              ),
              label: 'Chats',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(
                Icons.person_rounded,
                color: AppColors.primaryPink,
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

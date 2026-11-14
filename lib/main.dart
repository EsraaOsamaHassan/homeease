import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:homeease/screens/auth_gate.dart';

import 'firebase_options.dart';
import 'l10n.dart';
import 'models.dart';
import 'screens/ai_assistant_screen.dart';
import 'screens/home_screen.dart';
import 'screens/other_tabs.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const HomeEaseApp());
  }

class HomeEaseApp extends StatelessWidget {
  const HomeEaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: Lang.isArabic,
      builder: (context, ar, _) {
        return MaterialApp(
          key: ValueKey(ar),
          debugShowCheckedModeBanner: false,
          title: 'HomeEase',
          theme: buildTheme(),
          locale: Locale(ar ? 'ar' : 'en'),
          supportedLocales: const [Locale('ar'), Locale('en')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const AuthGate(signedIn: MainShell()),
        );
      },
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  @override
  void initState() {
    super.initState();
    shellTab.addListener(_onTab);
  }

  void _onTab() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    shellTab.removeListener(_onTab);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final index = shellTab.value;
    return Scaffold(
      body: IndexedStack(
        index: index,
        children: const [
          HomeScreen(),
          RequestsScreen(),
          AiAssistantScreen(),
          MyHomeScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: _BottomNav(
        index: index,
        onTap: (i) => shellTab.value = i,
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.index, required this.onTap});
  final int index;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _item(0, Icons.home_outlined, Icons.home, tr('الرئيسية', 'Home')),
              _item(1, Icons.receipt_long_outlined, Icons.receipt_long,
                  tr('طلباتي', 'My Requests')),
              _center(),
              _item(3, Icons.house_outlined, Icons.house, tr('منزلي', 'My Home')),
              _item(4, Icons.person_outline, Icons.person, tr('حسابي', 'Profile')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _item(int i, IconData icon, IconData activeIcon, String label) {
    final active = index == i;
    final color = active ? AppColors.terracotta : AppColors.muted;
    return Expanded(
      child: InkWell(
        onTap: () => onTap(i),
        child: SizedBox(
          height: 64,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(active ? activeIcon : icon, size: 22, color: color),
              const SizedBox(height: 3),
              Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                      color: color)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _center() {
    final active = index == 2;
    return Expanded(
      child: InkWell(
        onTap: () => onTap(2),
        child: SizedBox(
          height: 64,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              Positioned(
                top: -16,
                child: Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: AppColors.terracotta,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: const [
                      BoxShadow(
                          color: Color(0x33C8643C),
                          blurRadius: 10,
                          offset: Offset(0, 4)),
                    ],
                  ),
                  child: const Icon(Icons.auto_awesome, color: Colors.white),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  tr('المساعد الذكي', 'AI Assistant'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: active ? FontWeight.w800 : FontWeight.w700,
                    color: AppColors.terracotta,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

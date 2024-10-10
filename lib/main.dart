import 'package:flutter/material.dart';
import 'package:marketplace_instant_messaging/search.dart';
import 'login_page.dart';
import 'chat_page.dart';
import 'splash_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/searchUser': (context) => const SearchUserPage(
              username: '',
              targetUser: '',
            ),
        '/splashScreen': (context) => const SplashScreen(),
        '/chatScreen': (context) => const ChatScreen(
              username: '',
              targetUser: '',
            ),
      },
    );
  }
}

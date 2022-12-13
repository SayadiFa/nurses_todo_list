import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:nurses_todo_app/controllers/auth.dart';
import 'package:nurses_todo_app/models/user_model.dart';
import 'package:nurses_todo_app/screens/home_screen.dart';
import 'package:nurses_todo_app/screens/login_screen.dart';
import 'package:nurses_todo_app/screens/signup_screen.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/home':(context)=> const HomeScreen(),
        '/on_boarding':(context)=> const SignupScreen(),
        '/login':(context)=> const LoginScreen(),
      },
    );
  }
}


import 'package:flutter/material.dart';
import 'screens/home_screen.dart'; // HomeScreen을 import합니다.
import 'screens/library_screen.dart'; // LibraryScreen을 import합니다.
import 'screens/add_song_url.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music App',
      initialRoute: '/home', // 초기 경로를 /home으로 설정합니다.
      routes: {
        '/home': (context) => HomeScreen(), // 홈 화면 경로 정의
        '/library': (context) => LibraryScreen(), // 라이브러리 화면 경로 정의
        '/add_song': (context) => AddSongUrlScreen(),
      },
    );
  }
}
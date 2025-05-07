import 'package:flutter/material.dart';
import 'package:gymbro/screens/home_screen.dart';
// import 'package:provider/provider.dart'; // Uncomment when you set up a provider

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Example of setting up a Provider (you'll need to create your actual providers)
    // return MultiProvider(
    //   providers: [
    //     // ChangeNotifierProvider(create: (context) => ExerciseProvider()),
    //   ],
    //   child: MaterialApp(
    //     title: 'Exercise Tracker',
    //     theme: ThemeData(
    //       primarySwatch: Colors.blue,
    //     ),
    //     home: HomeScreen(), // Your main screen
    //   ),
    // );

    return MaterialApp(
      title: 'GymBro',
      themeMode: ThemeMode.dark,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        brightness: Brightness.light,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      darkTheme: ThemeData( // Define your dark theme
        primarySwatch: Colors.deepPurple, // Or any color you prefer for dark theme
        brightness: Brightness.dark,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        // Customize other dark theme properties:
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: AppBarTheme(color: Colors.grey[900]),
        cardColor: Colors.grey[850],
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.deepPurpleAccent,
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: Colors.white70)
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
          )
        )
      ),
      home: HomeScreen(),
    );
  }
}

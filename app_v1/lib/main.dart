import 'package:flutter/material.dart';
import 'signup.dart';
import 'login.dart';
import 'services/local_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize local storage
  await LocalStorageService.instance.init();
  
  runApp(AayurGramApp());
}

class AayurGramApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {'/': (context) => WelcomeScreen()},
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color.fromARGB(255, 4, 111, 92),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color.fromARGB(255, 4, 111, 92),
          primary: Color.fromARGB(255, 4, 111, 92),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(foregroundColor: Colors.white),
        ),
      ),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 4, 111, 92), // Dark green background
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Spacer(),

              // Logo and Title
              Text(
                'Aayur Gram',
                style: TextStyle(
                  fontSize: 32,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 24),

              // Welcome Image
              Image.asset(
                'welcome_image.png', // Image from assets folder
                height: 250,
              ),
              SizedBox(height: 24),

              Text(
                'Welcome to Aayur Gram',
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),

              Text(
                'Discover natural healing and balance with authentic Aayur Gram care.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              SizedBox(height: 48),

              // Log In Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: Text(
                    'Log In',
                    style: TextStyle(color: Colors.green[900], fontSize: 18),
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Create Account Text Button
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignupPage()),
                  );
                },
                child: Text(
                  'Create an Account',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),

              Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

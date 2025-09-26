import 'package:flutter/material.dart';
import 'signup.dart';
import 'collectordash.dart';
import 'services/web_authentication_service.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isPasswordVisible = false;

  InputDecoration getInputDecoration(String hint, IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: Colors.green[900]),
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400]),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.green, width: 2),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green[200]!, Colors.green[50]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.eco, size: 80, color: Colors.green[900]),
                SizedBox(height: 8),
                Text(
                  'Aayur Gram',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[900],
                  ),
                ),
                SizedBox(height: 32),
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  margin: EdgeInsets.symmetric(horizontal: 24),
                  child: Padding(
                    padding: const EdgeInsets.all(28.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Welcome Back!',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[900],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 24),
                        TextField(
                          controller: emailController,
                          decoration: getInputDecoration('Email', Icons.email),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        SizedBox(height: 18),
                        TextField(
                          controller: passwordController,
                          obscureText: !isPasswordVisible,
                          decoration: getInputDecoration('Password', Icons.lock)
                              .copyWith(
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    isPasswordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Colors.green[900],
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      isPasswordVisible = !isPasswordVisible;
                                    });
                                  },
                                ),
                              ),
                        ),
                        SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              // TODO: Implement forgot password
                            },
                            child: Text('Forgot Password?'),
                          ),
                        ),
                        SizedBox(height: 18),
                        ElevatedButton(
                          onPressed: () async {
                            try {
                              final email = emailController.text.trim();
                              final password = passwordController.text;

                              if (email.isEmpty || password.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Please fill in all fields'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              final user = await WebAuthenticationService
                                  .instance
                                  .authenticateUser(email, password);
                              if (user != null) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CollectorDashboard(
                                      collectorId: user.id.toString(),
                                      collectorName: user.name,
                                    ),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Invalid email or password'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('An error occurred: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[800],
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text('Login', style: TextStyle(fontSize: 18)),
                        ),
                        SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(child: Divider()),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                              ),
                              child: Text('or login with'),
                            ),
                            Expanded(child: Divider()),
                          ],
                        ),
                        SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.g_mobiledata,
                                size: 32,
                                color: Colors.red[700],
                              ),
                              onPressed: () {},
                              tooltip: 'Google Login',
                            ),
                            SizedBox(width: 16),
                            IconButton(
                              icon: Icon(
                                Icons.facebook,
                                size: 32,
                                color: Colors.blue[800],
                              ),
                              onPressed: () {},
                              tooltip: 'Facebook Login',
                            ),
                          ],
                        ),
                        SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Don't have an account? "),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SignupPage(),
                                  ),
                                );
                              },
                              child: Text(
                                'Sign Up',
                                style: TextStyle(
                                  color: Colors.green[800],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'services/web_authentication_service.dart';

class SignupPage extends StatefulWidget {
  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  String selectedRole = 'Collector';
  String selectedAge = '22';
  String selectedGender = 'Male';
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

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
            colors: [Colors.green[100]!, Colors.green[50]!],
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
                          'Create Your Account',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[900],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 24),
                        TextField(
                          controller: userNameController,
                          decoration: getInputDecoration(
                            'User name',
                            Icons.person,
                          ),
                        ),
                        SizedBox(height: 16),
                        TextField(
                          controller: emailController,
                          decoration: getInputDecoration('Email', Icons.email),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        SizedBox(height: 16),
                        TextField(
                          controller: phoneController,
                          decoration: getInputDecoration(
                            'Phone number',
                            Icons.phone,
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: selectedAge,
                                items:
                                    List.generate(
                                          100,
                                          (index) => (index + 1).toString(),
                                        )
                                        .map(
                                          (age) => DropdownMenuItem(
                                            value: age,
                                            child: Text(age),
                                          ),
                                        )
                                        .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedAge = value!;
                                  });
                                },
                                decoration: InputDecoration(
                                  labelText: 'Age',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: selectedGender,
                                items: ['Male', 'Female', 'Other']
                                    .map(
                                      (gender) => DropdownMenuItem(
                                        value: gender,
                                        child: Text(gender),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedGender = value!;
                                  });
                                },
                                decoration: InputDecoration(
                                  labelText: 'Gender',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            roleOption('Collector'),
                            roleOption('Consumer'),
                          ],
                        ),
                        SizedBox(height: 16),
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
                        SizedBox(height: 16),
                        TextField(
                          controller: confirmPasswordController,
                          obscureText: !isConfirmPasswordVisible,
                          decoration:
                              getInputDecoration(
                                'Confirm Password',
                                Icons.lock_outline,
                              ).copyWith(
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    isConfirmPasswordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Colors.green[900],
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      isConfirmPasswordVisible =
                                          !isConfirmPasswordVisible;
                                    });
                                  },
                                ),
                              ),
                        ),
                        SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () async {
                            try {
                              final name = userNameController.text.trim();
                              final email = emailController.text.trim();
                              final password = passwordController.text;
                              final confirmPassword =
                                  confirmPasswordController.text;

                              if (name.isEmpty ||
                                  email.isEmpty ||
                                  password.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Please fill in all fields'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              if (password != confirmPassword) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Passwords do not match'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              await WebAuthenticationService.instance
                                  .createUser(
                                    name: name,
                                    email: email,
                                    password: password,
                                    role: selectedRole.toLowerCase(),
                                  );

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Account created successfully!',
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );

                              Navigator.pop(context); // Go back to login screen
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
                          child: Text(
                            'Sign Up',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                        SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Already have an account? '),
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                'Login',
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

  Widget roleOption(String role) {
    bool isSelected = selectedRole == role;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedRole = role;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green[100] : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.green : Colors.grey,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              role == 'Collector' ? Icons.account_circle : Icons.shopping_cart,
              size: 36,
              color: Colors.green[900],
            ),
            SizedBox(height: 4),
            Text(role),
          ],
        ),
      ),
    );
  }
}

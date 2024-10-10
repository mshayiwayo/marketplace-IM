import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

import 'search.dart'; // For kIsWeb

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool isSignUp = false; // Toggle between login and signup

  Future<void> _loginOrSignup() async {
    if (_formKey.currentState!.validate()) {
      String username = _usernameController.text;
      String password = _passwordController.text;

      var url = isSignUp
          ? kIsWeb
              ? 'http://localhost:3000/signup'
              : 'http://10.0.2.2:3000/signup'
          : kIsWeb
              ? 'http://localhost:3000/login'
              : 'http://10.0.2.2:3000/login';

      try {
        var response = await http.post(
          Uri.parse(url),
          body: jsonEncode({
            'username': username,
            'password': password,
          }),
          headers: {'Content-Type': 'application/json'},
        );

        if (response.statusCode == 200) {
          String username = _usernameController.text; // Current user
          String targetUser =
              'targetUser'; // Replace this with the actual target user's username

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SearchUserPage(
                username: username,
                targetUser: targetUser,
              ),
            ),
          );

          var responseData = jsonDecode(response.body);
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('token', responseData['token']); // Store the token
          prefs.setString('username', username);

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SearchUserPage(
                username: username,
                targetUser: targetUser,
              ),
            ),
          );
        } else {
          // Handle error response
          print('Error: ${response.body}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Failed to ${isSignUp ? "sign up" : "login"}')),
          );
        }
      } catch (e, stacktrace) {
        // Catch any errors and print the stack trace
        print('Error: $e');
        print('Stacktrace: $stacktrace');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isSignUp ? 'Sign Up' : 'Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your username';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loginOrSignup,
                child: Text(isSignUp ? 'Sign Up' : 'Login'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    isSignUp = !isSignUp;
                  });
                },
                child: Text(isSignUp
                    ? 'Already have an account? Login'
                    : 'Don’t have an account? Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'register.dart';
import 'upload.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool loading = false;

  void loginUser() async {
          final email = emailController.text.trim();
          final password = passwordController.text.trim();

          final response = await http.post(
            Uri.parse("${ApiService.baseUrl}/login"),
            headers: {
              "Content-Type": "application/json",
            },
            body: jsonEncode({
              "email": email,
              "password": password,
            }),
          );
          if (!mounted) return;
          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => UploadScreen(userEmail: email),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Invalid email or password")),
            );
          }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: loginUser,
                    child: const Text("Login"),
                  ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                );
              },
              child: const Text("Create Account"),
            )
          ],
        ),
      ),
    );
  }
}

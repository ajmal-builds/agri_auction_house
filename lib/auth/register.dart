import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'kyc.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  final AuthService _authService = AuthService();

  bool _isValidEmail(String email) {
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(email);
  }

  bool _isValidPhone(String phone) {
    return RegExp(r'^\d{10}$').hasMatch(phone);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Full Name"),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Email"),
                validator: (v) =>
                    !_isValidEmail(v!) ? "Invalid email" : null,
              ),
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: "Phone",
                  prefixText: "+91 ",
                ),
                validator: (v) =>
                    !_isValidPhone(v!) ? "Enter 10 digit phone" : null,
              ),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Password"),
                validator: (v) =>
                    v!.length < 6 ? "Min 6 characters" : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;

                  try {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) =>
                          const Center(child: CircularProgressIndicator()),
                    );

                    await _authService.registerUser(
                      name: nameController.text.trim(),
                      email: emailController.text.trim(),
                      phone: "+91${phoneController.text.trim()}",
                      password: passwordController.text,
                    );

                    if (!mounted) return;
                    Navigator.pop(context);

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const KycPage()),
                    );
                  } catch (e) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString())),
                    );
                  }
                },
                child: const Text("Proceed to KYC"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../screens/car_selection_screen.dart';

class LoginScreen extends StatelessWidget {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (usernameController.text == 'admin' &&
                    passwordController.text == '1234') {
                  Get.to(() => CarSelectionScreen());
                } else {
                  Get.snackbar('Error', 'Invalid credentials',
                      snackPosition: SnackPosition.BOTTOM);
                }
              },
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../screens/diagnostics_screen.dart';

class CarSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Car'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Get.to(() => DiagnosticsScreen());
          },
          child: Text('FORD'),
        ),
      ),
    );
  }
}

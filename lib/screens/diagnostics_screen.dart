import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/bluetooth_controller.dart';

class DiagnosticsScreen extends StatelessWidget {
  final BluetoothController bluetoothController =
      Get.put(BluetoothController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Diagnostics'),
      ),
      body: Obx(() {
        if (bluetoothController.isConnecting.value) {
          return Center(child: CircularProgressIndicator());
        } else if (bluetoothController.connectionError.value.isNotEmpty) {
          return Center(
              child:
                  Text('Error: ${bluetoothController.connectionError.value}'));
        } else if (bluetoothController.obdData.isNotEmpty) {
          return ListView.builder(
            itemCount: bluetoothController.obdData.length,
            itemBuilder: (context, index) {
              return ListTile(
                subtitle: Text(bluetoothController.obdData[index]?['key']
                        ?.toString()
                        .trim()
                        .replaceAll('P', 'ID: ') ??
                    "Empty title"),
                subtitleTextStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
                titleTextStyle: TextStyle(
                  fontSize: 14,
                  letterSpacing: 1,
                  color: Colors.black,
                  height: 1.5,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 2,
                ),
                title: Text(
                  bluetoothController.obdData[index]?['value'] ?? "Empty vakye",
                ),
              );
            },
          );
        } else {
          return Center(child: Text('No data available'));
        }
      }),
    );
  }
}

import 'dart:convert';
import 'package:flutter/services.dart'; // For loading assets
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';

class BluetoothController extends GetxController {
  var isConnecting = true.obs;
  var connectionError = ''.obs;
  var obdData = [].obs;
  late BluetoothDevice obdDevice;

  @override
  void onInit() {
    super.onInit();
    connectToOBDDevice();
  }

  void connectToOBDDevice() async {
    try {
      // Wait for Bluetooth enabled and permissions granted
      await FlutterBluePlus.adapterState
          .where((val) => val == BluetoothAdapterState.on)
          .first;

      // Start scanning with a timeout
      await FlutterBluePlus.startScan(
        withServices: [Guid("180D")], // Example service UUID
        withNames: ["Bluno"], // Example device name
        timeout: Duration(seconds: 15),
      );

      // Listen to scan results
      var subscription = FlutterBluePlus.onScanResults.listen((results) async {
        if (results.isNotEmpty) {
          ScanResult result = results.last; // Most recently found device
          print(
              '${result.device.remoteId}: "${result.advertisementData.advName}" found!');

          // Connect to the device
          try {
            await result.device.connect();
            obdDevice = result.device;
            print("Connected to ${result.device.remoteId}");

            // Request ELM327 data
            await fetchOBDData(); // Fetch the data from ELM327
          } catch (e) {
            connectionError.value = 'Failed to connect to OBD device: $e';
          }
        } else {
          // No devices found, load mock CSV
          await loadSampleCSV();
        }
      });

      // Wait for scanning to stop
      await FlutterBluePlus.isScanning.where((val) => val == false).first;

      // Cleanup: Cancel subscription when scanning stops
      FlutterBluePlus.cancelWhenScanComplete(subscription);
    } catch (e) {
      connectionError.value = 'Error: $e';
      isConnecting.value = false;
      await loadSampleCSV(); // Load mock CSV if any error occurs
    }
  }

  Future<void> fetchOBDData() async {
    try {
      // Get the Bluetooth device's services
      List<BluetoothService> services = await obdDevice.discoverServices();

      // ELM327 usually uses UART (Serial Port) or a similar service
      BluetoothService? obdService;
      for (var service in services) {
        if (service.uuid.toString().contains("0000ffe0")) {
          obdService = service;
          break;
        }
      }

      if (obdService != null) {
        // Find the characteristic to send OBD commands
        BluetoothCharacteristic? writeChar;
        BluetoothCharacteristic? readChar;
        for (var characteristic in obdService.characteristics) {
          if (characteristic.uuid.toString().contains("0000ffe1")) {
            writeChar = characteristic;
          } else if (characteristic.uuid.toString().contains("0000ffe2")) {
            readChar = characteristic;
          }
        }

        if (writeChar != null && readChar != null) {
          // Send the command to get RPM (command "010C" for RPM)
          await writeOBDCommand(writeChar, "010C");
          String rpm = await readOBDResponse(readChar);
          print("RPM: $rpm");

          // Send the command to get Speed (command "010D" for Speed)
          await writeOBDCommand(writeChar, "010D");
          String speed = await readOBDResponse(readChar);
          print("Speed: $speed");

          // Send the command to get Fault Codes (command "03" for DTCs)
          await writeOBDCommand(writeChar, "03");
          String faultCodes = await readOBDResponse(readChar);
          print("Fault Codes: $faultCodes");

          // Update the data to be displayed
          obdData.value = [
            {'key': 'RPM', 'value': rpm},
            {'key': 'Speed', 'value': speed},
            {'key': 'Fault Codes', 'value': faultCodes},
          ];
        } else {
          connectionError.value = 'Required characteristics not found';
        }
      } else {
        connectionError.value = 'OBD service not found';
      }
    } catch (e) {
      connectionError.value = 'Error fetching OBD data: $e';
    } finally {
      isConnecting.value = false;
    }
  }

  // Method to send an OBD command (e.g., "010C" for RPM)
  Future<void> writeOBDCommand(BluetoothCharacteristic writeChar, String command) async {
    try {
      List<int> commandBytes = ascii.encode(command);
      await writeChar.write(commandBytes);
    } catch (e) {
      print('Error sending command $command: $e');
    }
  }

  // Method to read the OBD response
  Future<String> readOBDResponse(BluetoothCharacteristic readChar) async {
    try {
      List<int> response = await readChar.read();
      return ascii.decode(response).trim();
    } catch (e) {
      print('Error reading response: $e');
      return 'Error';
    }
  }

  // Fallback method to load sample CSV if no device is found
  Future<void> loadSampleCSV() async {
    try {
      final csvString = await rootBundle.loadString('assets/sample_data.csv');
      final lines = const LineSplitter().convert(csvString);

      var data = lines.map((line) {
        final parts = line.split(',');
        return {'key': parts[0], 'value': parts[1]};
      }).toList();

      obdData.value = data;
    } catch (e) {
      connectionError.value = 'Failed to load sample data: $e';
    } finally {
      isConnecting.value = false;
    }
  }
}

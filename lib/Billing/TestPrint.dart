import 'package:flutter/material.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'dart:typed_data';

class TestPrint extends StatefulWidget {
  @override
  _TestPrintState createState() => _TestPrintState();
}

class _TestPrintState extends State<TestPrint> {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  List<BluetoothDevice> _devices = [];
  BluetoothDevice? _selectedDevice;

  @override
  void initState() {
    super.initState();
    getBluetoothDevices();
  }

  void getBluetoothDevices() async {
    List<BluetoothDevice> devices = await bluetooth.getBondedDevices();
    setState(() {
      _devices = devices;
    });
  }

  void testPrint() async {
    print('--- TEST PRINT STARTED ---');

    if (_selectedDevice == null) {
      print('No printer selected!');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No printer selected!')),
      );
    } else {
      bool isConnected = await bluetooth.isConnected ?? false;
      print('Printer connected: $isConnected');

      if (!isConnected) {
        print('Attempting to connect to the printer...');
        await bluetooth.connect(_selectedDevice!);
        isConnected = await bluetooth.isConnected ?? false;
        print('Connected after attempt: $isConnected');

        if (!isConnected) {
          print('Failed to connect to the printer!');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to connect to printer!')),
          );
        }
      }
    }

    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);

    List<int> bytes = [];
    bytes += generator.text('Test Print', styles: PosStyles(align: PosAlign.center, bold: true));
    bytes += generator.text('Rugtek BP02', styles: PosStyles(align: PosAlign.center));
    bytes += generator.text('If you see this, the printer is working!', styles: PosStyles(align: PosAlign.center));
    bytes += generator.hr();
    bytes += generator.cut();

    print('Data to be sent to printer: $bytes');

    if (_selectedDevice != null && (await bluetooth.isConnected ?? false)) {
      try {
        await bluetooth.writeBytes(Uint8List.fromList(bytes));
        print('Data successfully sent to the printer.');
      } catch (e) {
        print('Error sending data to the printer: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error printing: $e')),
        );
      }
    } else {
      print('No printer connected, skipping print.');
    }

    print('--- TEST PRINT FINISHED ---');
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Test Print')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: (){
                Navigator.pushReplacementNamed(context, '/');
              },
              child: Text('Back'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: getBluetoothDevices,
              child: Text('Refresh Devices'),
            ),
            SizedBox(height: 20),
            DropdownButton<BluetoothDevice>(
              hint: Text('Select Printer'),
              value: _selectedDevice,
              onChanged: (device) {
                setState(() {
                  _selectedDevice = device;
                });
              },
              items: _devices
                  .map((device) => DropdownMenuItem(
                value: device,
                child: Text(device.name ?? "Unknown"),
              ))
                  .toList(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: testPrint,
              child: Text('Print Test Page'),
            ),
          ],
        ),
      ),
    );
  }
}

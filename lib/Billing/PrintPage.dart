import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'dart:typed_data';
import 'package:abis2/api_handling/SaveBillingAPI.dart';
import 'package:abis2/main.dart';

class PrintPage extends StatefulWidget {
  String? customerID;
  String? customerName;
  String? customerPhoneNumber;
  final List<Map<String, dynamic>> itemTableDetails;
  String? customerAddress;
  String? customerPlace;
  String? customerCity;
  String? customerState;
  String? customerPincode;
  int deliveryCharges;
  String selectedDeliveryType;
  String selectedGatewayName;
  String selectedCustomerType;
  String taxAmount;
  String discountAmount;
  String totalAmount;
  String saleId;

  PrintPage(
      {super.key,
      required this.customerID,
      required this.customerName,
      required this.customerPhoneNumber,
      required this.itemTableDetails,
      required this.customerAddress,
      required this.customerPlace,
      required this.customerCity,
      required this.customerState,
      required this.customerPincode,
      required this.deliveryCharges,
      required this.selectedDeliveryType,
      required this.selectedGatewayName,
      required this.selectedCustomerType,
      required this.taxAmount,
      required this.discountAmount,
      required this.totalAmount,
      required this.saleId});

  @override
  State<PrintPage> createState() => _PrintPageState();
}

class _PrintPageState extends State<PrintPage> {
  String currentTimeStamp = "Loading..."; // Placeholder before API response
String printDateTime = '';

  String getPrintDateTime() {
    DateTime now = DateTime.now();
    DateFormat formatter = DateFormat('M/dd/yyyy; HH:mm');
    return formatter.format(now);
  }

  late double totalItemPrice;
  late double subtotal;
  late double roundedTotal;
  late double roundOffValue;

  @override
  void initState() {
    super.initState();
    getBluetoothDevices();
    getCurrentDateTime(BearerToken);
    printDateTime = getPrintDateTime();
    calculation();
  }

  Future<void> getCurrentDateTime(String bearerToken) async {
    try {
      String businessDate = await SaveBillingAPI.getCurrentBusinessDay(bearerToken);

      if (businessDate.isEmpty || businessDate.length < 8) {
        setState(() {
          currentTimeStamp = "Error: Invalid business date";
        });
        return;
      }

      // Parse and format the date
      DateTime parsedDate = DateTime.parse(businessDate);
      String formattedDate = DateFormat('M/d/yyyy').format(parsedDate); // e.g., 3/20/2025

      setState(() {
        currentTimeStamp = formattedDate;
      });
    } catch (e) {
      setState(() {
        currentTimeStamp = "Error: $e";
      });
    }
  }




  void calculation() {
    double totalItemPrice = widget.itemTableDetails.fold(0.0,
        (sum, item) => sum + ((item['totalPrice'] ?? 0) as num).toDouble());

    subtotal = totalItemPrice + widget.deliveryCharges;

    roundedTotal = subtotal.roundToDouble();

    roundOffValue = (roundedTotal - subtotal).abs();
  }

  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  List<BluetoothDevice> _devices = [];
  BluetoothDevice? _selectedDevice;

  void getBluetoothDevices() async {
    List<BluetoothDevice> devices = await bluetooth.getBondedDevices();
    setState(() {
      _devices = devices;
    });
  }

  Map<String, dynamic> calculateTaxDetails(List<dynamic> items) {
    List<Map<String, dynamic>> taxBreakups = [];

    for (var item in items) {
      double taxPercent = item['taxPercentage']?.toDouble() ?? 0;
      double taxAmount = item['tax']?.toDouble() ?? 0;

      if (taxPercent > 0 && taxAmount > 0) {
        taxBreakups.add({
          "taxPercent": taxPercent,
          "cgstPercent": taxPercent / 2,
          "sgstPercent": taxPercent / 2,
          "cgstAmount": taxAmount / 2,
          "sgstAmount": taxAmount / 2,
        });
      }
    }

    return {"taxBreakups": taxBreakups};
  }

  void printReceipt() async {
    final taxDetails = calculateTaxDetails(widget.itemTableDetails);

    print('--- PRINT RECEIPT STARTED ---');

    if (_selectedDevice == null) {
      print('No printer selected!');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No printer selected!')),
      );
      return;
    }

    bool isConnected = await bluetooth.isConnected ?? false;
    print('Printer connected: $isConnected');

    if (isConnected) {
      print('Disconnecting previous connection...');
      await bluetooth.disconnect();  // Ensure no stale connection
      await Future.delayed(Duration(seconds: 1)); // Allow time for disconnect
    }

    print('Attempting to connect to the printer...');
    try {
      await bluetooth.connect(_selectedDevice!);
      isConnected = await bluetooth.isConnected ?? false;
      print('Connected after attempt: $isConnected');
    } catch (e) {
      print('Error connecting: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to connect to printer!')),
      );
      return;
    }

    if (!isConnected) {
      print('Failed to establish connection.');
      return;
    }

   try{
     final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);

    List<int> bytes = [];

    bool hideNosColumn =
        widget.itemTableDetails.every((item) => (item['quantity'] ?? 0) == 0);
    bool hideWeightColumn =
        widget.itemTableDetails.every((item) => (item['weight'] ?? 0) == 0);
     bool hideGSTColumn = widget.itemTableDetails.every((item) => (item['tax'] ?? 0)==0);

    bytes += generator.text(
      'ABIS Exports',
      styles: PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
          bold: false),
    );
    bytes += generator.text(
      'India Pvt Ltd',
      styles: PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
          bold: false),
    );
    bytes += generator.text(
      'TIKRAPARA SHOP',
      styles: PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
          bold: true),
    );
    bytes += generator.text(
        'R156 NEAR GOOD WILL HOSPITAL\nSIDDHARTH CHOWK\n'
            'Kalibadi, Raipur, Chhattisgarh, PIN-492001\nShop No.: 11122-22333\n'
            'FSSAI: 10519016000172\nGSTIN: 111222333444555',
        styles: PosStyles(align: PosAlign.center));
    bytes += generator.hr();

    // Bill Details
    bytes += generator.text('POS/Bill No: ${widget.saleId}');
    bytes += generator.text('Print Date: $printDateTime');
    bytes += generator.text('Bus. Date: $currentTimeStamp');
    bytes += generator.hr();

    bytes += generator.text('Item Details:', styles: PosStyles(bold: true));
    const int colWidth1 = 5; // Width for 'Nos'
    const int colWidth2 = 5; // Width for 'Qty'
    const int colWidth3 = 4; // Width for 'Rate'
    const int colWidth4 = 6; // Width for 'Total'

// Print the header row
     String headerText = hideGSTColumn
         ? '${'Qty'.padLeft(colWidth1)} ${'Rate'.padLeft(colWidth2)} ${'Total'.padLeft(colWidth4)}'
         : '${'Qty'.padLeft(colWidth1)} ${'Rate'.padLeft(colWidth2)} ${'GST'.padLeft(colWidth3)} ${'Total'.padLeft(colWidth4)}';

     bytes += generator.text(
       headerText,
       styles: PosStyles(bold: true, align: PosAlign.right),
     );

// Item Rows
     for (var item in widget.itemTableDetails) {
       String itemName = item['itemType'];
       bytes += generator.text(itemName);

       String qty = (item['weight'] != 0) ? '${item['weight']}' : '${item['quantity']}';
       String rate = item['price'].toString();
       String tax = item['tax'].toString();
       String total = item['finalPrice'].toString();

       String itemDetails = hideGSTColumn
           ? '${qty.padLeft(colWidth1)} ${rate.padLeft(colWidth2)} ${total.padLeft(colWidth4)}'
           : '${qty.padLeft(colWidth1)} ${rate.padLeft(colWidth2)} ${tax.padLeft(colWidth3)} ${total.padLeft(colWidth4)}';


       bytes +=
          generator.text(itemDetails, styles: PosStyles(align: PosAlign.right));
    }


    bytes += generator.hr();

    // Additional Charges & Total
    if (widget.deliveryCharges > 0) {
      bytes += generator.text('Freight: ${widget.deliveryCharges}');
    }
    bytes += generator.text('Round-off: ${roundOffValue.toStringAsFixed(2)}');
    bytes += generator.text('Total (incl. GST): ${widget.totalAmount}',
        styles: PosStyles(bold: true, height: PosTextSize.size1));

    // Payment Details
    if (widget.selectedCustomerType != "CS") {
      bytes += generator.hr();
      if (widget.selectedGatewayName == "Cash") {
        bytes += generator.text('Cash Paid: ${widget.totalAmount}');
      } else if (widget.selectedGatewayName == "UPI") {
        bytes += generator.text('UPI: ${widget.totalAmount}');
      } else if (widget.selectedGatewayName == "Debit Card") {
        bytes += generator.text('Debit Card: ${widget.totalAmount}');
      }
    }

    if (double.parse(widget.discountAmount) != 0 ||
        taxDetails['taxBreakups'].isNotEmpty) {
      bytes += generator.hr();
    }
    if (double.parse(widget.discountAmount) != 0) {
      bytes += generator.text('You saved Rs${double.parse(widget.discountAmount).toStringAsFixed(0)}',
          styles: PosStyles(align: PosAlign.center));
            bytes += generator.text(''); 
    }
    const int GSTcolWidth1 = 5;
    const int GSTcolWidth2 = 5;
    const int GSTcolWidth3 = 10;
    const int GSTcolWidth4 = 10;

    if (taxDetails['taxBreakups'].isNotEmpty) {
      // Print tax header row once
       bytes += generator.text(
        '${'CGST '.padRight(GSTcolWidth1)} '
            '${' SGST   '.padRight(GSTcolWidth2)} '
            '${' CGST'.padRight(GSTcolWidth3)} '
            '${'SGST'.padRight(GSTcolWidth4)}',
        styles: PosStyles(bold: true, align: PosAlign.left),
      );

      // Iterate over tax breakups and print each one
      for (var tax in taxDetails['taxBreakups']) {
         String taxRow =
            '${(tax['cgstPercent']?.toStringAsFixed(1) ?? '-').padLeft(GSTcolWidth1-2)}%'
            ' ${(tax['sgstPercent']?.toStringAsFixed(1) ?? '-').padLeft(GSTcolWidth2)}%'
            '${(tax['cgstAmount']?.toStringAsFixed(2) ?? '0.00').padLeft(GSTcolWidth3-1)}'
            '${(tax['sgstAmount']?.toStringAsFixed(2) ?? '0.00').padLeft(GSTcolWidth4)}';

        bytes += generator.text(
          taxRow,
          styles: PosStyles(align: PosAlign.left),
        );
      }
    }

    bytes += generator.hr();

    // Customer Details
    bytes += generator.text('Customer Details:', styles: PosStyles(bold: true));
    bytes += generator.text('Customer ID: ${widget.customerID}');
    bytes += generator.text('Name: ${widget.customerName}');
    bytes += generator.text('Mobile: ${widget.customerPhoneNumber}');
    if (widget.customerAddress!.isNotEmpty)
      bytes += generator.text('Address: ${widget.customerAddress}');
    if (widget.customerPlace!.isNotEmpty || widget.customerCity!.isNotEmpty) {
      bytes +=
          generator.text('${widget.customerPlace}, ${widget.customerCity}');
    }
    if (widget.customerState!.isNotEmpty ||
        widget.customerPincode!.isNotEmpty) {
      bytes +=
          generator.text('${widget.customerState}, ${widget.customerPincode}');
    }

    bytes += generator.hr();
    bytes += generator.text('Thanks & Visit Again!',
        styles: PosStyles(align: PosAlign.center));
    bytes += generator.cut();

    String decodedText = String.fromCharCodes(
        bytes.where((b) => (b >= 32 && b <= 126) || b == 10));

    print('📜 Generated receipt data (bytes): ${Uint8List.fromList(bytes)}');
    print('📜 Decoded receipt text: $decodedText');

    if (_selectedDevice != null && (await bluetooth.isConnected ?? false)) {
      try {
        await bluetooth.writeBytes(Uint8List.fromList(bytes));
        print('Data successfully sent to the printer.');

        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Print Successful"),
              content: Text("The receipt has been printed successfully."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("OK"),
                ),
              ],
            );
          },
        );
      } catch (e) {
        print('Error sending data to the printer: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Print failed: $e')),
        );
      }
    } else {
      print('No printer connected, skipping print.');
    }
   }catch (e) {
      print('Error printing: $e');
    } finally {
      print('Disconnecting after print...');
      await bluetooth.disconnect();
    }

    print('--- PRINT RECEIPT FINISHED ---');
  }

  @override
  Widget build(BuildContext context) {
    bool hideNosColumn =
        widget.itemTableDetails.every((item) => (item['quantity'] ?? 0) == 0);
    bool hideWeightColumn =
        widget.itemTableDetails.every((item) => (item['weight'] ?? 0) == 0);
    bool hideGSTColumn = widget.itemTableDetails.every((item) => (item['tax'] ?? 0)==0);

    final taxDetails = calculateTaxDetails(widget.itemTableDetails);

    return Scaffold(
      appBar: AppBar(title: const Text('Billing Page')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Company Details
            const Center(
              child: Column(
                children: [
                  Text(
                    'ABIS Exports India Pvt Ltd',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text('TIKRAPARA SHOP'),
                  Text('R156 NEAR GOOD WILL HOSPITAL'),
                  Text('SIDDHARTH CHOWK'),
                  Text('Kalibadi, Raipur, Chhattisgarh, PIN-492001'),
                  Text('Shop No. : 11122-22333'),
                  Text(
                      'FSSAI License Number: 10519016000172, GSTIN : 111222333444555'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Bill Information
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('POS/Bill No. : ${widget.saleId}'),
                Text('Print Date: $printDateTime'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [Text('Business Date: $currentTimeStamp')],
            ),
            const Divider(),
            // Item Table
            const Text('Item Details:'),
            const SizedBox(height: 10),
            Table(
              border: TableBorder.all(),
              columnWidths: {
                0: const FlexColumnWidth(2),
                // Item name
                if (!hideNosColumn) 1: const FlexColumnWidth(1),
                // Nos (if not hidden)
                if (!hideWeightColumn) 2: const FlexColumnWidth(1),
                // Weight (if not hidden)
                3: const FlexColumnWidth(1),
                // Rate
                4: const FlexColumnWidth(1),
                // Total
              },
              children: [
                // Table Header
                TableRow(
                  children: [
                    _tableHeaderCell('Item name'),
                     _tableHeaderCell('Qty'),
                   _tableHeaderCell('Rate'),
                    if(!hideGSTColumn) _tableHeaderCell('GST'),
                    _tableHeaderCell('Total'),
                  ],
                ),
                // Table Rows
                ...widget.itemTableDetails.map((item) {
                  return TableRow(
                    children: [  
                      _tableCell('${item['itemType']}'),
                   _tableCell((item['weight'] != 0)
                       ? '${item['weight']}'
                       : '${item['quantity']}'),
                      _tableCell('${item['price']}'),
                      if(!hideGSTColumn) _tableCell('${item['tax']}'),
                      _tableCell('${item['finalPrice']}'),
                    ],
                  );
                }).toList(),
              ],
            ),
            const SizedBox(height: 10),
            if (widget.deliveryCharges != 0)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Freight:'),
                  Text('₹${widget.deliveryCharges}',
                      textAlign: TextAlign.right),
                ],
              ),

// Roundoff (Aligned with "Total" column)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Roundoff:'),
                Text('₹${roundOffValue.toStringAsFixed(2)}',
                    textAlign: TextAlign.right),
              ],
            ),

// Total (Aligned with "Total" column)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total (incl. GST):',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text('₹${widget.totalAmount}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            if (widget.selectedCustomerType != "CS") const Divider(),
            if (widget.selectedCustomerType != "CS")
              if (widget.selectedGatewayName == "Cash")
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Cash Paid:'),
                    Text('₹${widget.totalAmount}', textAlign: TextAlign.right),
                  ],
                ),
            if (widget.selectedCustomerType != "CS")
              if (widget.selectedGatewayName == "UPI")
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('UPI:'),
                    Text('₹${widget.totalAmount}', textAlign: TextAlign.right),
                  ],
                ),
            if (widget.selectedCustomerType != "CS")
              if (widget.selectedGatewayName == "Debit Card")
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Debit Card:'),
                    Text('₹${widget.totalAmount}', textAlign: TextAlign.right),
                  ],
                ),
            if (double.parse(widget.discountAmount) != 0 ||
                taxDetails['taxBreakups'].isNotEmpty)
              const Divider(),
            if (double.parse(widget.discountAmount) != 0)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'You saved ₹${double.parse(widget.discountAmount).toStringAsFixed(0)}',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),

            if (taxDetails['taxBreakups'].isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _taxCell('CGST'),
                  _taxCell('SGST'),
                  _taxCell('CGST'),
                  _taxCell('SGST'),
                ],
              ),
              for (var tax in taxDetails['taxBreakups'])
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _taxCell('${tax["cgstPercent"]}%'),
                    _taxCell('${tax["sgstPercent"]}%'),
                    _taxCell('₹${tax["cgstAmount"].toStringAsFixed(2)}'),
                    _taxCell('₹${tax["sgstAmount"].toStringAsFixed(2)}'),
                  ],
                ),
            ],
            const Divider(),
            // Customer Details
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Customer Details:'),
                Text('Customer ID: ${widget.customerID}'),
                Text('Customer Name: ${widget.customerName}'),
                Text('Mobile: ${widget.customerPhoneNumber}'),
                if (widget.selectedDeliveryType == "Home")
                  Text('Address: ${widget.customerAddress}'),
                if (widget.selectedDeliveryType == "Home")
                  Text('${widget.customerPlace}, ${widget.customerCity}'),
                if (widget.selectedDeliveryType == "Home")
                  Text('${widget.customerState}, ${widget.customerPincode}'),
              ],
            ),
            const Divider(),
            const Center(child: Text('Thanks & Visit Again!')),

            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Refresh Button
                  IconButton(
                    icon: Icon(Icons.refresh),
                    onPressed: () {
                      getBluetoothDevices();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Refreshed Printer List')),
                      );
                    },
                  ),

                  // Printer Selection Dropdown
                  Expanded(
                    child: DropdownButton<BluetoothDevice>(
                      isExpanded: true,
                      value: _selectedDevice,
                      hint: Text("Select Printer"),
                      onChanged: (BluetoothDevice? newDevice) async {
                        setState(() {
                          _selectedDevice = newDevice;
                        });
                        if (newDevice != null) {
                          await bluetooth.connect(newDevice);
                        }
                      },
                      items: _devices
                          .map((device) => DropdownMenuItem(
                                value: device,
                                child: Text(device.name ?? "Unknown"),
                              ))
                          .toList(),
                    ),
                  ),

                  // Print Button
                  ElevatedButton.icon(
                    icon: Icon(Icons.print),
                    label: Text("Print"),
                    onPressed: () async {
                      printReceipt();

                      bool isConnected = await bluetooth.isConnected ?? false;
                      if (isConnected) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Print Successful!')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Print Failed!')),
                        );
                      }
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

Widget _tableHeaderCell(String text) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
  );
}

Widget _tableCell(String text) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Text(text),
  );
}

Widget _taxCell(String text) {
  return Expanded(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    ),
  );
}

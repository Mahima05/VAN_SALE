import 'package:flutter/material.dart';
import 'package:abis2/api_handling/CustomerNameAPI.dart';
import 'package:abis2/api_handling/CustomerCodeAPI.dart';
import 'package:abis2/api_handling/CustomerPhoneAPI.dart';
import 'package:abis2/main.dart';

class SearchCustomerDetailsPage extends StatefulWidget {
  const SearchCustomerDetailsPage({super.key});

  @override
  State<SearchCustomerDetailsPage> createState() =>
      _SearchCustomerDetailsPageState();
}

class _SearchCustomerDetailsPageState extends State<SearchCustomerDetailsPage> {
  final TextEditingController CustomerNameController =
      TextEditingController(text: customerName);
  final TextEditingController CustomerMobileController =
      TextEditingController(text: customerMobile);
  final TextEditingController CustomerIDController =
      TextEditingController(text: customerID);

  List<Map<String, dynamic>> customers = [];

  void fetchCustomers(
      String customerName, String customerMobile, String customerID) async {
    if (customerName.isEmpty && customerMobile.isEmpty && customerID.isEmpty) {
      return;
    }

    try {
      List<Map<String, dynamic>> fetchedCustomers = [];

      if (customerMobile.isNotEmpty && SelectedCustomerType == 'RT') {
        fetchedCustomers = await CustomerPhoneAPI.fetchCustomersByPhone(
            SelectedCustomerType, customerMobile, BearerToken);
      } else if (customerName.isNotEmpty) {
        // Prioritize fetching by name if customerName is filled
        fetchedCustomers = await CustomerNameAPI.fetchCustomersByName(
            SelectedCustomerType, customerName, BearerToken);
      } else if (customerID.isNotEmpty) {
        // Fetch by code if customerName is empty
        fetchedCustomers = await CustomerCodeAPI.fetchCustomersByCode(
            SelectedCustomerType, customerID, BearerToken);
      }

      if (fetchedCustomers.isEmpty) {
        // Show popup if no customers are found
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Customer Not Found'),
            content: const Text(
                'The customer you are searching for does not exist.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        setState(() {
          customers = fetchedCustomers;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching customers: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    if (customerName.length >= 4) {
      fetchCustomers(customerName, customerMobile, customerID);
    }
  }

  @override
  Widget build(BuildContext context) {
    final existingArgs =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Customer'),
        backgroundColor: const Color.fromARGB(255, 2, 9, 106),
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                isButtonsLocked = false;
              });
              Navigator.pushReplacementNamed(context, '/');
            },
            child: const Text(
              'Close',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: CustomerNameController,
                    decoration: InputDecoration(
                      labelText: 'Customer Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (value) {
                      customerName = value;
                      if (customerName.length >= 4) {
                        fetchCustomers(
                            customerName, customerMobile, customerID);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: CustomerMobileController,
                    keyboardType:
                        TextInputType.phone, // Set input type to phone
                    maxLength: 10, // Limit input to 10 characters
                    decoration: InputDecoration(
                      labelText: 'Mobile',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      counterText: '', // Hides the character counter
                    ),
                    onChanged: (value) {
                      customerMobile = value;
                      if (value.length != 10 ||
                          !RegExp(r'^[0-9]+$').hasMatch(value)) {
                        print('Invalid mobile number');
                      } else {
                        print('Valid mobile number');
                      }
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: CustomerIDController,
                    decoration: InputDecoration(
                      labelText: 'Customer ID',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (value) {
                      customerID = value;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          final customerName =
                              CustomerNameController.text.trim();
                          final customerID = CustomerIDController.text.trim();
                          final customerMobile =
                              CustomerMobileController.text.trim();
                          fetchCustomers(
                              customerName, customerMobile, customerID);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 2, 9, 106),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Search'),
                      ),
                      const SizedBox(width: 10),
                      /*ElevatedButton(
                        onPressed: () {
                          // Add logic for the Credit Card button
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 2, 9, 106),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Credit Card'),
                      ),*/
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 50),
            if (customers.isNotEmpty) ...[
              Flexible(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: customers.length,
                  itemBuilder: (context, index) {
                    final customer = customers[index];
                    return ElevatedButton(
                      onPressed: () {
                        if (customer['customerName'] != null &&
                            customer['mobile'] != null) {
                        
                          
                          isButtonsLocked = true;
                          Navigator.pop(context, {
                            'customerID': customer['custID'] ?? '',
                            'customerName': customer['customerName'] ?? '',
                            'customerMobile': customer['mobile'] ?? '',
                            'customerCreditLimit': customer['creditLimit']?.toString() ?? '0',
                            'customerCreditDays': customer['creditDays']?.toString() ?? '0',
                            'customerBranchID': customer['branchID'] ?? ''
                          });

                        } else {
                          print('Customer data is invalid: $customer');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: Text(
                        customer['customerName'],
                        textAlign: TextAlign.center,
                        style:
                            const TextStyle(fontSize: 14, color: Colors.white),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

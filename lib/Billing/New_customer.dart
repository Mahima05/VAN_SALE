import 'package:flutter/material.dart';
import 'package:abis2/api_handling/PincodeAreaAPI.dart';
import 'package:flutter/services.dart';
import 'package:abis2/api_handling/StateNameAPI.dart';
import 'package:abis2/api_handling/CityAPI.dart';
import 'package:abis2/api_handling/CustomerAddAPI.dart';
import 'package:abis2/main.dart';

class NewCustomerDetailsPage extends StatefulWidget {
  const NewCustomerDetailsPage({super.key});

  @override
  State<NewCustomerDetailsPage> createState() => _NewCustomerDetailsPageState();
}

class _NewCustomerDetailsPageState extends State<NewCustomerDetailsPage> {
  bool isCreditCustomer = false;

  double customerFontSize = 18.0;
  FontWeight customerFontWeight = FontWeight.bold;
  String customerFontFamily = 'Times New Roman';

  final TextEditingController _creditLimitController = TextEditingController();
  final TextEditingController _creditDaysController = TextEditingController();
  final TextEditingController _customerCodeController = TextEditingController();
  String? _selectedTitle;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _flatController = TextEditingController();
  final TextEditingController _buildingController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  List<Map<String, String>> _areaList = [];
  String? _selectedPlaceId;
  String? _selectedArea;
  final TextEditingController _distanceController = TextEditingController();
  String? _selectedState;
  String? _selectedCity;

  final _formKey = GlobalKey<FormState>();
  Color _borderColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    fetchStates();
  }

  void setCustomerFontSize(double size) {
    setState(() {
      customerFontSize = size;
    });
  }

  void setCustomerFontWeight(FontWeight weight) {
    setState(() {
      customerFontWeight = weight;
    });
  }

  void setCustomerFontFamily(String family) {
    setState(() {
      customerFontFamily = family;
    });
  }

  Future<void> _fetchAreas(String pincode) async {
    final areas = await PincodeAreaAPI.fetchAreas(pincode, BearerToken);

    setState(() {
      if (areas.isNotEmpty) {
        _areaList =
            areas; // List of maps: [{'placeId': '...', 'placeName': '...'}]
        _selectedArea = null;
        _selectedPlaceId = null;
      } else {
        _areaList = [];
        _selectedArea = null;
        _selectedPlaceId = null;
        _showInvalidPinCodeDialog();
      }
    });
  }

  void _showInvalidPinCodeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Invalid Pincode'),
          content: const Text('Please enter a valid pincode.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  List<Map<String, String>> states = [];
  String? selectedStateCode;

  Future<void> fetchStates() async {
    try {
      final List<Map<String, String>> fetchedStates =
          await StateNameAPI.fetchStates(BearerToken);
      setState(() {
        states = fetchedStates;
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  List<Map<String, String>> cities = [];
  String? selectedCityCode;

  Future<void> fetchCities(String stateCode) async {
    try {
      final List<Map<String, String>> fetchedCities = await CityAPI.fetchCities(
          BearerToken, stateCode); // Pass token and state code
      setState(() {
        cities = fetchedCities;
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  void _submitCustomerDetails() async {
    final api = CustomerAddAPI();

    final response = await api.addCustomerDetails(
      token: BearerToken,
      customerCode: _customerCodeController.text,
      title: _selectedTitle,
      customerName: _nameController.text,
      mobile: _mobileController.text,
      email: _emailController.text,
      houseNo: _flatController.text.trim().isEmpty ? "" : _flatController.text,
      building: _buildingController.text.trim().isEmpty ? "" : _buildingController.text,
      customerAddress: _addressController.text.trim().isEmpty ? "" : _addressController.text,
      landmark: _landmarkController.text.trim().isEmpty ? "" : _landmarkController.text,
      pinCode: _pincodeController.text,
      cityCode: selectedCityCode,
      areaName: _selectedArea,
      areaId: _selectedPlaceId,
    );

    if (response["result"] == 1) {
      print("Success: ${response['description']}");

      // Show success dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Customer Added"),
            content: const Text("The customer has been added successfully."),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, "/");
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    } else {
      print("Error: ${response['description']}");

      // Show error dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Invalid Details"),
            content: const Text("The customer details are invalid."),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    }
  }

  void showSelectCustomerTypeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Customer Type'),
          content: const Text('Please select a customer type before searching.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Customer Details'),
        backgroundColor: const Color.fromARGB(255, 2, 9, 106),
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () {
              if (SelectedCustomerType.isEmpty) {
                // Show dialog if no customer type is selected
                showSelectCustomerTypeDialog(context);
              }
              else{
                Navigator.pushReplacementNamed(context, '/edit_customer');
              }
            },
            child: const Text(
              'Edit',
              style: TextStyle(color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: () {},
            child: const Text(
              'Save',
              style: TextStyle(color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/'); // pg close
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
                    controller: _creditLimitController,
                    decoration: InputDecoration(
                      labelText: 'Credit Limit',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _creditDaysController,
                    decoration: InputDecoration(
                      labelText: 'Credit Days',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _customerCodeController,
                    decoration: InputDecoration(
                      labelText: 'Code',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: isCreditCustomer,
                  onChanged: (bool? newValue) {
                    setState(() {
                      isCreditCustomer = newValue!;
                    });
                  },
                ),
                const Text(
                  'Credit Customer',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 255, 255),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: const Color.fromARGB(255, 239, 239, 239)),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 1,
                        child: DropdownButtonFormField<String>(
                          value:
                              _selectedTitle, // Bind the selected value to this variable
                          items: [
                            // Placeholder item to display "Title" but not selectable
                            const DropdownMenuItem(
                              value: null, // Make it null or an empty string
                              child: Text(
                                'Title',
                                style: TextStyle(
                                    color: Color.fromARGB(255, 254, 254, 254)),
                              ),
                            ),
                            ...['Mr.', 'Mrs.', 'Miss'].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }),
                          ],
                          onChanged: (String? value) {
                            setState(() {
                              _selectedTitle =
                                  value; // Update the selected value
                            });
                            print(
                                'Selected Title: $value'); // Print the selected value
                          },
                          decoration: InputDecoration(
                            labelText: 'Title',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: const Color.fromARGB(255, 253, 253, 253),
                          ),
                          style: const TextStyle(
                              fontSize: 16, color: Colors.black),
                          dropdownColor: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 1,
                        child: TextField(
                          keyboardType: TextInputType.text,
                          controller: _nameController,
                          decoration: InputDecoration(
                            hintText: 'Name',
                            filled: true,
                            fillColor: const Color.fromARGB(255, 255, 255, 255),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 1,
                        child: TextField(
                          keyboardType: TextInputType.number,
                          controller: _mobileController,
                          inputFormatters: [
                            // Restrict to digits only
                            FilteringTextInputFormatter.digitsOnly,
                            // Limit the input length to 10 digits
                            LengthLimitingTextInputFormatter(10),
                          ],
                          decoration: InputDecoration(
                            hintText: 'Mobile',
                            errorText: _mobileController.text.length == 10 ||
                                    _mobileController.text.isEmpty
                                ? null
                                : 'Enter a valid 10-digit mobile number',
                            filled: true,
                            fillColor: const Color.fromARGB(255, 255, 255, 255),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                          ),
                          onChanged: (value) {
                            // Trigger state update for validation
                            setState(() {});
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 1,
                        child: TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            hintText: 'Email',
                            filled: true,
                            fillColor: const Color.fromARGB(255, 255, 255, 255),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 1,
                        child: TextField(
                          controller: _flatController,
                          decoration: InputDecoration(
                            hintText: 'Flat No',
                            filled: true,
                            fillColor: const Color.fromARGB(255, 255, 255, 255),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 1,
                        child: TextField(
                          controller: _buildingController,
                          decoration: InputDecoration(
                            hintText: 'Building',
                            filled: true,
                            fillColor: const Color.fromARGB(255, 255, 255, 255),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 1,
                        child: TextField(
                          controller: _addressController,
                          decoration: InputDecoration(
                            hintText: 'Address',
                            filled: true,
                            fillColor: const Color.fromARGB(255, 255, 255, 255),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 1,
                        child: TextField(
                          controller: _landmarkController,
                          decoration: InputDecoration(
                            hintText: 'Landmark',
                            filled: true,
                            fillColor: const Color.fromARGB(255, 255, 255, 255),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: TextField(
                          controller: _pincodeController,
                          decoration: InputDecoration(
                            hintText: 'PINCODE',
                            filled: true,
                            fillColor: const Color.fromARGB(255, 255, 255, 255),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: _borderColor),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(6),
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onChanged: (value) {
                            if (value.length == 6) {
                              _fetchAreas(value);
                            } else {
                              setState(() {
                                _borderColor = Colors.grey;
                                _areaList = [];
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 1,
                        child: DropdownButtonFormField<Map<String, String>>(
                          value: _selectedArea != null
                              ? _areaList.firstWhere(
                                  (area) => area['placeName'] == _selectedArea,
                                  orElse: () => {},
                                )
                              : null,
                          items: _areaList.map((area) {
                            return DropdownMenuItem<Map<String, String>>(
                              value: area, // Provide the full map as the value
                              child:
                                  Text(area['placeName']!), // Display placeName
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedArea = value?[
                                  'placeName']; // Update selected placeName
                              _selectedPlaceId =
                                  value?['placeId']; // Update selected placeId
                            });
                          },
                          decoration: InputDecoration(
                            labelText: 'Area',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: const Color.fromARGB(255, 255, 255, 255),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: TextField(
                          controller: _distanceController,
                          decoration: InputDecoration(
                            hintText: 'Distance',
                            filled: true,
                            fillColor: const Color.fromARGB(255, 255, 255, 255),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 1,
                        child: DropdownButtonFormField<String>(
                          items: [
                            DropdownMenuItem(
                              value: _selectedState,
                              child: const Text(
                                'Select State',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                            ...states.map((state) {
                              return DropdownMenuItem<String>(
                                value: state[
                                    'StateCode'], // Use StateCode as the value
                                child: Text(state['StateName'] ?? ''),
                              );
                            }),
                          ],
                          onChanged: (String? value) {
                            setState(() {
                              selectedStateCode = value;
                              selectedCityCode = null; // Reset city selection
                              cities = []; // Clear current cities
                              if (selectedStateCode != null &&
                                  selectedStateCode!.isNotEmpty) {
                                fetchCities(
                                    selectedStateCode!); // Fetch cities for the new state
                              }
                            });
                          },
                          decoration: InputDecoration(
                            labelText: 'State',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: const Color.fromARGB(255, 255, 255, 255),
                          ),
                          style: const TextStyle(
                              fontSize: 16, color: Colors.black),
                          dropdownColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: DropdownButtonFormField<String>(
                          value: selectedCityCode,
                          // Use selectedCityCode
                          items: [
                            DropdownMenuItem(
                              value: _selectedCity,
                              child: const Text(
                                'Select City',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                            ...cities.map((city) {
                              return DropdownMenuItem<String>(
                                value: city['CityCode'],
                                // Use CityCode as the value
                                child: Text(city['CityName'] ?? ''),
                              );
                            }),
                          ],
                          onChanged: (String? value) {
                            setState(() {
                              selectedCityCode =
                                  value; // Store selected CityCode
                            });
                          },
                          decoration: InputDecoration(
                            labelText: 'City',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: const Color.fromARGB(255, 255, 255, 255),
                          ),
                          style: const TextStyle(
                              fontSize: 16, color: Colors.black),
                          dropdownColor: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 1,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(255, 2, 9, 106),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  )),
                              child: const Text('Add Address'),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () {
                                _submitCustomerDetails();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 2, 9, 106),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('Save Address'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(List<String> labels) {
    return Row(
      children: labels.map((label) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: TextField(
              decoration: InputDecoration(
                labelText: label,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

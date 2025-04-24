import 'package:flutter/material.dart';
import 'package:abis2/api_handling/PincodeAreaAPI.dart';
import 'package:flutter/services.dart';
import 'package:abis2/api_handling/StateNameAPI.dart';
import 'package:abis2/api_handling/CityAPI.dart';
import 'package:abis2/api_handling/CustomerEditAPI.dart';
import 'package:abis2/api_handling/CustomerCodeAPI.dart';
import 'package:abis2/api_handling/CustomerPhoneAPI.dart';
import 'package:abis2/main.dart';
import 'package:abis2/api_handling/FetchCustomerAddress.dart';

class EditCustomerDetailsPage extends StatefulWidget {
  const EditCustomerDetailsPage({super.key});

  @override
  State<EditCustomerDetailsPage> createState() =>
      _EditCustomerDetailsPageState();
}

class _EditCustomerDetailsPageState extends State<EditCustomerDetailsPage> {
  final TextEditingController CustomerNameController =
      TextEditingController(text: customerName);
  final TextEditingController CustomerMobileController =
      TextEditingController(text: customerMobile);
  final TextEditingController CustomerIDController =
      TextEditingController(text: customerID);
  final TextEditingController CustomerCreditLimitController =
      TextEditingController(text: customerCreditLimit);
  final TextEditingController CustomerCreditDays =
      TextEditingController(text: customerCreditDays);

  bool isCreditCustomer = false;

  double customerFontSize = 18.0;
  FontWeight customerFontWeight = FontWeight.bold;
  String customerFontFamily = 'Times New Roman';

  String? _selectedTitle;

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
  final Color _borderColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    fetchStates();
    if (SelectedCustomerType == "RT") {
      fetchCustomerDetailsByMobile(customerMobile);
    } else if (SelectedCustomerType == "CS" || SelectedCustomerType == "FS") {
      fetchCustomerDetailsByCode(customerID);
    }

    fetchDistanceFromAPI(customerID);
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
        // Update the area list from the fetched results.
        _areaList = areas;

        // Check if the currently selected placeId is still valid.
        bool exists = _selectedPlaceId != null &&
            _areaList.any((area) => area['placeId'] == _selectedPlaceId);

        if (!exists) {
          // If not, reset the selection.
          _selectedArea = null;
          _selectedPlaceId = null;
        }
      } else {
        // No areas returned: clear the area list and selections,
        // then show the invalid pincode dialog.
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


  String selectedAddressId = "";
  void _submitCustomerDetails(
      String customerID, String customerName, String customerMobile) async {
    final api = CustomerEditAPI();

    final response = await api.addCustomerDetails(
      token: BearerToken,
      customerCode: customerID,
      title: _selectedTitle,
      customerName: customerName,
      mobile: customerMobile,
      email: _emailController.text,
      houseNo: _flatController.text,
      building: _buildingController.text,
      customerAddress: _addressController.text,
      landmark: _landmarkController.text,
      pinCode: _pincodeController.text,
      cityCode: selectedCityCode,
      areaName: _selectedArea,
      areaId: _selectedPlaceId,
      addressID: selectedAddressId,
      distance: double.parse(_distanceController.text.trim()).toInt(),
      customerBranchID: customerBranchID,
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

  void fetchCustomerDetailsByCode(String customerID) async {
    if (customerID.isEmpty) return;

    try {
      List<Map<String, dynamic>> fetchedCustomers =
          await CustomerCodeAPI.fetchCustomersByCode(
              SelectedCustomerType, customerID, BearerToken);

      if (fetchedCustomers.isNotEmpty) {
        final customer = fetchedCustomers.first;

        _emailController.text = customer['email'];
      } else {
        // Show popup if no customers are found
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Invalid Customer ID'),
            content: const Text('No customer exists for the provided ID.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching customer details: $e')),
      );
    }
  }

  void fetchCustomerDetailsByMobile(String customerMobile) async {
    if (customerMobile.length != 10) return;

    try {
      List<Map<String, dynamic>> fetchedCustomers =
          await CustomerPhoneAPI.fetchCustomersByPhone(
              SelectedCustomerType, customerMobile, BearerToken);

      if (fetchedCustomers.isNotEmpty) {
        final customer = fetchedCustomers.first;

        _emailController.text = customer['email'];
      } else {
        // Show popup if no customers are found
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Invalid Phone Number'),
            content:
                const Text('No customer exists for the provided Phone number'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching customer details: $e')),
      );
    }
  }

  List<Map<String, dynamic>>? customerDetailsList;
  Map<String, dynamic>? selectedAddress;

  void fetchDistanceFromAPI(String custId) async {
    if (custId.length > 5) {
      customerDetailsList = await FetchCustomerAddressAPI.fetchCustomerDetails(
          BearerToken, customerBranchID, custId);

      if (customerDetailsList != null && customerDetailsList!.isNotEmpty) {
        setState(() {
          selectedAddress = customerDetailsList!.first; // Default selection
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Edit Customer Details'),
        backgroundColor: const Color.fromARGB(255, 2, 9, 106),
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text(
              'Save',
              style: TextStyle(color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // pg close
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
                    controller: CustomerCreditLimitController,
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
                    controller: CustomerCreditDays,
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
                  child: GestureDetector(
                    onTap: () {},
                    child: AbsorbPointer(
                      child: TextField(
                        readOnly: true,
                        controller: CustomerIDController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Code',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onChanged: (value) {
                          customerID = value;
                        },
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
                      isCreditCustomer = newValue ?? false;
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
                          value: _selectedTitle,
                          // Bind the selected value to this variable
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
                          controller: CustomerNameController,
                          decoration: InputDecoration(
                            hintText: 'Name',
                            filled: true,
                            fillColor: const Color.fromARGB(255, 255, 255, 255),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                          ),
                          onChanged: (value) {},
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
                        child: GestureDetector(
                          onTap: () {},
                          child: AbsorbPointer(
                            child: TextField(
                              keyboardType: TextInputType.number,
                              controller: CustomerMobileController,
                              inputFormatters: [
                                // Restrict to digits only
                                FilteringTextInputFormatter.digitsOnly,
                                // Limit the input length to 10 digits
                                LengthLimitingTextInputFormatter(10),
                              ],
                              decoration: InputDecoration(
                                hintText: 'Mobile',
                                errorText: CustomerMobileController
                                                .text.length ==
                                            10 ||
                                        CustomerMobileController.text.isEmpty
                                    ? null
                                    : 'Enter a valid 10-digit mobile number',
                                filled: true,
                                fillColor:
                                    const Color.fromARGB(255, 255, 255, 255),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      const BorderSide(color: Colors.grey),
                                ),
                              ),
                              onChanged: (value) {
                                customerMobile = value;
                              },
                            ),
                          ),
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
                  if (customerDetailsList != null &&
                      customerDetailsList!.isNotEmpty)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: customerDetailsList!.map((address) {
                          bool isSelected = selectedAddressId == address['AddressID'];

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: ElevatedButton(
                              onPressed: () async {
                                setState(() {
                                  if (isSelected) {
                                    // Deselecting the button and clearing the fields
                                    selectedAddressId = "";
                                    selectedAddress = null;
                                    _pincodeController.clear();
                                    _flatController.clear();
                                    _buildingController.clear();
                                    _addressController.clear();
                                    _distanceController.clear();
                                    _selectedState = null;
                                    selectedStateCode = null;
                                    _selectedCity = null;
                                    selectedCityCode = null;
                                    _selectedArea = null;
                                    _selectedPlaceId = null;
                                  } else {
                                    // Selecting the address and populating fields
                                    selectedAddress = address;
                                    selectedAddressId = address['AddressID'];
                                    _pincodeController.text = address['PINCODE'] ?? "";
                                    _flatController.text = address['HouseNo'] ?? "";
                                    _buildingController.text = address['Building'] ?? "";
                                    _addressController.text = address['CustomerAddress'] ?? "";
                                    _distanceController.text = address['KmDistance'].toString();
                                  }
                                });

                                if (!isSelected) {
                                  // Fetching and setting state, city, and area details
                                  String stateName = address['StateName'] ?? "";
                                  String cityID = address['CityID'] ?? "";
                                  String placeID = address['PlaceID'] ?? "";

                                  for (var state in states) {
                                    if (state["StateName"] == stateName.trim()) {
                                      setState(() {
                                        _selectedState = state["StateName"];
                                        selectedStateCode = state["StateCode"];
                                      });
                                      break;
                                    }
                                  }

                                  await _fetchAreas(_pincodeController.text.trim());
                                  await fetchCities(selectedStateCode!);

                                  for (var city in cities) {
                                    if (city['CityCode'] == cityID.trim()) {
                                      setState(() {
                                        _selectedCity = city['CityName'];
                                        selectedCityCode = city['CityCode'];
                                      });
                                      break;
                                    }
                                  }

                                  for (var area in _areaList) {
                                    if (area['placeId'] == placeID.trim()) {
                                      setState(() {
                                        _selectedArea = area['placeName'];
                                        _selectedPlaceId = area['placeId'];
                                      });
                                      break;
                                    }
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isSelected ? Colors.grey : const Color.fromARGB(255, 2, 9, 106),
                                foregroundColor: isSelected ? Colors.black : Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text("${address['AddressID'] ?? ''}"),
                            ),
                          );
                        }).toList(),
                      ),
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
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(6),
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onChanged: (value) {
                            if (value.length == 6) {
                              setState(() {
                                _selectedPlaceId = null;
                                _selectedArea = null;
                              });
                              _fetchAreas(value);
                            } else {
                              setState(() {
                                _areaList = [];
                                _selectedPlaceId = null;
                                _selectedArea = null;
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                          flex: 1,
                          child: DropdownButtonFormField<String>(
                            value: _selectedPlaceId,
                            // Use placeId as the value
                            items: [
                              const DropdownMenuItem(
                                value: null,
                                child: Text(
                                  'Select Area',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                              ..._areaList.map((area) {
                                return DropdownMenuItem<String>(
                                  value: area['placeId'],
                                  // Use placeId as the value
                                  child: Text(area['placeName'] ?? ''),
                                );
                              }),
                            ],
                            onChanged: (String? value) {
                              setState(() {
                                _selectedPlaceId =
                                    value; // Store selected placeId
                                _selectedArea = _areaList.firstWhere(
                                  (area) => area['placeId'] == value,
                                  orElse: () => {'placeName': ''},
                                )['placeName']; // Store selected placeName
                              });
                            },
                            decoration: InputDecoration(
                              labelText: 'Area',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor:
                                  const Color.fromARGB(255, 255, 255, 255),
                            ),
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black),
                            dropdownColor: Colors.white,
                          )),
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
                          value: selectedStateCode,
                          // Ensure this is correctly updated in setState
                          items: [
                            const DropdownMenuItem(
                              value: null, // Default unselected state
                              child: Text(
                                'Select State',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                            ...states.map((state) {
                              return DropdownMenuItem<String>(
                                value: state['StateCode'],
                                // Use StateCode as the value
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
                                final customerID =
                                    CustomerIDController.text.trim();
                                final customerName =
                                    CustomerNameController.text.trim();
                                final customerMobile =
                                    CustomerMobileController.text.trim();
                                _submitCustomerDetails(
                                    customerID, customerName, customerMobile);
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

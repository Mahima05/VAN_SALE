import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:abis2/api_handling/FetchVehicleAPI.dart';
import 'package:abis2/main.dart';

class NewVehiclePage extends StatefulWidget {
  const NewVehiclePage({super.key});

  @override
  State<NewVehiclePage> createState() => _NewVehiclePageState();
}

class _NewVehiclePageState extends State<NewVehiclePage> {
  GlobalKey stockButtonKey = GlobalKey();
  String selectedMenu = 'Billing';
  bool showDropdown = false;
  String? selectedButton;

  double menuFontSize = 14.0; // billing
  FontWeight menuFontWeight = FontWeight.bold;
  String menuFontFamily = 'Times New Roman';

  double menubarFontSize = 20.0; // billing
  FontWeight menubarFontWeight = FontWeight.bold;
  String menubarFontFamily = 'Poppins';

  TextEditingController vehicleController = TextEditingController();
  TextEditingController branchController = TextEditingController();

  final List<String> menuOptions = [
    'Billing',
    'Stock',
    'Logistics',
    'Finance',
    'HR',
    'Utils',
    'Report',
    'Exit',
  ];

  final List<Map<String, dynamic>> stockDropdownOptions = [
    {'title': 'Indent', 'subOptions': []},
    {
      'title': 'Receiving',
      'subOptions': [
        'Receiving',
        'Franchise Sale Returns',
        'Consignment Returns',
        'GST Transfer In'
      ]
    },
    {
      'title': 'Dispatch',
      'subOptions': ['Transfer Out', 'Consignment Issue', 'Group Company Sale']
    },
    {
      'title': 'Conversions',
      'subOptions': [
        'Live to Dress',
        'Dress to Special',
        'Egg Crack',
        'Sp.Dress-Sp.Dress',
        'Live Stock Adjust',
        'RM to RM'
      ]
    },
    {'title': 'Wastage', 'subOptions': []},
    {'title': 'Stocktake', 'subOptions': []},
    {'title': 'Gen Material Indent', 'subOptions': []},
    {
      'title': 'Production Plan',
      'subOptions': ['Production Plan', 'Demand for PP']
    },
    {
      'title': 'Production',
      'subOptions': ['Packaging', 'Merging', 'De-Kitting']
    },
  ];
  Map<String, bool> expandedStates = {
    'Receiving': false,
    'Dispatch': false,
    'Indent': false,
    'Conversions': false,
    'Wastage': false,
    'Stocktake': false,
    'Gen Material Indent': false,
    'Production Plan': false,
    'Production': false,
  };

  String _getMonthName(int month) {
    const List<String> months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  void onMenuSelect(String option) {
    setState(() {
      selectedMenu = option;
      showDropdown = option == 'Stock' ? !showDropdown : false;
    });
  }

  String currentTime = DateFormat('hh:mm a').format(DateTime.now());
  Timer? timer;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() {
        currentTime = DateFormat('hh:mm a').format(DateTime.now());
      });
    });
  }


  void _FetchVehicle(BuildContext context) {
    List<Map<String, dynamic>> vehicles = [];
    bool isLoading = true;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Fetch vehicles immediately when the dialog is created
            Future.delayed(Duration.zero, () async {
              List<Map<String, dynamic>> fetchedVehicles =
              await FetchVehicleAPI.fetchVehicles("L111", BearerToken);

              setState(() {
                vehicles = fetchedVehicles;
                isLoading = false; // Stop loading once vehicles are fetched
              });
            });

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Container(
                padding: const EdgeInsets.all(15),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and Close Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Choose Vehicle',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),


                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              labelText: 'Enter branch No.',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 2, 9, 106),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Search',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    // Display Loading or Vehicles
                    isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : vehicles.isNotEmpty
                        ? Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: vehicles.take(4).map((vehicle) {
                        return ElevatedButton(
                          onPressed: () {
                            setState(() {
                              vehicleController.text = vehicle['VehicleId'];
                              branchController.text = vehicle['BranchID'];
                            });
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            vehicle['VehicleId'],
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList(),
                    )
                        : const Center(child: Text("No vehicles found")),

                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: const Color.fromARGB(255, 2, 9, 106),
            toolbarHeight: 80,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${DateFormat('dd MMMM yyyy').format(DateTime.now())}, ${DateFormat('EEEE').format(DateTime.now())}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        currentTime,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Text(
                        'Location, Area',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                // Menu Buttons
                Row(
                  children: menuOptions.map((option) {
                    final isExitButton = option == 'Exit';
                    final isSelected = selectedMenu == option;

                    return GestureDetector(
                      key: option == 'Stock' ? stockButtonKey : null,
                      onTap: () {
                        setState(() {
                          if (isExitButton) {
                            Navigator.pushReplacementNamed(context, '/login');
                          } else {
                            selectedMenu = option;
                            showDropdown =
                                (option == 'Stock' || option == 'Logistics')
                                    ? !showDropdown
                                    : false;
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (isExitButton
                                  ? const Color.fromARGB(255, 255, 51, 51)
                                  : const Color.fromARGB(255, 253, 197, 0))
                              : (isExitButton
                                  ? const Color.fromARGB(255, 255, 51, 51)
                                  : const Color.fromARGB(255, 2, 9, 106)),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          option,
                          style: TextStyle(
                            fontSize: menuFontSize,
                            fontWeight: menuFontWeight,
                            fontFamily: menuFontFamily,
                            color: isSelected ? Colors.black : Colors.white,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          body: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                color: const Color.fromARGB(255, 236, 236, 236),
                child: Row(
                  children: [
                    const SizedBox(width: 10),
                    Text(
                      'New Vehicle',
                      style: TextStyle(
                          fontSize: menubarFontSize + 8,
                          fontWeight: menubarFontWeight,
                          fontFamily: menubarFontFamily),
                    ),
                    const SizedBox(width: 38),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedButton = 'New';
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor:
                            const Color.fromARGB(255, 215, 214, 217),
                        // Text color
                        side: BorderSide(
                          color: selectedButton == 'New'
                              ? const Color.fromRGBO(0, 0, 0, 0.2)
                              : Colors.transparent, // Border color
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(10), // Rounded border
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10), // Padding
                      ),
                      child: Text('New',
                          style: TextStyle(
                              fontSize: menubarFontSize,
                              fontWeight: menubarFontWeight,
                              fontFamily: menubarFontFamily)),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedButton = 'View';
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor:
                            const Color.fromARGB(255, 215, 214, 217),
                        side: BorderSide(
                          color: selectedButton == 'New'
                              ? const Color.fromRGBO(0, 0, 0, 0.2)
                              : Colors.transparent,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                      ),
                      child: Text('View',
                          style: TextStyle(
                              fontSize: menubarFontSize,
                              fontWeight: menubarFontWeight,
                              fontFamily: menubarFontFamily)),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedButton = 'Save';
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: selectedButton == 'Save'
                            ? Colors.white
                            : Colors.black,
                        backgroundColor: selectedButton == 'Save'
                            ? const Color(0xFF02720F)
                            : const Color(0xFF02A515),
                        // Text color
                        side: BorderSide(
                          color: selectedButton == 'Save'
                              ? Colors.yellow
                              : Colors.transparent, // Border color
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(10), // Rounded border
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10), // Padding
                      ),
                      child: Text('Save',
                          style: TextStyle(
                              fontSize: menubarFontSize,
                              fontWeight: menubarFontWeight,
                              fontFamily: menubarFontFamily)),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, "/");

                        setState(() {
                          selectedButton = 'Cancel';
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: selectedButton == 'Cancel'
                            ? Colors.white
                            : Colors.black,
                        backgroundColor: selectedButton == 'Cancel'
                            ? const Color.fromARGB(255, 254, 0, 0)
                            : const Color(0xFFFF3333),
                        // Text color
                        side: BorderSide(
                          color: selectedButton == 'Cancel'
                              ? Colors.yellow
                              : Colors.transparent,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                      ),
                      child: Text('Cancel',
                          style: TextStyle(
                              fontSize: menubarFontSize,
                              fontWeight: menubarFontWeight,
                              fontFamily: menubarFontFamily)),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 10),
              Expanded(
                  child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          // 1st Row: Dropdown and TextField
                          Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: DropdownButtonFormField<String>(
                                  decoration: InputDecoration(
                                    labelText: 'Trip Type',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 10),
                                  ),
                                  items: [
                                    'Customer Delivery',
                                    'Indent/Local Po',
                                    'Repair Maintainance',
                                    'Transfer Out'
                                  ]
                                      .map((type) => DropdownMenuItem(
                                            value: type,
                                            child: Text(type),
                                          ))
                                      .toList(),
                                  onChanged: (value) {},
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 2,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        readOnly: true,
                                        decoration: InputDecoration(
                                          labelText: 'Vehicle Branch',
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 10, vertical: 10),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    SizedBox(
                                      width: 100.0,
                                      height: 50.0,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          _FetchVehicle(context);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color.fromARGB(
                                              255, 2, 9, 106),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 15),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                        child: const Text(
                                          'Select',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: DropdownButtonFormField<String>(
                                        decoration: InputDecoration(
                                          labelText: 'V Type',
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 10, vertical: 10),
                                        ),
                                        items: ['Company V', '3rd party']
                                            .map((type) => DropdownMenuItem(
                                                  value: type,
                                                  child: Text(type),
                                                ))
                                            .toList(),
                                        onChanged: (value) {},
                                      ),
                                    ),

                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: TextField(
                                        controller: vehicleController,
                                        readOnly: true,
                                        decoration: InputDecoration(
                                          labelText: 'Vehicle No',
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 10, vertical: 10),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                        width:
                                            10), // Space between TextField and button
                                    SizedBox(
                                      width: 100.0,
                                      height: 50.0,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          _FetchVehicle(context);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color.fromARGB(
                                              255, 2, 9, 106),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 15),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                        child: const Text(
                                          'Select',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 5),
                          Container(
                            child: Column(
                              // crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: branchController,
                                        decoration: InputDecoration(
                                          labelText: 'Start Reading',
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 10, vertical: 10),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 15),
                                    Expanded(
                                      child: TextField(
                                        decoration: InputDecoration(
                                          labelText: 'End Reading',
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 10, vertical: 10),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                TextField(
                                  decoration: InputDecoration(
                                    labelText: 'Destination',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 10),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                // Third Row: Add Remarks
                                TextField(
                                  decoration: InputDecoration(
                                    labelText: 'Remarks',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 10),
                                  ),
                                ),

                                const SizedBox(height: 10),
                                const Row(
                                  children: [
                                    Text(
                                      'Operator Details',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    const SizedBox(height: 5),
                                    Expanded(
                                      flex:
                                          2, // Gives more space to the dropdown
                                      child: DropdownButtonFormField<String>(
                                        decoration: InputDecoration(
                                          labelText: 'Select Operator',
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 10, vertical: 10),
                                        ),
                                        items: [
                                          'Operator 1',
                                          'Operator 2',
                                          'Operator 3'
                                        ]
                                            .map((operator) => DropdownMenuItem(
                                                  value: operator,
                                                  child: Text(operator),
                                                ))
                                            .toList(),
                                        onChanged: (value) {},
                                      ),
                                    ),
                                    const SizedBox(
                                        width: 10), // Space between elements

                                    // Operator Field (Read-only)
                                    Expanded(
                                      flex: 2,
                                      child: TextField(
                                        readOnly: true,
                                        decoration: InputDecoration(
                                          labelText: 'Operator',
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 10, vertical: 10),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                        width: 10), // Space between elements

                                    // Select Button
                                    SizedBox(
                                      width: 100.0,
                                      height: 50.0,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          _FetchVehicle(context);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color.fromARGB(
                                              255, 2, 9, 106),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 15),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                        child: const Text(
                                          'Select',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 10),

                                // Fourth Row: Add and Clear Buttons
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 100.0,
                                      height: 50.0,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          // Add item functionality
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color.fromARGB(
                                              255,
                                              2,
                                              9,
                                              106), // Set button color
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                10), // Set border radius
                                          ),
                                        ),
                                        child: const Text(
                                          'Add',
                                          style: TextStyle(
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                Colors.white, // Set text color
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    SizedBox(
                                      width: 100.0, // Set width
                                      height: 50.0, // Set height
                                      child: ElevatedButton(
                                        onPressed: () {
                                          // Clear inputs functionality
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color.fromARGB(
                                              255,
                                              2,
                                              9,
                                              106), // Set button color
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                10), // Set border radius
                                          ),
                                        ),
                                        child: const Text(
                                          'Clear',
                                          style: TextStyle(
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                Colors.white, // Set text color
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 10),

                                // Fifth Row: Table
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: DataTable(
                                    columns: const [
                                      DataColumn(
                                        label: Text(''), // Checkbox column
                                      ),
                                      DataColumn(
                                        label: Text('Line No.'),
                                      ),
                                      DataColumn(
                                        label: Text('Operator Design Name'),
                                      ),
                                      DataColumn(
                                        label: Text('Operator'),
                                      ),
                                      DataColumn(label: Text('wq'))
                                    ],
                                    rows: List.generate(5, (index) {
                                      return DataRow(
                                        cells: [
                                          DataCell(
                                            StatefulBuilder(
                                              builder: (context, setState) {
                                                bool isChecked = false;
                                                return Checkbox(
                                                  value: isChecked,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      isChecked = value!;
                                                    });
                                                  },
                                                );
                                              },
                                            ),
                                          ),
                                          DataCell(Text('${index + 1}')),
                                          const DataCell(Text('Sample Item')),
                                          const DataCell(Text('5')),
                                          const DataCell(Text('10')),
                                        ],
                                      );
                                    }),
                                  ),
                                ),

                                const SizedBox(height: 10),

                                // Delete Selected Row Button
                                Center(
                                  child: SizedBox(
                                    width: 200.0, // Set your desired width
                                    height: 50.0, // Set your desired height
                                    child: ElevatedButton(
                                      onPressed: () {
                                        // Delete selected rows functionality
                                      },
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 15, vertical: 15),
                                        backgroundColor: Colors.red,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              10), // Set border radius
                                        ),
                                      ),
                                      child: const Text(
                                        'Delete Selected Row',
                                        style: TextStyle(
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ], //main child
                      ),
                    ),
                  ], //final children
                ), //final colunm
              ))
            ],
          ),
        ),
        if (showDropdown && selectedMenu == 'Stock') _buildDropdownBelowStock(),
      ],
    );
  }

  Widget _buildDropdownBelowStock() {
    RenderBox? box =
        stockButtonKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return const SizedBox.shrink(); // Safety check

    Offset position = box.localToGlobal(Offset.zero);
    double buttonLeft = position.dx;
    double buttonBottom = position.dy + box.size.height;

    return Positioned(
      top: buttonBottom + 5, // Position dropdown below the Stock button
      left: buttonLeft, // Align dropdown's left with the Stock button's left
      child: Material(
        elevation: 4,
        color: const Color.fromARGB(255, 253, 197, 0),
        borderRadius: BorderRadius.circular(8), // Optional: Add rounded corners
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          // Add padding for better readability
          constraints: const BoxConstraints(
            minWidth: 150, // Set a minimum width for the dropdown
            maxWidth: 300, // Set a maximum width if needed
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            // Adjust dropdown height to fit content
            children: stockDropdownOptions.map((dropdownOption) {
              return GestureDetector(
                onTap: () {
                  // Toggle expanded state when a main option is tapped
                  if (dropdownOption['title'] == 'Indent') {
                    Navigator.pushReplacementNamed(context, '/indent');
                  }
                  if (dropdownOption['title'] == 'Wastage') {
                    Navigator.pushReplacementNamed(context, '/wastage');
                  }
                  if (dropdownOption['title'] == 'Stocktake') {
                    Navigator.pushReplacementNamed(context, '/stocktake');
                  }
                  if (dropdownOption['title'] == 'Gen Material Indent') {
                    Navigator.pushReplacementNamed(
                        context, '/gen_material_indent');
                  } else {
                    // Toggle expanded state for other options
                    setState(() {
                      expandedStates[dropdownOption['title']] =
                          !(expandedStates[dropdownOption['title']] ?? false);
                    });
                  }

                  if (dropdownOption['subOptions'].isEmpty) {
                    // Close dropdown if the option has no sub-options
                    setState(() {
                      showDropdown = false;
                    });
                  }
                },
                child: Column(
                  children: [
                    ListTile(
                      title: Text(
                        dropdownOption['title'],
                        style: TextStyle(
                          fontFamily: menuFontFamily,
                          fontSize: menuFontSize,
                          fontWeight: menuFontWeight,
                          color: const Color.fromARGB(255, 0, 0, 0),
                          overflow: TextOverflow
                              .ellipsis, // Prevent overflow if needed
                        ),
                      ),
                      trailing: dropdownOption['subOptions'].isNotEmpty
                          ? Icon(
                              expandedStates[dropdownOption['title']] ?? false
                                  ? Icons.arrow_drop_up
                                  : Icons.arrow_drop_down)
                          : null,
                    ),
                    // Only show sub-options if the main option is expanded
                    if ((expandedStates[dropdownOption['title']] ?? false) &&
                        dropdownOption['subOptions'].isNotEmpty)
                      ...dropdownOption['subOptions'].map((subOption) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 20.0),
                          child: ListTile(
                            title: Text(
                              subOption,
                              style: TextStyle(
                                fontFamily: menuFontFamily,
                                fontSize: menuFontSize,
                                fontWeight: menuFontWeight,
                                color: const Color.fromARGB(255, 0, 0, 0),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            onTap: () {
                              if (subOption == 'Receiving') {
                                Navigator.pushReplacementNamed(
                                    context, '/receiving');
                              }
                              if (subOption == 'Franchise Sale Returns') {
                                Navigator.pushReplacementNamed(
                                    context, '/franchise_sale_returns');
                              }
                              if (subOption == 'Consignment Returns') {
                                Navigator.pushReplacementNamed(
                                    context, '/consigment_returns');
                              }
                              if (subOption == 'GST Transfer In') {
                                Navigator.pushReplacementNamed(
                                    context, '/gst_transfer_in');
                              }
                              if (subOption == 'Transfer Out') {
                                Navigator.pushReplacementNamed(
                                    context, '/transfer_out');
                              }
                              if (subOption == 'Consignment Issue') {
                                Navigator.pushReplacementNamed(
                                    context, '/consignment_issue');
                              }
                              if (subOption == 'Group Company Sale') {
                                Navigator.pushReplacementNamed(
                                    context, '/group_company_sale');
                              }
                              if (subOption == 'Live to Dress') {
                                Navigator.pushReplacementNamed(
                                    context, '/live_to_dress');
                              }
                              if (subOption == 'Dress to Special') {
                                Navigator.pushReplacementNamed(
                                    context, '/dress_to_special');
                              }
                              if (subOption == 'Egg Crack') {
                                Navigator.pushReplacementNamed(
                                    context, '/egg_crack');
                              }
                              if (subOption == 'Sp.Dress-Sp.Dress') {
                                Navigator.pushReplacementNamed(
                                    context, '/sp_dress');
                              }
                              if (subOption == 'Live Stock Adjust') {
                                Navigator.pushReplacementNamed(
                                    context, '/live_stock_adjust');
                              }
                              if (subOption == 'RM to RM') {
                                Navigator.pushReplacementNamed(
                                    context, '/rm_to_rm');
                              }
                              if (subOption == 'Production Plan') {
                                Navigator.pushReplacementNamed(
                                    context, '/production_plan');
                              }
                              if (subOption == 'Demand for PP') {
                                Navigator.pushReplacementNamed(
                                    context, '/demand_for_pp');
                              }
                              if (subOption == 'Packaging') {
                                Navigator.pushReplacementNamed(
                                    context, '/packaging');
                              }
                              if (subOption == 'Merging') {
                                Navigator.pushReplacementNamed(
                                    context, '/merging');
                              }
                              if (subOption == 'De-Kitting') {
                                Navigator.pushReplacementNamed(
                                    context, '/de_kitting');
                              }

                              setState(() {
                                showDropdown = false;
                              });
                            },
                          ),
                        );
                      }).toList(),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

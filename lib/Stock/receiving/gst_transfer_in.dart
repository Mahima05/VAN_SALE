import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:abis2/login_handling/login.dart';

class GSTtransferIN extends StatefulWidget{
  const GSTtransferIN({super.key});
  @override
  State<GSTtransferIN> createState() => _GSTtransferINScreenState();
}
class _GSTtransferINScreenState extends State<GSTtransferIN>{
  String? selectedButton;

  double menuFontSize = 14.0; // billing
  FontWeight menuFontWeight = FontWeight.bold;
  String menuFontFamily = 'Times New Roman';

  double menubarFontSize = 20.0; // billing
  FontWeight menubarFontWeight = FontWeight.bold;
  String menubarFontFamily = 'Poppins';


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


  void _showLocationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Choose Location',
                      style: TextStyle(
                        fontSize: 18,
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
                          labelText: 'Enter branch name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'Enter location code',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                      },
                      child: const Text('Search'),
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                // Row: Location Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    4, 
                        (index) => Flexible(
                      flex: 1,
                      child: SizedBox(
                        height: 50, 
                        width: double.infinity, 
                        child: ElevatedButton(
                          onPressed: () {
                          },
                          child: Text('Location${index + 1}'),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // Add Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); 
                      },
                      child: const Text('Add'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showItemDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Search Item',
                      style: TextStyle(
                        fontSize: 18,
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
                          labelText: 'Enter item name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                      },
                      child: const Text('Search'),
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    4, 
                        (index) => Flexible(
                      flex: 1,
                      child: SizedBox(
                        height: 50, 
                        width: double.infinity, 
                        child: ElevatedButton(
                          onPressed: () {
                            
                          },
                          child: Text('Item${index + 1}'),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // Add Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); 
                      },
                      child: const Text('Add'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }



  void _showIndentSearchDialog(BuildContext context) {
    DateTime? startDate; 
    DateTime? endDate;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Indent Search',
                          style: TextStyle(
                            fontSize: 18,
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

                    // Document No. Text Field
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              labelText: 'Document No.',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 10,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    // Date Range and Search Button Row
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: startDate ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (pickedDate != null) {
                                setState(() {
                                  startDate = pickedDate; 
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    startDate != null
                                        ? '${startDate!.day}, ${_getMonthName(startDate!.month)} ${startDate!.year}'
                                        : 'Select Start Date',
                                  ),
                                  const Icon(Icons.calendar_today),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // End Date Field
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: endDate ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (pickedDate != null) {
                                setState(() {
                                  endDate = pickedDate; // Update end date
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    endDate != null
                                        ? '${endDate!.day}, ${_getMonthName(endDate!.month)} ${endDate!.year}'
                                        : 'Select End Date',
                                  ),
                                  const Icon(Icons.calendar_today),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Search Button
                        ElevatedButton(
                          onPressed: () {
                          },
                          child: const Text('Search'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              startDate = null; 
                              endDate = null; 
                            });
                          },
                          child: const Text('Clear'),
                        ),
                        const SizedBox(width: 20),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop(); 
                          },
                          child: const Text('Save'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String currentTime = DateFormat('hh:mm a').format(DateTime.now());
  Timer? timer;

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() {
        currentTime = DateFormat('hh:mm a').format(DateTime.now());
      });
    });
  }

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

  @override
  Widget build(BuildContext context) {

    final args =
    ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    final Branch? branch =
    args != null && args['BranchId'] != null && args['BranchName'] != null
        ? Branch(Branchid: args['BranchId'], Branchname: args['BranchName'])
        : null;
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
                      Text(
                        branch?.Branchname ?? 'Branch Name',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                // Menu Buttons
                const SizedBox(height: 8),
                Row(
                  children: menuOptions.map((option) {
                    final isExitButton = option == 'Exit';
                    final isSelected = selectedMenu == option;

                    return GestureDetector(
                      key: option == 'Stock'
                          ? stockButtonKey
                          : option == 'Logistics'
                          ? logisticButtonKey
                          : option == "Finance"
                          ? financeButtonKey
                          : option == "HR"
                          ? hrButtonKey
                          : option == "Utils"
                          ? utilsButtonKey
                          : option == "Reports"
                          ? reportButtonKey
                          : null,
                      onTap: () {
                        setState(() {
                          if (isExitButton) {
                            Navigator.pushReplacementNamed(context, '/login');
                          } else if (option == "Billing") {
                            if (selectedMenu != "Billing") {
                              selectedMenu = option;
                              Navigator.pushReplacementNamed(context, '/');
                            }
                          } else if (["Stock", "Logistics", "Finance", "HR", "Utils", "Reports"].contains(option)) {
                            selectedMenu = option;
                            showDropdown = true;
                          } else {
                            selectedMenu = option;
                            showDropdown = false;
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
                      'GST Transfer IN',
                      style: TextStyle(
                          fontSize: menubarFontSize + 5,
                          fontWeight: menubarFontWeight,
                          fontFamily: menubarFontFamily),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedButton = 'New';
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor: const Color.fromARGB(255, 215, 214, 217),
                        // Text color
                        side: BorderSide(
                          color: selectedButton == 'New'
                              ? const Color.fromRGBO(0, 0, 0, 0.2)
                              : Colors.transparent, 
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(10), 
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10), 
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
                        backgroundColor: const Color.fromARGB(255, 215, 214, 217),
                        // Text color
                        side: BorderSide(
                          color: selectedButton == 'New'
                              ? const Color.fromRGBO(0, 0, 0, 0.2)
                              : Colors.transparent, 
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(10), 
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
                              : Colors.transparent, 
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(10), 
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
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
                          borderRadius:
                          BorderRadius.circular(10),
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
              Expanded(child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [
                          BoxShadow(color: Color.fromARGB(255, 235, 235, 235)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Indent Details',
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                            ),
                          ),

                          // First
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: DropdownButtonFormField<String>(
                                  decoration: InputDecoration(
                                    labelText: 'Select Transfer Type',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 10),
                                  ),
                                  items: [
                                    'LOT',
                                    'IB ST',
                                    'PO(Local Vendor)',
                                    'Challan',
                                    'None'
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
                                flex: 1,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        readOnly: true,
                                        decoration: InputDecoration(
                                          labelText: 'Ref.PI/Order',
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
                                    const SizedBox(width: 5),
                                    SizedBox(
                                      width: 90.0,
                                      height: 50.0,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          _showIndentSearchDialog(context);
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
                          // Second Row TextField
                          Row(
                            children: [
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 1,
                                child: TextField(
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    labelText: 'Invoice',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 10),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 1,
                                child: TextField(
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    labelText: 'Lot',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 10),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    //location details
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [
                          BoxShadow(
                              color: Color.fromARGB(255, 235, 235,
                                  235) // changes position of shadow
                              ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // First Row: Title
                          const Text(
                            'Location & Vehicle Details',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Second Row: Dropdown and TextField
                          Row(
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    
                                    Expanded(
                                      child: TextField(
                                        readOnly: true,
                                        decoration: InputDecoration(
                                          labelText: 'Choose Location',
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
                                    // Select Button
                                    SizedBox(
                                        width: 90.0,
                                        height: 50.0,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            _showLocationDialog(context);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color.fromARGB(255, 2, 9, 106),
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
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
                                flex: 1,
                                child: DropdownButtonFormField<String>(
                                  decoration: InputDecoration(
                                    labelText: 'Select vehicle type',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 10),
                                  ),
                                  items: ['OWN', 'TRANSPORTER']
                                      .map((type) => DropdownMenuItem(
                                            value: type,
                                            child: Text(type),
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 1,
                                child: DropdownButtonFormField<String>(
                                  decoration: InputDecoration(
                                    labelText: 'Address',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 10),
                                  ),
                                  items: ['']
                                      .map((type) => DropdownMenuItem(
                                            value: type,
                                            child: Text(type),
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              
                              SizedBox(
                                        width: 90.0,
                                        height: 50.0,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            _showLocationDialog(context);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color.fromARGB(255, 2, 9, 106),
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                          ),
                                          child: const Text(
                                            'New',
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
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  decoration: InputDecoration(
                                    labelText: 'Distance',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 10),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  decoration: InputDecoration(
                                    labelText: 'Vehicle Number',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 10),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  decoration: InputDecoration(
                                    labelText: 'Driver',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 10),
                                  ),
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
                                      child: TextField(
                                        readOnly: true,
                                        decoration: InputDecoration(
                                          labelText: 'Add Remarks',
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
                                    // Select Button
                                    SizedBox(
                                        width: 90.0,
                                        height: 50.0,
                                        child: ElevatedButton(
                                          onPressed: () {
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color.fromARGB(255, 2, 9, 106),
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                          ),
                                          child: const Text(
                                            'Remove',
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
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 15),
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
                          // Title
                          const Text(
                            'Item Details',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 10),

                          // First Row: Item Name and Search Button
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  decoration: InputDecoration(
                                    labelText: 'Choose Location',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 10),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              SizedBox(
                                        width: 90.0,
                                        height: 50.0,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            _showItemDialog(context);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color.fromARGB(255, 2, 9, 106),
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
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
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  decoration: InputDecoration(
                                    labelText: 'Choose Batch',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 10),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              SizedBox(
                                        width: 90.0,
                                        height: 50.0,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            _showItemDialog(context);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color.fromARGB(255, 2, 9, 106),
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
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

                          // Second Row: Select port,Wt, Rate, Nos
                          Row(
                            children: [
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 1,
                                child: DropdownButtonFormField<String>(
                                  decoration: InputDecoration(
                                    labelText: 'Select Port',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 10),
                                  ),
                                  items: ['NONE', 'COM1', 'COM2']
                                      .map((type) => DropdownMenuItem(
                                            value: type,
                                            child: Text(type),
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                  },
                                ),
                              ),

                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  decoration: InputDecoration(
                                    labelText: 'Wt(kg)',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 10),
                                  ),
                                ),
                              ),
                              
                            ],
                          ),

                          const SizedBox(height:10),
                          Row(
                            children:[
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  decoration: InputDecoration(
                                    labelText: 'Nos',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 10),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  decoration: InputDecoration(
                                    labelText: 'VM Nos',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 10),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  decoration: InputDecoration(
                                    labelText: 'VM Wt(kg)',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 10),
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
                                        width: 90.0,
                                        height: 50.0,
                                        child: ElevatedButton(
                                          onPressed: () {
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color.fromARGB(255, 2, 9, 106),
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                          ),
                                          child: const Text(
                                            'Add',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),

                                        const SizedBox(width: 20),
                                         ElevatedButton(
                                          onPressed: () {
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color.fromARGB(255, 2, 9, 106),
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                          ),
                                          child: const Text(
                                            'Clear',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
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
                                  label: Text(''),
                                ),
                                DataColumn(
                                  label: Text('Line No.'),
                                ),
                                DataColumn(
                                  label: Text('Item Name'),
                                ),
                                DataColumn(
                                  label: Text('Nos'),
                                ),
                                DataColumn(
                                  label: Text('Kg'),
                                ),
                                DataColumn(
                                  label: Text('Remarks'),
                                ),
                              ],
                              rows: List.generate(5, (index) {
                                return DataRow(
                                  cells: [
                                    DataCell(
                                      Checkbox(
                                        value: false,
                                        onChanged: (value) {
                                        },
                                      ),
                                    ),
                                    DataCell(Text('${index + 1}')),
                                    const DataCell(Text('Sample Item')),
                                    const DataCell(Text('5')),
                                    const DataCell(Text('10')),
                                    const DataCell(Text('No remarks')),
                                  ],
                                );
                              }),
                            ),
                          ),
                          const SizedBox(height: 10),

                          ElevatedButton(
                                      onPressed: () {
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(255, 128, 2, 2),
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                      child: const Text(
                                        'Delete Selected Row',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                        
                        ],
                      ),
                    ),
                  ],
                ),
              ))
            ],
          ),
        ),
        if (showDropdown && selectedMenu == 'Stock') _buildDropdownBelowStock(),
        if (showDropdown && selectedMenu == 'Logistics')
          _buildDropdownBelowLogistics(),
        if (showDropdown && selectedMenu == "Finance")
          _buildDropdownBelowFinance(),
        if (showDropdown && selectedMenu == 'HR') _buildDropdownBelowHR(),
        if (showDropdown && selectedMenu == 'Utils')
          _buildDropdownBelowUtils(),
        if (showDropdown && selectedMenu == "Reports")
          _buildDropdownBelowReports(),
      ],
    );
  }

  GlobalKey stockButtonKey = GlobalKey();
  GlobalKey logisticButtonKey = GlobalKey();
  GlobalKey financeButtonKey = GlobalKey();
  GlobalKey hrButtonKey = GlobalKey();
  GlobalKey utilsButtonKey = GlobalKey();
  GlobalKey reportButtonKey = GlobalKey();
  String selectedMenu = 'Stock';
  bool showDropdown = false;

  final List<String> menuOptions = [
    'Billing',
    'Stock',
    'Logistics',
    'Finance',
    'HR',
    'Utils',
    'Reports',
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
    {'title': 'Bin Transfer', 'subOptions': []},

  ];

  final List<Map<String, dynamic>> logisticsDropdownOptions = [
    {'title': 'Trips', 'subOptions': []},
    {'title': 'Trip Plan', 'subOptions': []},
    {'title': 'Delivery', 'subOptions': []},
    {'title': 'Expenses', 'subOptions': []},
    {'title': 'Day End', 'subOptions': []},
    {'title': 'Odo Reset', 'subOptions': []},
  ];

  final List<Map<String, dynamic>> financeDropdownOptions = [
    {'title': 'Bank Transfer', 'subOptions': []},
    {'title': 'IB Branch Transfer', 'subOptions': []},
    {'title': 'HO Transfer', 'subOptions': []},
    {'title': 'Payments', 'subOptions': []},
    {
      'title': 'Receipts',
      'subOptions': [
        'From Silak Customer',
        'From HO Customer',
        'From Other Branch',
        'Misc. Collections'
      ]
    },
    {'title': 'Opening Receivable', 'subOptions': []},
  ];

  final List<Map<String, dynamic>> hrDropdownOptions = [
    {'title': 'Opening Attendance', 'subOptions': []},
    {'title': 'Day End Attendance', 'subOptions': []},
    {'title': 'Leave', 'subOptions': []},
  ];

  final List<Map<String, dynamic>> utilDropdownOptions = [
    {'title': 'Day End', 'subOptions': []},
    {'title': 'DataSynch', 'subOptions': []},
    {'title': 'BOM', 'subOptions': []},
    {'title': 'Items', 'subOptions': []},
    {'title': 'Carting Charges', 'subOptions': []},
    {'title': 'HO Customer', 'subOptions': []},
    {'title': 'Sets', 'subOptions': []},
    {'title': 'Batch Label', 'subOptions': []},
  ];

  final List<Map<String, dynamic>> reportsDropdownOptions = [
    {'title': 'Day Rate', 'subOptions': []},
    {'title': 'Stock', 'subOptions': []},
    {'title': 'Ledger', 'subOptions': []},
    {
      'title': 'Day Reports',
      'subOptions': ['Day Reports']
    },
    {'title': 'Opening Balance', 'subOptions': []},
  ];

  Map<String, bool> expandedStates = {
    'Receiving': false,
    'Dispatch': false,
    'Indent': false,
    'Conversions': false,
    'Wastage': false,
    'Stocktake': false,
    'Gen Material Indent': false,
    'Bin Transfer': false,
    'Production Plan': false,
    'Production': false,
    'Trips': false,
    'Trip Plan': false,
    'Delivery': false,
    'Expenses': false,
    'Day End': false,
    'Odo Reset': false,
    'Bank Transfer': false,
    'IB Branch Transfer': false,
    'HO Transfer': false,
    'Payments': false,
    'Receipts': false,
    'Opening Receivable': false,
    'Opening Attendance': false,
    'Day End Attendance': false,
    'Leave': false,
    'Day End': false,
    'DataSynch': false,
    'BOM': false,
    'Items': false,
    'Carting Charges': false,
    'HO Customer': false,
    'Sets': false,
    'Batch Label': false,
    'Day Rate': false,
    'Stock': false,
    'Ledger': false,
    'Day Reports': false,
    'Opening Balance': false,
  };

  void onMenuSelect(String option) {
    setState(() {
      selectedMenu = option;
      showDropdown = (option == 'Stock' ||
          option == 'Logistics' ||
          option == 'Finance' ||
          option == "HR" ||
          option == "Utils" ||
          option == "Reports")
          ? !showDropdown
          : false;
    });
  }

  // stock dropdown
  Widget _buildDropdownBelowStock() {
    RenderBox? box =
    stockButtonKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return const SizedBox.shrink();

    Offset position = box.localToGlobal(Offset.zero);
    double buttonLeft = position.dx;
    double buttonBottom = position.dy + box.size.height;

    return Positioned(
      top: buttonBottom + 5,
      left: buttonLeft,
      child: Material(
        elevation: 4,
        color: const Color.fromARGB(255, 253, 197, 0),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          constraints: const BoxConstraints(
            minWidth: 150,
            maxWidth: 300,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: stockDropdownOptions.map((dropdownOption) {
              return GestureDetector(
                onTap: () {
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
                  }
                  if(dropdownOption['title'] == 'Bin Transfer'){
                    Navigator.pushReplacementNamed(context, '/bin_transfer');
                  }else {
                    setState(() {
                      expandedStates[dropdownOption['title']] =
                      !(expandedStates[dropdownOption['title']] ?? false);
                    });
                  }

                  if (dropdownOption['subOptions'].isEmpty) {
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
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      trailing: dropdownOption['subOptions'].isNotEmpty
                          ? Icon(
                          expandedStates[dropdownOption['title']] ?? false
                              ? Icons.arrow_drop_up
                              : Icons.arrow_drop_down)
                          : null,
                    ),
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
// Logistic dropdown
  Widget _buildDropdownBelowLogistics() {
    RenderBox? box =
    logisticButtonKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return const SizedBox.shrink();

    Offset position = box.localToGlobal(Offset.zero);
    double buttonLeft = position.dx;
    double buttonBottom = position.dy + box.size.height;

    return Positioned(
      top: buttonBottom + 5,
      left: buttonLeft,
      child: Material(
        elevation: 4,
        color: const Color.fromARGB(255, 253, 197, 0),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          constraints: const BoxConstraints(
            minWidth: 150,
            maxWidth: 300,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: logisticsDropdownOptions.map((dropdownOption) {
              return GestureDetector(
                onTap: () {
                  if (dropdownOption['title'] == 'Trips') {
                    Navigator.pushReplacementNamed(context, '/trips');
                  } else if (dropdownOption['title'] == 'Trip Plan') {
                    Navigator.pushReplacementNamed(context, '/trip_plan');
                  } else if (dropdownOption['title'] == 'Delivery') {
                    Navigator.pushReplacementNamed(context, '/delivery');
                  } else if (dropdownOption['title'] == 'Expenses') {
                    Navigator.pushReplacementNamed(context, '/expenses');
                  } else if (dropdownOption['title'] == 'Day End') {
                    Navigator.pushReplacementNamed(context, '/day_end');
                  } else if (dropdownOption['title'] == 'Odo Reset') {
                    Navigator.pushReplacementNamed(context, '/odo_reset');
                  }
                  setState(() {
                    expandedStates[dropdownOption['title']] =
                    !(expandedStates[dropdownOption['title']] ?? false);
                  });

                  if (dropdownOption['subOptions'].isEmpty) {
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
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      trailing: dropdownOption['subOptions'].isNotEmpty
                          ? Icon(
                          expandedStates[dropdownOption['title']] ?? false
                              ? Icons.arrow_drop_up
                              : Icons.arrow_drop_down)
                          : null,
                    ),
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

  Widget _buildDropdownBelowFinance() {
    RenderBox? box =
    financeButtonKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return const SizedBox.shrink();

    Offset position = box.localToGlobal(Offset.zero);
    double buttonLeft = position.dx;
    double buttonBottom = position.dy + box.size.height;

    return Positioned(
      top: buttonBottom + 5,
      left: buttonLeft,
      child: Material(
        elevation: 4,
        color: const Color.fromARGB(255, 253, 197, 0),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          constraints: const BoxConstraints(
            minWidth: 150,
            maxWidth: 300,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: financeDropdownOptions.map((dropdownOption) {
              return GestureDetector(
                onTap: () {
                  if (dropdownOption['title'] == 'Bank Transfer') {
                    Navigator.pushReplacementNamed(context, '/bank_transfer');
                  }
                  if (dropdownOption['title'] == 'IB Branch Transfer') {
                    Navigator.pushReplacementNamed(context, '/ib_branch_transfer');
                  }
                  if (dropdownOption['title'] == 'HO Transfer') {
                    Navigator.pushReplacementNamed(context, '/ho_transfer');
                  }
                  if (dropdownOption['title'] == 'Payments') {
                    Navigator.pushReplacementNamed(context, '/finance_payments');
                  }
                  if (dropdownOption['title'] == 'Opening Receivable') {
                    Navigator.pushReplacementNamed(context, '/opening_receivable');
                  }else {
                    setState(() {
                      expandedStates[dropdownOption['title']] =
                      !(expandedStates[dropdownOption['title']] ?? false);
                    });
                  }

                  if (dropdownOption['subOptions'].isEmpty) {
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
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      trailing: dropdownOption['subOptions'].isNotEmpty
                          ? Icon(
                          expandedStates[dropdownOption['title']] ?? false
                              ? Icons.arrow_drop_up
                              : Icons.arrow_drop_down)
                          : null,
                    ),
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
                              if (subOption == 'From Silak Customer') {
                                Navigator.pushReplacementNamed(context, '/from_silak_customer');
                              }
                              if (subOption == 'From HO Customer') {
                                Navigator.pushReplacementNamed(context, '/from_ho_customer');
                              }
                              if (subOption == 'From Other Branch') {
                                Navigator.pushReplacementNamed(context, '/from_other_branch');
                              }
                              if (subOption == 'Misc. Collections') {
                                Navigator.pushReplacementNamed(context, '/misc_collection');
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

  Widget _buildDropdownBelowHR() {
    RenderBox? box =
    hrButtonKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return const SizedBox.shrink();

  Offset position = box.localToGlobal(Offset.zero);
  double buttonLeft = position.dx;
  double buttonBottom = position.dy + box.size.height;
  double buttonWidth = box.size.width;
  double screenWidth = MediaQuery.of(context).size.width;

  return Positioned(
    top: buttonBottom + 5,
    right: screenWidth - (buttonLeft + buttonWidth), 
      child: Material(
        elevation: 4,
        color: const Color.fromARGB(255, 253, 197, 0),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          constraints: const BoxConstraints(
            minWidth: 150,
            maxWidth: 300,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: hrDropdownOptions.map((dropdownOption) {
              return GestureDetector(
                onTap: () {
                  if (dropdownOption['title'] == 'Opening Attendance') {
                    Navigator.pushReplacementNamed(context, '/opening_attendance');
                  }
                  if (dropdownOption['title'] == 'Day End Attendance') {
                    Navigator.pushReplacementNamed(context, '/day_end_attendance');
                  }
                  if (dropdownOption['title'] == 'Leave') {
                    Navigator.pushReplacementNamed(context, '/leave');
                  }
                  setState(() {
                    expandedStates[dropdownOption['title']] =
                    !(expandedStates[dropdownOption['title']] ?? false);
                  });

                  if (dropdownOption['subOptions'].isEmpty) {
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
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      trailing: dropdownOption['subOptions'].isNotEmpty
                          ? Icon(
                          expandedStates[dropdownOption['title']] ?? false
                              ? Icons.arrow_drop_up
                              : Icons.arrow_drop_down)
                          : null,
                    ),
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
  Widget _buildDropdownBelowUtils() {
    RenderBox? box =
    utilsButtonKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return const SizedBox.shrink();

  Offset position = box.localToGlobal(Offset.zero);
  double buttonLeft = position.dx;
  double buttonBottom = position.dy + box.size.height;
  double buttonWidth = box.size.width;
  double screenWidth = MediaQuery.of(context).size.width;

  return Positioned(
    top: buttonBottom + 5,
    right: screenWidth - (buttonLeft + buttonWidth), 
      child: Material(
        elevation: 4,
        color: const Color.fromARGB(255, 253, 197, 0),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          constraints: const BoxConstraints(
            minWidth: 150,
            maxWidth: 300,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: utilDropdownOptions.map((dropdownOption) {
              return GestureDetector(
                onTap: () {
                  if (dropdownOption['title'] == 'Day End') {
                    Navigator.pushReplacementNamed(context, '/day_end_utils');
                  }
                  if (dropdownOption['title'] == 'DataSynch') {
                    Navigator.pushReplacementNamed(context, '/data_synch');
                  }
                  if (dropdownOption['title'] == 'BOM') {
                    Navigator.pushReplacementNamed(context, '/bom');
                  }
                  if (dropdownOption['title'] == 'Items') {
                    Navigator.pushReplacementNamed(context, '/items');
                  }
                  if (dropdownOption['title'] == 'Carting Charges') {
                    Navigator.pushReplacementNamed(context, '/carting_charges');
                  }
                  if (dropdownOption['title'] == 'HO Customer') {
                    Navigator.pushReplacementNamed(context, '/ho_customer');
                  }
                  if (dropdownOption['title'] == 'Sets') {
                    Navigator.pushReplacementNamed(context, '/sets');
                  }
                  if (dropdownOption['title'] == 'Batch Label') {
                    Navigator.pushReplacementNamed(context, '/batch_label');
                  }
                  setState(() {
                    expandedStates[dropdownOption['title']] =
                    !(expandedStates[dropdownOption['title']] ?? false);
                  });

                  if (dropdownOption['subOptions'].isEmpty) {
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
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      trailing: dropdownOption['subOptions'].isNotEmpty
                          ? Icon(
                          expandedStates[dropdownOption['title']] ?? false
                              ? Icons.arrow_drop_up
                              : Icons.arrow_drop_down)
                          : null,
                    ),
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

  Widget _buildDropdownBelowReports() {
    RenderBox? box =
    reportButtonKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return const SizedBox.shrink();

  Offset position = box.localToGlobal(Offset.zero);
  double buttonLeft = position.dx;
  double buttonBottom = position.dy + box.size.height;
  double buttonWidth = box.size.width;
  double screenWidth = MediaQuery.of(context).size.width;

  return Positioned(
    top: buttonBottom + 5,
    right: screenWidth - (buttonLeft + buttonWidth), 
      child: Material(
        elevation: 4,
        color: const Color.fromARGB(255, 253, 197, 0),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          constraints: const BoxConstraints(
            minWidth: 150,
            maxWidth: 300,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: reportsDropdownOptions.map((dropdownOption) {
              return GestureDetector(
                onTap: () {
                  if (dropdownOption['title'] == 'Day Rate') {
                    Navigator.pushReplacementNamed(context, '/day_rate');
                  }
                  if (dropdownOption['title'] == 'Stock') {
                    Navigator.pushReplacementNamed(context, '/stock');
                  }
                  if (dropdownOption['title'] == 'Ledger') {
                    Navigator.pushReplacementNamed(context, '/ledger');
                  }
                  if (dropdownOption['title'] == 'Opening Balance') {
                    Navigator.pushReplacementNamed(context, '/opening_balance');
                  } else {
                    setState(() {
                      expandedStates[dropdownOption['title']] =
                      !(expandedStates[dropdownOption['title']] ?? false);
                    });
                  }

                  if (dropdownOption['subOptions'].isEmpty) {
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
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      trailing: dropdownOption['subOptions'].isNotEmpty
                          ? Icon(
                          expandedStates[dropdownOption['title']] ?? false
                              ? Icons.arrow_drop_up
                              : Icons.arrow_drop_down)
                          : null,
                    ),
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
                              if (subOption == 'Day Reports') {
                                Navigator.pushReplacementNamed(context, '/day_reports');
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

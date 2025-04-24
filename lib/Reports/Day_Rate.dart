import 'dart:async';
import 'package:abis2/main.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:abis2/login_handling/login.dart';
import 'package:abis2/api_handling/DayRateReportAPI.dart';
import 'package:abis2/api_handling/BusinessDayAPI.dart';
import 'package:abis2/api_handling/BusinessChannelAPI.dart';

class DayRatePage extends StatefulWidget {
  const DayRatePage({super.key});

  @override
  State<DayRatePage> createState() => _DayRateScreenState();
}

class _DayRateScreenState extends State<DayRatePage> {
  String? selectedButton;

  double menuFontSize = 20; // billing
  FontWeight menuFontWeight = FontWeight.bold;
  String menuFontFamily = 'Times New Roman';

  double menubarFontSize = 20.0; // billing
  FontWeight menubarFontWeight = FontWeight.bold;
  String menubarFontFamily = 'Poppins';

  double groupFontSize = 10.0; //pos
  FontWeight groupFontWeight = FontWeight.bold;
  String groupFontFamily = 'Times New Roman';

  String currentTime = DateFormat('hh:mm a').format(DateTime.now());
  String? businessDate;

  Timer? timer;

  late Future<List<Map<String, dynamic>>> _dayRateData;

  List<String> businessChannels = [];

  String selectedBusinessChannels = 'VAN';

  @override
  void initState() {
    super.initState();
    startTimer();
    fetchBusinessDate();
    fetchBusinessChannels();
    fetchDayRateData();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void fetchBusinessDate() async {
    businessDate = await BusinessDayAPI.fetchBusinessDate(BearerToken, loginBranchId);
  }

  void fetchDayRateData() {
    setState(() {
      // Clear the existing data first
      _dayRateData = Future.value([]);
    });

    // Then fetch new data from API
    Future.delayed(Duration.zero, () {
      setState(() {
        _dayRateData = DayRateReportAPI.fetchDayRateReportByChannel(
            loginBranchId, selectedBusinessChannels == "VAN" ? "VNBIN" : "MCBIN", selectedBusinessChannels, BearerToken);
      });
    });
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() {
        currentTime = DateFormat('hh:mm a').format(DateTime.now());
      });
    });
  }

  Future<void> fetchBusinessChannels() async {
    try {
      final codes = await BusinessChannelAPI.fetchBusinessChannelCodes(
          BearerToken, loginBranchId);
      setState(() {
        businessChannels = codes;
      });
    } catch (e) {
      print("Error fetching business channels: $e");
    }
  }

  DateTime? selectedDate;

  String _getMonthName(int month) {
    const months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December"
    ];
    return months[month - 1];
  }

  int _sortColumnIndex = 0;
  bool _isAscending = true;

  void _sort<T>(Comparable<T> Function(Map<String, dynamic> dayRate) getField,
      int columnIndex, bool ascending) {
    _dayRateData = _dayRateData.then((list) {
      list.sort((a, b) {
        final aValue = getField(a);
        final bValue = getField(b);
        return ascending
            ? Comparable.compare(aValue, bValue)
            : Comparable.compare(bValue, aValue);
      });
      return list;
    });

    _sortColumnIndex = columnIndex;
    _isAscending = ascending;
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
                        '$businessDate',
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
                        "$loginBranchId, $loginBranchName",
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
                          } else if ([
                            "Stock",
                            "Logistics",
                            "Finance",
                            "HR",
                            "Utils",
                            "Reports"
                          ].contains(option)) {
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
                      'Day Rate',
                      style: TextStyle(
                          fontSize: menubarFontSize + 12,
                          fontWeight: menubarFontWeight,
                          fontFamily: menubarFontFamily),
                    ),
                    const SizedBox(width: 270),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedButton = 'Print';
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor:
                            const Color.fromARGB(255, 215, 214, 217),
                        side: BorderSide(
                          color: selectedButton == 'Print'
                              ? const Color.fromRGBO(0, 0, 0, 0.2)
                              : Colors.transparent,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Print',
                            style: TextStyle(
                              fontSize: menubarFontSize,
                              fontWeight: menubarFontWeight,
                              fontFamily: menubarFontFamily,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.print, size: 20),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedButton = 'Export';
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor:
                            const Color.fromARGB(255, 215, 214, 217),
                        side: BorderSide(
                          color: selectedButton == 'Export'
                              ? const Color.fromRGBO(0, 0, 0, 0.2)
                              : Colors.transparent,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Export',
                            style: TextStyle(
                              fontSize: menubarFontSize,
                              fontWeight: menubarFontWeight,
                              fontFamily: menubarFontFamily,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.file_upload, size: 20),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, "/");

                        setState(() {
                          selectedButton = 'Close';
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: selectedButton == 'Close'
                            ? Colors.white
                            : Colors.black,
                        backgroundColor: selectedButton == 'Close'
                            ? const Color.fromARGB(255, 254, 0, 0)
                            : const Color(0xFFFF3333),
                        // Text color
                        side: BorderSide(
                          color: selectedButton == 'Close'
                              ? Colors.yellow
                              : Colors.transparent,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                      ),
                      child: Text('Close',
                          style: TextStyle(
                              fontSize: menubarFontSize,
                              fontWeight: menubarFontWeight,
                              fontFamily: menubarFontFamily)),
                    ),
                  ],
                ),
              ),
              Expanded(
                  child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    /*Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      // Center the Row
                      children: [
                        // "Business Date:" Text (Black text, White Background)
                        const Text(
                          "Business Date: ",
                          style: TextStyle(
                              color: Colors.black, // Black font
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Times New Roman"),
                        ),

                        // Selected Date Container (Blue Background, White Text)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(4, 28, 68, 1),
                            // Dark Blue Background
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            selectedDate != null
                                ? '${selectedDate!.day} ${_getMonthName(selectedDate!.month)}, ${selectedDate!.year}'
                                : 'Select Date',
                            style: const TextStyle(
                              color: Colors.white, // White text
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),
                        // Space between date and icon

                        // Calendar Icon Button (Yellow Background, Black Icon)
                        GestureDetector(
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: selectedDate ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );

                            if (pickedDate != null &&
                                pickedDate != selectedDate) {
                              setState(() {
                                selectedDate = pickedDate;
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Color.fromRGBO(253, 197, 0, 1),
                              // Yellow background
                              shape: BoxShape.circle, // Circular shape
                            ),
                            child: const Icon(
                              Icons.calendar_today,
                              color: Colors.black, // Black icon color
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 1,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 2, 9, 106),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Rate Report',
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
                          flex: 1,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 2, 9, 106),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Min. Qty Report',
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
                          flex: 1,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 2, 9, 106),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Day Rates',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                    ),
                    const SizedBox(height: 10),*/
                    Row(
                      children: [
                        Flexible(
                          flex: businessChannels.length,
                          child: Container(
                            height: 70,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              border: Border.all(color: Colors.grey.shade400),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: businessChannels.map((button) {
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedBusinessChannels = button;
                                    });
                                    fetchDayRateData();
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 5),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 120, vertical: 18),
                                    decoration: BoxDecoration(
                                      color: selectedBusinessChannels == button
                                          ? const Color.fromARGB(255, 2, 9, 106)
                                          : Colors.grey.shade300,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      button,
                                      style: TextStyle(
                                        fontSize: groupFontSize,
                                        fontWeight: groupFontWeight,
                                        fontFamily: groupFontFamily,
                                        color:
                                            selectedBusinessChannels == button
                                                ? Colors.white
                                                : Colors.black,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          DataTableTheme(
                            data: DataTableThemeData(
                              headingRowColor: WidgetStateProperty.all(
                                  const Color.fromRGBO(4, 28, 68, 0.9)),
                              headingTextStyle:
                                  const TextStyle(color: Colors.white),
                            ),
                            child: FutureBuilder<List<Map<String, dynamic>>>(
                              future: _dayRateData,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                      child: CircularProgressIndicator());
                                } else if (snapshot.hasError) {
                                  return Center(
                                      child: Text("Error: ${snapshot.error}"));
                                } else if (!snapshot.hasData ||
                                    snapshot.data!.isEmpty) {
                                  return Center(
                                      child: Text("No dayRate available"));
                                }

                                final dayRateList = snapshot.data!;

                                return DataTable(
                                  border: TableBorder.all(color: Colors.grey),
                                  sortColumnIndex: _sortColumnIndex,
                                  sortAscending: _isAscending,
                                  columns: [
                                    DataColumn(
                                      label: Text('ItemCode'),
                                      onSort: (columnIndex, ascending) {
                                        _sort<String>(
                                            (dayRate) => dayRate["ItemID"],
                                            columnIndex,
                                            ascending);
                                      },
                                    ),
                                    DataColumn(
                                      label: Text('ItemName'),
                                      onSort: (columnIndex, ascending) {
                                        _sort<String>(
                                            (dayRate) => dayRate["ItemName"],
                                            columnIndex,
                                            ascending);
                                      },
                                    ),
                                    DataColumn(
                                      label: Text('Rate'),
                                      numeric: true,
                                      onSort: (columnIndex, ascending) {
                                        _sort<num>(
                                            (dayRate) => dayRate["Rate"] ?? 0,
                                            columnIndex,
                                            ascending);
                                      },
                                    ),
                                    DataColumn(
                                      label: Text('CategoryName'),
                                      onSort: (columnIndex, ascending) {
                                        _sort<String>(
                                            (dayRate) =>
                                                dayRate["CategoryName"] ?? "",
                                            columnIndex,
                                            ascending);
                                      },
                                    ),
                                  ],
                                  rows: dayRateList.map((dayRate) {
                                    return DataRow(cells: [
                                      DataCell(Text(dayRate["ItemID"] ?? "")),
                                      DataCell(Text(dayRate["ItemName"] ?? "")),
                                      DataCell(Text(
                                          dayRate["Rate"]?.toString() ?? "0")),
                                      DataCell(
                                          Text(dayRate["CategoryName"] ?? "")),
                                    ]);
                                  }).toList(),
                                );
                              },
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
        if (showDropdown && selectedMenu == 'Utils') _buildDropdownBelowUtils(),
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
  String selectedMenu = 'Reports';
  bool showDropdown = false;

  final List<String> menuOptions = [
    'Billing',
    'Stock',
    /*'Logistics',
    'Finance',
    'HR',
    'Utils',*/
    'Reports',
    'Exit',
  ];

  final List<Map<String, dynamic>> stockDropdownOptions = [
    /* {'title': 'Indent', 'subOptions': []},
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
    },*/
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
    /*{'title': 'Ledger', 'subOptions': []},
    {
      'title': 'Day Reports',
      'subOptions': ['Day Reports']
    },
    {'title': 'Opening Balance', 'subOptions': []},*/
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
                  if (dropdownOption['title'] == 'Bin Transfer') {
                    Navigator.pushReplacementNamed(context, '/bin_transfer');
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
                    Navigator.pushReplacementNamed(
                        context, '/ib_branch_transfer');
                  }
                  if (dropdownOption['title'] == 'HO Transfer') {
                    Navigator.pushReplacementNamed(context, '/ho_transfer');
                  }
                  if (dropdownOption['title'] == 'Payments') {
                    Navigator.pushReplacementNamed(
                        context, '/finance_payments');
                  }
                  if (dropdownOption['title'] == 'Opening Receivable') {
                    Navigator.pushReplacementNamed(
                        context, '/opening_receivable');
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
                              if (subOption == 'From Silak Customer') {
                                Navigator.pushReplacementNamed(
                                    context, '/from_silak_customer');
                              }
                              if (subOption == 'From HO Customer') {
                                Navigator.pushReplacementNamed(
                                    context, '/from_ho_customer');
                              }
                              if (subOption == 'From Other Branch') {
                                Navigator.pushReplacementNamed(
                                    context, '/from_other_branch');
                              }
                              if (subOption == 'Misc. Collections') {
                                Navigator.pushReplacementNamed(
                                    context, '/misc_collection');
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
                    Navigator.pushReplacementNamed(
                        context, '/opening_attendance');
                  }
                  if (dropdownOption['title'] == 'Day End Attendance') {
                    Navigator.pushReplacementNamed(
                        context, '/day_end_attendance');
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
                                Navigator.pushReplacementNamed(
                                    context, '/day_reports');
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
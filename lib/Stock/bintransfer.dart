import 'dart:async';
import 'package:abis2/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:abis2/api_handling/FromBinAPI.dart';
import 'package:abis2/login_handling/login.dart';
import 'package:abis2/api_handling/AllItemListAPI.dart';
import 'package:abis2/api_handling/FetchStockAPI.dart';
import 'package:abis2/api_handling/InsertBinAPI.dart';
import 'package:abis2/api_handling/ItemDetailsAPI.dart';
import 'package:abis2/api_handling/BusinessDayAPI.dart';

class BinTransferPage extends StatefulWidget {
  const BinTransferPage({super.key});

  @override
  State<BinTransferPage> createState() => _BinTransferScreenState();
}

class _BinTransferScreenState extends State<BinTransferPage> {
  String? selectedButton;

  double menuFontSize = 20; // billing
  FontWeight menuFontWeight = FontWeight.bold;
  String menuFontFamily = 'Times New Roman';

  double menubarFontSize = 20.0; // billing
  FontWeight menubarFontWeight = FontWeight.bold;
  String menubarFontFamily = 'Poppins';

  String currentTime = DateFormat('hh:mm a').format(DateTime.now());
  String? businessDate; 
  Timer? timer;

  TextEditingController _dateController = TextEditingController();

  List<Map<String, dynamic>> _bins = [];
  String? _selectedFromBinID;
  String? _selectedToBinID;

  bool _isItemButtonEnabled = true;
  bool _isDayEndButtonEnabled = true;


  List<Map<String, dynamic>> items = [];
  List<Map<String, dynamic>> batchNumbers = [];
  List<Map<String, dynamic>> itemTableList = [];
  String selectedItemName = "Item Name";
  String selectedItemID = "";

  bool selectAll = false;
  int? selectedRowIndex;

  TextEditingController batchNoController = TextEditingController();
  TextEditingController stockController = TextEditingController();
  double StockQty = 0.0;

  TextEditingController kgsController = TextEditingController();
  TextEditingController nosController = TextEditingController();
  TextEditingController remarksController = TextEditingController();
  List<bool> selectedRows = [];

  @override
  void initState() {
    super.initState();
    _loadBins();
    startTimer();
    fetchBusinessDate();
    fetchBusinessDate2();

  }

  void fetchBusinessDate2() async {
    businessDate =
        await BusinessDayAPI.fetchBusinessDate(BearerToken,loginBranchId);
  }

  void fetchBusinessDate() async {
    String bearerToken = BearerToken;
    String branchId = loginBranchId;
    String? businessDate =
        await BusinessDayAPI.fetchBusinessDate(bearerToken, branchId);

    if (businessDate != null) {
      setState(() {
        _dateController.text = businessDate;
      });
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    _dateController.dispose();
    super.dispose();
  }

  ValueNotifier<bool> isKgsValid = ValueNotifier(true);
  ValueNotifier<bool> isNosValid = ValueNotifier(true);

  void validateInput(
      TextEditingController controller, ValueNotifier<bool> validator) {
    final double? value = double.tryParse(controller.text);
    if (value != null && value > StockQty) {
      validator.value = false;
    } else {
      validator.value = true;
    }
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() {
        currentTime = DateFormat('hh:mm a').format(DateTime.now());
      });
    });
  }

  Future<void> _loadBins() async {
    List<Map<String, dynamic>> bins =
        await FromBinAPI.fetchBins(loginBranchId, BearerToken);

    setState(() {
      _bins = bins.toList();
    });
  }

  void _fetchItems() async {
    setState(() {
      items = []; // Clear current items
    });

    try {
      var fetchedItems = await ItemStockAPI.fetchItemStock(
        _selectedFromBinID!,
        loginBranchId,
        _selectedFromBinID == "VNBIN" ? "VAN" : "MOC",
        "ALL",
        "ALL",
        BearerToken,
      );

      if (fetchedItems != null && fetchedItems.isNotEmpty) {
        setState(() {
          items = fetchedItems;
        });
      } else {
        _showNoItemsPopup(); // Show popup if no items found
      }
    } catch (error) {
      print('Error fetching items: $error');
    }
  }

  void _showNoItemsPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          title: const Text('No Items Found'),
          content:
              const Text('There are no items available in the selected bin.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showItemPopup() {
    if (items.isEmpty) {
      print('No items available.');
      return;
    }

    TextEditingController searchController = TextEditingController();
    ValueNotifier<List<Map<String, dynamic>>> filteredItems = ValueNotifier(
      items
          .where(
              (item) => (item["StockQty"] > 0 /*&& item["StockAltQty"] >= 0*/))
          .toList(),
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Select an Item',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(
                        width: 150,
                        child: TextField(
                          controller: searchController,
                          onChanged: (query) {
                            filteredItems.value = items.where((item) {
                              String itemName =
                                  item['ItemName'].toString().toLowerCase();
                              return !itemName.startsWith('combo') &&
                                  itemName.replaceAll(' ', '').contains(
                                      query.replaceAll(' ', '').toLowerCase());
                            }).toList();
                          },
                          decoration: InputDecoration(
                            hintText: 'Search...',
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: const Icon(Icons.search),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ValueListenableBuilder<List<Map<String, dynamic>>>(
                      valueListenable: filteredItems,
                      builder: (context, filtered, _) {
                        return SingleChildScrollView(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              double buttonSize =
                                  (constraints.maxWidth - 32) / 4 - 16;
                              return Wrap(
                                spacing: 16.0,
                                runSpacing: 16.0,
                                children: filtered.map((item) {
                                  String batchNumber = item['BatchNumber'] ??
                                      '0'; // Default to '0' if null
                                  String itemName = item['ItemName'];

                                  return SizedBox(
                                    width: buttonSize,
                                    height: buttonSize + 50,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        minimumSize:
                                            Size(buttonSize, buttonSize),
                                        backgroundColor: const Color.fromARGB(
                                            255, 253, 197, 0),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      onPressed: () {
                                        selectedItemName = itemName;
                                        selectedItemID = item['ItemID'];
                                        batchNoController.text =
                                            batchNumber; // Set batch number
                                        stockController.text =
                                            item['StockQty'].toString();
                                        StockQty = item['StockQty'];

                                        print("Item Name : $selectedItemName");
                                        print("Item ID : $selectedItemID");
                                        print(
                                            "Batch Number : ${batchNoController.text}");
                                        print("Stock Quantity : $StockQty");

                                        fetchAndSetItemDetails(selectedItemID);
                                        Navigator.pop(context);
                                      },
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          if (batchNumber !=
                                              '0') // Only show if batch number exists
                                            Text(
                                              batchNumber,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          Text(
                                            itemName,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Close',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Map<String, dynamic>? selectedItemDetails;
  final FocusNode quantityFocusNode = FocusNode();
  final FocusNode weightFocusNode = FocusNode();

  bool selectedAltQtyEnabled = false;
  bool selectedSellByWeight = false;
  bool selectedBatchEnabled = false;

  void fetchAndSetItemDetails(String itemId) async {
    final itemDetails =
        await ItemDetailsAPI.fetchItemDetails(itemId, BearerToken);

    if (itemDetails != null) {
      setState(() {
        selectedItemDetails = itemDetails;

        selectedAltQtyEnabled = itemDetails['AltQtyEnabled'];
        selectedSellByWeight = itemDetails['SellByWeight'];
        selectedBatchEnabled = itemDetails['BatchEnabled'];

        kgsController.clear();
        nosController.clear();
      });

      updateFocus();
    } else {
      print('Failed to fetch item details.');
    }
  }

  bool isNumberTextFieldEnabled() {
    if (selectedItemName == 'Item Name') {
      return false;
    }
    if (!selectedSellByWeight ||
        (selectedAltQtyEnabled && selectedSellByWeight)) {
      return true;
    }

    return false;
  }

  bool isWeightTextFieldEnabled() {
    if (selectedItemName == '') {
      return false;
    }

    if (selectedSellByWeight ||
        (selectedAltQtyEnabled && selectedSellByWeight)) {
      return true;
    }

    return false;
  }

  bool isBatchTextFieldEnabled() {
    return selectedBatchEnabled;
  }

  void updateFocus() {
    if (!mounted) return; // Ensure widget is still active

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        bool isQuantityEnabled = isNumberTextFieldEnabled();
        bool isWeightEnabled = isWeightTextFieldEnabled();

        // Clear the focus first
        FocusScope.of(context).unfocus();

        // Set the correct focus
        if (isQuantityEnabled && !isWeightEnabled) {
          FocusScope.of(context).requestFocus(quantityFocusNode);
        } else if (isWeightEnabled && !isQuantityEnabled) {
          FocusScope.of(context).requestFocus(weightFocusNode);
        }
      });
    });
  }

  void onRowSelected(int index) {
    setState(() {
      selectedRowIndex = index;
      var item = itemTableList[index];

      selectedItemID = item["itemID"];
      selectedItemName = item["itemName"];
      batchNoController.text = item["batchNumber"] ?? '';
      nosController.text = item["nos"].toString();
      kgsController.text = item["kgs"].toString();
      StockQty = item["stockQty"];
      stockController.text = item["stockQty"].toString();
      selectedSellByWeight = item["sellByWeight"];
      selectedAltQtyEnabled = item["altQtyEnabled"];
      selectedBatchEnabled = item["batchEnabled"];
    });
  }

  void onRowTapped(int index) {
    setState(() {
      selectedRowIndex = index;
      var item = itemTableList[index];

      selectedItemID = item["itemID"];
      selectedItemName = item["itemName"];
      batchNoController.text = item["batchNumber"] ?? '';
      nosController.text = item["nos"].toString();
      kgsController.text = item["kgs"].toString();
      StockQty = item["stockQty"];
      stockController.text = item["stockQty"].toString();
      selectedSellByWeight = item["sellByWeight"];
      selectedAltQtyEnabled = item["altQtyEnabled"];
      selectedBatchEnabled = item["batchEnabled"];
    });
  }

  void updateTable() {
    if (selectedItemID.isNotEmpty) {
      double enteredKgs = double.tryParse(kgsController.text) ?? 0;
      double enteredNos = double.tryParse(nosController.text) ?? 0;

      if (enteredKgs > StockQty || enteredNos > StockQty) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Invalid Quantity"),
            content: Text("Qty cannot be more than $StockQty"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
        );
        return;
      }

      setState(() {
        if (selectedRowIndex != null) {
          // Update existing row
          itemTableList[selectedRowIndex!] = {
            "lineNo": itemTableList[selectedRowIndex!]["lineNo"],
            // Keep the same line number
            "itemID": selectedItemID,
            "batchNumber":
                batchNoController.text.isNotEmpty ? batchNoController.text : "",
            "itemName": selectedItemName,
            "nos": nosController.text.isNotEmpty ? nosController.text : "0",
            "kgs": kgsController.text.isNotEmpty ? kgsController.text : "0",
            "stockQty": StockQty,
            "sellByWeight": selectedSellByWeight,
            "altQtyEnabled": selectedAltQtyEnabled,
            "batchEnabled": selectedBatchEnabled,
          };
          selectedRowIndex = null; // Reset selection after update
        } else {
          // Add new row
          int lineNo = itemTableList.length + 1;
          String formattedLineNo = lineNo.toString().padLeft(3, '0');

          itemTableList.add({
            "lineNo": formattedLineNo,
            "itemID": selectedItemID,
            "batchNumber":
                batchNoController.text.isNotEmpty ? batchNoController.text : "",
            "itemName": selectedItemName,
            "nos": nosController.text.isNotEmpty ? nosController.text : "0",
            "kgs": kgsController.text.isNotEmpty ? kgsController.text : "0",
            "stockQty": StockQty,
            "sellByWeight": selectedSellByWeight,
            "altQtyEnabled": selectedAltQtyEnabled,
            "batchEnabled": selectedBatchEnabled,
          });

          selectedRows.add(false);
        }
        resetFields();
      });
    }
  }

  void resetFields() {
    setState(() {
      selectedRowIndex = null; // Reset selection when clearing fields
      selectedItemName = "Item Name";
      selectedItemID = "";
      batchNoController.clear();
      kgsController.clear();
      nosController.clear();
      stockController.clear();
      StockQty = 0;
      selectedAltQtyEnabled = false;
      selectedSellByWeight = false;
      selectedBatchEnabled = false;
    });
  }

  void deleteSelectedRows() {
    setState(() {
      List<Map<String, dynamic>> remainingItems = [];
      List<bool> remainingSelections = [];

      for (int i = 0; i < itemTableList.length; i++) {
        if (!selectedRows[i]) {
          remainingItems.add(itemTableList[i]);
          remainingSelections.add(false);
        }
      }

      // Renumber line numbers
      for (int i = 0; i < remainingItems.length; i++) {
        remainingItems[i]["lineNo"] = (i + 1).toString().padLeft(3, '0');
      }

      itemTableList = remainingItems;
      selectedRows = remainingSelections;
    });
  }

  void handleDayEnd() async {
    List<Map<String, dynamic>> newItemTable = [];

    List<Future<Map<String, dynamic>>> fetchTasks = items.map((item) async {
      final itemId = item["ItemID"];

      final itemDetails =
          await ItemDetailsAPI.fetchItemDetails(itemId, BearerToken);

      return {
        "lineNo": '',
        "itemID": itemId,
        "batchNumber": item["BatchNumber"] ?? '',
        "itemName": item["ItemName"],
        "nos": itemDetails?['SellByWeight'] == false ? item["StockQty"] : 0,
        "kgs": itemDetails?['SellByWeight'] == true ? item["StockQty"] : 0,
        "stockQty": item["StockQty"] ?? 0,
        "sellByWeight": itemDetails?['SellByWeight'] ?? false,
        "altQtyEnabled": itemDetails?['AltQtyEnabled'] ?? false,
        "batchEnabled": itemDetails?['BatchEnabled'] ?? false,
      };
    }).toList();

    final itemRows = await Future.wait(fetchTasks);

    // Add line numbers
    for (int i = 0; i < itemRows.length; i++) {
      itemRows[i]["lineNo"] = (i + 1).toString().padLeft(3, '0');
    }

    setState(() {
      itemTableList = itemRows;
      selectedRows = List.generate(itemRows.length, (_) => false);
    });
  }

  void sendBinTransfer(BuildContext context) async {
    if (_selectedFromBinID == null ||
        _selectedToBinID == null ||
        itemTableList.isEmpty) {
      await showMessagePopup(context, "Please fill all required fields.");
      return;
    }

    if (_dateController.text.isEmpty) {
      await showMessagePopup(context, "Business date is not set.");
      return;
    }

    try {
      List<String> dateParts = _dateController.text.split("-");
      DateTime businessDate = DateTime(
        int.parse(dateParts[2]),
        int.parse(dateParts[1]),
        int.parse(dateParts[0]),
      );

      String formattedDate =
          "${businessDate.toIso8601String().split('T')[0]}T00:00:00.000Z";

      List<Map<String, dynamic>> detailsList = [];

      for (int i = 0; i < itemTableList.length; i++) {
        if (selectedRows[i]) {
          var item = itemTableList[i];
          double kgs = double.tryParse(item["kgs"].toString()) ?? 0;
          double nos = double.tryParse(item["nos"].toString()) ?? 0;

          detailsList.add({
            "LineNumber": (detailsList.length + 1).toString().padLeft(3, '0'),
            "ItemID": item["itemID"].toString(),
            "BatchNumber": item["batchNumber"].toString(),
            "Qty": kgs != 0 ? kgs : nos,
            "AltQty": 0.0,
            "DML": "I"
          });
        }
      }

      print(detailsList);

      if (detailsList.isEmpty) {
        await showMessagePopup(
            context, "Please select at least one row to submit.");
        return;
      }

      String responseMessage = await InsertBinAPI.insertBinTransfer(
        branchID: loginBranchId,
        binTransferDate: formattedDate,
        remarks: remarksController.text,
        fromBinID: _selectedFromBinID!,
        toBinID: _selectedToBinID!,
        createdUserId: "",
        transType: "BINTRF",
        details: detailsList,
        bearerToken: BearerToken,
      );

      await showMessagePopup(context, responseMessage);
      Navigator.pushReplacementNamed(context, '/bin_transfer');
    } catch (e, stackTrace) {
      debugPrint("Error occurred: $e");
      debugPrint("Stack trace: $stackTrace");
      await showMessagePopup(context, "Error: $e");
    }
  }

  Future<void> showMessagePopup(BuildContext context, String message) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Bin Transfer"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
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
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
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
                ),
              ],
            ),
          ),
          body: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                color: const Color.fromARGB(255, 236, 236, 236),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      const SizedBox(width: 5),
                      Text(
                        'Bin Transfer',
                        style: TextStyle(
                            fontSize: 28,
                            fontWeight: menubarFontWeight,
                            fontFamily: menubarFontFamily),
                      ),
                      const SizedBox(width: 300),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selectedButton = 'New';
                          });
                          Navigator.pushReplacementNamed(
                              context, '/bin_transfer');
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
                        child: Text('New',
                            style: TextStyle(
                                fontSize: menubarFontSize,
                                fontWeight: menubarFontWeight,
                                fontFamily: menubarFontFamily)),
                      ),
                      /*const SizedBox(width: 10),
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
                            color: selectedButton == 'View'
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
                      ),*/
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: selectedRows.contains(true)
                            ? () {
                          setState(() {
                            selectedButton = 'Save';
                          });

                          showDialog(
                            context: context,
                            builder: (BuildContext dialogContext) {
                              return AlertDialog(
                                title: Text('Confirm Transfer'),
                                content: Text('Do you want to transfer the bin?'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(dialogContext).pop(); // Close the dialog
                                    },
                                    child: Text('No'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(dialogContext).pop(); // Close the dialog
                                      sendBinTransfer(context); // Call the save function
                                    },
                                    child: Text('Yes'),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                            : null, // Disabled when no row is selected
                        style: ElevatedButton.styleFrom(
                          foregroundColor: selectedButton == 'Save' ? Colors.white : Colors.black,
                          backgroundColor: selectedRows.contains(true)
                              ? (selectedButton == 'Save'
                              ? const Color(0xFF02720F)
                              : const Color(0xFF02A515))
                              : Colors.grey,
                          side: BorderSide(
                            color: selectedButton == 'Save'
                                ? Colors.yellow
                                : Colors.transparent,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        ),
                        child: Text(
                          'Save',
                          style: TextStyle(
                            fontSize: menubarFontSize,
                            fontWeight: menubarFontWeight,
                            fontFamily: menubarFontFamily,
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(
                              context, "/bin_transfer");
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
              ),
              Expanded(
                  child: SingleChildScrollView(
                child: Column(
                  children: [
                    // const SizedBox(height: 10),
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
                          Row(
                            children: [
                              const SizedBox(height: 8),
                              Expanded(
                                flex: 1,
                                child: TextField(
                                  decoration: InputDecoration(
                                    labelText: 'Doc',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 10,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              // Spacing between fields
                              const Text(
                                "Business Date :",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ), // Spacing between fields
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 1,
                                child: TextField(
                                  controller: _dateController,
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    labelText: 'Select Date',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    suffixIcon: IconButton(
                                      icon: const Icon(Icons.calendar_today),
                                      onPressed: () async {
                                        DateTime? pickedDate =
                                            await showDatePicker(
                                          context: context,
                                          initialDate: DateTime.now(),
                                          firstDate: DateTime(2000),
                                          lastDate: DateTime(2100),
                                        );
                                        if (pickedDate != null) {
                                          String formattedDate =
                                              "${pickedDate.day}-${pickedDate.month}-${pickedDate.year}";
                                          _dateController.text = formattedDate;
                                        }
                                      },
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
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: DropdownButtonFormField<String>(
                                  decoration: InputDecoration(
                                    labelText: 'From Bin',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 10),
                                  ),
                                  items: _bins.map((bin) {
                                    return DropdownMenuItem<String>(
                                      value: bin['BinID'],
                                      child: Text(bin['BinName'] ?? ''),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedFromBinID = value;
                                    });
                                    print(
                                        'Selected Bin ID: $_selectedFromBinID');
                                    _fetchItems();
                                  },
                                  isExpanded: true,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 1,
                                child: DropdownButtonFormField<String>(
                                  decoration: InputDecoration(
                                    labelText: 'To Bin',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 10),
                                  ),
                                  items: [
                                    'OKBIN',
                                  ]
                                      .map((type) => DropdownMenuItem(
                                            value: type,
                                            child: Text(type),
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedToBinID = value;
                                    });
                                    print('Selected Bin ID: $_selectedToBinID');
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: remarksController,
                                  decoration: InputDecoration(
                                    labelText: 'Add Remarks',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 10),
                                  ),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                    //const SizedBox(height: 10),
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
                                flex: 1,
                                child: SizedBox(
                                    height: 50, // Set a fixed height
                                    child: GestureDetector(
                                      onTap: () {},
                                      child: AbsorbPointer(
                                        child: TextField(
                                          enabled: isBatchTextFieldEnabled(),
                                          controller: batchNoController,
                                          decoration: InputDecoration(
                                            labelText: 'Batch',
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 10,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )),
                              ),
                              const SizedBox(width: 10.0),
                              Expanded(
                                flex: 2,
                                child: SizedBox(
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: _isItemButtonEnabled
                                        ? () {
                                      if (_selectedFromBinID == null || _selectedFromBinID!.isEmpty) {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text("BIN not Selected"),
                                            content: const Text("Please select the BIN"),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context),
                                                child: const Text("OK"),
                                              ),
                                            ],
                                          ),
                                        );
                                      } else {
                                        setState(() {
                                          _isDayEndButtonEnabled = false; // Disable the DayEnd button
                                        });
                                        _showItemPopup();
                                      }
                                    }
                                        : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _isItemButtonEnabled
                                          ? const Color.fromARGB(255, 2, 9, 106)
                                          : Colors.grey,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: Text(
                                      selectedItemName,
                                      style: const TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10.0),
                              Expanded(
                                flex: 1,
                                child: SizedBox(
                                    height: 50, // Ensure consistency
                                    child: GestureDetector(
                                      onTap: () {},
                                      child: AbsorbPointer(
                                        child: TextField(
                                          controller: stockController,
                                          decoration: InputDecoration(
                                            labelText: 'Stock Qty',
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 10,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          // Second Row: Wt, Rate, Nos
                          Row(
                            children: [
                              Expanded(
                                child: ValueListenableBuilder<bool>(
                                  valueListenable: isKgsValid,
                                  builder: (context, isValid, child) {
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        TextField(
                                          enabled: isWeightTextFieldEnabled(),
                                          focusNode: weightFocusNode,
                                          keyboardType:
                                              TextInputType.numberWithOptions(
                                                  decimal: true),
                                          controller: kgsController,
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(
                                                RegExp(r'^\d*\.?\d*$')),
                                          ],
                                          decoration: InputDecoration(
                                            labelText: 'Kgs',
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                  color: isValid
                                                      ? Colors.grey
                                                      : Colors.red),
                                            ),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 10),
                                          ),
                                          onChanged: (value) => validateInput(
                                              kgsController, isKgsValid),
                                        ),
                                        if (!isValid)
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 4),
                                            child: Text(
                                              "Cannot be more than $StockQty",
                                              style: const TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 12),
                                            ),
                                          ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ValueListenableBuilder<bool>(
                                  valueListenable: isNosValid,
                                  builder: (context, isValid, child) {
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        TextField(
                                          enabled: isNumberTextFieldEnabled(),
                                          focusNode: quantityFocusNode,
                                          keyboardType:
                                              TextInputType.numberWithOptions(
                                                  decimal: true),
                                          controller: nosController,
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(
                                                RegExp(r'^\d*\.?\d*$')),
                                          ],
                                          decoration: InputDecoration(
                                            labelText: 'Nos',
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                  color: isValid
                                                      ? Colors.grey
                                                      : Colors.red),
                                            ),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 10),
                                          ),
                                          onChanged: (value) => validateInput(
                                              nosController, isNosValid),
                                        ),
                                        if (!isValid)
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 4),
                                            child: Text(
                                              "Cannot be more than $StockQty",
                                              style: const TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 12),
                                            ),
                                          ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(width: 20),
                              SizedBox(
                                width: 100.0,
                                height: 50.0,
                                child: ElevatedButton(
                                  onPressed: _isDayEndButtonEnabled
                                      ? () {
                                    if (_selectedFromBinID == null || _selectedFromBinID!.isEmpty) {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text("BIN not Selected"),
                                          content: const Text("Please select the BIN"),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context),
                                              child: const Text("OK"),
                                            ),
                                          ],
                                        ),
                                      );
                                    } else {
                                      setState(() {
                                        _isItemButtonEnabled = false; // Disable the item button
                                      });
                                      handleDayEnd();
                                    }
                                  }
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _isDayEndButtonEnabled
                                        ? const Color.fromARGB(255, 2, 9, 106)
                                        : Colors.grey,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text(
                                    'DayEnd',
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 15),
                              SizedBox(
                                width: 100.0,
                                height: 50.0,
                                child: ElevatedButton(
                                  onPressed: updateTable,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color.fromARGB(255, 2, 9, 106),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text(
                                    'Update',
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              SizedBox(
                                width: 100.0,
                                height: 50.0,
                                child: ElevatedButton(
                                  onPressed: resetFields,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color.fromARGB(255, 2, 9, 106),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text(
                                    'X',
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          Container(
                            width: double.infinity,
                            height: 250,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade400),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: SingleChildScrollView(
                                child: DataTable(
                                  headingRowColor: WidgetStateProperty.all(
                                      Color.fromARGB(255, 2, 9, 106)),
                                  columns: [
                                    DataColumn(
                                      label: Checkbox(
                                        value: selectAll,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            selectAll = value ?? false;
                                            for (int i = 0;
                                                i < selectedRows.length;
                                                i++) {
                                              selectedRows[i] = selectAll;
                                            }
                                          });
                                        },
                                        side: BorderSide(
                                          color: Color.fromARGB(255, 255, 255,
                                              255), // White border
                                        ),
                                      ),
                                    ),
                                    const DataColumn(
                                        label: Text('Line No.',
                                            style: TextStyle(
                                                color: Color.fromARGB(
                                                    255, 255, 255, 255)))),
                                    const DataColumn(
                                        label: Text('ItemID',
                                            style: TextStyle(
                                                color: Color.fromARGB(
                                                    255, 255, 255, 255)))),
                                    const DataColumn(
                                        label: Text('BatchNumber',
                                            style: TextStyle(
                                                color: Color.fromARGB(
                                                    255, 255, 255, 255)))),
                                    const DataColumn(
                                        label: Text('Item Name',
                                            style: TextStyle(
                                                color: Color.fromARGB(
                                                    255, 255, 255, 255)))),
                                    const DataColumn(
                                        label: Text('Nos',
                                            style: TextStyle(
                                                color: Color.fromARGB(
                                                    255, 255, 255, 255)))),
                                    const DataColumn(
                                        label: Text('Kgs',
                                            style: TextStyle(
                                                color: Color.fromARGB(
                                                    255, 255, 255, 255)))),
                                  ],
                                  rows: List.generate(itemTableList.length,
                                      (index) {
                                    var item = itemTableList[index];
                                    return DataRow(
                                      selected: selectedRowIndex == index,
                                      cells: [
                                        DataCell(
                                          Checkbox(
                                            value: selectedRows[index],
                                            onChanged: (bool? selected) {
                                              setState(() {
                                                selectedRows[index] =
                                                    selected ?? false;
                                                selectAll = selectedRows
                                                    .every((e) => e);
                                              });
                                            },
                                          ),
                                        ),
                                        DataCell(
                                          Text('${item["lineNo"]}'),
                                          onTap: () => onRowTapped(index),
                                        ),
                                        DataCell(
                                          Text(item["itemID"]),
                                          onTap: () => onRowTapped(index),
                                        ),
                                        DataCell(
                                          Text(item["batchNumber"] ?? ''),
                                          onTap: () => onRowTapped(index),
                                        ),
                                        DataCell(
                                          Text(item["itemName"]),
                                          onTap: () => onRowTapped(index),
                                        ),
                                        DataCell(
                                          Text(item["nos"].toString()),
                                          onTap: () => onRowTapped(index),
                                        ),
                                        DataCell(
                                          Text(item["kgs"].toString()),
                                          onTap: () => onRowTapped(index),
                                        ),
                                      ],
                                    );
                                  }),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          // Delete Selected Row Button
                          Center(
                            child: SizedBox(
                              width: 200.0, // Set your desired width
                              height: 50.0, // Set your desired height
                              child: ElevatedButton(
                                onPressed: deleteSelectedRows,
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
  String selectedMenu = 'Stock';
  bool showDropdown = false;

  final List<String> menuOptions = [
    'Billing',
    'Stock',
    //'Logistics',
    //'Finance',
    //'HR',
    //'Utils',
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
    {'title': 'Test', 'subOptions': []},
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
   /* {'title': 'Ledger', 'subOptions': []},
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
    'Test': false,
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
                  } if (dropdownOption['title'] == 'Test') {
                    Navigator.pushReplacementNamed(context, '/test');
                  }  else {
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

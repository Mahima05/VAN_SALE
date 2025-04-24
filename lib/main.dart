import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

//billing import
import 'Billing/New_customer.dart';
import 'Billing/Search_customer.dart';
import 'Billing/Payment_screen.dart';
import 'Billing/ViewPage.dart';
import 'Billing/PrintPage.dart';
import 'Billing/TestPrint.dart';
import 'Billing/Edit_customer.dart';
import 'Billing/NewVehicle.dart';
import 'Billing/Order.dart';

//login import
import 'login_handling/login.dart';

//api imports
import 'api_handling/http_overrides.dart';
import 'package:abis2/api_handling/ItemCategoryAPI.dart';
import 'package:abis2/api_handling/ItemNameAPI.dart';
import 'package:abis2/api_handling/TimeSlotAPI.dart';
import 'package:abis2/api_handling/BusinessChannelAPI.dart';
import 'package:abis2/api_handling/TransactionTypeAPI.dart';
import 'package:abis2/api_handling/CustomerTypeAPI.dart';
import 'package:abis2/api_handling/ItemWeightAPI.dart';
import 'package:abis2/api_handling/SaveBillingAPI.dart';
import 'package:abis2/api_handling/FetchCustomerAddress.dart';
import 'package:abis2/api_handling/CustomerNameAPI.dart';
import 'package:abis2/api_handling/CustomerPhoneAPI.dart';
import 'package:abis2/api_handling/CustomerCodeAPI.dart';
import 'package:abis2/api_handling/ItemPriceAPI.dart';
import 'package:abis2/api_handling/FetchBillAPI.dart';
import 'package:abis2/api_handling/ItemDetailsAPI.dart';
import 'package:abis2/api_handling/DiscountAPI.dart';
import 'package:abis2/api_handling/FetchBillDetailsAPI.dart';
import 'package:abis2/api_handling/FetchStockAPI.dart';
import 'package:abis2/api_handling/BusinessDayAPI.dart';
import 'package:abis2/api_handling/CustomerAddAPI.dart';

//stock imports
import 'package:abis2/Stock/indent.dart';
import 'package:abis2/Stock/conversion/RM_to_RM.dart';
import 'package:abis2/Stock/conversion/dress_to_special.dart';
import 'package:abis2/Stock/conversion/egg_crack.dart';
import 'package:abis2/Stock/conversion/live_stock_adjust.dart';
import 'package:abis2/Stock/conversion/live_to_dress.dart';
import 'package:abis2/Stock/conversion/sp.dress_sp.dress.dart';
import 'package:abis2/Stock/dispatch/consignment_issue.dart';
import 'package:abis2/Stock/dispatch/group_company_sale.dart';
import 'package:abis2/Stock/dispatch/transfer_out.dart';
import 'package:abis2/Stock/gen_material_indent.dart';
import 'package:abis2/Stock/production/de_kitting.dart';
import 'package:abis2/Stock/production/merging.dart';
import 'package:abis2/Stock/production/packaging.dart';
import 'package:abis2/Stock/production_plan/demand_for_pp.dart';
import 'package:abis2/Stock/production_plan/production_plan.dart';
import 'package:abis2/Stock/receiving/consignment_return.dart';
import 'package:abis2/Stock/receiving/franchise_sale_return.dart';
import 'package:abis2/Stock/receiving/gst_transfer_in.dart';
import 'package:abis2/Stock/receiving/receiving.dart';
import 'package:abis2/Stock/stocktake.dart';
import 'package:abis2/Stock/wastage.dart';
import 'package:abis2/Stock/bintransfer.dart';

//logistics import
import 'package:abis2/Logistics/trips.dart';
import 'package:abis2/Logistics/trip_plan.dart';
import 'package:abis2/Logistics/delivery.dart';
import 'package:abis2/Logistics/expenses.dart';
import 'package:abis2/Logistics/day_end.dart';
import 'package:abis2/Logistics/odo_reset.dart';

//finance import
import 'package:abis2/Finance/Bank_Transfer.dart';
import 'package:abis2/Finance/HO_Transfer.dart';
import 'package:abis2/Finance/IB_Branch_Transfer.dart';
import 'package:abis2/Finance/Opening_Receivable.dart';
import 'package:abis2/Finance/Payments.dart';
import 'package:abis2/Finance/Receipts/From_HO_Customer.dart';
import 'package:abis2/Finance/Receipts/From_Other_Branch.dart';
import 'package:abis2/Finance/Receipts/From_Silak_Customer.dart';
import 'package:abis2/Finance/Receipts/Misc_Collections.dart';

// HR import
import 'package:abis2/HR/DayEnd_Attendance.dart';
import 'package:abis2/HR/Leave.dart';
import 'package:abis2/HR/Opening_Attendance.dart';

// Utils import
import 'package:abis2/Utils/Batch_Label.dart';
import 'package:abis2/Utils/BOM.dart';
import 'package:abis2/Utils/Carting_Charges.dart';
import 'package:abis2/Utils/DataSynch.dart';
import 'package:abis2/Utils/Day_End.dart';
import 'package:abis2/Utils/HOCustomer.dart';
import 'package:abis2/Utils/Items.dart';
import 'package:abis2/Utils/Sets.dart';

// reports import

import 'package:abis2/Reports/Day_Rate.dart';
import 'package:abis2/Reports/Ledger.dart';
import 'package:abis2/Reports/Opening_Balance.dart';
import 'package:abis2/Reports/Stock.dart';
import 'package:abis2/Reports/Day Reports/Day_Reports.dart';

String BearerToken = loginBearerToken;
String customerName = '';
String customerID = '';
String customerMobile = '';
String customerCreditLimit = '';
String customerCreditDays = '';
String customerBranchID = "";
String SelectedCustomerType = 'RT';
bool isButtonsLocked = false;

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Horizontal Menu Bar',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        //login pages
        '/login': (context) => const LoginPage(),

        // billing main page
        '/': (context) => const MyHomePage(),

        //billing related pages
        '/new_customer': (context) => const NewCustomerDetailsPage(),
        '/search_customer': (context) => const SearchCustomerDetailsPage(),
        '/edit_customer': (context) => const EditCustomerDetailsPage(),
        '/test': (context) => TestPrint(),
        '/new_vehicle': (context) => const NewVehiclePage(),
        '/order_page': (context) => const OrderPage(),

        //stock page
        '/indent': (context) => const IndentPage(),
        '/wastage': (context) => const WastagePage(),
        '/stocktake': (context) => const StocktakePage(),
        '/gen_material_indent': (context) => const GenMaterialIndentPage(),
        '/bin_transfer': (context) => const BinTransferPage(),

        //stock-receiving
        '/receiving': (context) => const ReceivingPage(),
        '/franchise_sale_returns': (context) => const FranchiseSaleReturn(),
        '/consigment_returns': (context) => const ConsignmentReturn(),
        '/gst_transfer_in': (context) => const GSTtransferIN(),

        //stock-dispatch
        '/transfer_out': (context) => const TransferOut(),
        '/consignment_issue': (context) => const ConsignmentIssue(),
        '/group_company_sale': (context) => const GroupCompanySale(),

        //stock-conversion
        '/live_to_dress': (context) => const LiveToDressPage(),
        '/dress_to_special': (context) => const DressToSpecialPage(),
        '/egg_crack': (context) => const EggCrackPage(),
        '/sp_dress': (context) => const SPDressToSPDressPage(),
        '/live_stock_adjust': (context) => const LiveStockAdjustPage(),
        '/rm_to_rm': (context) => const RMToRMPage(),

        //stock-production-plan
        '/production_plan': (context) => const ProductionPlanPage(),
        '/demand_for_pp': (context) => const DemandForPPPage(),

        //stock-production
        '/packaging': (context) => const PackagingPage(),
        '/merging': (context) => const MergingPage(),
        '/de_kitting': (context) => const DeKittingPage(),

        //logistics
        '/trips': (context) => const TripsPage(),
        '/trip_plan': (context) => const TripPlanPage(),
        '/delivery': (context) => const DeliveryPage(),
        '/day_end': (context) => const DayEndPage(),
        '/expenses': (context) => const ExpensesPage(),
        '/odo_reset': (context) => const OdoResetPage(),

        //finance
        '/bank_transfer': (context) => const BankTransferPage(),
        '/ho_transfer': (context) => const HOTransferPage(),
        '/ib_branch_transfer': (context) => const IBBranchTransferPage(),
        '/opening_receivable': (context) => const OpeningReceivablePage(),
        '/finance_payments': (context) => const PaymentsPage(),

        //finance - receipts
        '/from_ho_customer': (context) => const FromHOCustomerPage(),
        '/from_silak_customer': (context) => const FromSilakCustomerPage(),
        '/from_other_branch': (context) => const FromOtherBranchPage(),
        '/misc_collection': (context) => const MiscCollectionPage(),

        // HR
        '/day_end_attendance': (context) => const DayEndAttendancePage(),
        '/opening_attendance': (context) => const OpeningAttendancePage(),
        '/leave': (context) => const LeavePage(),

        // utils
        '/batch_label': (context) => const BatchLabelPage(),
        '/bom': (context) => const BOMPage(),
        '/carting_charges': (context) => const CartingChargesPage(),
        '/data_synch': (context) => const DataSynchPage(),
        '/day_end_utils': (context) => const DayEndUtilsPage(),
        '/ho_customer': (context) => const HOCustomerPage(),
        '/items': (context) => const ItemsPage(),
        '/sets': (context) => const SetsPage(),

        // reports
        '/day_rate': (context) => const DayRatePage(),
        '/ledger': (context) => const LedgerPage(),
        '/opening_balance': (context) => const OpeningBalancePage(),
        '/stock': (context) => const StockReportsPage(),
        '/day_reports': (context) => const DayReportsPage(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double menuFontSize = 20; // billing
  FontWeight menuFontWeight = FontWeight.bold;
  String menuFontFamily = 'Times New Roman';

  double scrollFontSize = 14.0; // new
  FontWeight scrollFontWeight = FontWeight.bold;
  String scrollFontFamily = 'Times New Roman';

  double groupFontSize = 10.0; //pos
  FontWeight groupFontWeight = FontWeight.bold;
  String groupFontFamily = 'Times New Roman';

  double textFieldFontSize = 16.0; // limit
  FontWeight textFieldFontWeight = FontWeight.bold;
  String textFieldFontFamily = 'Times New Roman';

  double customerFontSize = 12.0; // CD
  FontWeight customerFontWeight = FontWeight.bold;
  String customerFontFamily = 'Times New Roman';

  double deliveryFontSize = 12.0; // DD
  FontWeight deliveryFontWeight = FontWeight.bold;
  String deliveryFontFamily = 'Times New Roman';

  double itemFontSize = 12.0; // ID
  FontWeight itemFontWeight = FontWeight.bold;
  String itemFontFamily = 'Times New Roman';

  // current date and time
  String currentTime = DateFormat('hh:mm a').format(DateTime.now());
  String? businessDate;
  Timer? timer;

  //menu options
  final List<String> scrollOptions = [
    'Save',
    'Cancel',
    'View',
    'Cancel Bill',
    /*'Order'*/
  ];

  bool isBillSaved = false;

  String? selectedScrollOption;

  //customer types
  List<String> customerTypes = [];

  // business channels
  List<String> businessChannels = [];

  String selectedBusinessChannels = 'VAN';

  // customer details
  List<Map<String, dynamic>>? customerDetailsList;
  List<Map<String, dynamic>> customers = [];
  Map<String, dynamic>? selectedAddress;

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
  final TextEditingController CustomerBranchID =
      TextEditingController(text: customerBranchID);

  bool isCustomerLoading = false;

  String addressID = '';
  String customerAddress = '';
  String houseNo = '';
  String altPhone = '';
  String building = '';
  String pincode = '';
  String placeID = '';
  String cityID = '';
  String landmark = '';
  String placeName = '';
  String cityName = '';
  String stateName = '';

  // delivery details
  String selectedDeliveryType = "Takeaway";
  String? selectedTimeSlotId; //if null bhi ho skta
  String? selectedTimeSlotName;

  bool isDeliveryButtonSelected = false;

  List<Map<String, String>> timeSlots = [];

  int deliveryCharges = 0;

  TextEditingController deliveryChargesController = TextEditingController();
  TextEditingController distanceController = TextEditingController();
  TextEditingController locationController = TextEditingController();

  // transaction type
  String? TransactionTypeID;
  String? selectedTransactionSubType;

  List<Map<String, String>> transactionSubTypes = [];

  // item details
  String? ItemID;
  String? ItemName;
  String? ItemTaxCategoryID;
  String? ItemStockGroupID;
  String? ItemFamilyID;
  String selectedItemName = '';
  String? selectedItemType;
  String? selectedItemCategoryID;
  String? selectedItemFamilyId;
  String? selectedItemID;
  int? selectedRowIndex;

  double? minWeight;
  double maxWeight = 0;
  double maxQuantity = 0;
  double ItemDayRate = 0.0;
  String validationMessage = "";
  double discountValue = 0.0;

  double itemStockQty = 0;
  double itemStockAltQty = 0;

  bool isQtyInvalid = false;
  String? qtyErrorText;

  bool isWeightInvalid = false;
  String? weightErrorText;

  List<String> itemTypes = [];
  List<Map<String, dynamic>> selectedItems = [];
  final List<Map<String, dynamic>> itemDetails = [];
  final List<Map<String, dynamic>> stockDetails = [];

  TextEditingController quantityController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController discountController = TextEditingController();

  TextEditingController weightController = TextEditingController();
  TextEditingController batchNoController = TextEditingController();

  final FocusNode quantityFocusNode = FocusNode();
  final FocusNode weightFocusNode = FocusNode();

  bool selectedAltQtyEnabled = false;
  bool selectedSellByWeight = false;
  bool selectedBatchEnabled = false;
  bool isLoading = true;
  bool isOverrideChecked = false;

  // discount & remarks
  String? selectedDiscountType;
  String remarks = "";

  List<Map<String, dynamic>> discounts = [];

  TextEditingController remarksController = TextEditingController();

  // table
  double totalPrice = 0.0;
  double totalItemPrice = 0;
  double totalTax = 0;
  double totalDiscount = 0;
  double subtotal = 0;
  double roundedTotal = 0;
  double taxPercent = 0;

  List<Map<String, dynamic>> itemTableDetails = [];
  List<Map<String, dynamic>> discountedItemDetails = [];
  Set<int> selectedRows = {};
  Map<String, dynamic>? selectedItemDetails;

  // payment
  String paymentMethodId = "";
  String paymentGatewayId = "";
  String paymentGatewayName = "";

  @override
  void initState() {
    super.initState();
    quantityController.addListener(_calculateTotalPrice);
    priceController.addListener(_calculateTotalPrice);
    discountController.addListener(_calculateTotalPrice);
    weightController.addListener(_calculateTotalPrice);
    fetchTimeSlots();
    fetchBusinessChannels();
    fetchTransactionTypes();
    startTimer();
    fetchCustomerTypes();
    fetchBusinessDate();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      updateFocus();
    });
  }

  @override
  void dispose() {
    quantityController.dispose();
    priceController.dispose();
    discountController.dispose();
    weightController.dispose();
    batchNoController.dispose();
    timer?.cancel();
    quantityFocusNode.dispose();
    weightFocusNode.dispose();
    super.dispose();
  }

  void fetchBusinessDate() async {
    businessDate = await BusinessDayAPI.fetchBusinessDate(loginBearerToken, loginBranchId);
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() {
        currentTime = DateFormat('hh:mm a').format(DateTime.now());
      });
    });
  }

  void onScrollOptionSelect(String option) {
    setState(() {
      selectedScrollOption = option;
    });
  }

  void saveBill() async {
    String branchId = loginBranchId;
    String CustomerType = SelectedCustomerType;
    String ChannelType = selectedBusinessChannels;
    String CustomerID = CustomerIDController.text.trim();
    String CustomerName = CustomerNameController.text.trim();
    String CustomerMobile = CustomerMobileController.text.trim();

    // Check if customer ID is missing
    if (CustomerID.isEmpty) {
      // Validate phone number and name
      if (CustomerMobile.length != 10 || CustomerName.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "Please enter a valid 10-digit phone number and customer name.")),
        );
        return;
      }

      // Create new customer
      var customerAddAPI = CustomerAddAPI();
      var createResponse = await customerAddAPI.addCustomerDetails(
        token: loginBearerToken,
        customerCode: "",
        title: "",
        customerName: CustomerName,
        mobile: CustomerMobile,
        email: "",
        houseNo: "",
        building: "",
        customerAddress: "",
        landmark: "",
        pinCode: "",
        cityCode: "",
        areaName: "",
        areaId: "",
      );

      if (createResponse["result"] == 1) {
        // Fetch newly created customer
        await fetchCustomers("", CustomerMobile, "");

        if (customers.isNotEmpty) {
          final newCustomer = customers.first;

          setState(() {
            CustomerIDController.text = newCustomer['custID'] ?? '';
            CustomerNameController.text = newCustomer['customerName'] ?? '';
            CustomerMobileController.text = newCustomer['mobile'] ?? '';

            customerID = newCustomer['custID'] ?? '';
            customerName = newCustomer['customerName'] ?? '';
            customerMobile = newCustomer['mobile'] ?? '';
            customerCreditDays = newCustomer['creditDays']?.toString() ?? '0';
            customerCreditLimit = newCustomer['creditLimit']?.toString() ?? '0';
            customerBranchID = newCustomer['branchID'] ?? "";
          });

          // Set updated values for saving
          CustomerID = customerID;
          CustomerName = customerName;
          CustomerMobile = customerMobile;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    "Customer creation succeeded but could not fetch customer details.")),
          );
          return;
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "Customer creation failed: ${createResponse["description"]}")),
        );
        return;
      }
    }

    print(
        "Branch ID: $branchId, Customer Type: $CustomerType, Channel Type: $ChannelType, "
        "Customer ID: $CustomerID, Customer Name: $CustomerName, Customer Mobile: $CustomerMobile, "
        "Address ID: $addressID, Customer Address: $customerAddress, House No: $houseNo, "
        "Alt Phone: $altPhone, Building: $building, Pincode: $pincode, Place ID: $placeID, "
        "City ID: $cityID, Landmark: $landmark, Place Name: $placeName, City Name: $cityName, "
        "State Name: $stateName, Transaction Type ID: $TransactionTypeID, "
        "Selected Transaction Sub Type: $selectedTransactionSubType, Selected Time Slot ID: $selectedTimeSlotId, ");
    print("Selected Items : $selectedItems");
    print("Selected payment id : $paymentMethodId,"
        "Selected gateway id : $paymentGatewayId, Selected gateway name : $paymentGatewayName, "
        "Remarks : $remarks");

    Map<String, dynamic> response = await SaveBillingAPI.saveBillingData(
        loginBearerToken,
        branchId,
        CustomerType,
        ChannelType,
        CustomerID,
        CustomerName,
        CustomerMobile,
        addressID,
        customerAddress,
        houseNo,
        altPhone,
        building,
        pincode,
        placeID,
        cityID,
        landmark,
        placeName,
        cityName,
        stateName,
        TransactionTypeID,
        selectedTransactionSubType,
        selectedTimeSlotId,
        selectedItems,
        paymentMethodId,
        paymentGatewayId,
        paymentGatewayName,
        deliveryCharges,
        remarks,
        selectedDiscountType);

    if (response["result"] == 1) {
      setState(() {
        isBillSaved = true;
      });

      String businessDate =
          await SaveBillingAPI.getCurrentBusinessDay(loginBearerToken);

// Extract only the date part (YYYY-MM-DD)
      String businessDateOnly = businessDate.split("T")[0];

// Remove dashes to get the required format
      String fromDate = businessDateOnly.replaceAll("-", "");

// Calculate toDate (1 day after fromDate)
      DateTime businessDateTime = DateTime.parse(businessDateOnly);
      DateTime nextBusinessDateTime = businessDateTime.add(Duration(days: 1));
      String toDate =
          "${nextBusinessDateTime.year}${nextBusinessDateTime.month.toString().padLeft(2, '0')}${nextBusinessDateTime.day.toString().padLeft(2, '0')}";

      try {
        List<Map<String, dynamic>> salesData =
            await FetchBillAPI.fetchSalesData(
                branchId, fromDate, selectedBusinessChannels, loginBearerToken);

        // Find the latest sale for the customer based on the highest SaleId
        String latestSaleId = "";

        for (var sale in salesData) {
          if (sale["POSCustomerID"] == CustomerID) {
            String saleId = sale["SaleId"];
            if (latestSaleId.isEmpty || saleId.compareTo(latestSaleId) > 0) {
              latestSaleId = saleId;
            }
          }
        }

        if (latestSaleId.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text("Latest Sale ID not found for this customer.")),
          );
          return;
        }

        // Show print confirmation popup
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Bill Saved"),
              content: Text(
                  "Your bill has been saved successfully.\nDo you want to print the bill?"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    resetAndReload();
                  },
                  child: Text("No"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PrintPage(
                            customerID: CustomerID,
                            customerName: CustomerName,
                            customerPhoneNumber: CustomerMobile,
                            itemTableDetails: itemTableDetails,
                            customerAddress: customerAddress,
                            customerPlace: placeName,
                            customerCity: cityName,
                            customerState: stateName,
                            customerPincode: pincode,
                            deliveryCharges: deliveryCharges,
                            selectedDeliveryType: selectedDeliveryType,
                            selectedGatewayName: paymentGatewayName,
                            selectedCustomerType: SelectedCustomerType,
                            taxAmount: totalTax.toString(),
                            discountAmount: totalDiscount.toString(),
                            totalAmount: roundedTotal.toStringAsFixed(2),
                            saleId: latestSaleId // Pass the fetched Sale ID
                            ),
                      ),
                    ).then((_) {
                      Future.delayed(Duration(seconds: 2), () {
                        resetAndReload(); // Clear fields after printing
                      });
                    });
                  },
                  child: Text("Yes"),
                ),
              ],
            );
          },
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error fetching Sale ID: $e")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed: ${response["description"]}")),
      );
    }
  }

  void resetAndReload() {
    setState(() {
      isBillSaved = false;
      CustomerNameController.text = '';
      CustomerIDController.text = '';
      CustomerMobileController.text = '';
      CustomerCreditLimitController.text = "";
      CustomerCreditDays.text = "";
      distanceController.text = "";
      customerCreditLimit = "";
      customerCreditDays = "";
      customerName = '';
      customerMobile = '';
      customerID = '';
      SelectedCustomerType = 'RT';
      isButtonsLocked = false;
      isDeliveryButtonSelected = false;
    });

    Future.delayed(Duration(milliseconds: 200), () {
      Navigator.pushReplacementNamed(context, '/');
    });
  }

  Future<void> fetchSalesData(
      String fromDate, Function(List<Map<String, dynamic>>) onFetch) async {
    List<Map<String, dynamic>> salesList = await FetchBillAPI.fetchSalesData(
        loginBranchId, fromDate, selectedBusinessChannels, loginBearerToken);
    onFetch(salesList);
  }

  void ShowSalesDialog(BuildContext context) async {
    TextEditingController fromDateController = TextEditingController();
    TextEditingController toDateController = TextEditingController();
    TextEditingController searchController = TextEditingController();
    List<Map<String, dynamic>> salesList = [];
    ValueNotifier<List<Map<String, dynamic>>> filteredSales = ValueNotifier([]);

    String businessDate =
        await SaveBillingAPI.getCurrentBusinessDay(loginBearerToken);

// Extract only the date part (YYYY-MM-DD)
    String businessDateOnly = businessDate.split("T")[0];
    String fromDate = businessDateOnly.replaceAll("-", "");

// Calculate 'toDate' (1 day after 'fromDate')
    DateTime businessDateTime = DateTime.parse(businessDateOnly);
    DateTime nextBusinessDateTime = businessDateTime.add(Duration(days: 1));
    String toDate =
        "${nextBusinessDateTime.year}${nextBusinessDateTime.month.toString().padLeft(2, '0')}${nextBusinessDateTime.day.toString().padLeft(2, '0')}";

// Set the controllers
    fromDateController.text = fromDate;
    toDateController.text = toDate;

    // Fetch sales initially
    fetchSalesData(fromDateController.text, (fetchedSales) {
      salesList = fetchedSales;
      filteredSales.value = fetchedSales; // Initialize filtered sales list
    });

    // Function to select date and fetch sales dynamically
    Future<void> selectDate(
        BuildContext context, TextEditingController controller) async {
      DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );

      if (pickedDate != null) {
        controller.text = DateFormat('yyyyMMdd').format(pickedDate);
        fetchSalesData(fromDateController.text, (fetchedSales) {
          salesList = fetchedSales;
          filteredSales.value = fetchedSales; // Update filtered list
        });
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        onChanged: (query) {
                          filteredSales.value = salesList
                              .where((sale) => sale['DocName']
                                  .toString()
                                  .replaceAll(' ', '')
                                  .toLowerCase()
                                  .contains(
                                      query.replaceAll(' ', '').toLowerCase()))
                              .toList();
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
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: fromDateController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'From Date',
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: () =>
                                selectDate(context, fromDateController),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    /*Expanded(
                      child: TextField(
                        controller: toDateController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'To Date',
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: () =>
                                selectDate(context, toDateController),
                          ),
                        ),
                      ),
                    ),*/
                  ],
                ),

                const SizedBox(height: 20),

                // Sales List
                ValueListenableBuilder<List<Map<String, dynamic>>>(
                  valueListenable: filteredSales,
                  builder: (context, sales, _) {
                    return sales.isNotEmpty
                        ? Flexible(
                            child: GridView.builder(
                              shrinkWrap: true,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                              ),
                              itemCount: sales.length,
                              itemBuilder: (context, index) {
                                final sale = sales[index];

                                return ElevatedButton(
                                  onPressed: () async {
                                    String selectedSaleId =
                                        sale['SaleId'] ?? '';
                                    print("Selected Sale ID: $selectedSaleId");

                                    Map<String, dynamic>? saleData =
                                        await FetchBillDetailsAPI
                                            .fetchBillDetails(loginBranchId,
                                                selectedSaleId, loginBearerToken);

                                    if (saleData != null) {
                                      var saleHeader =
                                          saleData['saleHeader'][0];
                                      var saleDetails = saleData['saleDetails'];
                                      var customerInfo =
                                          saleData['customerInfo'][0];
                                      var deliveryAddress =
                                          (saleData['deliveryAddress']
                                                      is List &&
                                                  saleData['deliveryAddress']
                                                      .isNotEmpty)
                                              ? saleData['deliveryAddress'][0]
                                              : {};
                                      var billingDetails =
                                          (saleData['billingDetails'] is List &&
                                                  saleData['billingDetails']
                                                      .isNotEmpty)
                                              ? saleData['billingDetails'][0]
                                              : {};

                                      customerBranchID =
                                          customerInfo['BranchId'];
                                      await fetchDistanceFromAPI(
                                          customerInfo['CustID']);

                                      if (customerDetailsList != null &&
                                          customerDetailsList!.isNotEmpty) {
                                        for (int i = 0;
                                            i < customerDetailsList!.length;
                                            i++) {
                                          if (deliveryAddress["AddressID"] ==
                                              customerDetailsList![i]
                                                  ['AddressID']) {
                                            addressID = customerDetailsList![i]
                                                    ['AddressID'] ??
                                                "";
                                            customerAddress =
                                                customerDetailsList![i]
                                                        ['CustomerAddress'] ??
                                                    "";
                                            pincode = customerDetailsList![i]
                                                    ['PINCODE'] ??
                                                "";
                                            placeName = customerDetailsList![i]
                                                    ['PlaceName'] ??
                                                "";
                                            cityName = customerDetailsList![i]
                                                    ['CityName'] ??
                                                "";
                                            stateName = customerDetailsList![i]
                                                    ['StateName'] ??
                                                "";
                                          }
                                        }
                                      }

                                      Navigator.of(context).pop();
                                      await Future.delayed(
                                          const Duration(milliseconds: 100));

                                      if (!context.mounted) return;

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ViewPage(
                                            saleID: saleHeader['SaleId'] ?? '',
                                            businessDate:
                                                saleHeader['BusinessDate'] ??
                                                    '',
                                            customerID:
                                                customerInfo['CustID'] ?? '',
                                            customerName:
                                                customerInfo['CustomerName'] ??
                                                    '',
                                            customerPhoneNumber:
                                                customerInfo['Mobile'] ?? '',
                                            itemTableDetails: saleDetails,
                                            customerAddress:
                                                customerAddress ?? '',
                                            customerPlace: placeName ?? '',
                                            customerCity: cityName,
                                            customerState: stateName,
                                            customerPincode: pincode ?? '',
                                            deliveryCharges:
                                                saleHeader['DeliveryCharge'] ??
                                                    0,
                                            selectedDeliveryType:
                                                selectedDeliveryType,
                                            selectedGatewayName: billingDetails[
                                                    'PaymentGatewayName'] ??
                                                '',
                                            selectedCustomerType:
                                                saleHeader['CustomerType'] ??
                                                    '',
                                            taxAmount: saleHeader['TaxAmount']
                                                .toString(),
                                            discountAmount:
                                                saleHeader['DiscountAmount']
                                                    .toString(),
                                            totalAmount:
                                                saleHeader['TotalAmount']
                                                    .toString(),
                                            roundOffAmount:
                                                saleHeader['RoundOffAmount']
                                                    .toString(),
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color.fromARGB(255, 253, 197, 0),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  ),
                                  child: Text(
                                    sale['DocName'] ?? '',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontSize: 14,
                                        color: Color.fromARGB(255, 2, 2, 2)),
                                  ),
                                );
                              },
                            ),
                          )
                        : const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text("No sales found"),
                          );
                  },
                ),

                const SizedBox(height: 10),

                // Back Button
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Back',
                    style: TextStyle(color: Colors.black, fontSize: 15),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void OrderDialogBox(BuildContext context) {
    TextEditingController docNoController = TextEditingController();
    TextEditingController businessDateFromController = TextEditingController();
    TextEditingController businessDateToController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Centered Order Text
                const Text(
                  "Order",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: docNoController,
                        decoration:
                            const InputDecoration(labelText: "Document No."),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: businessDateFromController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: "Business Date From",
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: () async {
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2101),
                              );
                              if (pickedDate != null) {
                                businessDateFromController.text = pickedDate
                                    .toLocal()
                                    .toString()
                                    .split(' ')[0];
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: businessDateToController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: "Business Date To",
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: () async {
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2101),
                              );
                              if (pickedDate != null) {
                                businessDateToController.text = pickedDate
                                    .toLocal()
                                    .toString()
                                    .split(' ')[0];
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text("Search"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Clear all fields
                        docNoController.clear();
                        businessDateFromController.clear();
                        businessDateToController.clear();
                      },
                      child: const Text("Discard"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Save and Close functionality
                        Navigator.pop(dialogContext);
                      },
                      child: const Text("Save & Close"),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Selected Button with Rounded Rectangle Border
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      Navigator.pushReplacementNamed(context, '/order_page');
                    },
                    child: const Text("Select"),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool checkTextFields() {
    return CustomerNameController.text.isEmpty &&
        CustomerMobileController.text.isEmpty &&
        CustomerIDController.text.isEmpty;
  }

  void onCustomerTypeSelect(String button) {
    setState(() {
      if (!isButtonsLocked) {
        SelectedCustomerType = button;
      }
    });
  }

  void fetchCustomerTypes() async {
    try {
      List<String> fetchedButtons =
          await CustomerTypeAPI.fetchCustomerTypes(loginBearerToken, 'L101');
      setState(() {
        customerTypes.addAll(fetchedButtons);
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  void onBusinessChannelSelect(String button) {
    setState(() {
      selectedBusinessChannels = button;
    });
  }

  Future<void> fetchBusinessChannels() async {
    try {
      final codes = await BusinessChannelAPI.fetchBusinessChannelCodes(
          loginBearerToken, loginBranchId);
      setState(() {
        businessChannels = codes;
      });
    } catch (e) {
      print("Error fetching business channels: $e");
    }
  }

  Future<void> fetchCustomers(
      String customerName, String customerMobile, String customerID) async {
    if (customerName.isEmpty && customerMobile.isEmpty && customerID.isEmpty) {
      return;
    }

    setState(() {
      customers = [];
      isCustomerLoading = true; // Show loading before API call
    });

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing while loading
      builder: (context) => AlertDialog(
        content: Row(
          children: const [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('Loading...'),
          ],
        ),
      ),
    );

    try {
      List<Map<String, dynamic>> fetchedCustomers = [];

      if (customerMobile.isNotEmpty && SelectedCustomerType == 'RT') {
        fetchedCustomers = await CustomerPhoneAPI.fetchCustomersByPhone(
            SelectedCustomerType, customerMobile, loginBearerToken);
      } else if (customerName.isNotEmpty) {
        fetchedCustomers = await CustomerNameAPI.fetchCustomersByName(
            SelectedCustomerType, customerName, loginBearerToken);
      } else if (customerID.isNotEmpty) {
        fetchedCustomers = await CustomerCodeAPI.fetchCustomersByCode(
            SelectedCustomerType, customerID, loginBearerToken);
      }

      Navigator.pop(context); // Close loading dialog

      if (fetchedCustomers.isEmpty) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Customer Not Found'),
            content: const Text(
                'Customer does not exist, please create a new customer.'),
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
      Navigator.pop(context); // Close loading dialog on error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching customers: $e')),
      );
    } finally {
      setState(() {
        isCustomerLoading = false;
      });
    }
  }

  void ShowCustomersDialog(
      BuildContext context, List<Map<String, dynamic>> customers) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Select Customer',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Flexible(
                    child: GridView.builder(
                      shrinkWrap: true,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
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
                              setState(() {
                                CustomerIDController.text =
                                    customer['custID'] ?? '';
                                CustomerNameController.text =
                                    customer['customerName'] ?? '';
                                CustomerMobileController.text =
                                    customer['mobile'] ?? '';
                                CustomerCreditLimitController.text =
                                    customer['creditLimit']?.toString() ?? '0';
                                CustomerCreditDays.text =
                                    customer['creditDays']?.toString() ?? '0';
                                CustomerBranchID.text =
                                    customer['branchID'] ?? "";
                                isButtonsLocked = true;

                                customerID = customer['custID'] ?? '';
                                customerName = customer['customerName'] ?? '';
                                customerMobile = customer['mobile'] ?? '';
                                customerCreditDays =
                                    customer['creditDays']?.toString() ?? '0';
                                customerCreditLimit =
                                    customer['creditLimit']?.toString() ?? '0';
                                customerBranchID = customer['branchID'] ?? "";
                              });

                              fetchDistanceFromAPI(
                                  CustomerIDController.text.trim());
                              Navigator.pop(context);
                            } else {
                              print('Customer data is invalid: $customer');
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 253, 197, 0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          child: Text(
                            customer['customerName'],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color.fromARGB(255, 2, 2, 2),
                            ),
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
                      'Back',
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

  void showSelectCustomerTypeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Customer Type'),
          content:
              const Text('Please select a customer type before searching.'),
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

  Future<void> fetchTimeSlots() async {
    try {
      final slots = await TimeSlotAPI.fetchTimeSlots(loginBearerToken);
      setState(() {
        timeSlots = slots;
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchDistanceFromAPI(String custId) async {
    if (custId.length > 4) {
      customerDetailsList = await FetchCustomerAddressAPI.fetchCustomerDetails(
          loginBearerToken, customerBranchID, custId);

      if (customerDetailsList != null && customerDetailsList!.isNotEmpty) {
        setState(() {
          selectedAddress = customerDetailsList!.first; // Default selection
        });
      }
    }
  }

  Future<void> fetchTransactionTypes() async {
    try {
      final types =
          await TransactionTypeAPI.fetchTransactionTypes(loginBearerToken, loginBranchId);
      setState(() {
        transactionSubTypes = types;
        isLoading = false;
      });
      for (int i = 0; i < transactionSubTypes.length; i++) {
        if (transactionSubTypes[i]['TranSubTypeId'] == "RETAIL") {
          selectedTransactionSubType = transactionSubTypes[i]['TranSubTypeId'];
          TransactionTypeID = transactionSubTypes[i]['TransactionTypeId'];
        }
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching transaction types: $error');
    }
  }

  void showItemCategorySelection() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      List<Map<String, dynamic>> fetchedItemNames =
          await ItemCategoryAPI.fetchItemCategory(
        'L101',
        loginBearerToken,
      );

      Navigator.pop(context);

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Category',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          double buttonSize =
                              (constraints.maxWidth - 32) / 4 - 16;
                          return Wrap(
                            spacing: 16.0,
                            runSpacing: 16.0,
                            children: fetchedItemNames.map((item) {
                              final categoryName = item['CategoryName']!;
                              final itemCategoryID = item['ItemCategoryID']!;
                              final itemFamilyID = item['ItemFamilyID']!;
                              return SizedBox(
                                width: buttonSize,
                                height: buttonSize,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: Size(buttonSize, buttonSize),
                                    backgroundColor:
                                        const Color.fromARGB(255, 253, 197, 0),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      selectedItemName = categoryName;
                                      selectedItemCategoryID = itemCategoryID;
                                      selectedItemType = null;
                                    });
                                    Navigator.pop(context);
                                    showItemNameSelection();
                                  },
                                  child: Text(
                                    categoryName,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Color.fromARGB(255, 2, 2, 2),
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                      const SizedBox(height: 18),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Back',
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
            ),
          );
        },
      );
    } catch (e) {
      Navigator.pop(context);
      print('Error: $e');
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Failed to load item names. Please try again.'),
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
  }

  void showItemNameSelection() async {
    if (selectedItemCategoryID == null) {
      print('ItemCategoryID is not selected.');
      return;
    }

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      List<Map<String, dynamic>>? fetchedItemNames =
          await ItemStockAPI.fetchItemStock(
        "VNBIN",
        loginBranchId,
        selectedBusinessChannels,
        selectedItemCategoryID!,
        "ALL",
        loginBearerToken,
      );

      Navigator.pop(context);

      List<Map<String, dynamic>> filteredStockItems = (fetchedItemNames ?? [])
          .where(
              (item) => (item["StockQty"] > 0 /*&& item["StockAltQty"] >= 0*/))
          .toList();

      TextEditingController searchController = TextEditingController();
      ValueNotifier<List<Map<String, dynamic>>> filteredItems =
          ValueNotifier(filteredStockItems);

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
                            'Item Name',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(
                          width: 150,
                          child: TextField(
                            controller: searchController,
                            onChanged: (query) {
                              filteredItems.value = filteredStockItems
                                  .where((item) => item['ItemName']
                                      .toString()
                                      .replaceAll(' ', '')
                                      .toLowerCase()
                                      .contains(query
                                          .replaceAll(' ', '')
                                          .toLowerCase()))
                                  .toList();
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
                        builder: (context, items, _) {
                          return SingleChildScrollView(
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                double buttonSize =
                                    (constraints.maxWidth - 32) / 4 - 16;
                                return Wrap(
                                  spacing: 16.0,
                                  runSpacing: 16.0,
                                  children: items.map((item) {
                                    String buttonText = item['BatchNumber'] ==
                                            null
                                        ? item['ItemName']
                                        : "${item['BatchNumber']}\n${item['ItemName']}";
                                    return SizedBox(
                                      width: buttonSize,
                                      height: buttonSize,
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
                                          final itemId = item['ItemID'];
                                          final batchNumber =
                                              item['BatchNumber'];

                                          fetchAndSetItemDetails(itemId);
                                          fetchAndSetItemStock(
                                              itemId, batchNumber);
                                          batchNoController.text =
                                              item['BatchNumber'] ?? "";
                                          Navigator.pop(context);
                                        },
                                        child: Text(
                                          buttonText,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: Color.fromARGB(255, 1, 1, 1),
                                            fontSize: 12,
                                          ),
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
                        showItemCategorySelection();
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Back',
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
    } catch (e) {
      Navigator.pop(context);
      print('Error: $e');

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Failed to load item names. Please try again.'),
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
  }

  void fetchAndSetItemDetails(String itemId) async {
    final itemDetails =
        await ItemDetailsAPI.fetchItemDetails(itemId, loginBearerToken);

    if (itemDetails != null) {
      setState(() {
        selectedItemID = itemDetails['ItemID'];
        selectedItemType = itemDetails['ItemName'];
        selectedItemDetails = itemDetails;

        ItemID = itemDetails['ItemID'];
        ItemName = itemDetails['ItemName'];
        ItemTaxCategoryID = itemDetails['TaxCategoryID'];
        ItemStockGroupID = itemDetails['StockGroupID'];
        ItemFamilyID = itemDetails['ItemFamilyID'];
        minWeight = itemDetails['UnitMinWt'];
        maxWeight = 10000;
        maxQuantity = 10000;
        taxPercent = itemDetails['TotalTaxPercent'];

        selectedAltQtyEnabled = itemDetails['AltQtyEnabled'];
        selectedSellByWeight = itemDetails['SellByWeight'];
        selectedBatchEnabled = itemDetails['BatchEnabled'];

        weightController.clear();
        quantityController.clear();
      });

      fetchItemPrice();
      updateFocus();
    } else {
      print('Failed to fetch item details.');
    }
  }

  void fetchAndSetItemStock(String itemId, String? batchNumber) async {
    try {
      final itemStockData = await ItemStockAPI.fetchItemStock(
        "VNBIN",
        loginBranchId,
        selectedBusinessChannels,
        selectedItemCategoryID!,
        itemId,
        loginBearerToken,
      );

      if (itemStockData != null && itemStockData.isNotEmpty) {
        // Match both ItemID and BatchNumber if BatchNumber is not null
        final matchingStock = itemStockData.firstWhere(
          (item) =>
              item['ItemID'] == itemId &&
              (batchNumber == null || item['BatchNumber'] == batchNumber),
          orElse: () => {},
        );

        // Avoid runtime errors when firstWhere returns empty map
        if (matchingStock.isNotEmpty) {
          setState(() {
            itemStockQty = matchingStock['StockQty'] ?? 0;
            itemStockAltQty = matchingStock['StockAltQty'] ?? 0;
          });
        } else {
          setState(() {
            itemStockQty = 0;
            itemStockAltQty = 0;
          });
        }
      }
    } catch (e) {
      print('Error fetching item stock: $e');
    }
  }

  bool isNumberTextFieldEnabled() {
    if (selectedItemName == '') {
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

  Future<void> _loadDiscounts() async {
    try {
      List<Map<String, dynamic>> fetchedDiscounts =
          await DiscountAPI.fetchDiscounts(loginBranchId, loginBearerToken);
      setState(() {
        discounts = fetchedDiscounts;
      });
    } catch (e) {
      print('Error fetching discounts: $e');
    }
  }

  void fetchItemPrice() async {
    if (selectedItemID == null) {
      print("No item selected");
      return;
    }

    var priceData = await ItemPriceAPI.fetchItemPrice("20250319", loginBranchId,
        selectedBusinessChannels, selectedItemID!, loginBearerToken);

    setState(() {
      if (priceData != null &&
          priceData.isNotEmpty &&
          priceData['rate'] != null) {
        priceController.text = priceData['rate'].toString();
        ItemDayRate = priceData['rate'];
      } else {
        priceController.text = "";
        ItemDayRate = 0;
      }
    });
  }

  void addItem(String itemType, double price, double weight, int quantity) {
    setState(() {
      double totalPrice = price * quantity;
      itemTableDetails.add({
        "itemType": itemType,
        "price": price,
        "weight": weight,
        "quantity": quantity,
        "totalPrice": totalPrice,
      });
    });
  }

  void addItemToTable() {
    try {
      if (selectedRowIndex == null) {
        // Validation only for new items
        if (selectedItemName == 'Item Name' || selectedItemType == null) {
          throw Exception('Please select a valid item and type.');
        }
      }

      if (priceController.text.isEmpty) {
        throw Exception('Price field must be filled.');
      }

      double price = double.parse(priceController.text.trim());
      double discount = discountController.text.isNotEmpty
          ? double.parse(discountController.text.trim())
          : 0.0;
      double weight = weightController.text.isNotEmpty
          ? double.parse(weightController.text.trim())
          : 0.0;
      int quantity = quantityController.text.isNotEmpty
          ? int.parse(quantityController.text.trim())
          : 0;
      String batchNo = batchNoController.text.isNotEmpty
          ? batchNoController.text.trim().toString()
          : "";

      if (weight == 0 && quantity == 0) {
        throw Exception('Please fill either Weight or Quantity field.');
      }

      if (quantity > itemStockQty) {
        throw Exception('Quantity cannot be more than $itemStockQty');
      }
      if (weight > itemStockQty) {
        throw Exception('Weight cannot be more than $itemStockQty');
      }

      double roundedPrice = double.parse(price.toStringAsFixed(2));
      double roundedWeight = double.parse(weight.toStringAsFixed(3));

      double totalPrice;
      if (weight > 0) {
        totalPrice = roundedPrice * roundedWeight;
      } else {
        totalPrice = roundedPrice * quantity;
      }
      totalPrice = double.parse(totalPrice.toStringAsFixed(2));

      double itemTax = (totalPrice * (taxPercent / 100));
      int itemDiscount = 0;
      double finalItemPrice = totalPrice - itemDiscount + itemTax;

      // Check for duplicate item name and batch number
      // Check for duplicate item name and batch number
      bool isDuplicateItem = itemTableDetails.asMap().entries.any((entry) {
        int index = entry.key;
        var item = entry.value;
        if (selectedRowIndex != null && index == selectedRowIndex) return false; // Skip current item in edit mode
        return item['itemName'] == selectedItemName;
      });

      bool isSameItemSameBatch = itemTableDetails.asMap().entries.any((entry) {
        int index = entry.key;
        var item = entry.value;
        if (selectedRowIndex != null && index == selectedRowIndex) return false; // Skip current item in edit mode
        return item['itemName'] == selectedItemName && item['batchNo'] == batchNo;
      });


      if (isSameItemSameBatch) {
        throw Exception('This item is already added.');
      }

      if (isDuplicateItem && !isSameItemSameBatch) {
        throw Exception(
            'This item is already added with a different batch. Please change the batch number.');
      }

      setState(() {
        isDeliveryButtonSelected = true;

        if (selectedRowIndex != null) {
          itemTableDetails[selectedRowIndex!] = {
            'batchNo': batchNo,
            'itemName': selectedItemName,
            'itemType': selectedItemType,
            "ItemID": ItemID ?? "", // Ensure non-null
            "ItemTaxCategoryID": ItemTaxCategoryID ?? "",
            "ItemStockGroupID": ItemStockGroupID ?? "",
            "ItemFamilyID": ItemFamilyID ?? "",
            'price': roundedPrice,
            'weight': roundedWeight,
            'quantity': quantity,
            'totalPrice': totalPrice,
            'tax': double.parse(itemTax.toStringAsFixed(2)),
            'taxPercentage': taxPercent,
            'discount': itemDiscount,
            'finalPrice': double.parse(finalItemPrice.toStringAsFixed(2)),
            "ItemAltQtyEnabled": selectedAltQtyEnabled,
            "ItemSellByWeight": selectedSellByWeight,
            "BatchEnabled": selectedBatchEnabled,
            "minWeight": minWeight,
            "maxWeight": maxWeight,
            "maxQuantity": maxQuantity,
            "itemStockQTY": itemStockQty,
            "itemStockALTQTY": itemStockAltQty,
          };

          selectedItems[selectedRowIndex!] = {
            'BatchNo': batchNo,
            "ItemID": ItemID ?? "", // Ensure non-null
            "ItemName": selectedItemName,
            "ItemTaxCategoryID": ItemTaxCategoryID ?? "",
            "ItemStockGroupID": ItemStockGroupID ?? "",
            "ItemFamilyID": ItemFamilyID ?? "",
            "ItemPrice": roundedPrice.toDouble(), // Ensure double
            "ItemDayRate":
                ((ItemDayRate ?? 0) > 0 ? ItemDayRate : 0).toDouble(),
            "ItemQuantity": quantity,
            "ItemWeight": roundedWeight.toDouble(),
            "ItemTotalPrice": totalPrice.toDouble(),
            "ItemAltQtyEnabled": selectedAltQtyEnabled,
            "ItemSellByWeight": selectedSellByWeight,
            "BatchEnabled": selectedBatchEnabled,
            "TaxPercent": taxPercent > 0 ? taxPercent.toDouble() : 0.0,
            "Discount": itemDiscount.toDouble(),
            "itemStockQTY": itemStockQty,
            "itemStockALTQTY": itemStockAltQty,
          };

          selectedRowIndex = null; // ✅ Reset after editing
        } else {
          itemTableDetails.add({
            'batchNo': batchNo,
            'itemName': selectedItemName,
            'itemType': selectedItemType,
            "ItemID": ItemID,
            "ItemTaxCategoryID": ItemTaxCategoryID,
            "ItemStockGroupID": ItemStockGroupID,
            "ItemFamilyID": ItemFamilyID,
            'price': roundedPrice,
            'weight': roundedWeight,
            'quantity': quantity,
            'totalPrice': totalPrice,
            'tax': double.parse(itemTax.toStringAsFixed(2)),
            'taxPercentage': taxPercent,
            'discount': itemDiscount,
            'finalPrice': double.parse(finalItemPrice.toStringAsFixed(2)),
            "ItemAltQtyEnabled": selectedAltQtyEnabled,
            "ItemSellByWeight": selectedSellByWeight,
            "BatchEnabled": selectedBatchEnabled,
            "minWeight": minWeight,
            "maxWeight": maxWeight,
            "maxQuantity": maxQuantity,
            "itemStockQTY": itemStockQty,
            "itemStockALTQTY": itemStockAltQty,
          });

          selectedItems.add({
            'BatchNo': batchNo,
            "ItemID": ItemID,
            "ItemName": ItemName,
            "ItemTaxCategoryID": ItemTaxCategoryID,
            "ItemStockGroupID": ItemStockGroupID,
            "ItemFamilyID": ItemFamilyID,
            "ItemPrice": roundedPrice,
            "ItemDayRate": (ItemDayRate ?? 0) > 0 ? ItemDayRate : 0,
            "ItemQuantity": quantity,
            "ItemWeight": roundedWeight,
            "ItemTotalPrice": totalPrice,
            "ItemAltQtyEnabled": selectedAltQtyEnabled,
            "ItemSellByWeight": selectedSellByWeight,
            "BatchEnabled": selectedBatchEnabled,
            "TaxPercent": taxPercent > 0 ? taxPercent : 0,
            "Discount": double.tryParse(itemDiscount.toString()) ?? 0.0,
            "itemStockQTY": itemStockQty,
            "itemStockALTQTY": itemStockAltQty,
          });
        }

        updateTotalPrice();
        updateDiscountPrice(); // ✅ Ensure total is updated

        batchNoController.clear();
        priceController.clear();
        weightController.clear();
        quantityController.clear();
        selectedItemName = '';
        selectedItemType = null;
        selectedBatchEnabled = false;
      });
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text(e.toString().replaceAll('Exception: ', '')),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    }
  }

  void deleteSelectedRows() {
    setState(() {
      // Remove selected items from `itemTableDetails`
      List<Map<String, dynamic>> updatedItemTableDetails = [];
      List<Map<String, dynamic>> updatedSelectedItems = [];

      for (int i = 0; i < itemTableDetails.length; i++) {
        if (!selectedRows.contains(i)) {
          updatedItemTableDetails.add(itemTableDetails[i]);
          updatedSelectedItems.add(
              selectedItems[i]); // Keep corresponding item in selectedItems
        }
      }

      itemTableDetails = updatedItemTableDetails;
      selectedItems = updatedSelectedItems;
      selectedRows.clear(); // Clear selection

      updateTotalPrice();
      updateDiscountPrice();
    });
  }

  void _calculateTotalPrice() {
    double pricePerUnit = double.tryParse(priceController.text.trim()) ?? 0.0;
    double weight = double.tryParse(weightController.text.trim()) ?? 0.0;
    double discount = double.tryParse(discountController.text.trim()) ?? 0.0;
    int quantity = int.tryParse(quantityController.text.trim()) ?? 0;

    double calculatedTotal;
    if (quantity > 0) {
      calculatedTotal = pricePerUnit * quantity;
    } else if (weight > 0) {
      calculatedTotal = pricePerUnit * weight;
    } else {
      calculatedTotal = pricePerUnit * 1; // Default multiplier
    }

    setState(() {
      totalPrice = calculatedTotal;
    });
  }

  void updateTotalPrice() {
    setState(() {
      totalItemPrice = itemTableDetails.fold(
          0.0, (sum, item) => sum + (item['totalPrice'] as num).toDouble());

      totalTax = itemTableDetails.fold(
          0, (sum, item) => sum + (item['tax'] as num).toDouble());

      totalDiscount = itemTableDetails.fold(
          0, (sum, item) => sum + (item['discount'] as num).toInt());

      deliveryCharges = int.tryParse(deliveryChargesController.text) ?? 0;

      double finalTotal =
          totalItemPrice + totalTax - totalDiscount + deliveryCharges;
      roundedTotal =
          double.parse(finalTotal.roundToDouble().toStringAsFixed(2));
    });
  }

  void updateDiscountPrice() {
    setState(() {
      double enteredDiscount = double.tryParse(discountController.text) ?? 0.0;

      if ((selectedDiscountType == "Total value" ||
              selectedDiscountType == "Total percentage" ||
              selectedDiscountType == "Total kg") &&
          enteredDiscount > totalItemPrice) {
        // Show alert and return early
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Invalid Discount"),
              content:
                  const Text("Discount cannot be more than the total amount."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
        return; // Stop further execution
      }

      // Create a copy of itemTableDetails to work with discounts
      discountedItemDetails = itemTableDetails
          .map((item) => Map<String, dynamic>.from(item))
          .toList();

      // Reset total values
      totalItemPrice = discountedItemDetails.fold(
          0.0, (sum, item) => sum + (item['totalPrice'] as num).toDouble());
      totalTax = discountedItemDetails.fold(
          0, (sum, item) => sum + (item['tax'] as num).toDouble());
      totalDiscount = 0;

      if (selectedDiscountType == "None") {
        discountValue = 0.0;
      }

      // Case 1: Total Value Discount (Proportional Distribution)
      if (selectedDiscountType == "Total value") {
        discountValue = double.tryParse(discountController.text) ?? 0.0;

        if (totalItemPrice > 0) {
          double discountPercentage =
              discountValue / totalItemPrice; // Calculate percentage

          totalDiscount = 0;
          for (var item in discountedItemDetails) {
            double itemTotalPrice = (item['totalPrice'] as num).toDouble();
            double itemDiscount = itemTotalPrice *
                discountPercentage; // Apply discount proportionally

            item['discount'] = itemDiscount;
            totalDiscount += itemDiscount; // Sum total discount
          }
        }
      }

      // Case 2: Total Kg Discount
      if (selectedDiscountType == "Total kg") {
        discountValue = double.tryParse(discountController.text) ?? 0.0;
        var weightedItems = discountedItemDetails
            .where((item) => (item['weight'] as num) > 0)
            .toList();
        double totalWeight = weightedItems.fold(
            0.0, (sum, item) => sum + (item['weight'] as num).toDouble());

        if (totalWeight > 0) {
          for (var item in weightedItems) {
            double itemWeight = (item['weight'] as num).toDouble();
            double originalPricePerKg = (item['price'] as num).toDouble();

            double discountPerKg = discountValue;
            double newPricePerKg =
                (originalPricePerKg - discountPerKg).clamp(0, double.infinity);

            double newTotalPrice = newPricePerKg * itemWeight;
            double itemDiscount =
                (originalPricePerKg * itemWeight) - newTotalPrice;

            item['discount'] = itemDiscount;
            item['price'] = newPricePerKg;
            item['totalPrice'] = newTotalPrice;

            totalDiscount += itemDiscount; // Keep track of discount
          }
        }
      }

      // Case 3: Total Percentage Discount
      if (selectedDiscountType == "Total percentage") {
        discountValue = double.tryParse(discountController.text) ?? 0.0;
        double discountPercentage = discountValue / 100;

        totalDiscount = 0;
        totalTax = 0; // Reset total tax before recalculating

        for (var item in discountedItemDetails) {
          double originalTotalPrice = (item['totalPrice'] as num).toDouble();

          // Calculate discount and round it
          double itemDiscount = originalTotalPrice * discountPercentage;
          itemDiscount =
              itemDiscount.roundToDouble(); // Round to the nearest whole number

          double itemTax =
              ((item['taxPercentage'] as num) / 100) * originalTotalPrice;
          itemTax = double.parse(itemTax.toStringAsFixed(2));

          item['discount'] = itemDiscount;
          item['totalPrice'] = originalTotalPrice; // Apply rounded discount

          totalDiscount += itemDiscount;
          totalTax += itemTax;
        }
      }

      // Recalculate totals
      totalItemPrice = discountedItemDetails.fold(
          0.0, (sum, item) => sum + (item['totalPrice'] as num).toDouble());

      // Final total calculation based on discount type
      double finalTotal = totalItemPrice + deliveryCharges + totalTax;
      if (selectedDiscountType == "Total value" ||
          selectedDiscountType == "Total percentage") {
        finalTotal -= totalDiscount;
      }

      roundedTotal =
          double.parse(finalTotal.roundToDouble().toStringAsFixed(2));

      // Update selectedItems with final values
      selectedItems = discountedItemDetails
          .map((item) => {
                "BatchNo": item['batchNo'],
                "ItemID": item["ItemID"],
                "ItemName": item["itemName"],
                "ItemTaxCategoryID": item["ItemTaxCategoryID"],
                "ItemStockGroupID": item["ItemStockGroupID"],
                "ItemFamilyID": item["ItemFamilyID"],
                "ItemPrice": (item["price"] is String)
                    ? double.tryParse(item["price"]) ?? 0.0
                    : (item["price"] as num).toDouble(),
                "ItemDayRate": (item["ItemDayRate"] ?? 0) is String
                    ? double.tryParse(item["ItemDayRate"]) ?? 0.0
                    : (item["ItemDayRate"] ?? 0).toDouble(),
                "ItemQuantity": (item["quantity"] is String)
                    ? int.tryParse(item["quantity"]) ?? 0
                    : item["quantity"],
                "ItemWeight": (item["weight"] is String)
                    ? double.tryParse(item["weight"]) ?? 0.0
                    : (item["weight"] as num).toDouble(),
                "ItemTotalPrice": (item["totalPrice"] is String)
                    ? double.tryParse(item["totalPrice"]) ?? 0.0
                    : (item["totalPrice"] as num).toDouble(),
                "ItemAltQtyEnabled": item["ItemAltQtyEnabled"],
                "ItemSellByWeight": item["ItemSellByWeight"],
                "BatchEnabled": item["BatchEnabled"],
                "TaxPercent": (item["taxPercentage"] is String)
                    ? double.tryParse(item["taxPercentage"]) ?? 0.0
                    : (item["taxPercentage"] as num).toDouble(),
                "Discount": (item["discount"] is String)
                    ? double.tryParse(item["discount"].toString()) ?? 0.0
                    : (item["discount"] as num).toDouble(),
                "itemStockQTY": item['itemStockQTY'],
                "itemStockALTQTY": item['itemStockALTQTY'],
              })
          .toList();
    });
  }

  void setGroupFontSize(double size) {
    setState(() {
      groupFontSize = size;
    });
  }

  void setGroupFontWeight(FontWeight weight) {
    setState(() {
      groupFontWeight = weight;
    });
  }

  void setGroupFontFamily(String family) {
    setState(() {
      groupFontFamily = family;
    });
  }

  void setTextFieldFontSize(double size) {
    setState(() {
      textFieldFontSize = size;
    });
  }

  void setTextFieldFontWeight(FontWeight weight) {
    setState(() {
      textFieldFontWeight = weight;
    });
  }

  void setTextFieldFontFamily(String family) {
    setState(() {
      textFieldFontFamily = family;
    });
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

          //new vala
          body: Column(
            children: [
              const SizedBox(height: 5),
              Container(
                color: const Color.fromARGB(255, 240, 240, 240),
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: scrollOptions.sublist(0, 4).map((option) {
                        Color buttonColor = selectedScrollOption == option
                            ? const Color(0xFF02096A)
                            : const Color.fromARGB(255, 222, 221, 221);
                        Color borderColor = Colors.transparent;

                        if (option == 'Cancel Bill') {
                          buttonColor = selectedScrollOption == option
                              ? const Color.fromARGB(255, 254, 0, 0)
                              : const Color(0xFFFF3333);
                          //  borderColor = Colors.yellow;
                        }
                        if (option == 'Save') {
                          buttonColor = selectedScrollOption == option
                              ? const Color(0xFF02720F)
                              : const Color(0xFF02A515);
                          // borderColor = Colors.yellow;
                        }
                        String viewOrPrint = isBillSaved ? "Print" : "View";
                        if (option == 'View') option = viewOrPrint;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              if (option == 'Cancel') {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Save Existing Bill?'),
                                      content: const Text(
                                          'Do you want to save the existing bill before starting a new one?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            setState(() {
                                              isBillSaved = false;
                                              CustomerNameController.text = '';
                                              CustomerIDController.text = '';
                                              CustomerMobileController.text =
                                                  '';
                                              CustomerCreditLimitController
                                                  .text = "";
                                              CustomerCreditDays.text = "";

                                              distanceController.text = "";
                                              customerCreditLimit = "";
                                              customerCreditDays = "";
                                              customerName = '';
                                              customerMobile = '';
                                              customerID = '';
                                              SelectedCustomerType = 'RT';
                                              isButtonsLocked = false;
                                              isDeliveryButtonSelected = false;
                                            });

                                            Navigator.pop(context);
                                            Navigator.pushReplacementNamed(
                                                context, '/');
                                          },
                                          child: const Text('No'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text('Yes'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                              if (option == 'Cancel Bill') {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Cancel Bill?'),
                                      content: const Text(
                                          'Are you sure you want to cancel the current bill?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            setState(() {
                                              isBillSaved = false;
                                              CustomerNameController.text = '';
                                              CustomerIDController.text = '';
                                              CustomerMobileController.text =
                                                  '';
                                              CustomerCreditLimitController
                                                  .text = "";
                                              CustomerCreditDays.text = "";

                                              distanceController.text = "";
                                              customerCreditLimit = "";
                                              customerCreditDays = "";
                                              customerName = '';
                                              customerMobile = '';
                                              customerID = '';
                                              SelectedCustomerType = 'RT';
                                              isButtonsLocked = false;
                                              isDeliveryButtonSelected = false;
                                            });

                                            Navigator.pop(context);
                                            Navigator.pushReplacementNamed(
                                                context, '/');
                                          },
                                          child: const Text('Yes'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text('No'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }

                              if (option == 'Order') {
                                OrderDialogBox(context);
                              }

                              if (option == 'Save') {
                                if (SelectedCustomerType == "CS") {
                                  if (CustomerNameController.text.isEmpty ||
                                      CustomerMobileController.text.isEmpty ||
                                      CustomerIDController.text.isEmpty ||
                                      itemTableDetails == null ||
                                      itemTableDetails.isEmpty) {
                                    // Show a pop-up alert
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text("Missing Details"),
                                          content: const Text(
                                              "Please fill in all the required fields before saving."),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text("OK"),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  } else {
                                    saveBill();
                                  }
                                } else {
                                  if (CustomerMobileController.text.isEmpty ||
                                      CustomerNameController.text.isEmpty ||
                                      itemTableDetails == null ||
                                      itemTableDetails.isEmpty) {
                                    // Show a pop-up alert
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text("Missing Details"),
                                          content: const Text(
                                              "Please fill in all the required fields before payment"),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text("OK"),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  } else {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PaymentScreen(
                                          totalPrice:
                                              roundedTotal.toStringAsFixed(2),
                                          itemTotalPrice:
                                              totalItemPrice.toStringAsFixed(2),
                                        ),
                                      ),
                                    );

                                    if (result != null) {
                                      paymentMethodId =
                                          result['paymentMethodId'];
                                      paymentGatewayId =
                                          result['paymentGatewayId'];
                                      paymentGatewayName =
                                          result['paymentGatewayName'];

                                      // Call saveBill() only if the "Save" button was pressed
                                      if (result['action'] == 'save') {
                                        saveBill();
                                      }
                                    }
                                  }
                                }
                              }

                              if (option == 'View') {
                                ShowSalesDialog(context);
                              }
                              onScrollOptionSelect(option);
                            },
                            child: Container(
                              height: 50,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: buttonColor,
                                border:
                                    Border.all(color: borderColor, width: 1.5),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              alignment: Alignment.center,
                              child: option == 'New'
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add,
                                          color: selectedScrollOption == option
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          option,
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: scrollFontSize,
                                            fontWeight: scrollFontWeight,
                                            fontFamily: scrollFontFamily,
                                            color:
                                                selectedScrollOption == option
                                                    ? Colors.white
                                                    : Colors.black,
                                          ),
                                        ),
                                      ],
                                    )
                                  : option == 'View'
                                      ? Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.visibility,
                                              color:
                                                  selectedScrollOption == option
                                                      ? Colors.white
                                                      : Colors.black,
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              option,
                                              textAlign: TextAlign.center,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: scrollFontSize,
                                                fontWeight: scrollFontWeight,
                                                fontFamily: scrollFontFamily,
                                                color: selectedScrollOption ==
                                                        option
                                                    ? Colors.white
                                                    : Colors.black,
                                              ),
                                            ),
                                          ],
                                        )
                                      : Text(
                                          option,
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: scrollFontSize,
                                            fontWeight: scrollFontWeight,
                                            fontFamily: scrollFontFamily,
                                            color:
                                                selectedScrollOption == option
                                                    ? Colors.white
                                                    : Colors.black,
                                          ),
                                        ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              // pos box
              const SizedBox(height: 1),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          /*Flexible(
                            // 1st pos box
                            flex: customerTypes.length,
                            child: Container(
                              height: 60,
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                border: Border.all(color: Colors.grey.shade400),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: customerTypes.map((button) {
                                  return GestureDetector(
                                    onTap: isButtonsLocked
                                        ? null // Disable buttons after search is clicked
                                        : () => onCustomerTypeSelect(button),
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 5),
                                      // Spacing between buttons
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: SelectedCustomerType == button
                                            ? const Color.fromARGB(
                                                255, 2, 9, 106)
                                            : Colors.grey.shade300,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        button,
                                        style: TextStyle(
                                          fontSize: groupFontSize,
                                          fontWeight: groupFontWeight,
                                          fontFamily: groupFontFamily,
                                          color: SelectedCustomerType == button
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),*/
                          //const SizedBox(width: 10),
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
                                      fetchItemPrice();
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 5),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 170, vertical: 18),
                                      decoration: BoxDecoration(
                                        color:
                                            selectedBusinessChannels == button
                                                ? const Color.fromARGB(
                                                    255, 2, 9, 106)
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

                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(4),
                        /*decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: const Color.fromARGB(255, 216, 216, 216)),
                        ),*/
                        child: Column(
                          //crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /*Text(
                              'Customer Details',
                              style: TextStyle(
                                fontSize: customerFontSize + 2,
                                fontWeight: customerFontWeight,
                                fontFamily: customerFontFamily,
                              ),
                              ),*/

                            Row(
                              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Delivery Type Dropdown with only Icons
                                /*SizedBox(
                                  width: 60, // Adjust the width to fit the icon
                                  height: 50,
                                  child: DropdownButtonFormField<String>(
                                    value: selectedDeliveryType,
                                    items: ['Home', 'Takeaway']
                                        .map((type) => DropdownMenuItem(
                                              value: type,
                                              child: Icon(
                                                type == 'Home'
                                                    ? Icons.pedal_bike_rounded
                                                    : Icons.work_outline,
                                                color: Colors.black,
                                              ),
                                            ))
                                        .toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedDeliveryType = value.toString();

                                        if (selectedDeliveryType != "Home") {
                                          selectedAddress = null;
                                          distanceController.clear();
                                          addressID = "";
                                          customerAddress = "";
                                          houseNo = "";
                                          altPhone = "";
                                          building = "";
                                          pincode = "";
                                          placeID = "";
                                          cityID = "";
                                          landmark = "";
                                          placeName = "";
                                          cityName = "";
                                          stateName = "";
                                        }
                                      });
                                    },
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    dropdownColor: Colors.white,
                                  ),
                                ),*/
                                //const SizedBox(width:10),
                                IntrinsicWidth(
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(minWidth: 125),
                                    child: GestureDetector(
                                      onTap: () {},
                                      child: AbsorbPointer(
                                        child: SizedBox(
                                          height: 50,
                                          child: TextField(
                                            readOnly: true,
                                            controller: CustomerIDController,
                                            decoration: InputDecoration(
                                              labelText: 'Custr. Id',
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 20,
                                                      horizontal: 20),
                                            ),
                                            onChanged: (value) {
                                              customerID = value;
                                              setState(() {
                                                if (customerID.length > 9) {
                                                  fetchDistanceFromAPI(
                                                      customerID);
                                                }
                                                if (checkTextFields()) {
                                                  isButtonsLocked = false;
                                                }
                                              });
                                            },
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                IntrinsicWidth(
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(minWidth: 120),
                                    child: TextField(
                                      controller: CustomerMobileController,
                                      keyboardType:
                                          TextInputType.numberWithOptions(
                                              decimal: true),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        LengthLimitingTextInputFormatter(10),
                                      ],
                                      decoration: InputDecoration(
                                        labelText: 'Phone',
                                        labelStyle: const TextStyle(
                                          fontSize: 12,
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 16, horizontal: 16),
                                        prefixIcon: const Icon(Icons.phone,
                                            color:
                                                Color.fromARGB(255, 2, 9, 106)),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      style: TextStyle(
                                        fontSize: customerFontSize,
                                        fontWeight: customerFontWeight,
                                        fontFamily: customerFontFamily,
                                      ),
                                      onChanged: (value) async {
                                        customerMobile = value;
                                        if (value.length < 10) {
                                          print(
                                              'Please enter a 10-digit phone number');
                                        } else if (value.length == 10) {
                                          print('Valid phone number');
                                        }

                                        if (value.length == 10) {
                                          if (SelectedCustomerType.isEmpty) {
                                            showSelectCustomerTypeDialog(
                                                context);
                                          } else {
                                            final customerName =
                                                CustomerNameController.text
                                                    .trim();
                                            final customerID =
                                                CustomerIDController.text
                                                    .trim();
                                            final customerMobile =
                                                CustomerMobileController.text
                                                    .trim();

                                            // Fetch customers first before opening the dialog
                                            await fetchCustomers(customerName,
                                                customerMobile, customerID);

                                            if (mounted &&
                                                customers.isNotEmpty) {
                                              ShowCustomersDialog(
                                                  context, customers);
                                            }
                                          }
                                        }
                                        setState(() {
                                          if (checkTextFields()) {
                                            isButtonsLocked =
                                                false; // Re-enable buttons when both text fields are empty
                                          }
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextField(
                                    controller: CustomerNameController,
                                    decoration: InputDecoration(
                                      labelText: 'Name',
                                      labelStyle: const TextStyle(
                                        fontSize: 14.0,
                                      ),
                                      prefixIcon: const Icon(Icons.person,
                                          color:
                                              Color.fromARGB(255, 2, 9, 106)),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 16, horizontal: 16),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'^[a-zA-Z\s]+$'))
                                    ],
                                    onChanged: (value) {
                                      customerName = value;
                                      setState(() {
                                        if (checkTextFields()) {
                                          isButtonsLocked = false;
                                        }
                                      });
                                    },
                                    style: TextStyle(
                                      fontSize: customerFontSize,
                                      fontWeight: customerFontWeight,
                                      fontFamily: customerFontFamily,
                                    ),
                                  ),
                                ),
                                /* Expanded(
                                  flex: 2,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {},
                                          child: AbsorbPointer(
                                            child: SizedBox(
                                              height: 50,
                                              child: TextField(
                                                readOnly: true,
                                                controller:
                                                    CustomerCreditLimitController,
                                                onChanged: (value) {
                                                  customerCreditLimit = value;
                                                },
                                                keyboardType:
                                                    TextInputType.number,
                                                decoration: InputDecoration(
                                                  labelText: 'Limit',
                                                  labelStyle: const TextStyle(
                                                      fontSize: 14),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  contentPadding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                          vertical: 5,
                                                          horizontal: 10),
                                                ),
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      Expanded(
                                        child: SizedBox(
                                          height: 50,
                                          child: TextField(
                                            enabled: false,
                                            keyboardType: TextInputType.number,
                                            decoration: InputDecoration(
                                              labelText: 'Temporary',
                                              labelStyle:
                                                  const TextStyle(fontSize: 14),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 5,
                                                      horizontal: 10),
                                            ),
                                            style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      Expanded(
                                        child: SizedBox(
                                          height: 50,
                                          child: TextField(
                                            enabled: false,
                                            keyboardType: TextInputType.number,
                                            decoration: InputDecoration(
                                              labelText: 'Available',
                                              labelStyle:
                                                  const TextStyle(fontSize: 14),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 5,
                                                      horizontal: 10),
                                            ),
                                            style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),*/
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                /* Expanded(
                                  child: TextField(
                                    controller: CustomerMobileController,
                                    keyboardType:
                                        TextInputType.numberWithOptions(
                                            decimal: true),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(10),
                                    ],
                                    decoration: InputDecoration(
                                      labelText: 'Phone Number',
                                      labelStyle: const TextStyle(
                                        fontSize: 14.0,
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 12),
                                      prefixIcon: const Icon(Icons.phone,
                                          color:
                                              Color.fromARGB(255, 2, 9, 106)),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    style: TextStyle(
                                      fontSize: customerFontSize,
                                      fontWeight: customerFontWeight,
                                      fontFamily: customerFontFamily,
                                    ),
                                    onChanged: (value) async {
                                      customerMobile = value;
                                      if (value.length < 10) {
                                        print(
                                            'Please enter a 10-digit phone number');
                                      } else if (value.length == 10) {
                                        print('Valid phone number');
                                      }

                                      if (value.length == 10) {
                                        if (SelectedCustomerType.isEmpty) {
                                          showSelectCustomerTypeDialog(context);
                                        } else {
                                          final customerName =
                                              CustomerNameController.text
                                                  .trim();
                                          final customerID =
                                              CustomerIDController.text.trim();
                                          final customerMobile =
                                              CustomerMobileController.text
                                                  .trim();

                                          // Fetch customers first before opening the dialog
                                          await fetchCustomers(customerName,
                                              customerMobile, customerID);

                                          // Open the dialog only if customers are available
                                          if (customers.isNotEmpty) {
                                            ShowCustomersDialog(
                                                context, customers);
                                          }
                                        }
                                      }
                                      setState(() {
                                        if (checkTextFields()) {
                                          isButtonsLocked =
                                              false; // Re-enable buttons when both text fields are empty
                                        }
                                      });
                                    },
                                  ),
                                ),*/
                                //  const SizedBox(width: 10),
                                /*Expanded(
                                  child: TextField(
                                    controller: CustomerNameController,
                                    decoration: InputDecoration(
                                      labelText: 'Name',
                                      labelStyle: const TextStyle(
                                        fontSize: 14.0,
                                      ),
                                      prefixIcon: const Icon(Icons.person,
                                          color:
                                              Color.fromARGB(255, 2, 9, 106)),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 12),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'^[a-zA-Z\s]+$'))
                                    ],
                                    onChanged: (value) {
                                      customerName = value;
                                      setState(() {
                                        if (checkTextFields()) {
                                          isButtonsLocked = false;
                                        }
                                      });
                                    },
                                    style: TextStyle(
                                      fontSize: customerFontSize,
                                      fontWeight: customerFontWeight,
                                      fontFamily: customerFontFamily,
                                    ),
                                  ),
                                ),*/
                                const SizedBox(width: 0),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    if (CustomerNameController
                                            .text.isNotEmpty ||
                                        CustomerMobileController
                                            .text.isNotEmpty ||
                                        CustomerIDController.text.isNotEmpty) {
                                      if (SelectedCustomerType.isEmpty) {
                                        // Show dialog if no customer type is selected
                                        showSelectCustomerTypeDialog(context);
                                      } else {
                                        Navigator.pushNamed(
                                            context, '/edit_customer');
                                      }
                                    } else {
                                      Navigator.pushReplacementNamed(
                                          context, '/new_customer');
                                    }
                                  },
                                  /*icon: CustomerNameController
                                              .text.isNotEmpty ||
                                          CustomerMobileController
                                              .text.isNotEmpty ||
                                          CustomerIDController.text.isNotEmpty
                                      ////? const Icon(Icons.edit)
                                      : const Icon(Icons.add),*/
                                  label: Text(
                                    CustomerNameController.text.isNotEmpty ||
                                            CustomerMobileController
                                                .text.isNotEmpty ||
                                            CustomerIDController.text.isNotEmpty
                                        ? 'Edit'
                                        : 'New',
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color.fromARGB(255, 2, 9, 106),
                                    foregroundColor: const Color.fromARGB(
                                        255, 255, 255, 255),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    minimumSize: const Size(0, 45),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            SearchCustomerDetailsPage(),
                                      ),
                                    );

                                    if (result != null) {
                                      print('Received data: $result');
                                      setState(() {
                                        CustomerIDController.text =
                                            result['customerID'] ?? '';
                                        CustomerNameController.text =
                                            result['customerName'] ?? '';
                                        CustomerMobileController.text =
                                            result['customerMobile'] ?? '';
                                        CustomerCreditLimitController.text =
                                            result['customerCreditLimit']
                                                    ?.toString() ??
                                                '0';
                                        CustomerCreditDays.text =
                                            result['customerCreditDays']
                                                    ?.toString() ??
                                                '0';
                                        CustomerBranchID.text =
                                            result['customerBranchID'] ?? '';

                                        isButtonsLocked = true; // Lock buttons

                                        customerID = result['customerID'] ?? '';
                                        customerName =
                                            result['customerName'] ?? '';
                                        customerMobile =
                                            result['customerMobile'] ?? '';
                                        customerCreditLimit =
                                            result['customerCreditLimit']
                                                    ?.toString() ??
                                                '0';
                                        customerCreditDays =
                                            result['customerCreditDays']
                                                    ?.toString() ??
                                                '0';
                                        customerBranchID =
                                            result['customerBranchID'] ?? '';

                                        fetchDistanceFromAPI(
                                            CustomerIDController.text.trim());
                                      });
                                    }
                                  },
                                  label: const Text('Search'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color.fromARGB(255, 2, 9, 106),
                                    foregroundColor:
                                        const Color.fromRGBO(255, 255, 255, 1),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    minimumSize: const Size(0, 45),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                // Container for existing 2 buttons
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    height:
                                        55, // Same height as the first container
                                    /* decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey.shade400,
                                        width: 1, // Set the width of the border
                                      ),
                                      borderRadius: BorderRadius.circular(
                                          10), // Optional: for rounded corners
                                    ),*/
                                    padding: const EdgeInsets.all(
                                        5), // Add padding inside the container
                                    child: Row(
                                      children: [
                                        // Existing "Choose Category" button
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: () {
                                              String CustomerName =
                                                  CustomerNameController.text
                                                      .trim();
                                              String CustomerMobile =
                                                  CustomerMobileController.text
                                                      .trim();

                                              if (CustomerMobile.length != 10 ||
                                                  CustomerName.isEmpty) {
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return AlertDialog(
                                                      title:
                                                          Text("Invalid Input"),
                                                      content: Text(
                                                          "Please enter a valid 10-digit phone number and customer name."),
                                                      actions: [
                                                        TextButton(
                                                          child: Text("OK"),
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop(); // close the dialog
                                                          },
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              } else {
                                                showItemCategorySelection();
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  const Color.fromARGB(
                                                      255, 2, 9, 106),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              minimumSize: const Size(50, 50),
                                            ),
                                            child: const Text(
                                              'Choose Category',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Color.fromARGB(
                                                    255, 255, 255, 255),
                                              ),
                                            ),
                                          ),
                                        ),
                                        /*const SizedBox(width: 10),
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed:
                                                (selectedItemName.isNotEmpty)
                                                    ? () {
                                                        showItemTypeSelection();
                                                      }
                                                    : null,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  selectedItemName.isNotEmpty
                                                      ? const Color.fromARGB(
                                                          255, 2, 9, 106)
                                                      : Colors.grey.shade300,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              minimumSize: const Size(50, 50),
                                            ),
                                            child: const Text(
                                              'Item Type',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: Color.fromARGB(
                                                    255, 255, 255, 255),
                                              ),
                                            ),
                                          ),
                                        ),*/
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      /* const SizedBox(height: 3),

                      // delivery details Section
                      Container(
                        padding: const EdgeInsets.all(4),
                        /*decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade400),
                        ),*/
                        child: Column(
                          //crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /*Text(
                              'Delivery Details',
                              style: TextStyle(
                                fontSize: deliveryFontSize + 2,
                                fontWeight: deliveryFontWeight,
                                fontFamily: deliveryFontFamily,
                              ),
                            ),*/

                            Row(
                              children: [
                                // Delivery Type Dropdown with only Icons
                                SizedBox(
                                  width: 60, // Adjust the width to fit the icon
                                  height: 50,
                                  child: DropdownButtonFormField<String>(
                                    value: selectedDeliveryType,
                                    items: ['Home', 'Takeaway']
                                        .map((type) => DropdownMenuItem(
                                              value: type,
                                              child: Icon(
                                                type == 'Home'
                                                    ? Icons.pedal_bike_rounded
                                                    : Icons.work_outline,
                                                color: Colors.black,
                                              ),
                                            ))
                                        .toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedDeliveryType = value.toString();

                                        if (selectedDeliveryType != "Home") {
                                          selectedAddress = null;
                                          distanceController.clear();
                                          addressID = "";
                                          customerAddress = "";
                                          houseNo = "";
                                          altPhone = "";
                                          building = "";
                                          pincode = "";
                                          placeID = "";
                                          cityID = "";
                                          landmark = "";
                                          placeName = "";
                                          cityName = "";
                                          stateName = "";
                                        }
                                      });
                                    },
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    dropdownColor: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Flexible(
                                  child: ConstrainedBox(
                                    constraints:
                                        const BoxConstraints(minWidth: 60),
                                    child: SizedBox(
                                      height: 50, // set height to 50
                                      child: isLoading
                                          ? const Center(
                                              child:
                                                  CircularProgressIndicator())
                                          : DropdownButtonFormField<String>(
                                              value: selectedTimeSlotName,
                                              items: timeSlots
                                                  .map((slot) =>
                                                      DropdownMenuItem(
                                                        value: slot[
                                                            'TimeSlotName'],
                                                        child: Text(
                                                          slot['TimeSlotName']!,
                                                          style: TextStyle(
                                                            fontSize:
                                                                deliveryFontSize,
                                                            fontWeight:
                                                                deliveryFontWeight,
                                                            fontFamily:
                                                                deliveryFontFamily,
                                                          ),
                                                        ),
                                                      ))
                                                  .toList(),
                                              onChanged:
                                                  selectedDeliveryType == "Home"
                                                      ? (value) {
                                                          setState(() {
                                                            selectedTimeSlotName =
                                                                value;
                                                            selectedTimeSlotId =
                                                                timeSlots
                                                                    .firstWhere(
                                                              (slot) =>
                                                                  slot[
                                                                      'TimeSlotName'] ==
                                                                  value,
                                                            )['TimeSlotId'];
                                                          });
                                                        }
                                                      : null,
                                              hint: const Text(
                                                "Select Time Slot",
                                                style:
                                                    TextStyle(fontSize: 14.0),
                                              ),
                                              decoration: InputDecoration(
                                                labelStyle: const TextStyle(
                                                    fontSize: 14.0),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                contentPadding: const EdgeInsets
                                                    .symmetric(
                                                    vertical: 10,
                                                    horizontal:
                                                        10), // Adjust padding for height
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 5),
                                // Delivery Address TextField with adjusted width
                                Flexible(
                                  flex: 2,
                                  child: SizedBox(
                                    height: 50, // Set height to 50
                                    child: DropdownButtonFormField<
                                        Map<String, dynamic>>(
                                      value: selectedDeliveryType == "Home"
                                          ? selectedAddress
                                          : null,
                                      hint: Text('Delivery Address'),
                                      items: selectedDeliveryType == "Home"
                                          ? customerDetailsList?.map((address) {
                                              return DropdownMenuItem<
                                                  Map<String, dynamic>>(
                                                value: address,
                                                child: Text(
                                                  "${address['AddressID']}, ${address['PlaceName']}, ${address['CityName']}, ${address['StateName']}",
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              );
                                            }).toList()
                                          : [],
                                      // Show no items if delivery type is not "Home"
                                      onChanged: selectedDeliveryType == "Home"
                                          ? (selected) {
                                              if (selected != null) {
                                                setState(() {
                                                  selectedAddress = selected;
                                                  distanceController.text =
                                                      selected['KmDistance']
                                                              ?.toString() ??
                                                          "";
                                                  addressID =
                                                      selected['AddressID'] ??
                                                          "";
                                                  customerAddress = selected[
                                                          'CustomerAddress'] ??
                                                      "";
                                                  houseNo =
                                                      selected['HouseNo'] ?? "";
                                                  altPhone =
                                                      selected['AltPhone'] ??
                                                          "";
                                                  building =
                                                      selected['Building'] ??
                                                          "";
                                                  pincode =
                                                      selected['PINCODE'] ?? "";
                                                  placeID =
                                                      selected['PlaceID'] ?? "";
                                                  cityID =
                                                      selected['CityID'] ?? "";
                                                  landmark =
                                                      selected['Landmark'] ??
                                                          "";
                                                  placeName =
                                                      selected['PlaceName'] ??
                                                          "";
                                                  cityName =
                                                      selected['CityName'] ??
                                                          "";
                                                  stateName =
                                                      selected['StateName'] ??
                                                          "";
                                                });
                                              }
                                            }
                                          : null,
                                      // Disable onChanged if not "Home"
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),
                            // Text fields for Distance, and Price
                            Row(
                              children: [
                                const SizedBox(width: 1),
                                Expanded(
                                  flex: 1,
                                  child: TextField(
                                    controller: distanceController,
                                    enabled: selectedDeliveryType == 'Home',
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      // Allows only numeric input
                                    ],
                                    decoration: InputDecoration(
                                      labelText: 'Dis (km)',
                                      /*prefixIcon: const Icon(Icons.straighten,
                                          color:
                                              Color.fromARGB(255, 2, 9, 106)),*/
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      labelStyle: const TextStyle(
                                        fontSize: 14.0,
                                      ),
                                    ),
                                    style: TextStyle(
                                      fontSize: deliveryFontSize,
                                      fontWeight: deliveryFontWeight,
                                      fontFamily: deliveryFontFamily,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 2,
                                  child: TextField(
                                    controller: deliveryChargesController,
                                    enabled: selectedDeliveryType == 'Home',
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: 'Freight charges',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      labelStyle:
                                          const TextStyle(fontSize: 14.0),
                                    ),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      // Allows only numeric input
                                    ],
                                    onChanged: (value) {
                                      updateTotalPrice();
                                    },
                                    style: TextStyle(
                                      fontSize: deliveryFontSize,
                                      fontWeight: deliveryFontWeight,
                                      fontFamily: deliveryFontFamily,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 1,
                                  child: TextField(
                                    enabled: selectedDeliveryType == 'Home',
                                    decoration: InputDecoration(
                                      labelText: 'Vehicle Trip',
                                      prefixIcon: const Icon(
                                          Icons.directions_car,
                                          color:
                                              Color.fromARGB(255, 2, 9, 106)),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      labelStyle: const TextStyle(
                                        fontSize: 14.0,
                                      ),
                                    ),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      // Allows only numeric input
                                    ],
                                    style: TextStyle(
                                      fontSize: deliveryFontSize,
                                      fontWeight: deliveryFontWeight,
                                      fontFamily: deliveryFontFamily,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton.icon(
                                  onPressed: selectedDeliveryType == 'Home'
                                      ? () {
                                          Navigator.pushReplacementNamed(
                                              context, '/new_vehicle');
                                        }
                                      : null,
                                  //icon: const Icon(Icons.bike_scooter),
                                  label: const Text('New'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color.fromARGB(255, 2, 9, 106),
                                    foregroundColor:
                                        const Color.fromRGBO(255, 255, 255, 1),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    minimumSize: const Size(0, 45),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),*/
                      const SizedBox(height: 0),

                      // Add the item section
                      Container(
                        padding: const EdgeInsets.all(4),
                        /*decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade400),
                        ),*/
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /*Text(
                              'Item Details',
                              style: TextStyle(
                                fontSize: itemFontSize + 2,
                                fontWeight: itemFontWeight,
                                fontFamily: itemFontFamily,
                              ),
                            ),*/
                            //const SizedBox(height: 5),
                            Row(
                              children: [
                                // Container for API buttons (5 buttons)
                                /*Expanded(
                                  flex: 2,
                                  child: Container(
                                    height: 50,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey.shade400,
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.all(5),
                                    child: Row(
                                      children: [
                                        ...transactionSubTypes.map((type) {
                                          return Expanded(
                                            child: GestureDetector(
                                              onTap: () {
                                                if (!isDeliveryButtonSelected) {
                                                  setState(() {
                                                    selectedTransactionSubType =
                                                        type['TranSubTypeId']!;
                                                    TransactionTypeID = type[
                                                        'TransactionTypeId'];
                                                  });
                                                }
                                              },
                                              child: Container(
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 1),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 8),
                                                decoration: BoxDecoration(
                                                  color:
                                                      selectedTransactionSubType ==
                                                              type[
                                                                  'TranSubTypeId']
                                                          ? const Color
                                                              .fromARGB(
                                                              255, 2, 9, 106)
                                                          : Colors
                                                              .grey.shade300,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    type['TranSubTypeId'] ?? "",
                                                    style: TextStyle(
                                                      fontSize: 8,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      color: selectedTransactionSubType ==
                                                              type[
                                                                  'TranSubTypeId']
                                                          ? Colors.white
                                                          : Colors.black,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        }),
                                      ],
                                    ),
                                  ),
                                ),*/

                                // const SizedBox(width: 8),

                                // Container for existing 2 buttons
                                /* Expanded(
                                  flex: 1,
                                  child: Container(
                                    height:
                                        50, // Same height as the first container
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey.shade400,
                                        width: 1, // Set the width of the border
                                      ),
                                      borderRadius: BorderRadius.circular(
                                          10), // Optional: for rounded corners
                                    ),
                                    padding: const EdgeInsets.all(
                                        5), // Add padding inside the container
                                    child: Row(
                                      children: [
                                        // Existing "Choose Category" button
                                        /*Expanded(
                                          child: ElevatedButton(
                                            onPressed: () {
                                              showItemCategorySelection();
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  const Color.fromARGB(
                                                      255, 2, 9, 106),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              minimumSize: const Size(50, 50),
                                            ),
                                            child: const Text(
                                              'Choose Category',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: Color.fromARGB(
                                                    255, 255, 255, 255),
                                              ),
                                            ),
                                          ),
                                        ),*/
                                        /*const SizedBox(width: 10),
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed:
                                                (selectedItemName.isNotEmpty)
                                                    ? () {
                                                        showItemTypeSelection();
                                                      }
                                                    : null,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  selectedItemName.isNotEmpty
                                                      ? const Color.fromARGB(
                                                          255, 2, 9, 106)
                                                      : Colors.grey.shade300,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              minimumSize: const Size(50, 50),
                                            ),
                                            child: const Text(
                                              'Item Type',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: Color.fromARGB(
                                                    255, 255, 255, 255),
                                              ),
                                            ),
                                          ),
                                        ),*/
                                      ],
                                    ),
                                  ),
                                ),*/
                              ],
                            ),
                            const SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  selectedItemName != ''
                                      ? (selectedItemType != null
                                          ? '$selectedItemName / $selectedItemType'
                                          : '$selectedItemName / Item Type') // If type not selected
                                      : 'Category / Item Type',
                                  // Default text
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            Row(
                              children: [
                                const SizedBox(width: 0),
                                Expanded(
                                    flex: 1,
                                    child: GestureDetector(
                                      onTap: () {},
                                      child: AbsorbPointer(
                                        child: TextField(
                                          controller: batchNoController,
                                          enabled: isBatchTextFieldEnabled(),
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                            labelText: 'Batch No.',
                                            labelStyle: const TextStyle(
                                              fontSize:
                                                  14.0, // Set your desired font size
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          style: TextStyle(
                                            fontSize: itemFontSize,
                                            fontWeight: itemFontWeight,
                                            fontFamily: itemFontFamily,
                                          ),
                                        ),
                                      ),
                                    )),
                                const SizedBox(width: 5),
                                Expanded(
                                  flex: 2,
                                  child: TextField(
                                    focusNode: quantityFocusNode,
                                    controller: quantityController,
                                    enabled: isNumberTextFieldEnabled(),
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: 'Nos',
                                      labelStyle:
                                          const TextStyle(fontSize: 14.0),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      errorText:
                                          isQtyInvalid ? qtyErrorText : null,
                                    ),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    onChanged: (value) {
                                      if (value.isEmpty) {
                                        setState(() {
                                          isQtyInvalid = false;
                                          qtyErrorText = null;
                                        });
                                        return;
                                      }

                                      final enteredQty = double.tryParse(value);

                                      if (enteredQty == null) {
                                        setState(() {
                                          isQtyInvalid = true;
                                          qtyErrorText = 'Invalid quantity';
                                        });
                                        return;
                                      }

                                      if (enteredQty > itemStockQty) {
                                        setState(() {
                                          isQtyInvalid = true;
                                          qtyErrorText =
                                              'Cannot be more than $itemStockQty';
                                        });
                                      } else {
                                        setState(() {
                                          isQtyInvalid = false;
                                          qtyErrorText = null;
                                        });
                                      }
                                    },
                                    style: TextStyle(
                                      fontSize: itemFontSize,
                                      fontWeight: itemFontWeight,
                                      fontFamily: itemFontFamily,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Expanded(
                                  flex: 2,
                                  child: TextField(
                                    focusNode: weightFocusNode,
                                    controller: weightController,
                                    enabled: isWeightTextFieldEnabled(),
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: 'Weight (kg)',
                                      labelStyle:
                                          const TextStyle(fontSize: 14.0),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      errorText: isWeightInvalid
                                          ? weightErrorText
                                          : null,
                                    ),
                                    style: TextStyle(
                                      fontSize: itemFontSize,
                                      fontWeight: itemFontWeight,
                                      fontFamily: itemFontFamily,
                                    ),
                                    onChanged: (value) {
                                      if (value.isEmpty) {
                                        setState(() {
                                          isWeightInvalid = false;
                                          weightErrorText = null;
                                        });
                                        return;
                                      }

                                      final enteredWeight =
                                          double.tryParse(value);

                                      if (enteredWeight == null) {
                                        setState(() {
                                          isWeightInvalid = true;
                                          weightErrorText = 'Invalid weight';
                                        });
                                        return;
                                      }

                                      if (enteredWeight > itemStockQty) {
                                        setState(() {
                                          isWeightInvalid = true;
                                          weightErrorText =
                                              'Cannot be more than $itemStockQty';
                                        });
                                      } else {
                                        setState(() {
                                          isWeightInvalid = false;
                                          weightErrorText = null;
                                        });
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 5),
                                SizedBox(
                                  width: 166,
                                  child: DropdownButtonFormField<String>(
                                    value: selectedDiscountType,
                                    items: [
                                      DropdownMenuItem<String>(
                                        value: 'None',
                                        child: Text('None'),
                                      ),
                                      DropdownMenuItem<String>(
                                        value: 'Total value',
                                        child: Text('Total value'),
                                      ),
                                      DropdownMenuItem<String>(
                                        value: 'Total kg',
                                        child: Text('Total kg'),
                                      ),
                                      DropdownMenuItem<String>(
                                        value: 'Total percentage',
                                        child: Text('Total percentage'),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        selectedDiscountType = value;
                                        discountController.text = '';
                                      });
                                      updateDiscountPrice();
                                    },
                                    decoration: InputDecoration(
                                      labelText: 'Discount',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 12, horizontal: 12),
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
                                    child: TextFormField(
                                      controller: discountController,
                                      keyboardType:
                                          TextInputType.numberWithOptions(
                                              decimal: true),
                                      // Corrected line
                                      decoration: InputDecoration(
                                        labelText: 'Discount %',
                                        labelStyle: const TextStyle(
                                          fontSize: 14.0,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                            RegExp(r'^\d*\.?\d*')),
                                      ],
                                      onChanged: (value) {
                                        updateDiscountPrice();
                                      },
                                      style: TextStyle(
                                        fontSize: itemFontSize,
                                        fontWeight: itemFontWeight,
                                        fontFamily: itemFontFamily,
                                      ),
                                    )),
                                const SizedBox(width: 5),
                                Expanded(
                                  flex: 1,
                                  child: GestureDetector(
                                    onTap: () {
                                      if (!isOverrideChecked) {
                                        FocusScope.of(context)
                                            .unfocus(); // Prevent keyboard popup
                                      }
                                    },
                                    child: AbsorbPointer(
                                      absorbing: !isOverrideChecked,
                                      // Block touches when unchecked
                                      child: TextField(
                                        controller: priceController,
                                        readOnly: !isOverrideChecked,
                                        keyboardType:
                                            TextInputType.numberWithOptions(
                                                decimal: true),
                                        decoration: InputDecoration(
                                          labelText: 'Price per Unit',
                                          labelStyle:
                                              const TextStyle(fontSize: 14.0),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                              RegExp(r'^\d*\.?\d*')),
                                        ],
                                        onChanged: (value) {
                                          setState(() {
                                            double? enteredPrice =
                                                double.tryParse(value);
                                            if (enteredPrice != null &&
                                                enteredPrice < ItemDayRate) {
                                              validationMessage =
                                                  "Price cannot be less than $ItemDayRate";
                                            } else {
                                              validationMessage = "";
                                            }
                                          });
                                        },
                                        style: TextStyle(
                                          fontSize: itemFontSize,
                                          fontWeight: itemFontWeight,
                                          fontFamily: itemFontFamily,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Checkbox(
                                  value: isOverrideChecked,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      isOverrideChecked = value ?? false;
                                      if (!isOverrideChecked) {
                                        priceController.text =
                                            ItemDayRate.toString();
                                        validationMessage = "";
                                      }
                                    });
                                  },
                                ),
                                const Text("OverRide",
                                    style: TextStyle(fontSize: 13)),
                                const SizedBox(width: 5),
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                          0, 255, 255, 255),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      'Total Price: ₹${totalPrice.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            const Color.fromARGB(255, 0, 0, 0),
                                        fontFamily: itemFontFamily,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 1,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      addItemToTable();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          const Color.fromARGB(255, 2, 9, 106),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(9),
                                      ),
                                      minimumSize: const Size(0, 52),
                                    ),
                                    child: Text(
                                      'Add',
                                      style: TextStyle(
                                        fontSize: itemFontSize,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontFamily: itemFontFamily,
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
                                  flex: 4,
                                  child: TextField(
                                    controller: remarksController,
                                    decoration: InputDecoration(
                                      labelText: 'Remarks',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      labelStyle: const TextStyle(
                                        fontSize: 14.0,
                                      ),
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        remarks = value.toString();
                                      });
                                    },
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'^[a-zA-Z\s]+$'))
                                    ],
                                    style: TextStyle(
                                      fontSize: deliveryFontSize,
                                      fontWeight: deliveryFontWeight,
                                      fontFamily: deliveryFontFamily,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  flex: 1,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        selectedRowIndex = null;

                                        batchNoController.clear();
                                        priceController.clear();
                                        weightController.clear();
                                        quantityController.clear();
                                        discountController.clear();
                                        selectedItemName = '';
                                        selectedItemType = null;
                                        selectedBatchEnabled = false;
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          const Color.fromARGB(255, 2, 9, 106),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(9),
                                      ),
                                      minimumSize: const Size(0, 52),
                                    ),
                                    child: Text(
                                      'X',
                                      style: TextStyle(
                                        fontSize: itemFontSize,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontFamily: itemFontFamily,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              height: 220,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade400),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: SingleChildScrollView(
                                  child: DataTable(
                                    headingRowColor: WidgetStateProperty.all(
                                        const Color.fromARGB(255, 2, 9, 106)),
                                    columns: const [
                                      DataColumn(
                                          label: Text('Select',
                                              style: TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 255, 255, 255)))),
                                      // Checkbox Column
                                      DataColumn(
                                          label: Text('BatchNo',
                                              style: TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 255, 255, 255)))),
                                      DataColumn(
                                          label: Text('Item Name',
                                              style: TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 255, 255, 255)))),
                                      DataColumn(
                                          label: Text('Price',
                                              style: TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 255, 255, 255)))),
                                      DataColumn(
                                          label: Text('Weight (kg)',
                                              style: TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 255, 255, 255)))),
                                      DataColumn(
                                          label: Text('Quantity',
                                              style: TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 255, 255, 255)))),
                                      DataColumn(
                                          label: Text('Total Price',
                                              style: TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 255, 255, 255)))),
                                    ],
                                    rows: List.generate(itemTableDetails.length,
                                        (index) {
                                      var item = itemTableDetails[index];
                                      return DataRow(
                                        selected: selectedRows.contains(index),
                                        cells: [
                                          DataCell(Checkbox(
                                            value: selectedRows.contains(index),
                                            onChanged: (bool? selected) {
                                              setState(() {
                                                if (selected == true) {
                                                  selectedRows.add(index);
                                                } else {
                                                  selectedRows.remove(index);
                                                }
                                              });
                                            },
                                          )),
                                          DataCell(
                                            Text(item['batchNo'].toString()),
                                            onTap: () {
                                              setState(() {
                                                selectedRowIndex = index;
                                                batchNoController.text = item[
                                                    'batchNo']; // Track index for editing
                                                selectedItemName =
                                                    item['itemName'];
                                                selectedItemType =
                                                    item['itemType'];
                                                priceController.text =
                                                    item['price'].toString();
                                                weightController.text =
                                                    item['weight'] > 0
                                                        ? item['weight']
                                                            .toString()
                                                        : '';
                                                quantityController.text =
                                                    item['quantity'] > 0
                                                        ? item['quantity']
                                                            .toString()
                                                        : '';
                                                selectedAltQtyEnabled =
                                                    item["ItemAltQtyEnabled"];
                                                selectedSellByWeight =
                                                    item["ItemSellByWeight"];
                                                selectedBatchEnabled =
                                                    item["BatchEnabled"];
                                                minWeight = item["minWeight"];
                                                maxWeight = item["maxWeight"];
                                                itemStockQty =
                                                    item["itemStockQTY"];
                                                itemStockAltQty =
                                                    item['itemStockALTQTY'];
                                              });
                                            },
                                          ),
                                          DataCell(
                                            Text(item['itemType'].toString()),
                                            onTap: () {
                                              setState(() {
                                                selectedRowIndex =
                                                    index; // Track index for editing
                                                batchNoController.text =
                                                    item['batchNo'];
                                                selectedItemName =
                                                    item['itemName'];
                                                selectedItemType =
                                                    item['itemType'];
                                                priceController.text =
                                                    item['price'].toString();
                                                weightController.text =
                                                    item['weight'] > 0
                                                        ? item['weight']
                                                            .toString()
                                                        : '';
                                                quantityController.text =
                                                    item['quantity'] > 0
                                                        ? item['quantity']
                                                            .toString()
                                                        : '';
                                                selectedAltQtyEnabled =
                                                    item["ItemAltQtyEnabled"];
                                                selectedSellByWeight =
                                                    item["ItemSellByWeight"];
                                                selectedBatchEnabled =
                                                    item["BatchEnabled"];
                                                minWeight = item["minWeight"];
                                                maxWeight = item["maxWeight"];
                                                itemStockQty =
                                                    item["itemStockQTY"];
                                                itemStockAltQty =
                                                    item['itemStockALTQTY'];
                                              });
                                            },
                                          ),
                                          DataCell(
                                            Text('₹${item['price']}'),
                                            onTap: () {
                                              setState(() {
                                                selectedRowIndex =
                                                    index; // Track index for editing
                                                batchNoController.text =
                                                    item['batchNo'];
                                                selectedItemName =
                                                    item['itemName'];
                                                selectedItemType =
                                                    item['itemType'];
                                                priceController.text =
                                                    item['price'].toString();
                                                weightController.text =
                                                    item['weight'] > 0
                                                        ? item['weight']
                                                            .toString()
                                                        : '';
                                                quantityController.text =
                                                    item['quantity'] > 0
                                                        ? item['quantity']
                                                            .toString()
                                                        : '';

                                                selectedAltQtyEnabled =
                                                    item["ItemAltQtyEnabled"];
                                                selectedSellByWeight =
                                                    item["ItemSellByWeight"];
                                                selectedBatchEnabled =
                                                    item["BatchEnabled"];
                                                minWeight = item["minWeight"];
                                                maxWeight = item["maxWeight"];
                                                itemStockQty =
                                                    item["itemStockQTY"];
                                                itemStockAltQty =
                                                    item['itemStockALTQTY'];
                                              });
                                            },
                                          ),
                                          DataCell(
                                            Text('${item['weight']} kg'),
                                            onTap: () {
                                              setState(() {
                                                selectedRowIndex =
                                                    index; // Track index for editing
                                                batchNoController.text =
                                                    item['batchNo'];
                                                selectedItemName =
                                                    item['itemName'];
                                                selectedItemType =
                                                    item['itemType'];
                                                priceController.text =
                                                    item['price'].toString();
                                                weightController.text =
                                                    item['weight'] > 0
                                                        ? item['weight']
                                                            .toString()
                                                        : '';
                                                quantityController.text =
                                                    item['quantity'] > 0
                                                        ? item['quantity']
                                                            .toString()
                                                        : '';

                                                selectedAltQtyEnabled =
                                                    item["ItemAltQtyEnabled"];
                                                selectedSellByWeight =
                                                    item["ItemSellByWeight"];
                                                selectedBatchEnabled =
                                                    item["BatchEnabled"];
                                                minWeight = item["minWeight"];
                                                maxWeight = item["maxWeight"];
                                                itemStockQty =
                                                    item["itemStockQTY"];
                                                itemStockAltQty =
                                                    item['itemStockALTQTY'];
                                              });
                                            },
                                          ),
                                          DataCell(
                                            Text(item['quantity'].toString()),
                                            onTap: () {
                                              setState(() {
                                                selectedRowIndex =
                                                    index; // Track index for editing
                                                batchNoController.text =
                                                    item['batchNo'];
                                                selectedItemName =
                                                    item['itemName'];
                                                selectedItemType =
                                                    item['itemType'];
                                                priceController.text =
                                                    item['price'].toString();
                                                weightController.text =
                                                    item['weight'] > 0
                                                        ? item['weight']
                                                            .toString()
                                                        : '';
                                                quantityController.text =
                                                    item['quantity'] > 0
                                                        ? item['quantity']
                                                            .toString()
                                                        : '';

                                                selectedAltQtyEnabled =
                                                    item["ItemAltQtyEnabled"];
                                                selectedSellByWeight =
                                                    item["ItemSellByWeight"];
                                                selectedBatchEnabled =
                                                    item["BatchEnabled"];
                                                minWeight = item["minWeight"];
                                                maxWeight = item["maxWeight"];
                                                itemStockQty =
                                                    item["itemStockQTY"];
                                                itemStockAltQty =
                                                    item['itemStockALTQTY'];
                                              });
                                            },
                                          ),
                                          DataCell(
                                            Text('₹${item['totalPrice']}'),
                                            onTap: () {
                                              setState(() {
                                                selectedRowIndex =
                                                    index; // Track index for editing
                                                batchNoController.text =
                                                    item['batchNo'];
                                                selectedItemName =
                                                    item['itemName'];
                                                selectedItemType =
                                                    item['itemType'];
                                                priceController.text =
                                                    item['price'].toString();
                                                weightController.text =
                                                    item['weight'] > 0
                                                        ? item['weight']
                                                            .toString()
                                                        : '';
                                                quantityController.text =
                                                    item['quantity'] > 0
                                                        ? item['quantity']
                                                            .toString()
                                                        : '';

                                                selectedAltQtyEnabled =
                                                    item["ItemAltQtyEnabled"];
                                                selectedSellByWeight =
                                                    item["ItemSellByWeight"];
                                                selectedBatchEnabled =
                                                    item["BatchEnabled"];
                                                minWeight = item["minWeight"];
                                                maxWeight = item["maxWeight"];
                                                itemStockQty =
                                                    item["itemStockQTY"];
                                                itemStockAltQty =
                                                    item['itemStockALTQTY'];
                                              });
                                            },
                                          ),
                                        ],
                                      );
                                    }),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 2),
                                  child: ElevatedButton(
                                    onPressed: deleteSelectedRows,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 14),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // First Row: Kg, Nos, Amount
                                      Row(
                                        children: [
                                          const SizedBox(
                                            width: 50,
                                            child: Text(
                                              'Kg : ',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Times New Roman',
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 70,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 5),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors.black),
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              child: Text(
                                                itemTableDetails
                                                    .fold(
                                                        0.0,
                                                        (sum, item) =>
                                                            sum +
                                                            (item['weight']
                                                                    as num)
                                                                .toDouble())
                                                    .toStringAsFixed(3),
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: 'Times New Roman',
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 20),
                                          const SizedBox(
                                            width: 50,
                                            child: Text(
                                              'Nos : ',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Times New Roman',
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 40),
                                          SizedBox(
                                            width: 70,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 5),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors.black),
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              child: Text(
                                                itemTableDetails
                                                    .fold(
                                                        0,
                                                        (sum, item) =>
                                                            sum +
                                                            (item['quantity']
                                                                    as num)
                                                                .toInt())
                                                    .toString(),
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: 'Times New Roman',
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 20),
                                          const SizedBox(
                                            width: 80,
                                            child: Text(
                                              'Amount : ',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Times New Roman',
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          SizedBox(
                                            width: 70,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 5),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors.black),
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              child: Text(
                                                '₹${totalItemPrice.toStringAsFixed(2)}',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: 'Times New Roman',
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 5),
                                      // Second Row: Tax, Discount, Total
                                      Row(
                                        children: [
                                          const SizedBox(
                                            width: 50,
                                            child: Text(
                                              'Tax : ',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Times New Roman',
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 70,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 5),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors.black),
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              child: Text(
                                                '₹${totalTax.toStringAsFixed(2)}',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: 'Times New Roman',
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 19),
                                          const SizedBox(
                                            width: 90,
                                            child: Text(
                                              'Discount : ',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Times New Roman',
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 70,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 5),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors.black),
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              child: Text(
                                                '₹${totalDiscount.toStringAsFixed(2)}',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: 'Times New Roman',
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 22),
                                          const SizedBox(
                                            width: 60,
                                            child: Text(
                                              'Total : ',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Times New Roman',
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 26),
                                          SizedBox(
                                            width: 70,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 5),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors.black),
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              child: Text(
                                                '₹${roundedTotal.toStringAsFixed(2)}',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: 'Times New Roman',
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
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
  String selectedMenu = 'Billing';
  bool showDropdown = false;

  final List<String> menuOptions = [
    'Billing',
    'Stock',
    // 'Logistics',
    // 'Finance',
    // 'HR',
    // 'Utils',
    'Reports',
    'Exit',
  ];

  //stock drop down
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
                  }
                  if (dropdownOption['title'] == 'Test') {
                    Navigator.pushReplacementNamed(context, '/test');
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

// 3 widget LEFT
  Widget _buildDropdownBelowHR() {
    RenderBox? box =
        hrButtonKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return const SizedBox.shrink();
// 8 LINES
    Offset position = box.localToGlobal(Offset.zero);
    double buttonLeft = position.dx;
    double buttonBottom = position.dy + box.size.height;
    double buttonWidth = box.size.width;
    double screenWidth = MediaQuery.of(context).size.width;

    return Positioned(
      top: buttonBottom + 5,
      right: screenWidth - (buttonLeft + buttonWidth),
      //END in all files
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

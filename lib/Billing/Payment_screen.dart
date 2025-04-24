import 'package:abis2/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:abis2/api_handling/PaymentMethodsAPI.dart';
import 'package:abis2/api_handling/PaymentGatewayAPI.dart';

class PaymentScreen extends StatefulWidget {
  String itemTotalPrice;
  String totalPrice;

  PaymentScreen(
      {super.key, required this.totalPrice, required this.itemTotalPrice});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  @override
  void initState() {
    super.initState();
    fetchPaymentMethods();
    lineNumberController.text = "001";
    billAmountController.text = widget.totalPrice;
    amountController.text = widget.itemTotalPrice;
  }

  List<Map<String, dynamic>> paymentsMethods = [];
  bool isLoading = true;
  String? selectedPaymentMethodId;
  String? selectedPaymentGatewayId;
  String? selectedPaymentGatewayName;

  double text_Field_Font_Size = 16.0;
  FontWeight text_Field_Font_Weight = FontWeight.bold;
  String text_Field_Font_Family = 'Times New Roman';

  double payment_Button_Font_Size = 16.0;
  FontWeight payment_Button_Font_Weight = FontWeight.bold;
  String payment_Button_Font_Family = 'Times New Roman';

  TextEditingController lineNumberController = TextEditingController();
  TextEditingController receiptModeController = TextEditingController();

  TextEditingController utrNumberController = TextEditingController();

  TextEditingController billAmountController = TextEditingController();
  TextEditingController totalAmountController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  String change = "";

  void calculateChange() {
    double billAmount = double.tryParse(billAmountController.text) ?? 0.0;
    double totalAmount = double.tryParse(totalAmountController.text) ?? 0.0;
    double changeAmount = totalAmount - billAmount;

    setState(() {
      change = changeAmount >= 0
          ? changeAmount.toStringAsFixed(2)
          : "Insufficient amount";
    });
  }

  Future<void> fetchPaymentMethods() async {
    try {
      final methods =
          await Paymentmethodsapi.fetchPaymentsMethods('L101', BearerToken);
      setState(() { 
        paymentsMethods = methods;
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching payment methods: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Payment Screen'),
          backgroundColor: const Color.fromARGB(255, 2, 9, 106),
          foregroundColor: Colors.white,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, {
                  'paymentMethodId': selectedPaymentMethodId,
                  'paymentGatewayId': selectedPaymentGatewayId,
                  'paymentGatewayName': selectedPaymentGatewayName,
                  'action': 'back', // Indicating Back action
                });
              },
              child: const Text(
                'Back',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: TextField(
                        style: TextStyle(
                          fontSize: text_Field_Font_Size,
                          fontFamily: text_Field_Font_Family,
                          fontWeight: text_Field_Font_Weight,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Current Balance',
                          labelStyle: TextStyle(
                            fontSize: 14,
                            fontFamily: text_Field_Font_Family,
                            fontWeight: text_Field_Font_Weight,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    Expanded(
                      flex: 1,
                      child: TextField(
                        style: TextStyle(
                          fontSize: text_Field_Font_Size,
                          fontFamily: text_Field_Font_Family,
                          fontWeight: text_Field_Font_Weight,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Bill',
                          labelStyle: TextStyle(
                            fontSize: 14,
                            fontFamily: text_Field_Font_Family,
                            fontWeight: text_Field_Font_Weight,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 1,
                      child: TextField(
                        controller: utrNumberController,
                        enabled: selectedPaymentGatewayName != "Cash",
                        style: TextStyle(
                          fontSize: text_Field_Font_Size,
                          fontFamily: text_Field_Font_Family,
                          fontWeight: text_Field_Font_Weight,
                        ),
                        decoration: InputDecoration(
                          labelText: 'UTR No.',
                          labelStyle: TextStyle(
                            fontSize: 14,
                            fontFamily: text_Field_Font_Family,
                            fontWeight: text_Field_Font_Weight,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          errorText: (utrNumberController.text.isNotEmpty &&
                                  !RegExp(r'^\d{12}$')
                                      .hasMatch(utrNumberController.text))
                              ? 'UTR No. must be exactly 12 digits'
                              : null,
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter
                              .digitsOnly, // Allow only digits
                          LengthLimitingTextInputFormatter(
                              12), // Limit input to 12 characters
                        ],
                      ),
                    ),
                  ],
                ),
                // const SizedBox(height: 16.0),
                /*Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: TextField(
                        controller: lineNumberController,
                        readOnly: true,
                        style: TextStyle(
                          fontSize: text_Field_Font_Size,
                          fontFamily: text_Field_Font_Family,
                          fontWeight: text_Field_Font_Weight,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Line',
                          labelStyle: TextStyle(
                            fontSize: text_Field_Font_Size,
                            fontFamily: text_Field_Font_Family,
                            fontWeight: text_Field_Font_Weight,
                          ),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      flex: 1,
                      child: TextField(
                        controller: receiptModeController,
                        readOnly: true,
                        style: TextStyle(
                          fontSize: text_Field_Font_Size,
                          fontFamily: text_Field_Font_Family,
                          fontWeight: text_Field_Font_Weight,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Receipt Mode',
                          labelStyle: TextStyle(
                            fontSize: text_Field_Font_Size,
                            fontFamily: text_Field_Font_Family,
                            fontWeight: text_Field_Font_Weight,
                          ),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),*/
                // const SizedBox(height: 16.0),
                /* Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: TextField(
                        enabled: selectedPaymentMethodName != "Cash" ? true : false,
                        style: TextStyle(
                          fontSize: text_Field_Font_Size,
                          fontFamily: text_Field_Font_Family,
                          fontWeight: text_Field_Font_Weight,
                        ),
                        decoration: InputDecoration(
                          labelText: 'UTR No/Authorization Code',
                          labelStyle: TextStyle(
                            fontSize: text_Field_Font_Size,
                            fontFamily: text_Field_Font_Family,
                            fontWeight: text_Field_Font_Weight,
                          ),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                */
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(
                        flex: 1,
                        child: GestureDetector(
                          onTap: () {},
                          child: AbsorbPointer(
                            child: TextField(
                              controller: amountController,
                              style: TextStyle(
                                fontSize: text_Field_Font_Size,
                                fontFamily: text_Field_Font_Family,
                                fontWeight: text_Field_Font_Weight,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Amount',
                                labelStyle: TextStyle(
                                  fontSize: 14,
                                  fontFamily: text_Field_Font_Family,
                                  fontWeight: text_Field_Font_Weight,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                prefixIcon: const Icon(Icons.currency_rupee),
                              ),
                            ),
                          ),
                        )),
                    const SizedBox(width: 16.0),
                    Expanded(
                      flex: 1,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 2, 9, 106),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            )),
                        child: Text('Update',
                            style: TextStyle(
                              fontSize: payment_Button_Font_Size,
                              fontFamily: payment_Button_Font_Family,
                              fontWeight: payment_Button_Font_Weight,
                            )),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        flex: 1,
                        child: GestureDetector(
                          onTap: () {},
                          child: AbsorbPointer(
                            child: TextField(
                              controller: billAmountController,
                              keyboardType: TextInputType.number,
                              style: TextStyle(
                                fontSize: text_Field_Font_Size,
                                fontFamily: text_Field_Font_Family,
                                fontWeight: text_Field_Font_Weight,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Bill Amount',
                                labelStyle: TextStyle(
                                  fontSize: 14,
                                  fontFamily: text_Field_Font_Family,
                                  fontWeight: text_Field_Font_Weight,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                prefixIcon: const Icon(Icons.currency_rupee),
                              ),
                              onChanged: (value) => calculateChange(),
                            ),
                          ),
                        )),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 1,
                      child: TextField(
                        style: TextStyle(
                          fontSize: text_Field_Font_Size,
                          fontFamily: text_Field_Font_Family,
                          fontWeight: text_Field_Font_Weight,
                        ),
                        controller: totalAmountController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Total Amount Received',
                          labelStyle: TextStyle(
                            fontSize: 14,
                            fontFamily: text_Field_Font_Family,
                            fontWeight: text_Field_Font_Weight,
                          ),
                          prefixIcon: const Icon(Icons.currency_rupee),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onChanged: (value) => calculateChange(),
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      flex: 1,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'Change: ',
                            style: TextStyle(
                              fontSize: text_Field_Font_Size,
                              fontFamily: text_Field_Font_Family,
                              fontWeight: text_Field_Font_Weight,
                            ),
                          ),
                          Text(
                            '₹$change',
                            style: TextStyle(
                              fontSize: 18,
                              color: change == "Insufficient amount"
                                  ? Colors.red
                                  : Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: isLoading
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: paymentsMethods.map((method) {
                            final paymentMethodId =
                                method['PaymentMethodId'] as String;
                            final paymentGatewayName =
                                method['PaymentGatewayName'] as String;
                            final paymentGatewayId =
                                method['PaymentGatewayId'] as String;
                            final isSelected =
                                selectedPaymentMethodId == paymentMethodId;

                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    selectedPaymentMethodId = paymentMethodId;
                                    receiptModeController.text =
                                        paymentGatewayName;
                                    selectedPaymentGatewayName =
                                        paymentGatewayName;
                                    selectedPaymentGatewayId = paymentGatewayId;
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isSelected
                                      ? const Color.fromARGB(255, 2, 9, 106)
                                      : Colors.grey,
                                  foregroundColor:
                                      isSelected ? Colors.white : Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  paymentGatewayName,
                                  style: TextStyle(
                                    fontSize: payment_Button_Font_Size,
                                    fontFamily: payment_Button_Font_Family,
                                    fontWeight: payment_Button_Font_Weight,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: ElevatedButton(
                        onPressed: () {
                          if (selectedPaymentGatewayName == null) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title:
                                      const Text("Payment option not selected"),
                                  content: const Text(
                                      "Please select a payment option"),
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
                          } else if ((selectedPaymentGatewayName == "UPI" ||
                                  selectedPaymentGatewayName == "Debit Card") &&
                              utrNumberController.text.isEmpty) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text("UTR number not entered"),
                                  content:
                                      const Text("Please enter the UTR number"),
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
                            Navigator.pop(context, {
                              'paymentMethodId': selectedPaymentMethodId,
                              'paymentGatewayId': selectedPaymentGatewayId,
                              'paymentGatewayName': selectedPaymentGatewayName,
                              'action': 'save', // Indicating Save action
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 2, 9, 106),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            )),
                        child: Text('Save',
                            style: TextStyle(
                              fontSize: payment_Button_Font_Size,
                              fontFamily: payment_Button_Font_Family,
                              fontWeight: payment_Button_Font_Weight,
                            )),
                      ),
                    ),
                  ],
                )
                // const SizedBox(height: 16.0),
                /*Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: TextField(
                        style: TextStyle(
                          fontSize: text_Field_Font_Size,
                          fontFamily: text_Field_Font_Family,
                          fontWeight: text_Field_Font_Weight,
                        ),
                        decoration: InputDecoration(
                          labelText: 'TENDER',
                          labelStyle: TextStyle(
                            fontFamily: text_Field_Font_Family,
                            fontWeight: text_Field_Font_Weight,
                          ),
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.currency_rupee),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      flex: 1,
                      child: TextField(
                        style: TextStyle(
                          fontSize: text_Field_Font_Size,
                          fontFamily: text_Field_Font_Family,
                          fontWeight: text_Field_Font_Weight,
                        ),
                        decoration: InputDecoration(
                          labelText: 'BALANCE',
                          labelStyle: TextStyle(
                            fontSize: text_Field_Font_Size,
                            fontFamily: text_Field_Font_Family,
                            fontWeight: text_Field_Font_Weight,
                          ),
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.currency_rupee),
                        ),
                      ),
                    ),
                  ],
                ),*/
              ],
            ),
          ),
        ));
  }
}

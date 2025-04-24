import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:abis2/main.dart';

class SaveBillingAPI {
  static const String apiUrl = "https://retailuat.abisaio.com:9001/Api/POS";

  static const String businessDayApiUrl =
      "https://retailuat.abisibg.com/api/v1/currentbusinessday?BranchId=L101";

  static Future<String> getCurrentBusinessDay(String token) async {
    try {
      final response = await http.get(
        Uri.parse(businessDayApiUrl),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          String businessDateCode = data[0]["BusinessDateCode"];
        
          return businessDateCode;
        }
      }
      return ""; // Return empty string if API fails
    } catch (e) {
      print("Error fetching business date: $e");
      return "";
    }
  }

  static Future<Map<String, dynamic>> saveBillingData(
      String token,
      String branchId,
      String CustomerType,
      String ChannelType,
      String CustomerID,
      String CustomerName,
      String CustomerMobile,
      String addressID,
      String customerAddress,
      String houseNo,
      String altPhone,
      String building,
      String pincode,
      String placeID,
      String cityID,
      String landmark,
      String placeName,
      String cityName,
      String stateName,
      String? transTypeID,
      String? transSubTypeID,
      String? TimeSlotID,
      List<Map<String, dynamic>> items,
      String paymentMethodId,
      String paymentGatewayId,
      String paymentGatewayName,
      int deliveryCharge,
      String remarks,
      String? selectedDiscountType) async {
    String currentTimestamp = await getCurrentBusinessDay(token);

    List<Map<String, dynamic>> saleDetails = [];
    double totalProductAmount = 0;
    double totalDiscountAmount = 0;
    double totalTaxAmount = 0;
    double totalAmount = 0;

    double ItemDiscountAmount = 0;
    double ItemTaxAmount = 0;
    double ItemTotalAmount = 0;

    for (int i = 0; i < items.length; i++) {
      double productAmount = (items[i]["ItemTotalPrice"] as num).toDouble();
      ItemTaxAmount = productAmount * ((items[i]["TaxPercent"] as num) / 100);
      ItemDiscountAmount = (items[i]["Discount"] as num).toDouble();

      ItemTaxAmount = double.parse(ItemTaxAmount.toStringAsFixed(2));

      double productRounded = double.parse(productAmount.toStringAsFixed(3));
      double roundOffAdjustment = productRounded - productAmount;
      productAmount = productRounded;

      double discountDecimalPart =
          ItemDiscountAmount - ItemDiscountAmount.floor();
      double discountRoundOffAmount = discountDecimalPart >= 0.50
          ? (1.0 - discountDecimalPart)
          : -discountDecimalPart;
      ItemDiscountAmount += discountRoundOffAmount;

      if (selectedDiscountType == "Total value" ||
          selectedDiscountType == "Total percentage") {
        ItemTotalAmount = productAmount + ItemTaxAmount - ItemDiscountAmount;
      } else {
        ItemTotalAmount = productAmount + ItemTaxAmount;
      }

      totalProductAmount += productAmount;
      totalDiscountAmount += ItemDiscountAmount;
      totalTaxAmount += ItemTaxAmount;

      print("------------------------");
      print("Item number : $i");
      print("Product amount : $productAmount");
      print("Product Round off : $roundOffAdjustment");
      print("Discount amount : $ItemDiscountAmount");
      print("Discount Round off : $discountRoundOffAmount");
      print("Tax amount : $ItemTaxAmount");
      print("Total amount : $ItemTotalAmount");

      saleDetails.add({
        "lineNumber": (i + 1).toString().padLeft(3, '0'),
        "isSet": false,
        "itemName": items[i]["ItemName"],
        "isSaleReturn": false,
        "nos": items[i]['ItemAltQtyEnabled']
            ? items[i]["ItemQuantity"].toString()
            : (items[i]["ItemQuantity"] == 0
                ? ""
                : items[i]["ItemQuantity"].toString()),
        "kgs": items[i]['ItemAltQtyEnabled']
            ? items[i]["ItemWeight"].toString()
            : (items[i]["ItemWeight"] == 0
                ? ""
                : items[i]["ItemWeight"].toString()),
        "batchNumber": items[i]['BatchNo'].toString().isNotEmpty
            ? items[i]['BatchNo'].toString()
            : "",
        "rate": items[i]["ItemPrice"],
        "tradeDiscountRate": 0,
        "tradeDiscountAmount": ItemDiscountAmount,
        "taxableSubtotal": 0,
        "taxAmount": ItemTaxAmount,
        "lineFinalAmount": ItemTotalAmount,
        "binID": "OKBIN",
        "batchEnabled": false,
        "taxCategoryId": items[i]["ItemTaxCategoryID"],
        "taxStructureCode": "STATEGST",
        "setItemId": "",
        "setDiscountApportionRatio": 0,
        "isSetFreeItem": false,
        "isOfferItem": false,
        "itemStatusId": "OK",
        "lineDiscountCode": "",
        "qtyUOM": "",
        "altQtyUOM": "",
        "discountOn": "",
        "lineDiscountRate": 0,
        "lineDiscountAmount": 0,
        "lineDiscountType": "",
        "altQty": 0,
        "qty": items[i]["ItemWeight"] != 0 ? items[i]["ItemWeight"] : items[i]["ItemQuantity"],
        "productAmount": items[i]["ItemTotalPrice"],
        "totalTaxPercent": items[i]["TaxPercent"] as num,
        "deliveryCharge": deliveryCharge,
        "isOverRideRate": true,
        "isAmountMode": true,
        "packageCnt": 0,
        "sellByWeight": items[i]['ItemSellByWeight'],
        "unitMRP": 134,
        "isMRPSale": true,
        "altQtyEnabled": items[i]['ItemAltQtyEnabled'],
        "dayRate": items[i]["ItemDayRate"],
        "stockQty": 0,
        "stockAltQty": 0,
        "groupStockQty": 0,
        "amountModeAllowed": true,
        "allowMixSaleOfGroupItem": false,
        "itemID": items[i]["ItemID"],
        "itemCode": "",
        "wScale": 0,
        "stockGroupId": items[i]["ItemStockGroupID"],
        "itemFamilyId": items[i]["ItemFamilyID"],
        "parentSaleId": "",
        "parentSaleLineNumber": "",
        "deleted": "N",
        "batchUseByDate": currentTimestamp,
        "refDocType": "",
        "refDocId": "",
        "refLineNumber": "",
        "refDocName": "",
        "dml": "I",
        "unitGrossWt": 0
      });
    }

    if (selectedDiscountType == "Total value" ||
        selectedDiscountType == "Total percentage") {
      totalAmount = totalProductAmount +
          totalTaxAmount +
          deliveryCharge -
          totalDiscountAmount;
    } else {
      totalAmount = totalProductAmount + totalTaxAmount + deliveryCharge;
    }

    totalAmount = double.parse(totalAmount.toStringAsFixed(2));

    double TotalDecimalPart = totalAmount - totalAmount.floor();

    double TotalRoundOffAmount =
        TotalDecimalPart >= 0.50 ? (1.0 - TotalDecimalPart) : -TotalDecimalPart;
    TotalRoundOffAmount = double.parse(TotalRoundOffAmount.toStringAsFixed(2));

    totalAmount += TotalRoundOffAmount;

    totalAmount = double.parse(totalAmount.toStringAsFixed(2));

    print("------------------------");
    print("total Product amount : $totalProductAmount");
    print("total Discount amount : $totalDiscountAmount");
    print("total Tax amount : $totalTaxAmount");
    print("Round off amount : $TotalRoundOffAmount");
    print("Total amount : $totalAmount");

    Map<String, dynamic> billingData = {
      "saleID": "",
      "branchId": branchId,
      "channelId": ChannelType,
      "transTypeId": "SALE",
      "tranSubTypeId": "RETAIL",
      "pricingSchemeId": "CASH",
      "businessDate": currentTimestamp,
      "remarks": remarks,
      "invType": "",
      "customerID": "",
      "posCustomerID": CustomerID,
      "termsID": "",
      "isO_number": "",
      "delieveryMode": "",
      "deliveryAddressID": addressID,
      "billingAddressID": "",
      "discountCode": "",
      "discountRate": 0,
      "totalDiscountAmount": totalDiscountAmount,
      "productTotal": totalProductAmount,
      "taxableSubtotal": 0,
      "taxAmount": totalTaxAmount,
      "roundOffAmount": TotalRoundOffAmount,
      "totalAmount": totalAmount,
      "deliveryDistance": 0,
      "deliveryCharge": deliveryCharge,
      "deliveryDiscount": 0,
      "deliveryStatusCode": "",
      "pointsEarned": 0,
      "timeSlotId": "",
      "tripId": "",
      "posted": true,
      "deleted": "N",
      "posNumber": 0,
      "createdUserID": "",
      "parentSaleBranchID": branchId,
      "parentSaleID": "",
      "saleOrderId": "",
      "isCancelledSale": true,
      "createdDate": currentTimestamp,
      "modifiedUserID": "",
      "modifiedDate": currentTimestamp,
      "deletedUserID": "",
      "deletedDate": currentTimestamp,
      "postedUserID": "",
      "postedDate": currentTimestamp,
      "saleDetails": saleDetails,
      "billDetails": [
        {
          "lineNumber": "001",
          "paymentGatewayName": paymentGatewayName?.toString() ?? "",
          "amount": totalAmount.toInt(),
          "refundAmount": 0,
          "authCode": "",
          "promoId": "",
          "paymentGatewayID": paymentGatewayId?.toString() ?? "",
          "paymentMethodId": paymentMethodId?.toString() ?? "",
          "deleted": "N",
          "authRequired": true,
          "createdUserId": "",
          "createdDate": currentTimestamp,
          "modifiedUserId": "",
          "modifiedDate": currentTimestamp,
          "deletedUserId": "",
          "deletedDate": currentTimestamp,
          "dml": "l",
          "isCarryForward": true
        }
      ]
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(billingData),
      );
      print(currentTimestamp);
      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      //print('BILL details: ${jsonEncode(billingData)}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {"result": -1, "description": "Failed to save bill"};
      }
    } catch (e) {
      return {"result": -1, "description": "Error: ${e.toString()}"};
    }
  }
}

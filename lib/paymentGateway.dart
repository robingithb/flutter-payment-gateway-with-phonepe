import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:phonepe_payment_sdk/phonepe_payment_sdk.dart';

class Paymentgateway extends StatefulWidget {
  const Paymentgateway({super.key});

  @override
  State<Paymentgateway> createState() => _PaymentgatewayState();
}

class _PaymentgatewayState extends State<Paymentgateway> {
  String? environmentValue = "SANDBOX";
  String? appId = '';
  String? merchantId = "PGTESTPAYUAT86";
  bool enableLogin = true;
  String? saltKey = "96434309-7796-489d-8924-ab56988a6076";
  String? saltIndexKey = "1";
  Object? result;

  String? body = "";
  String? callBack = "https://webhook.site/callback-url";
  String? checkSum = "";
  String? packageName = "";

  //api end point
  String? apiEndPoint = "/pg/v1/pay";

  @override
  void initState() {
    body = getCheckSum().toString();
    _initializePaymentGateway();

    super.initState();
  }

  void startPaymentTransaction() {
    PhonePePaymentSdk.startTransaction(
            body!, checkSum!, callBack!, packageName!)
        .then((response) {
      setState(() {
        if (response != null) {
          String status = response["status"].toString();
          String error = response["error"].toString();
          if (status == "SUCCESS") {
            result = "Flow complted - Status : SUCCESS";
          } else {
            result = "Flow completed - Status : $status  Error : $error";
          }
        } else {
          result = "Flow Incomplete";
        }
      });
    }).catchError((error) {
      return <dynamic>{};
    });
  }

  void _initializePaymentGateway() {
    PhonePePaymentSdk.init(environmentValue!, appId!, merchantId!, enableLogin)
        .then((val) => {
              setState(() {
                result = val;
              })
            })
        .catchError((error) {
      traceError(error);
      return <dynamic>{};
    });
  }

  void traceError(error) {
    result = error;
  }

  // dynamic getCheckSum() {
  //   final requestDataPayload = {
  //     {

  //       "merchantId": merchantId,
  //       "merchantTransactionId": "t_52554",
  //       "merchantUserId": "MUID123",
  //       "amount": 10000,
  //       "callbackUrl": callBack,
  //       "mobileNumber": "9999999999",
  //       "paymentInstrument": {"type": "PAY_PAGE"}
  //     }
  //   };
  //   String? base64body =
  //       base64.encode(utf8.encode(json.encode(requestDataPayload)));
  //   checkSum =
  //       "${sha256.convert(utf8.encode(base64body + apiEndPoint! + saltKey!)).toString()}###$saltIndexKey";
  //   return base64body;
  // }
  dynamic getCheckSum() {
    final requestDataPayload = {
      "merchantId": merchantId,
      "merchantTransactionId": "t_52554",
      "merchantUserId": "MUID123",
      "amount": 10000,
      "callbackUrl": callBack,
      "mobileNumber": "9999999999",
      "paymentInstrument": {"type": "PAY_PAGE"}
    };
    String? base64body =
        base64.encode(utf8.encode(json.encode(requestDataPayload)));
    checkSum =
        "${sha256.convert(utf8.encode(base64body + apiEndPoint! + saltKey!)).toString()}###$saltIndexKey";
    return base64body;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment Gateway"),
      ),
      body: Center(
        child: Column(
          children: [
            Container(
              child: OutlinedButton(
                  onPressed: startPaymentTransaction, child: Text("Pay")),
            ),
            Text("$result")
          ],
        ),
      ),
    );
  }
}

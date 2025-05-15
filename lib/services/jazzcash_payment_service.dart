import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:intl/intl.dart';

class JazzCashPaymentService {
  // TODO: Fill these with your sandbox credentials
  final String merchantId = 'Test00127801';
  final String password = '000000000';
  final String integritySalt = 'YOUR_INTEGRITY_SALT';

  /// Generates pp_SecureHash over all input fields (sorted by key)
  String _generateSecureHash(Map<String, String> params) {
    final sortedKeys = params.keys.toList()..sort();
    final rawString = sortedKeys.map((k) => params[k]).join();
    final hmac = Hmac(sha256, utf8.encode(integritySalt));
    return hmac.convert(utf8.encode(rawString)).toString();
  }

  /// AUTHORIZE a one-time card payment
  Future<Map<String, dynamic>> authorize({
    required String txnRefNo,
    required int amount, // no decimals: e.g. ₨100.00 → 10000
    required String cardNumber,
    required String cardExpiry, // MMYY
    required String cardCvv,
  }) async {
    // timestamp in yyyyMMddHHmmss
    final now = DateFormat('yyyyMMddHHmmss').format(DateTime.now());
    final req = <String, String>{
      'pp_InstrumentType': 'CARD',
      'pp_TxnRefNo': txnRefNo,
      'pp_Amount': amount.toString(),
      'pp_TxnCurrency': 'PKR',
      'InstrumentDTO.pp_CustomerCardNumber': cardNumber,
      'InstrumentDTO.pp_CustomerCardExpiry': cardExpiry,
      'InstrumentDTO.pp_CustomerCardCvv': cardCvv,
      'pp_MerchantID': merchantId,
      'pp_Password': password,
      'pp_TxnDateTime': now,
      'pp_Frequency': 'SINGLE',
    };
    req['pp_SecureHash'] = _generateSecureHash(req);
    final body = jsonEncode({'AuthorizeRequest': req});

    final url = Uri.parse(
      'https://sandbox.jazzcash.com.pk/Sandbox/Payments/Authorize',
    );
    final resp = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );
    return jsonDecode(resp.body) as Map<String, dynamic>;
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/jazzcash_payment_service.dart';

final jazzCashServiceProvider = Provider((ref) => JazzCashPaymentService());

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/selected_products_provider.dart';
import '../providers/auth_provider.dart';
import '../services/order_service.dart';
import '../models/order.dart';

enum PaymentMethod { card, cashOnDelivery }

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen>
    with SingleTickerProviderStateMixin {
  final _cardCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();
  bool _isLoading = false;
  PaymentMethod _paymentMethod = PaymentMethod.card;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _cardCtrl.dispose();
    _expiryCtrl.dispose();
    _cvvCtrl.dispose();
    super.dispose();
  }

  Future<void> _onPayNow() async {
    setState(() => _isLoading = true);
    final orderService = ref.read(orderServiceProvider);
    final user = ref.read(authProvider);
    final cartItems = ref.read(selectedProductsProvider);

    if (user == null) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('User not logged in'),
            backgroundColor: Colors.red[400],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
      return;
    }

    try {
      if (_paymentMethod == PaymentMethod.cashOnDelivery) {
        await orderService.checkout(
          cartItems,
          userId: user.id,
          userEmail: user.email,
          paymentMethod: 'cash_on_delivery',
          cardNumber: '',
          cardExpiry: '',
          cardCvv: '',
        );
      } else {
        await orderService.checkout(
          cartItems,
          userId: user.id,
          userEmail: user.email,
          paymentMethod: 'card',
          cardNumber: _cardCtrl.text.trim(),
          cardExpiry: _expiryCtrl.text.trim(),
          cardCvv: _cvvCtrl.text.trim(),
        );
      }

      ref.read(selectedProductsProvider.notifier).clearSelectedProducts();

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _paymentMethod == PaymentMethod.card
                  ? 'Payment & Order successful!'
                  : 'Order placed successfully (Cash on Delivery)!',
            ),
            backgroundColor: Colors.green[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder:
              (_) => AlertDialog(
                title: const Text('Transaction Failed'),
                content: Text(e.toString()),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'OK',
                      style: TextStyle(color: Colors.green[600]),
                    ),
                  ),
                ],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selected = ref.watch(selectedProductsProvider);
    final subtotal = selected.fold<double>(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );
    final tax = subtotal * 0.08;
    final total = subtotal + tax;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.green[800],
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: SlideTransition(
                  position: _slideAnimation,
                  child: ListView(
                    children: [
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: BorderSide(color: Colors.grey[200]!),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Order Summary',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[800],
                                ),
                              ),
                              const SizedBox(height: 12),
                              ...selected.map(
                                (product) => ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      width: 50,
                                      height: 50,
                                      color: Colors.grey[200],
                                      child: Icon(
                                        Icons.shopping_bag,
                                        color: Colors.green[600],
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    product.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '₨${product.price.toStringAsFixed(2)} x ${product.quantity}',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                  trailing: Text(
                                    '₨${(product.price * product.quantity).toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const Divider(),
                              _buildPriceRow('Subtotal', subtotal),
                              _buildPriceRow('Tax (8%)', tax),
                              _buildPriceRow('Total', total, isBold: true),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: BorderSide(color: Colors.grey[200]!),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Payment Method',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[800],
                                ),
                              ),
                              const SizedBox(height: 12),
                              _buildPaymentMethodCard(
                                'Credit/Debit Card',
                                PaymentMethod.card,
                                Icons.credit_card,
                              ),
                              _buildPaymentMethodCard(
                                'Cash on Delivery',
                                PaymentMethod.cashOnDelivery,
                                Icons.money,
                              ),
                              if (_paymentMethod == PaymentMethod.card) ...[
                                const SizedBox(height: 16),
                                TextField(
                                  controller: _cardCtrl,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: 'Card Number',
                                    labelStyle: TextStyle(
                                      color: Colors.grey[600],
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: Colors.grey[300]!,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: Colors.grey[300]!,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: Colors.green[400]!,
                                        width: 2,
                                      ),
                                    ),
                                    prefixIcon: Icon(
                                      Icons.credit_card,
                                      color: Colors.green[600],
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _expiryCtrl,
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          labelText: 'Expiry (MMYY)',
                                          labelStyle: TextStyle(
                                            color: Colors.grey[600],
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            borderSide: BorderSide(
                                              color: Colors.grey[300]!,
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            borderSide: BorderSide(
                                              color: Colors.grey[300]!,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            borderSide: BorderSide(
                                              color: Colors.green[400]!,
                                              width: 2,
                                            ),
                                          ),
                                          prefixIcon: Icon(
                                            Icons.calendar_today,
                                            color: Colors.green[600],
                                          ),
                                          filled: true,
                                          fillColor: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: TextField(
                                        controller: _cvvCtrl,
                                        keyboardType: TextInputType.number,
                                        obscureText: true,
                                        decoration: InputDecoration(
                                          labelText: 'CVV',
                                          labelStyle: TextStyle(
                                            color: Colors.grey[600],
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            borderSide: BorderSide(
                                              color: Colors.grey[300]!,
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            borderSide: BorderSide(
                                              color: Colors.grey[300]!,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            borderSide: BorderSide(
                                              color: Colors.green[400]!,
                                              width: 2,
                                            ),
                                          ),
                                          prefixIcon: Icon(
                                            Icons.lock,
                                            color: Colors.green[600],
                                          ),
                                          filled: true,
                                          fillColor: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _onPayNow,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                      shadowColor: Colors.green[200],
                    ),
                    child:
                        _isLoading
                            ? const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            )
                            : Text(
                              _paymentMethod == PaymentMethod.card
                                  ? 'Pay Now'
                                  : 'Place Order',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 18 : 16,
              color: Colors.grey[700],
            ),
          ),
          Text(
            '₨${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 18 : 16,
              color: isBold ? Colors.green[800] : Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard(
    String title,
    PaymentMethod method,
    IconData icon,
  ) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color:
              _paymentMethod == method ? Colors.green[400]! : Colors.grey[300]!,
          width: _paymentMethod == method ? 1.5 : 1,
        ),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color:
              _paymentMethod == method ? Colors.green[600] : Colors.grey[600],
        ),
        title: Text(
          title,
          style: TextStyle(
            color:
                _paymentMethod == method ? Colors.green[800] : Colors.grey[800],
            fontWeight:
                _paymentMethod == method ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        trailing: Radio<PaymentMethod>(
          value: method,
          groupValue: _paymentMethod,
          onChanged: (method) => setState(() => _paymentMethod = method!),
          activeColor: Colors.green[600],
        ),
        onTap: () => setState(() => _paymentMethod = method),
      ),
    );
  }
}

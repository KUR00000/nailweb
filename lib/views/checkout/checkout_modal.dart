import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/order.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../services/integration_service.dart';
import '../../services/stripe_service.dart';

/// Modal dialog facilitating Stripe Payment Processing and Order Confirmation.
class CheckoutModal extends StatefulWidget {
  const CheckoutModal({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (context) => const CheckoutModal(),
    );
  }

  @override
  State<CheckoutModal> createState() => _CheckoutModalState();
}

class _CheckoutModalState extends State<CheckoutModal> {
  final _formKey = GlobalKey<FormState>();

  // Customer & Shipping Form
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController(text: '742 Evergreen Terrace');
  final _cityController = TextEditingController(text: 'Beverly Hills');
  final _zipController = TextEditingController(text: '90210');

  // Stripe Card Form
  final _cardholderController = TextEditingController();
  final _cardNumberController = TextEditingController(text: '4242 4242 4242 4242');
  final _expiryController = TextEditingController(text: '12/28');
  final _cvcController = TextEditingController(text: '123');

  bool _isProcessing = false;
  String? _errorMessage;
  OrderModel? _completedOrder;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    _emailController.text = auth.isAuthenticated ? auth.userEmail : 'cutie@ivorynails.com';
    _nameController.text = auth.isAuthenticated ? auth.userName : 'Princess Ivory';
    _cardholderController.text = _nameController.text;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _zipController.dispose();
    _cardholderController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvcController.dispose();
    super.dispose();
  }

  Future<void> _handlePayment() async {
    if (!_formKey.currentState!.validate()) return;

    final cart = context.read<CartProvider>();
    if (cart.isEmpty) {
      Navigator.of(context).pop();
      return;
    }

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    final result = await StripeService().processPayment(
      cartItems: cart.items,
      subtotal: cart.subtotal,
      tax: cart.tax,
      shipping: cart.shipping,
      totalAmount: cart.total,
      cardholderName: _cardholderController.text.trim(),
      cardNumber: _cardNumberController.text.trim(),
      expiryDate: _expiryController.text.trim(),
      cvc: _cvcController.text.trim(),
      postalCode: _zipController.text.trim(),
      customerEmail: _emailController.text.trim(),
      customerName: _nameController.text.trim(),
      shippingAddress: {
        'street': _addressController.text.trim(),
        'city': _cityController.text.trim(),
        'postal_code': _zipController.text.trim(),
      },
      promoCode: cart.appliedPromoCode,
    );

    if (result.isSuccess && result.completedOrder != null) {
      cart.clearCart();
      setState(() {
        _isProcessing = false;
        _completedOrder = result.completedOrder;
      });
    } else {
      setState(() {
        _isProcessing = false;
        _errorMessage = result.errorMessage ?? 'Payment failed. Please verify your card details.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 800;
    final cart = context.watch<CartProvider>();

    return Dialog(
      backgroundColor: AppTheme.pureWhite,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isDesktop ? 860 : 480,
          maxHeight: 760,
        ),
        child: _completedOrder != null
            ? _buildSuccessReceipt(context)
            : _buildCheckoutForm(context, isDesktop, cart),
      ),
    );
  }

  Widget _buildCheckoutForm(BuildContext context, bool isDesktop, CartProvider cart) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.blush100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.credit_card, color: AppTheme.dustyRose, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Stripe Checkout',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const Text(
                          '256-bit AES Encrypted • Powered by Stripe',
                          style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                  ],
                ),
                if (!_isProcessing)
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, size: 20),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Scrollable Body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.errorCrimson.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.errorCrimson.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: AppTheme.errorCrimson, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: AppTheme.errorCrimson, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Section 1: Customer Contact & Shipping
                  const Text(
                    '1. SHIPPING & CONTACT DETAILS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: AppTheme.textMuted,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(labelText: 'Full Name'),
                          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(labelText: 'Email Address'),
                          validator: (v) => v == null || !v.contains('@') ? 'Valid email required' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(labelText: 'Street Address'),
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: _cityController,
                          decoration: const InputDecoration(labelText: 'City'),
                          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          controller: _zipController,
                          decoration: const InputDecoration(labelText: 'Postal Code'),
                          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 18),

                  // Section 2: Stripe Payment Information
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '2. PAYMENT METHOD (STRIPE)',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: AppTheme.textMuted,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: IntegrationService().paymentService.isDemo
                                  ? AppTheme.dustyRose
                                  : AppTheme.charcoalNoir,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              IntegrationService().paymentService.isDemo
                                  ? 'ATELIER DEMO MODE'
                                  : 'STRIPE SECURE',
                              style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _cardholderController,
                    decoration: const InputDecoration(labelText: 'Cardholder Name'),
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _cardNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Card Number',
                      hintText: '4242 •••• •••• 4242',
                      prefixIcon: Icon(Icons.credit_card, color: AppTheme.dustyRose),
                    ),
                    validator: (v) => v == null || v.length < 15 ? 'Enter 16-digit card number' : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _expiryController,
                          decoration: const InputDecoration(labelText: 'Expires (MM/YY)'),
                          validator: (v) => v == null || !v.contains('/') ? 'MM/YY required' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _cvcController,
                          decoration: const InputDecoration(labelText: 'CVC / CVV'),
                          obscureText: true,
                          validator: (v) => v == null || v.length < 3 ? 'CVC required' : null,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  // Order Summary Recap inside checkout
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.ivoryGround,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.delicateBorder),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${cart.itemCount} items subtotal', style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                            Text('\$${cart.subtotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Shipping & Taxes', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                            Text('\$${(cart.tax + cart.shipping).toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const Padding(padding: EdgeInsets.symmetric(vertical: 6), child: Divider()),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total to Pay', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                            Text('\$${cart.total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.dustyRose)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Pay Button
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: AppTheme.pureWhite,
              border: Border(top: BorderSide(color: AppTheme.delicateBorder)),
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _handlePayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.charcoalNoir,
                  foregroundColor: AppTheme.pureWhite,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _isProcessing
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.pureWhite),
                          ),
                          SizedBox(width: 12),
                          Text('Authorizing Stripe Payment...', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.lock, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            'Pay Now • \$${cart.total.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessReceipt(BuildContext context) {
    final order = _completedOrder!;

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppTheme.emeraldSuccess.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: AppTheme.emeraldSuccess, size: 32),
          ),
          const SizedBox(height: 18),
          Text(
            'Payment Confirmed!',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 24,
                ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Thank you for your order with Ivory Nails Atelier.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
          ),
          const SizedBox(height: 20),

          // Order Reference Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppTheme.ivoryGround,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.delicateBorder),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Order Reference:', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                    Text(
                      '#${order.id}',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, fontFamily: 'monospace'),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Payment Method:', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                    const Text('Stripe (Visa •••• 4242)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Delivering to:', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                    Text(order.customerEmail, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
                const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider()),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Charged:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    Text(
                      '\$${order.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.dustyRose),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Action Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.charcoalNoir,
                foregroundColor: AppTheme.pureWhite,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Return to Atelier Catalog', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

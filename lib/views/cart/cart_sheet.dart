import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/cart_provider.dart';
import '../checkout/checkout_modal.dart';

/// Shopping Bag Drawer / Slide-Over Sheet.
class CartSheet extends StatefulWidget {
  const CartSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CartSheet(),
    );
  }

  @override
  State<CartSheet> createState() => _CartSheetState();
}

class _CartSheetState extends State<CartSheet> {
  final TextEditingController _promoController = TextEditingController();
  String? _promoMessage;
  bool _promoSuccess = false;

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final isDesktop = MediaQuery.of(context).size.width >= 700;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isDesktop ? 540 : double.infinity,
          maxHeight: MediaQuery.of(context).size.height * 0.90,
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: AppTheme.pureWhite,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Color(0x1F000000),
                blurRadius: 30,
                offset: Offset(0, -10),
              )
            ],
          ),
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.shopping_bag_outlined, color: AppTheme.dustyRose, size: 22),
                        const SizedBox(width: 10),
                        Text(
                          'Shopping Bag',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.blush100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${cartProvider.itemCount}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.dustyRose,
                            ),
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, size: 20, color: AppTheme.charcoalNoir),
                      style: IconButton.styleFrom(
                        backgroundColor: AppTheme.ivoryGround,
                        shape: const CircleBorder(),
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Free Shipping Progress Banner
              if (!cartProvider.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  color: AppTheme.blush50,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              if (cartProvider.freeShippingAmountRemaining <= 0) ...[
                                const Icon(Icons.check_circle_outline, size: 14, color: AppTheme.emeraldSuccess),
                                const SizedBox(width: 6),
                              ],
                              Text(
                                cartProvider.freeShippingAmountRemaining > 0
                                    ? 'Add \$${cartProvider.freeShippingAmountRemaining.toStringAsFixed(2)} for free express packaging'
                                    : 'Complimentary express packaging unlocked',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: cartProvider.freeShippingAmountRemaining <= 0
                                      ? AppTheme.emeraldSuccess
                                      : AppTheme.charcoalNoir,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${(cartProvider.freeShippingProgress * 100).toInt()}%',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.dustyRose,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: cartProvider.freeShippingProgress,
                          backgroundColor: AppTheme.blush200,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.dustyRose),
                          minHeight: 4,
                        ),
                      ),
                    ],
                  ),
                ),

              // Cart Items List or Empty State
              Expanded(
                child: cartProvider.isEmpty
                    ? _buildEmptyState(context)
                    : ListView.separated(
                        padding: const EdgeInsets.all(24),
                        itemCount: cartProvider.items.length,
                        separatorBuilder: (_, __) => const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(),
                        ),
                        itemBuilder: (context, index) {
                          final item = cartProvider.items[index];
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Product Thumbnail
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  width: 64,
                                  height: 64,
                                  color: AppTheme.blush50,
                                  child: Image.network(
                                    item.product.imageUrl,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),

                              // Item Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.product.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: AppTheme.charcoalNoir,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '\$${item.product.price.toStringAsFixed(2)} each',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.dustyRose,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Quantity Controls
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppTheme.delicateBorder),
                                  borderRadius: BorderRadius.circular(10),
                                  color: AppTheme.ivoryGround,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      onPressed: () => cartProvider.updateQuantity(
                                        item.product.id,
                                        item.quantity - 1,
                                      ),
                                      icon: const Icon(Icons.remove, size: 14),
                                      visualDensity: VisualDensity.compact,
                                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                    ),
                                    Text(
                                      '${item.quantity}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () => cartProvider.updateQuantity(
                                        item.product.id,
                                        item.quantity + 1,
                                      ),
                                      icon: const Icon(Icons.add, size: 14),
                                      visualDensity: VisualDensity.compact,
                                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 12),

                              // Subtotal for item & Trash icon
                              IconButton(
                                onPressed: () => cartProvider.removeItem(item.product.id),
                                icon: const Icon(Icons.delete_outline, size: 18, color: AppTheme.textSubtle),
                                tooltip: 'Remove',
                              ),
                            ],
                          );
                        },
                      ),
              ),

              // Bottom Pricing & Stripe Checkout Action
              if (!cartProvider.isEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: AppTheme.ivoryGround,
                    border: Border(top: BorderSide(color: AppTheme.delicateBorder)),
                  ),
                  child: Column(
                    children: [
                      // Promo Code Row
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 42,
                              child: TextField(
                                controller: _promoController,
                                decoration: InputDecoration(
                                  hintText: 'Promo code (try IVORY10)',
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  fillColor: AppTheme.pureWhite,
                                  suffixIcon: cartProvider.appliedPromoCode != null
                                      ? IconButton(
                                          onPressed: () {
                                            cartProvider.removePromoCode();
                                            _promoController.clear();
                                            setState(() {
                                              _promoMessage = null;
                                            });
                                          },
                                          icon: const Icon(Icons.close, size: 16),
                                        )
                                      : null,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          OutlinedButton(
                            onPressed: () {
                              final success = cartProvider.applyPromoCode(_promoController.text);
                              setState(() {
                                _promoSuccess = success;
                                _promoMessage = success
                                    ? 'Applied ${(cartProvider.discountPercentage * 100).toInt()}% off!'
                                    : 'Invalid promo code';
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              backgroundColor: AppTheme.pureWhite,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            child: const Text('Apply'),
                          ),
                        ],
                      ),
                      if (_promoMessage != null) ...[
                        const SizedBox(height: 6),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _promoMessage!,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _promoSuccess ? AppTheme.emeraldSuccess : AppTheme.errorCrimson,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),

                      // Breakdown
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Subtotal', style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                          Text('\$${cartProvider.rawSubtotal.toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        ],
                      ),
                      if (cartProvider.discountAmount > 0) ...[
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Promo Discount (${(cartProvider.discountPercentage * 100).toInt()}%)',
                              style: const TextStyle(color: AppTheme.emeraldSuccess, fontSize: 13),
                            ),
                            Text(
                              '-\$${cartProvider.discountAmount.toStringAsFixed(2)}',
                              style: const TextStyle(color: AppTheme.emeraldSuccess, fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Estimated Tax (8%)', style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                          Text('\$${cartProvider.tax.toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Shipping', style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                          Text(
                            cartProvider.shipping == 0 ? 'FREE' : '\$${cartProvider.shipping.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: cartProvider.shipping == 0 ? AppTheme.emeraldSuccess : AppTheme.charcoalNoir,
                            ),
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Divider(),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Amount',
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppTheme.charcoalNoir)),
                          Text(
                            '\$${cartProvider.total.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.dustyRose,
                                  fontSize: 20,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Primary Stripe Checkout Trigger Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            CheckoutModal.show(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.charcoalNoir,
                            foregroundColor: AppTheme.pureWhite,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.lock_outline, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                'Stripe Checkout • \$${cartProvider.total.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.blush100,
              ),
              child: const Icon(Icons.shopping_bag_outlined, color: AppTheme.dustyRose, size: 32),
            ),
            const SizedBox(height: 16),
            const Text(
              'Your shopping bag is empty',
              style: TextStyle(
                fontFamily: 'Playfair Display',
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Explore our 13 handcrafted press-ons, gel glosses, and salon topcoats.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.charcoalNoir,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Explore Atelier Collection'),
            ),
          ],
        ),
      ),
    );
  }
}

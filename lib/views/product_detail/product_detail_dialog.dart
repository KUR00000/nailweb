import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/product.dart';
import '../../providers/cart_provider.dart';

/// Modal dialog providing detailed craftsmanship specs and bag addition for a selected product.
class ProductDetailDialog extends StatefulWidget {
  final Product product;

  const ProductDetailDialog({super.key, required this.product});

  static Future<void> show(BuildContext context, Product product) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (context) => ProductDetailDialog(product: product),
    );
  }

  @override
  State<ProductDetailDialog> createState() => _ProductDetailDialogState();
}

class _ProductDetailDialogState extends State<ProductDetailDialog> {
  int _selectedQuantity = 1;

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 800;
    final cartProvider = context.watch<CartProvider>();

    return Dialog(
      backgroundColor: AppTheme.pureWhite,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isDesktop ? 860 : 440,
          maxHeight: isDesktop ? 620 : 780,
        ),
        child: Stack(
          children: [
            isDesktop ? _buildDesktopLayout(context, cartProvider) : _buildMobileLayout(context, cartProvider),

            // Top Close Button
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, size: 20, color: AppTheme.charcoalNoir),
                style: IconButton.styleFrom(
                  backgroundColor: AppTheme.ivoryGround,
                  shape: const CircleBorder(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, CartProvider cartProvider) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Left Column: Large Product Imagery
        Expanded(
          flex: 5,
          child: ClipRRect(
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(24)),
            child: Container(
              color: AppTheme.blush50,
              child: Image.network(
                widget.product.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: AppTheme.blush100,
                  child: const Center(
                    child: Icon(Icons.spa_outlined, color: AppTheme.dustyRose, size: 48),
                  ),
                ),
              ),
            ),
          ),
        ),

        // Right Column: Product Specs & Actions
        Expanded(
          flex: 6,
          child: Padding(
            padding: const EdgeInsets.all(36),
            child: SingleChildScrollView(
              child: _buildDetailsContent(context, cartProvider),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, CartProvider cartProvider) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: AspectRatio(
              aspectRatio: 1.2,
              child: Image.network(
                widget.product.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: _buildDetailsContent(context, cartProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsContent(BuildContext context, CartProvider cartProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Badge & Stock status
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.blush100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                widget.product.category.toUpperCase(),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: AppTheme.dustyRose,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.emeraldSuccess.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, size: 12, color: AppTheme.emeraldSuccess),
                  SizedBox(width: 4),
                  Text(
                    'IN STOCK',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.emeraldSuccess,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Product Name
        Text(
          widget.product.name,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: 26,
                fontWeight: FontWeight.w600,
                color: AppTheme.charcoalNoir,
              ),
        ),
        const SizedBox(height: 8),

        // Rating & Price Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.star, color: AppTheme.goldAccent, size: 16),
                const SizedBox(width: 4),
                Text(
                  widget.product.rating.toStringAsFixed(1),
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
                const SizedBox(width: 6),
                Text(
                  '(${widget.product.reviewCount} verified reviews)',
                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                ),
              ],
            ),
            Text(
              '\$${widget.product.price.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.dustyRose,
                    fontSize: 22,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 16),

        // Description
        Text(
          widget.product.description,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 14,
                color: AppTheme.charcoalNoir,
                height: 1.5,
              ),
        ),
        const SizedBox(height: 14),

        // Craftsmanship Specs
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.ivoryGround,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.delicateBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ATELIER CRAFTSMANSHIP & DETAILS',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: AppTheme.textMuted,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.product.details,
                style: const TextStyle(fontSize: 12, color: AppTheme.textMuted, height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Quantity Selector and Add to Bag Button
        Row(
          children: [
            // Quantity Box
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.delicateBorder),
                borderRadius: BorderRadius.circular(12),
                color: AppTheme.ivoryGround,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _selectedQuantity > 1
                        ? () => setState(() => _selectedQuantity--)
                        : null,
                    icon: const Icon(Icons.remove, size: 16),
                    visualDensity: VisualDensity.compact,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      '$_selectedQuantity',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() => _selectedQuantity++),
                    icon: const Icon(Icons.add, size: 16),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),

            // Primary Add Button
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  cartProvider.addToCart(widget.product, quantity: _selectedQuantity);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Added $_selectedQuantity × ${widget.product.name} to atelier bag.'),
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: AppTheme.charcoalNoir,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.charcoalNoir,
                  foregroundColor: AppTheme.pureWhite,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(
                  'Add to Bag • \$${(widget.product.price * _selectedQuantity).toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

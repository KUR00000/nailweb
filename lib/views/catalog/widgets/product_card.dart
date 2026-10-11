import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/product.dart';
import '../../../providers/cart_provider.dart';

/// Minimalist Editorial Luxury Product Card with Shade Swatch, Finish Specs & Couture Badges.
class ProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _isHovered = false;

  Color _parseShadeColor(String hex) {
    try {
      final clean = hex.replaceAll('#', '');
      return Color(int.parse('FF$clean', radix: 16));
    } catch (_) {
      return AppTheme.blush200;
    }
  }

  IconData _getTagIcon(String tag) {
    switch (tag.toUpperCase()) {
      case 'BESTSELLER':
        return Icons.trending_up_rounded;
      case 'VIRAL SHADE':
        return Icons.auto_awesome_rounded;
      case 'MUST-HAVE':
        return Icons.favorite_border_rounded;
      case 'BRIDAL EDIT':
        return Icons.diamond_outlined;
      case 'STRENGTHENING':
        return Icons.shield_outlined;
      case 'ICONIC':
        return Icons.star_border_rounded;
      case 'TIMELESS':
        return Icons.schedule_rounded;
      case 'ATELIER MASTERPIECE':
        return Icons.workspace_premium_outlined;
      default:
        return Icons.auto_awesome_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final inCart = cartProvider.isInCart(widget.product.id);
    final quantityInCart = cartProvider.getQuantity(widget.product.id);
    final shadeColor = _parseShadeColor(widget.product.shadeHex);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(0.0, _isHovered ? -5.0 : 0.0, 0.0),
          decoration: BoxDecoration(
            color: AppTheme.pureWhite,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isHovered ? AppTheme.charcoalNoir : AppTheme.delicateBorder,
              width: _isHovered ? 1.2 : 1.0,
            ),
            boxShadow: _isHovered ? AppTheme.cardHoverShadow : AppTheme.softShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image Container
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
                    child: AspectRatio(
                      aspectRatio: 1.05,
                      child: Container(
                        color: AppTheme.blush50,
                        child: Image.network(
                          widget.product.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: AppTheme.blush100,
                              child: const Center(
                                child: Icon(
                                  Icons.spa_outlined,
                                  color: AppTheme.dustyRose,
                                  size: 36,
                                ),
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: AppTheme.blush50,
                              child: const Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppTheme.dustyRose,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  // Editorial Badge (Top Left)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.product.tag != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.charcoalNoir,
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(_getTagIcon(widget.product.tag!), size: 10, color: AppTheme.pureWhite),
                                const SizedBox(width: 4),
                                Text(
                                  widget.product.tag!,
                                  style: const TextStyle(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.8,
                                    color: AppTheme.pureWhite,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 5),
                        ],
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.pureWhite.withValues(alpha: 0.94),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppTheme.delicateBorder),
                          ),
                          child: Text(
                            widget.product.shapeOrVolume.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.6,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Quick Action Button (Top Right)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          cartProvider.toggleItem(widget.product);
                        },
                        borderRadius: BorderRadius.circular(30),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: inCart ? AppTheme.charcoalNoir : AppTheme.pureWhite.withValues(alpha: 0.94),
                            border: Border.all(
                              color: inCart ? AppTheme.charcoalNoir : AppTheme.delicateBorder,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: Icon(
                            inCart ? Icons.check : Icons.shopping_bag_outlined,
                            size: 16,
                            color: inCart ? AppTheme.pureWhite : AppTheme.charcoalNoir,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Product Info Body
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Rating & Finish Tag Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, color: AppTheme.goldAccent, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              widget.product.rating.toStringAsFixed(1),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.charcoalNoir,
                                  ),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '(${widget.product.reviewCount})',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.textSubtle,
                                    fontSize: 10,
                                  ),
                            ),
                          ],
                        ),

                        // Finish Tag
                        Text(
                          widget.product.finish,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.dustyRose,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Title with Color Swatch Dot
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: shadeColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppTheme.delicateBorder, width: 1.2),
                            boxShadow: [
                              BoxShadow(
                                color: shadeColor.withValues(alpha: 0.4),
                                blurRadius: 4,
                              )
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.product.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontFamily: 'Playfair Display',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: AppTheme.charcoalNoir,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),

                    // Description
                    Text(
                      widget.product.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textMuted,
                            height: 1.4,
                            fontSize: 12,
                          ),
                    ),
                    const SizedBox(height: 14),

                    // Price & Action Button Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '\$${widget.product.price.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Playfair Display',
                                color: AppTheme.charcoalNoir,
                              ),
                        ),

                        // Add to Bag Button
                        ElevatedButton(
                          onPressed: () {
                            cartProvider.addToCart(widget.product);
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Added ${widget.product.name} to your atelier bag.'),
                                duration: const Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: AppTheme.charcoalNoir,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: inCart ? AppTheme.blush100 : AppTheme.charcoalNoir,
                            foregroundColor: inCart ? AppTheme.deepRose : AppTheme.pureWhite,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(
                                color: inCart ? AppTheme.blush300 : Colors.transparent,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                inCart ? Icons.check : Icons.add,
                                size: 14,
                                color: inCart ? AppTheme.deepRose : AppTheme.pureWhite,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                inCart ? 'In Bag ($quantityInCart)' : 'Add to Bag',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

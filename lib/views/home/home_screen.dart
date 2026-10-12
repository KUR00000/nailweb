import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/product.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/catalog_provider.dart';
import '../auth/auth_modal.dart';
import '../cart/cart_sheet.dart';
import '../catalog/widgets/product_card.dart';
import '../orders/order_history_modal.dart';
import '../product_detail/product_detail_dialog.dart';
import '../common/atelier_star_icon.dart';

/// Modern Editorial Luxury Storefront for Ivory Nails Atelier.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _selectedShadeName;

  static const List<Map<String, String>> aestheticShades = [
    {'name': 'All Shades', 'hex': '#1C1917'},
    {'name': 'Rose Quartz', 'hex': '#F7CAC9'},
    {'name': 'Glazed Pearl', 'hex': '#FFF5F5'},
    {'name': 'Ballet Crème', 'hex': '#E8D5D2'},
    {'name': 'Cherry Fleck', 'hex': '#F9CCD3'},
    {'name': 'Strawberry Glass', 'hex': '#E27D8C'},
    {'name': 'Baby Blossom', 'hex': '#FAD2E1'},
    {'name': 'Angel Aurora', 'hex': '#F0E6EF'},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToCatalog() {
    _scrollController.animateTo(
      620,
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeInOutCubic,
    );
  }

  void _scrollToGuide() {
    _scrollController.animateTo(
      1550,
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;
    final isTablet = screenWidth >= 640 && screenWidth < 1024;

    final cart = context.watch<CartProvider>();
    final auth = context.watch<AuthProvider>();
    final catalog = context.watch<CatalogProvider>();

    return Scaffold(
      backgroundColor: AppTheme.ivoryGround,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // ------------------------------------------------------------------
          // 1. STICKY ATELIER NAVIGATION HEADER
          // ------------------------------------------------------------------
          SliverAppBar(
            pinned: true,
            toolbarHeight: 76,
            backgroundColor: AppTheme.pureWhite.withValues(alpha: 0.94),
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(color: AppTheme.delicateBorder, height: 1),
            ),
            title: Padding(
              padding: EdgeInsets.symmetric(horizontal: isDesktop ? 32 : 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Logo & Brand Mark
                  InkWell(
                    onTap: () {
                      catalog.setCategory('All');
                      catalog.setSearchQuery('');
                      _searchController.clear();
                      setState(() => _selectedShadeName = null);
                      _scrollController.animateTo(0, duration: const Duration(milliseconds: 400), curve: Curves.easeOut);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppTheme.charcoalNoir,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.12),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: AtelierStarIcon(size: 18, color: AppTheme.goldAccent),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Ivory Nails',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      fontFamily: 'Playfair Display',
                                      fontWeight: FontWeight.w700,
                                      fontSize: 21,
                                      letterSpacing: 0.2,
                                      color: AppTheme.charcoalNoir,
                                    ),
                              ),
                              const Text(
                                'ATELIER DE MANUCURE • PARIS',
                                style: TextStyle(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.4,
                                  color: AppTheme.dustyRose,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Center Nav Tabs (Desktop)
                  if (isDesktop)
                    Row(
                      children: [
                        _buildNavPill(
                          icon: Icons.auto_awesome_mosaic_outlined,
                          label: 'Catalog (13 Items)',
                          onTap: _scrollToCatalog,
                        ),
                        const SizedBox(width: 4),
                        _buildNavPill(
                          icon: Icons.straighten_outlined,
                          label: 'Sizing & Fit Guide',
                          onTap: _scrollToGuide,
                        ),
                        const SizedBox(width: 4),
                        _buildNavPill(
                          icon: Icons.receipt_long_outlined,
                          label: 'Orders & Receipts',
                          onTap: () => OrderHistoryModal.show(context),
                        ),
                        const SizedBox(width: 4),
                        _buildNavPill(
                          icon: Icons.shield_outlined,
                          label: 'Account & Security',
                          onTap: () => AuthModal.show(context),
                        ),
                      ],
                    ),

                  // Right Actions (User Badge & Bag Button)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // User Status Badge
                      InkWell(
                        onTap: () => AuthModal.show(context),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          height: 40,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: AppTheme.pureWhite,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.delicateBorder),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                auth.isAuthenticated ? Icons.workspace_premium_outlined : Icons.person_outline_rounded,
                                size: 16,
                                color: auth.isAuthenticated ? AppTheme.goldAccent : AppTheme.textMuted,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                auth.isAuthenticated ? auth.userName : 'Guest Mode',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.charcoalNoir,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: auth.isAuthenticated ? AppTheme.emeraldSuccess : AppTheme.textSubtle,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Floating Cart / Bag Trigger
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          InkWell(
                            onTap: () => CartSheet.show(context),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppTheme.charcoalNoir,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.16),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Icon(Icons.shopping_bag_outlined, color: AppTheme.pureWhite, size: 18),
                              ),
                            ),
                          ),
                          if (cart.itemCount > 0)
                            Positioned(
                              top: -4,
                              right: -4,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: AppTheme.dustyRose,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                                child: Center(
                                  child: Text(
                                    '${cart.itemCount}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ------------------------------------------------------------------
          // 2. RUNNING ATELIER MARQUEE RIBBON
          // ------------------------------------------------------------------
          SliverToBoxAdapter(
            child: Container(
              color: AppTheme.charcoalNoir,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                child: Row(
                  children: [
                    _buildMarqueeSegment('HAND-SCULPTED IN LIMITED ATELIER BATCHES'),
                    _buildMarqueeSegment('10-FREE CLEAN BEAUTY FORMULATION'),
                    _buildMarqueeSegment('SALON-GRADE 3-WEEK RETENTION'),
                    _buildMarqueeSegment('COMPLIMENTARY EXPRESS GIFT BOX OVER \$50'),
                    _buildMarqueeSegment('SUPABASE CLOUD SYNC & STRIPE 256-BIT SECURE'),
                    _buildMarqueeSegment('PARISIAN ATELIER STANDARDS'),
                  ],
                ),
              ),
            ),
          ),

          // ------------------------------------------------------------------
          // 3. ASYMMETRIC HAUTE COUTURE HERO SHOWCASE
          // ------------------------------------------------------------------
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1320),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 36 : 20,
                    vertical: isDesktop ? 48 : 24,
                  ),
                  child: isDesktop ? _buildDesktopHero(context) : _buildMobileHero(context),
                ),
              ),
            ),
          ),

          // ------------------------------------------------------------------
          // 4. INTERACTIVE LIVE SHADE PALETTE SELECTOR BAR
          // ------------------------------------------------------------------
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1320),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: isDesktop ? 36 : 20, vertical: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.pureWhite,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: AppTheme.delicateBorder),
                      boxShadow: AppTheme.subtleDepth,
                    ),
                    child: Row(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: AppTheme.blush100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.palette_outlined, size: 15, color: AppTheme.deepRose),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'SHADE SPECTRUM:',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.0,
                                color: AppTheme.charcoalNoir,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: aestheticShades.map((shade) {
                                final isSelected = (_selectedShadeName ?? 'All Shades') == shade['name'];
                                final color = Color(int.parse('FF${shade['hex']!.replaceAll('#', '')}', radix: 16));

                                return Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        _selectedShadeName = shade['name'];
                                      });
                                      if (shade['name'] == 'All Shades') {
                                        catalog.setSearchQuery('');
                                      } else {
                                        catalog.setSearchQuery(shade['name']!);
                                      }
                                    },
                                    borderRadius: BorderRadius.circular(22),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: isSelected ? AppTheme.velvetNoir : AppTheme.ivoryGround,
                                        borderRadius: BorderRadius.circular(22),
                                        border: Border.all(
                                          color: isSelected ? AppTheme.velvetNoir : AppTheme.delicateBorder,
                                          width: 1.0,
                                        ),
                                        boxShadow: isSelected
                                            ? [
                                                BoxShadow(
                                                  color: Colors.black.withValues(alpha: 0.12),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 13,
                                            height: 13,
                                            decoration: BoxDecoration(
                                              color: color,
                                              shape: BoxShape.circle,
                                              border: Border.all(color: Colors.white, width: 1.5),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withValues(alpha: 0.08),
                                                  blurRadius: 2,
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            shade['name']!,
                                            style: TextStyle(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w600,
                                              color: isSelected ? Colors.white : AppTheme.charcoalNoir,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ------------------------------------------------------------------
          // 5. SEARCH & CATEGORY FILTER BAR
          // ------------------------------------------------------------------
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1280),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: isDesktop ? 32 : 20, vertical: 12),
                  child: Column(
                    children: [
                      // Search and Sorting Row
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: (val) {
                                catalog.setSearchQuery(val);
                                setState(() => _selectedShadeName = null);
                              },
                              decoration: InputDecoration(
                                hintText: 'Search 13 atelier creations (e.g. Angel Wing, Glazed, Almond, Rose)...',
                                prefixIcon: const Icon(Icons.search, color: AppTheme.textMuted, size: 20),
                                suffixIcon: _searchController.text.isNotEmpty
                                    ? IconButton(
                                        onPressed: () {
                                          _searchController.clear();
                                          catalog.setSearchQuery('');
                                          setState(() => _selectedShadeName = null);
                                        },
                                        icon: const Icon(Icons.clear, size: 18),
                                      )
                                    : null,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),

                          // Sort Dropdown
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: AppTheme.pureWhite,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppTheme.delicateBorder),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: catalog.sortBy,
                                icon: const Icon(Icons.tune, size: 18, color: AppTheme.textMuted),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.charcoalNoir,
                                ),
                                onChanged: (val) {
                                  if (val != null) catalog.setSortBy(val);
                                },
                                items: const [
                                  DropdownMenuItem(value: 'featured', child: Text('Curated Collection')),
                                  DropdownMenuItem(value: 'price_asc', child: Text('Price: Low to High')),
                                  DropdownMenuItem(value: 'price_desc', child: Text('Price: High to Low')),
                                  DropdownMenuItem(value: 'rating', child: Text('Highest Rated')),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Category Filter Pills & Item Counter
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Category Tabs
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: CatalogProvider.categories.map((cat) {
                              final isSelected = catalog.selectedCategory.toLowerCase() == cat.toLowerCase();
                              final displayLabel = cat == 'All'
                                  ? 'All (13)'
                                  : cat == 'Press-On'
                                      ? 'Press-On Nails'
                                      : cat == 'Polish'
                                          ? 'Haute Polishes'
                                          : 'Care & Prep';

                              return InkWell(
                                onTap: () => catalog.setCategory(cat),
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppTheme.charcoalNoir : AppTheme.pureWhite,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected ? AppTheme.charcoalNoir : AppTheme.delicateBorder,
                                    ),
                                  ),
                                  child: Text(
                                    displayLabel,
                                    style: TextStyle(
                                      color: isSelected ? AppTheme.pureWhite : AppTheme.charcoalNoir,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),

                          Text(
                            'Showing ${catalog.filteredProducts.length} items',
                            style: const TextStyle(fontSize: 12, color: AppTheme.textMuted, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ------------------------------------------------------------------
          // 6. RESPONSIVE PRODUCT GRID (13 ITEMS)
          // ------------------------------------------------------------------
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1280),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 32 : 20,
                    vertical: 20,
                  ),
                  child: catalog.filteredProducts.isEmpty
                      ? _buildNoResults(context, catalog)
                      : GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: catalog.filteredProducts.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: isDesktop ? 4 : (isTablet ? 3 : 1),
                            crossAxisSpacing: 22,
                            mainAxisSpacing: 26,
                            childAspectRatio: isDesktop ? 0.64 : (isTablet ? 0.65 : 0.82),
                          ),
                          itemBuilder: (context, index) {
                            final product = catalog.filteredProducts[index];
                            return ProductCard(
                              product: product,
                              onTap: () => ProductDetailDialog.show(context, product),
                            );
                          },
                        ),
                ),
              ),
            ),
          ),

          // ------------------------------------------------------------------
          // 7. ATELIER CRAFTSMANSHIP & SIZING GUIDE SECTION
          // ------------------------------------------------------------------
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1320),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: isDesktop ? 36 : 20, vertical: 48),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'The Atelier Quality Standard',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      fontFamily: 'Playfair Display',
                                      fontSize: isDesktop ? 32 : 24,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: -0.4,
                                      color: AppTheme.charcoalNoir,
                                    ),
                              ),
                              const SizedBox(height: 6),
                              ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 620),
                                child: const Text(
                                  'Three foundational pillars engineered for 5+ reusable wears with zero natural keratin damage.',
                                  style: TextStyle(fontSize: 13.5, color: AppTheme.textMuted, height: 1.55),
                                ),
                              ),
                            ],
                          ),
                          if (isDesktop)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                              decoration: BoxDecoration(
                                color: AppTheme.pureWhite,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppTheme.delicateBorder),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  AtelierStarIcon(size: 10, color: AppTheme.goldAccent),
                                  SizedBox(width: 8),
                                  Text(
                                    'PARIS SALON PROTOCOL',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.0,
                                      color: AppTheme.charcoalNoir,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // Architectural 3-Pillar Editorial Container
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.pureWhite,
                          borderRadius: BorderRadius.circular(26),
                          border: Border.all(color: AppTheme.delicateBorder),
                          boxShadow: AppTheme.editorialShadow,
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: isDesktop ? 40 : 22,
                          vertical: isDesktop ? 42 : 26,
                        ),
                        child: isDesktop
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: _buildEditorialPillar(
                                      romanNumeral: 'I',
                                      title: 'Precision Sizing Architecture',
                                      badge: '15 Curated Widths',
                                      description:
                                          'Every set includes 30 nails across 15 curated widths (14mm petite to 18mm wide). Ergonomic natural curvature mapping ensures flush cuticle alignment in under 60 seconds.',
                                    ),
                                  ),
                                  Container(
                                    width: 1,
                                    height: 140,
                                    color: AppTheme.delicateBorder,
                                    margin: const EdgeInsets.symmetric(horizontal: 32),
                                  ),
                                  Expanded(
                                    child: _buildEditorialPillar(
                                      romanNumeral: 'II',
                                      title: 'Dual Wear Protocols',
                                      badge: 'Tabs or Acrylic Resin',
                                      description:
                                          'Select your duration: Ultra-hold adhesive tabs for weekend galas with instant reusability, or salon acrylic resin glue for 3 full weeks of waterproof keyboard retention.',
                                    ),
                                  ),
                                  Container(
                                    width: 1,
                                    height: 140,
                                    color: AppTheme.delicateBorder,
                                    margin: const EdgeInsets.symmetric(horizontal: 32),
                                  ),
                                  Expanded(
                                    child: _buildEditorialPillar(
                                      romanNumeral: 'III',
                                      title: 'Keratin Plate Preservation',
                                      badge: 'Zero Natural Damage',
                                      description:
                                          'Warm botanical oil immersion dissolves the adhesive bond effortlessly without peeling. Your natural nail bed stays hydrated, strong, and intact. 10-Free certified.',
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  _buildEditorialPillar(
                                    romanNumeral: 'I',
                                    title: 'Precision Sizing Architecture',
                                    badge: '15 Curated Widths',
                                    description:
                                        'Every set includes 30 nails across 15 curated widths (14mm petite to 18mm wide) ensuring flush cuticle alignment.',
                                  ),
                                  const Divider(color: AppTheme.delicateBorder, height: 32),
                                  _buildEditorialPillar(
                                    romanNumeral: 'II',
                                    title: 'Dual Wear Protocols',
                                    badge: 'Tabs or Acrylic Resin',
                                    description:
                                        'Ultra-hold adhesive tabs for weekend galas or salon acrylic resin for 3 weeks of waterproof retention.',
                                  ),
                                  const Divider(color: AppTheme.delicateBorder, height: 32),
                                  _buildEditorialPillar(
                                    romanNumeral: 'III',
                                    title: 'Keratin Plate Preservation',
                                    badge: 'Zero Natural Damage',
                                    description:
                                        'Warm botanical oil immersion releases the bond cleanly. 10-Free & cruelty-free guaranteed.',
                                  ),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ------------------------------------------------------------------
          // 8. CONNOISSEUR EDITORIAL REVIEWS
          // ------------------------------------------------------------------
          SliverToBoxAdapter(
            child: Container(
              color: AppTheme.pureWhite,
              padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1040),
                  child: Column(
                    children: [
                      const AtelierStarIcon(size: 20, color: AppTheme.goldAccent),
                      const SizedBox(height: 16),
                      Text(
                        '“The almond silhouette fits so cleanly at the cuticle that everyone assumed I spent two hours at a private Beverly Hills salon.”',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontFamily: 'Playfair Display',
                              fontSize: isDesktop ? 25 : 19,
                              fontStyle: FontStyle.italic,
                              height: 1.48,
                              color: AppTheme.charcoalNoir,
                            ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'CAMILLE R. • EDITORIAL DIRECTOR, PARIS VOGUE SELECTS',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.4,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ------------------------------------------------------------------
          // 9. FOOTER
          // ------------------------------------------------------------------
          SliverToBoxAdapter(
            child: Container(
              color: AppTheme.ivoryGround,
              padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
              child: Column(
                children: [
                  const Text(
                    '© 2026 Ivory Nails Atelier — Powered by Flutter Web, Supabase Cloud & Stripe Checkout',
                    style: TextStyle(fontSize: 12, color: AppTheme.textMuted, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(onPressed: () {}, child: const Text('Privacy Protocol', style: TextStyle(fontSize: 11, color: AppTheme.textMuted))),
                      const Text('•', style: TextStyle(color: AppTheme.delicateBorder)),
                      TextButton(onPressed: () {}, child: const Text('Terms of Sale', style: TextStyle(fontSize: 11, color: AppTheme.textMuted))),
                      const Text('•', style: TextStyle(color: AppTheme.delicateBorder)),
                      TextButton(onPressed: () {}, child: const Text('Atelier Care Guide', style: TextStyle(fontSize: 11, color: AppTheme.textMuted))),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopHero(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final spotlightProduct = Product.defaultProducts.firstWhere(
      (p) => p.id == 'p13', // Angel Wing Glaze
      orElse: () => Product.defaultProducts.first,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left Column: Editorial Manifesto
        Expanded(
          flex: 7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bespoke Glaze &\nSculpted Form.',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 64,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Playfair Display',
                      color: AppTheme.charcoalNoir,
                      height: 1.04,
                      letterSpacing: -0.8,
                    ),
              ),
              const SizedBox(height: 20),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Text(
                  'Haute couture salon press-ons and 10-Free micro-milled lacquers. Hand-sculpted in limited batches for 3-week retention with zero natural keratin damage.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textMuted,
                        fontSize: 15.5,
                        height: 1.65,
                      ),
                ),
              ),
              const SizedBox(height: 32),

              // Action Buttons
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _scrollToCatalog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.velvetNoir,
                      foregroundColor: AppTheme.pureWhite,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      elevation: 0,
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Explore 13 Pieces', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5, letterSpacing: 0.2)),
                        SizedBox(width: 8),
                        AtelierStarIcon(size: 10, color: AppTheme.goldAccent),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  OutlinedButton(
                    onPressed: _scrollToGuide,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      backgroundColor: AppTheme.pureWhite,
                      side: const BorderSide(color: AppTheme.delicateBorder),
                    ),
                    child: const Text('Fitting & Sizing Protocol', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5, color: AppTheme.charcoalNoir)),
                  ),
                ],
              ),
              const SizedBox(height: 36),

              // Hallmarks
              Row(
                children: [
                  _buildHallmarkItem('15 Sizing Widths'),
                  _buildHallmarkDivider(),
                  _buildHallmarkItem('Salon Acrylic Retention'),
                  _buildHallmarkDivider(),
                  _buildHallmarkItem('10-Free Clean Beauty'),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(width: 48),

        // Right Column: Spotlight Masterpiece Showcase
        Expanded(
          flex: 5,
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.pureWhite,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppTheme.delicateBorder),
              boxShadow: AppTheme.editorialShadow,
            ),
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: AspectRatio(
                        aspectRatio: 1.15,
                        child: Image.network(
                          spotlightProduct.imageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 14,
                      left: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.velvetNoir.withValues(alpha: 0.90),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AtelierStarIcon(size: 9, color: AppTheme.goldAccent),
                            SizedBox(width: 6),
                            Text(
                              'FLAGSHIP SPOTLIGHT • SPRING 2026',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                                color: AppTheme.pureWhite,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          spotlightProduct.name,
                          style: const TextStyle(
                            fontFamily: 'Playfair Display',
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                            color: AppTheme.charcoalNoir,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${spotlightProduct.shapeOrVolume} • ${spotlightProduct.finish}',
                          style: const TextStyle(fontSize: 12, color: AppTheme.dustyRose, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    Text(
                      '\$${spotlightProduct.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontFamily: 'Playfair Display',
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.charcoalNoir,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      cart.addToCart(spotlightProduct);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Added ${spotlightProduct.name} to atelier bag.'),
                          backgroundColor: AppTheme.charcoalNoir,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.charcoalNoir,
                      foregroundColor: AppTheme.pureWhite,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Reserve Piece • \$28.00', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
                        SizedBox(width: 8),
                        AtelierStarIcon(size: 11, color: AppTheme.goldAccent),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileHero(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bespoke Glaze &\nSculpted Form.',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontSize: 36,
                fontWeight: FontWeight.w700,
                fontFamily: 'Playfair Display',
                height: 1.1,
                letterSpacing: -0.5,
              ),
        ),
        const SizedBox(height: 12),
        const Text(
          '13 handcrafted pastel polishes & press-ons with Supabase sync and Stripe checkout.',
          style: TextStyle(color: AppTheme.textMuted, fontSize: 13.5, height: 1.55),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _scrollToCatalog,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.charcoalNoir,
            foregroundColor: AppTheme.pureWhite,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            elevation: 0,
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Explore 13 Pieces', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              SizedBox(width: 8),
              AtelierStarIcon(size: 10, color: AppTheme.goldAccent),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEditorialPillar({
    required String romanNumeral,
    required String title,
    required String badge,
    required String description,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              romanNumeral,
              style: const TextStyle(
                fontFamily: 'Playfair Display',
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppTheme.goldAccent,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.blush100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                badge,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: AppTheme.deepRose,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Playfair Display',
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: AppTheme.charcoalNoir,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: const TextStyle(
            fontSize: 13,
            color: AppTheme.textMuted,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildHallmarkItem(String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const AtelierStarIcon(size: 9, color: AppTheme.goldAccent),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: AppTheme.charcoalNoir,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildHallmarkDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Container(
        width: 3,
        height: 3,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.textSubtle,
        ),
      ),
    );
  }

  Widget _buildNavPill({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: AppTheme.textMuted),
            const SizedBox(width: 7),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12.5,
                color: AppTheme.charcoalNoir,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarqueeSegment(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AtelierStarIcon(size: 8, color: AppTheme.goldAccent),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: AppTheme.pureWhite,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults(BuildContext context, CatalogProvider catalog) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          children: [
            const Icon(Icons.search_off, size: 48, color: AppTheme.dustyRose),
            const SizedBox(height: 16),
            const Text(
              'No atelier items found',
              style: TextStyle(fontFamily: 'Playfair Display', fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text('Try adjusting your search terms or selecting another category.', style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {
                _searchController.clear();
                catalog.setCategory('All');
                catalog.setSearchQuery('');
                setState(() => _selectedShadeName = null);
              },
              child: const Text('Reset All Filters'),
            ),
          ],
        ),
      ),
    );
  }
}

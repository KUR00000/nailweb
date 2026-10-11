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
                constraints: const BoxConstraints(maxWidth: 1280),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 32 : 20,
                    vertical: isDesktop ? 40 : 24,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.pureWhite, Color(0xFFF9F5F3)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: AppTheme.delicateBorder),
                      boxShadow: AppTheme.softShadow,
                    ),
                    padding: EdgeInsets.all(isDesktop ? 48 : 24),
                    child: isDesktop ? _buildDesktopHero(context) : _buildMobileHero(context),
                  ),
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
                constraints: const BoxConstraints(maxWidth: 1280),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: isDesktop ? 32 : 20, vertical: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppTheme.pureWhite,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppTheme.delicateBorder),
                    ),
                    child: Row(
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.palette_outlined, size: 16, color: AppTheme.dustyRose),
                            SizedBox(width: 8),
                            Text(
                              'SHADE PALETTE:',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                                color: AppTheme.charcoalNoir,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
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
                                    borderRadius: BorderRadius.circular(20),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: isSelected ? AppTheme.charcoalNoir : AppTheme.ivoryGround,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: isSelected ? AppTheme.charcoalNoir : AppTheme.delicateBorder,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 12,
                                            height: 12,
                                            decoration: BoxDecoration(
                                              color: color,
                                              shape: BoxShape.circle,
                                              border: Border.all(color: Colors.white, width: 1.5),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            shade['name']!,
                                            style: TextStyle(
                                              fontSize: 11,
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
                constraints: const BoxConstraints(maxWidth: 1280),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: isDesktop ? 32 : 20, vertical: 36),
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
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.blush100,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'SALON PROTOCOL',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.8, color: AppTheme.dustyRose),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'The Atelier Quality Standard',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      fontFamily: 'Playfair Display',
                                      fontSize: 26,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                          if (isDesktop)
                            const Text(
                              'Designed for 5+ Reusable Wears • Zero Damage',
                              style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                            ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // 3 Feature Cards
                      Row(
                        children: [
                          Expanded(
                            child: _buildGuideCard(
                              context,
                              icon: Icons.straighten,
                              tag: 'STEP 1: SIZING',
                              title: 'Precision Sizing',
                              description:
                                  'Every set includes 30 nails across 15 curated widths. From delicate petite beds (14mm) to wide profiles (18mm), finding your custom contour takes under 60 seconds.',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildGuideCard(
                              context,
                              icon: Icons.brush_outlined,
                              tag: 'STEP 2: APPLICATION',
                              title: 'Two Wear Protocols',
                              description:
                                  'Option A: Ultra-hold adhesive tabs for weekend galas (reusable instantly). Option B: Salon acrylic resin glue for 3 full weeks of shower and keyboard-proof hold.',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildGuideCard(
                              context,
                              icon: Icons.auto_awesome,
                              tag: 'STEP 3: LONGEVITY',
                              title: 'Zero Natural Damage',
                              description:
                                  'Gentle warm water & cuticle oil soak enables seamless removal without damaging your natural nail bed keratin layer. 10-Free & cruelty-free guaranteed.',
                            ),
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
          // 8. CONNOISSEUR EDITORIAL REVIEWS
          // ------------------------------------------------------------------
          SliverToBoxAdapter(
            child: Container(
              color: AppTheme.pureWhite,
              padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: Column(
                    children: [
                      const Icon(Icons.format_quote, size: 36, color: AppTheme.dustyRose),
                      const SizedBox(height: 12),
                      Text(
                        '“The almond silhouette fits so cleanly at the cuticle that everyone assumed I spent two hours at a private Beverly Hills salon.”',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontFamily: 'Playfair Display',
                              fontSize: 22,
                              fontStyle: FontStyle.italic,
                              height: 1.45,
                              color: AppTheme.charcoalNoir,
                            ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'CAMILLE R. • EDITORIAL DIRECTOR, PARIS VOGUE SELECTS',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: AppTheme.textMuted),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.charcoalNoir,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AtelierStarIcon(size: 8, color: AppTheme.goldAccent),
                    SizedBox(width: 8),
                    Text(
                      'SPRING 2026 EDITORIAL • 13 HAND-POURED CREATIONS',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: AppTheme.pureWhite,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Bespoke Glaze &\nSculpted Form.',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 54,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Playfair Display',
                      color: AppTheme.charcoalNoir,
                      height: 1.08,
                    ),
              ),
              const SizedBox(height: 16),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 540),
                child: Text(
                  'Haute couture salon press-ons and 10-Free micro-milled lacquers. Engineered for zero natural nail damage and effortless 3-week wear, paired with Supabase authentication and safe Stripe payments.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textMuted,
                        fontSize: 15,
                        height: 1.6,
                      ),
                ),
              ),
              const SizedBox(height: 28),

              // Action Buttons
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _scrollToCatalog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.charcoalNoir,
                      foregroundColor: AppTheme.pureWhite,
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Explore 13 Pieces', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_downward, size: 16),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  OutlinedButton(
                    onPressed: _scrollToGuide,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      backgroundColor: AppTheme.pureWhite,
                    ),
                    child: const Text('Sizing & Fit Guide', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(width: 40),

        // Right Column: Spotlight Masterpiece Card
        Expanded(
          flex: 5,
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.pureWhite,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.delicateBorder),
              boxShadow: AppTheme.cardHoverShadow,
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: AspectRatio(
                        aspectRatio: 1.15,
                        child: Image.network(
                          spotlightProduct.imageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppTheme.charcoalNoir,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AtelierStarIcon(size: 10, color: AppTheme.goldAccent),
                            SizedBox(width: 6),
                            Text(
                              'FLAGSHIP SPOTLIGHT',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                                color: AppTheme.goldAccent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          spotlightProduct.name,
                          style: const TextStyle(
                            fontFamily: 'Playfair Display',
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: AppTheme.charcoalNoir,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${spotlightProduct.shapeOrVolume} • ${spotlightProduct.finish}',
                          style: const TextStyle(fontSize: 11, color: AppTheme.dustyRose, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    Text(
                      '\$${spotlightProduct.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontFamily: 'Playfair Display',
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.charcoalNoir,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

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
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Add Flagship to Bag • \$28.00', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.charcoalNoir,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AtelierStarIcon(size: 8, color: AppTheme.goldAccent),
              SizedBox(width: 6),
              Text(
                'SPRING 2026 • 13 PIECES',
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: Colors.white),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Bespoke Glaze &\nSculpted Form.',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                fontFamily: 'Playfair Display',
                height: 1.15,
              ),
        ),
        const SizedBox(height: 10),
        const Text(
          '13 handcrafted pastel polishes & press-ons with Supabase sync and Stripe checkout.',
          style: TextStyle(color: AppTheme.textMuted, fontSize: 13, height: 1.5),
        ),
        const SizedBox(height: 18),
        ElevatedButton(
          onPressed: _scrollToCatalog,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.charcoalNoir,
            foregroundColor: AppTheme.pureWhite,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Explore 13 Pieces', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              SizedBox(width: 6),
              Icon(Icons.arrow_downward, size: 14),
            ],
          ),
        ),
      ],
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

  Widget _buildGuideCard(
    BuildContext context, {
    required IconData icon,
    required String tag,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppTheme.pureWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.delicateBorder),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.blush50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.dustyRose, size: 22),
          ),
          const SizedBox(height: 14),
          Text(
            tag,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: AppTheme.dustyRose,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Playfair Display',
              fontWeight: FontWeight.w700,
              fontSize: 17,
              color: AppTheme.charcoalNoir,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textMuted,
              height: 1.5,
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

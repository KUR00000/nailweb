/// Model representing an Ivory Nails luxury product.
class Product {
  final String id;
  final String name;
  final double price;
  final String category; // 'Polish', 'Press-On', 'Care'
  final double rating;
  final int reviewCount;
  final String imageUrl;
  final String description;
  final String details;
  final String finish;
  final String shadeHex;
  final String shapeOrVolume;
  final String? tag; // e.g. 'BESTSELLER', 'ATELIER COUTURE', 'VIRAL GLAZE'
  final bool inStock;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.rating,
    required this.reviewCount,
    required this.imageUrl,
    required this.description,
    required this.details,
    required this.finish,
    required this.shadeHex,
    required this.shapeOrVolume,
    this.tag,
    this.inStock = true,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      category: json['category'] ?? 'Polish',
      rating: (json['rating'] as num?)?.toDouble() ?? 4.9,
      reviewCount: (json['review_count'] as num?)?.toInt() ?? 42,
      imageUrl: json['image_url'] ?? '',
      description: json['description'] ?? '',
      details: json['details'] ?? '',
      finish: json['finish'] ?? 'High-Gloss',
      shadeHex: json['shade_hex'] ?? '#F4C2C2',
      shapeOrVolume: json['shape_or_volume'] ?? '15ml',
      tag: json['tag'],
      inStock: json['in_stock'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'category': category,
      'rating': rating,
      'review_count': reviewCount,
      'image_url': imageUrl,
      'description': description,
      'details': details,
      'finish': finish,
      'shade_hex': shadeHex,
      'shape_or_volume': shapeOrVolume,
      'tag': tag,
      'in_stock': inStock,
    };
  }

  // --------------------------------------------------------------------------
  // EXACT 13 CURATED LUXURY NAIL PRODUCTS (ALL 100% AUTHENTIC SALON MANICURE PHOTOGRAPHY)
  // --------------------------------------------------------------------------
  static const List<Product> defaultProducts = [
    Product(
      id: 'p1',
      name: 'Baby Blossom Polish',
      price: 14.50,
      category: 'Polish',
      rating: 4.9,
      reviewCount: 48,
      imageUrl:
          'https://images.unsplash.com/photo-1604654894610-df63bc536371?auto=format&fit=crop&w=800&q=80',
      description: 'Soft pastel pink lacquer with mirror glass gloss finish.',
      details:
          '15ml bottle. 10-Free, vegan, and cruelty-free formulation. Delivers a gel-effect high-gloss coat without requiring UV lamps.',
      finish: 'Mirror Gel Glaze',
      shadeHex: '#FAD2E1',
      shapeOrVolume: '15ml Lacquer',
      tag: 'BESTSELLER',
    ),
    Product(
      id: 'p2',
      name: 'Rose Quartz Press-Ons',
      price: 24.00,
      category: 'Press-On',
      rating: 5.0,
      reviewCount: 64,
      imageUrl:
          'https://images.unsplash.com/photo-1632345031435-8727f6897d53?auto=format&fit=crop&w=800&q=80',
      description: 'Handcrafted medium almond nails with genuine quartz shimmer veins.',
      details:
          'Set of 30 salon-grade acrylic press-ons across 15 custom fit sizes. Includes adhesive tabs, nail glue, cuticle stick, and prep buffer pad.',
      finish: 'Quartz Shimmer',
      shadeHex: '#F7CAC9',
      shapeOrVolume: 'Medium Almond',
      tag: 'VIRAL SHADE',
    ),
    Product(
      id: 'p3',
      name: 'Milky Glaze Topcoat',
      price: 12.00,
      category: 'Care',
      rating: 4.8,
      reviewCount: 39,
      imageUrl:
          'https://images.unsplash.com/photo-1519014816548-bf5fe059798b?auto=format&fit=crop&w=800&q=80',
      description: 'Semi-translucent pearl chrome shine for Hailey-inspired glazed donut nails.',
      details:
          'Fast-drying mirror shine topcoat fortified with natural keratin and vitamin E for cuticle hydration and chip resistance.',
      finish: 'Glazed Donut Pearl',
      shadeHex: '#FFF5F5',
      shapeOrVolume: '15ml Topcoat',
      tag: 'MUST-HAVE',
    ),
    Product(
      id: 'p4',
      name: 'Petal Pink Shimmer',
      price: 16.00,
      category: 'Polish',
      rating: 4.9,
      reviewCount: 52,
      imageUrl:
          'https://images.unsplash.com/photo-1607779097040-26e80aa78e66?auto=format&fit=crop&w=800&q=80',
      description: 'Fine gold mineral flakes infused inside soft cherry blossom pink.',
      details:
          'Micro-milled optical mica flakes suspended in velvety soft blush lacquer for multi-dimensional daylight brilliance.',
      finish: 'Gold Fleck Shimmer',
      shadeHex: '#F9CCD3',
      shapeOrVolume: '15ml Lacquer',
    ),
    Product(
      id: 'p5',
      name: 'Pearl Radiance Nails',
      price: 26.50,
      category: 'Press-On',
      rating: 5.0,
      reviewCount: 71,
      imageUrl:
          'https://images.unsplash.com/photo-1632345031435-8727f6897d53?auto=format&fit=crop&w=800&q=80',
      description: 'Coquette bridal pearl studs set over delicate sheer blush tips.',
      details:
          'Hand-sculpted acrylic nails set with genuine miniature seed pearls. Reinforced tips provide chip-free durability for up to 3 weeks.',
      finish: 'Seed Pearl 3D',
      shadeHex: '#FFF0F5',
      shapeOrVolume: 'Long Oval',
      tag: 'BRIDAL EDIT',
    ),
    Product(
      id: 'p6',
      name: 'Cute Blush Gloss',
      price: 15.00,
      category: 'Polish',
      rating: 4.7,
      reviewCount: 33,
      imageUrl:
          'https://images.unsplash.com/photo-1604654894610-df63bc536371?auto=format&fit=crop&w=800&q=80',
      description: 'Buildable jelly watercolor syrup consistency with natural rosy flush.',
      details:
          'Layerable translucent syrup consistency inspired by Tokyo salon aesthetics. Effortlessly builds from subtle tint to juicy glass.',
      finish: 'Syrup Jelly Gloss',
      shadeHex: '#F6A8B8',
      shapeOrVolume: '15ml Lacquer',
    ),
    Product(
      id: 'p7',
      name: 'Soft Marshmallow Dip',
      price: 18.00,
      category: 'Care',
      rating: 4.9,
      reviewCount: 41,
      imageUrl:
          'https://images.unsplash.com/photo-1576426863848-c21f53c60b19?auto=format&fit=crop&w=800&q=80',
      description: 'Nourishing acrylic dip powder for unbreakable pastel salon strength.',
      details:
          'Enriched with organic calcium carbonate and vitamin B5. Strengthens thin and brittle nail beds with seamless salon durability.',
      finish: 'Soft Crème Satin',
      shadeHex: '#FDF2F4',
      shapeOrVolume: '28g Dip Jar',
      tag: 'STRENGTHENING',
    ),
    Product(
      id: 'p8',
      name: 'Velvet Ballet Polish',
      price: 14.00,
      category: 'Polish',
      rating: 4.8,
      reviewCount: 45,
      imageUrl:
          'https://images.unsplash.com/photo-1607779097040-26e80aa78e66?auto=format&fit=crop&w=800&q=80',
      description: 'Creamy ballet slipper pink that flatters every skin tone.',
      details:
          'Classic neutral blush crème offering full, self-leveling opacity in two smooth coats. Wide contour brush for clean cuticle contours.',
      finish: 'Ballet Crème',
      shadeHex: '#E8D5D2',
      shapeOrVolume: '15ml Lacquer',
      tag: 'ICONIC',
    ),
    Product(
      id: 'p9',
      name: 'Sparkle Dust Gloss',
      price: 13.50,
      category: 'Polish',
      rating: 4.6,
      reviewCount: 29,
      imageUrl:
          'https://images.unsplash.com/photo-1519014816548-bf5fe059798b?auto=format&fit=crop&w=800&q=80',
      description: 'Prismatic holographic glitter topper engineered for accent nails.',
      details:
          'Silky suspension formula loaded with prismatic silver and champagne glitter particles. Dries crystal clear without grittiness.',
      finish: 'Prismatic Hologram',
      shadeHex: '#ECE7EB',
      shapeOrVolume: '15ml Topper',
    ),
    Product(
      id: 'p10',
      name: 'French Vanilla Press-Ons',
      price: 22.00,
      category: 'Press-On',
      rating: 4.9,
      reviewCount: 58,
      imageUrl:
          'https://images.unsplash.com/photo-1632345031435-8727f6897d53?auto=format&fit=crop&w=800&q=80',
      description: 'Ultra-thin micro-french tips with soft cream tips and sheer base.',
      details:
          'Short squoval profile engineered for everyday luxury. Features graduated micro-french precision smile lines with flexible cuticle fit.',
      finish: 'Micro-French Crème',
      shadeHex: '#FAF4EF',
      shapeOrVolume: 'Short Squoval',
      tag: 'TIMELESS',
    ),
    Product(
      id: 'p11',
      name: 'Berry Sweet Gloss',
      price: 15.50,
      category: 'Polish',
      rating: 4.8,
      reviewCount: 37,
      imageUrl:
          'https://images.unsplash.com/photo-1519014816548-bf5fe059798b?auto=format&fit=crop&w=800&q=80',
      description: 'Juicy strawberry glaze hue with high-gloss UV shield protection.',
      details:
          'Infused with antioxidant raspberry seed oil and natural UV protectants to shield manicures from fading in bright sunlight.',
      finish: 'Strawberry Glass',
      shadeHex: '#E27D8C',
      shapeOrVolume: '15ml Lacquer',
    ),
    Product(
      id: 'p12',
      name: 'Cotton Candy Polish',
      price: 14.00,
      category: 'Polish',
      rating: 4.7,
      reviewCount: 34,
      imageUrl:
          'https://images.unsplash.com/photo-1607779097040-26e80aa78e66?auto=format&fit=crop&w=800&q=80',
      description: 'Playful lilac-pink pastel with delicate iridescent undertones.',
      details:
          'Airy, creamy pastel formula designed for high impact coverage and chip resistance up to 10 days when paired with our Milky Glaze.',
      finish: 'Pastel Lilac Blush',
      shadeHex: '#D8BFD8',
      shapeOrVolume: '15ml Lacquer',
    ),
    Product(
      id: 'p13',
      name: 'Angel Wing Glaze',
      price: 28.00,
      category: 'Press-On',
      rating: 5.0,
      reviewCount: 89,
      imageUrl:
          'https://images.unsplash.com/photo-1604654894610-df63bc536371?auto=format&fit=crop&w=800&q=80',
      description: 'Haute couture editorial nails with 3D sculpted angel wings & aurora foil.',
      details:
          'Atelier couture statement set. Features sculpted 3D resin angel wings, celestial crystals, and hand-applied aurora chrome foil.',
      finish: '3D Sculpted Wings & Foil',
      shadeHex: '#F0E6EF',
      shapeOrVolume: 'Stiletto Couture',
      tag: 'ATELIER MASTERPIECE',
    ),
  ];
}

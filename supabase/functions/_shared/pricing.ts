export interface CartItemInput {
  productId: string;
  quantity: number;
}

export interface ProductRecord {
  id: string;
  name: string;
  price: number;
  in_stock: boolean;
  image_url?: string;
}

export interface CalculatedOrder {
  items: Array<{
    productId: string;
    productName: string;
    quantity: number;
    unitPrice: number;
    totalPrice: number;
    imageUrl?: string;
  }>;
  subtotal: number;
  discountAmount: number;
  discountPercentage: number;
  appliedPromoCode: string | null;
  tax: number;
  shipping: number;
  totalAmount: number;
}

const TAX_RATE = 0.08;
const FREE_SHIPPING_THRESHOLD = 50.00;
const STANDARD_SHIPPING_FEE = 4.99;

export function calculateOrderDetails(
  inputItems: CartItemInput[],
  dbProducts: Map<string, ProductRecord>,
  promoCode?: string
): CalculatedOrder {
  if (!inputItems || inputItems.length === 0) {
    throw new Error('Shopping bag is empty');
  }

  const items: CalculatedOrder['items'] = [];
  let rawSubtotal = 0;

  for (const input of inputItems) {
    if (!input.quantity || input.quantity <= 0 || !Number.isInteger(input.quantity)) {
      throw new Error(`Invalid quantity for item ${input.productId}`);
    }

    const product = dbProducts.get(input.productId);
    if (!product) {
      throw new Error(`Product ${input.productId} not found in catalog`);
    }

    if (!product.in_stock) {
      throw new Error(`Product "${product.name}" is out of stock`);
    }

    const unitPrice = Number(product.price);
    const totalPrice = Math.round(unitPrice * input.quantity * 100) / 100;
    rawSubtotal += totalPrice;

    items.push({
      productId: product.id,
      productName: product.name,
      quantity: input.quantity,
      unitPrice,
      totalPrice,
      imageUrl: product.image_url,
    });
  }

  rawSubtotal = Math.round(rawSubtotal * 100) / 100;

  // Authoritative promo validation
  let discountPercentage = 0.0;
  let appliedPromoCode: string | null = null;
  if (promoCode) {
    const cleanCode = promoCode.trim().toUpperCase();
    if (cleanCode === 'IVORY10' || cleanCode === 'VIP10') {
      discountPercentage = 0.10;
      appliedPromoCode = cleanCode;
    } else if (cleanCode === 'ATELIER20') {
      discountPercentage = 0.20;
      appliedPromoCode = cleanCode;
    }
  }

  const discountAmount = Math.round(rawSubtotal * discountPercentage * 100) / 100;
  const subtotal = Math.round((rawSubtotal - discountAmount) * 100) / 100;
  const tax = Math.round(subtotal * TAX_RATE * 100) / 100;
  const shipping = (items.length === 0 || subtotal >= FREE_SHIPPING_THRESHOLD) ? 0.00 : STANDARD_SHIPPING_FEE;
  const totalAmount = Math.round((subtotal + tax + shipping) * 100) / 100;

  return {
    items,
    subtotal,
    discountAmount,
    discountPercentage,
    appliedPromoCode,
    tax,
    shipping,
    totalAmount,
  };
}

export interface Database {
  public: {
    Tables: {
      products: {
        Row: {
          id: string;
          name: string;
          price: number;
          category: string;
          rating: number;
          review_count: number;
          image_url: string;
          description: string;
          details: string | null;
          in_stock: boolean;
          created_at: string;
        };
        Insert: Partial<Database['public']['Tables']['products']['Row']>;
        Update: Partial<Database['public']['Tables']['products']['Row']>;
      };
      profiles: {
        Row: {
          id: string;
          email: string;
          full_name: string | null;
          role: string;
          avatar_url: string | null;
          created_at: string;
          updated_at: string;
        };
        Insert: Partial<Database['public']['Tables']['profiles']['Row']>;
        Update: Partial<Database['public']['Tables']['profiles']['Row']>;
      };
      orders: {
        Row: {
          id: string;
          user_id: string | null;
          customer_email: string;
          customer_name: string;
          subtotal: number;
          tax: number;
          shipping: number;
          total_amount: number;
          status: string;
          stripe_payment_id: string | null;
          shipping_address: Record<string, any> | null;
          created_at: string;
        };
        Insert: Partial<Database['public']['Tables']['orders']['Row']>;
        Update: Partial<Database['public']['Tables']['orders']['Row']>;
      };
      order_items: {
        Row: {
          id: string;
          order_id: string;
          product_id: string;
          product_name: string;
          quantity: number;
          unit_price: number;
          total_price: number;
        };
        Insert: Partial<Database['public']['Tables']['order_items']['Row']>;
        Update: Partial<Database['public']['Tables']['order_items']['Row']>;
      };
    };
  };
}

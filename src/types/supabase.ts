export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export interface Database {
  public: {
    Tables: {
      audit_logs: {
        Row: {
          id: string | null
          user_id: string | null
          action: string | null
          entity_type: string | null
          entity_id: string | null
          metadata: Json | null
          ip_address: string | null
          user_agent: string | null
          created_at: string | null
        }
        Insert: {
          id?: string | null
          user_id?: string | null
          action?: string | null
          entity_type?: string | null
          entity_id?: string | null
          metadata?: Json | null
          ip_address?: string | null
          user_agent?: string | null
          created_at?: string | null
        }
        Update: {
          id?: string | null
          user_id?: string | null
          action?: string | null
          entity_type?: string | null
          entity_id?: string | null
          metadata?: Json | null
          ip_address?: string | null
          user_agent?: string | null
          created_at?: string | null
        }
      }
      disease_scans: {
        Row: {
          id: string | null
          user_id: string | null
          farm_id: string | null
          image_url: string | null
          disease_name: string | null
          confidence_score: number | null
          symptoms: Json | null
          cause: string | null
          treatment: Json | null
          recommended_fertilizers: Json | null
          recommended_pesticides: Json | null
          prevention_tips: Json | null
          created_at: string | null
        }
        Insert: {
          id?: string | null
          user_id?: string | null
          farm_id?: string | null
          image_url?: string | null
          disease_name?: string | null
          confidence_score?: number | null
          symptoms?: Json | null
          cause?: string | null
          treatment?: Json | null
          recommended_fertilizers?: Json | null
          recommended_pesticides?: Json | null
          prevention_tips?: Json | null
          created_at?: string | null
        }
        Update: {
          id?: string | null
          user_id?: string | null
          farm_id?: string | null
          image_url?: string | null
          disease_name?: string | null
          confidence_score?: number | null
          symptoms?: Json | null
          cause?: string | null
          treatment?: Json | null
          recommended_fertilizers?: Json | null
          recommended_pesticides?: Json | null
          prevention_tips?: Json | null
          created_at?: string | null
        }
      }
      farms: {
        Row: {
          id: string | null
          user_id: string | null
          name: string | null
          health: number | null
          status: string | null
          created_at: string | null
          area_acres: number | null
          soil_type: string | null
          crop_type: string | null
          irrigation_type: string | null
          water_source: string | null
          coordinates: Json | null
          images: string[] | null
        }
        Insert: {
          id?: string | null
          user_id?: string | null
          name?: string | null
          health?: number | null
          status?: string | null
          created_at?: string | null
          area_acres?: number | null
          soil_type?: string | null
          crop_type?: string | null
          irrigation_type?: string | null
          water_source?: string | null
          coordinates?: Json | null
          images?: string[] | null
        }
        Update: {
          id?: string | null
          user_id?: string | null
          name?: string | null
          health?: number | null
          status?: string | null
          created_at?: string | null
          area_acres?: number | null
          soil_type?: string | null
          crop_type?: string | null
          irrigation_type?: string | null
          water_source?: string | null
          coordinates?: Json | null
          images?: string[] | null
        }
      }
      irrigation_configs: {
        Row: {
          id: string | null
          user_id: string | null
          farm_id: string | null
          moisture_threshold: number | null
          temperature_threshold: number | null
          rain_detection_enabled: boolean | null
          watering_schedule: Json | null
          emergency_watering_enabled: boolean | null
          pump_status: string | null
          created_at: string | null
          updated_at: string | null
        }
        Insert: {
          id?: string | null
          user_id?: string | null
          farm_id?: string | null
          moisture_threshold?: number | null
          temperature_threshold?: number | null
          rain_detection_enabled?: boolean | null
          watering_schedule?: Json | null
          emergency_watering_enabled?: boolean | null
          pump_status?: string | null
          created_at?: string | null
          updated_at?: string | null
        }
        Update: {
          id?: string | null
          user_id?: string | null
          farm_id?: string | null
          moisture_threshold?: number | null
          temperature_threshold?: number | null
          rain_detection_enabled?: boolean | null
          watering_schedule?: Json | null
          emergency_watering_enabled?: boolean | null
          pump_status?: string | null
          created_at?: string | null
          updated_at?: string | null
        }
      }
      learning_progress: {
        Row: {
          id: string | null
          user_id: string | null
          course_id: string | null
          lesson_id: string | null
          status: string | null
          video_timestamp_seconds: number | null
          created_at: string | null
          updated_at: string | null
        }
        Insert: {
          id?: string | null
          user_id?: string | null
          course_id?: string | null
          lesson_id?: string | null
          status?: string | null
          video_timestamp_seconds?: number | null
          created_at?: string | null
          updated_at?: string | null
        }
        Update: {
          id?: string | null
          user_id?: string | null
          course_id?: string | null
          lesson_id?: string | null
          status?: string | null
          video_timestamp_seconds?: number | null
          created_at?: string | null
          updated_at?: string | null
        }
      }
      notifications: {
        Row: {
          id: string | null
          user_id: string | null
          type: string | null
          title: string | null
          message: string | null
          link: string | null
          is_read: boolean | null
          created_at: string | null
        }
        Insert: {
          id?: string | null
          user_id?: string | null
          type?: string | null
          title?: string | null
          message?: string | null
          link?: string | null
          is_read?: boolean | null
          created_at?: string | null
        }
        Update: {
          id?: string | null
          user_id?: string | null
          type?: string | null
          title?: string | null
          message?: string | null
          link?: string | null
          is_read?: boolean | null
          created_at?: string | null
        }
      }
      order_items: {
        Row: {
          id: string | null
          order_id: string | null
          product_id: string | null
          quantity: number | null
          unit_price: number | null
          created_at: string | null
        }
        Insert: {
          id?: string | null
          order_id?: string | null
          product_id?: string | null
          quantity?: number | null
          unit_price?: number | null
          created_at?: string | null
        }
        Update: {
          id?: string | null
          order_id?: string | null
          product_id?: string | null
          quantity?: number | null
          unit_price?: number | null
          created_at?: string | null
        }
      }
      orders: {
        Row: {
          id: string | null
          buyer_id: string | null
          total_amount: number | null
          status: string | null
          shipping_address: Json | null
          payment_method: string | null
          razorpay_order_id: string | null
          created_at: string | null
          updated_at: string | null
        }
        Insert: {
          id?: string | null
          buyer_id?: string | null
          total_amount?: number | null
          status?: string | null
          shipping_address?: Json | null
          payment_method?: string | null
          razorpay_order_id?: string | null
          created_at?: string | null
          updated_at?: string | null
        }
        Update: {
          id?: string | null
          buyer_id?: string | null
          total_amount?: number | null
          status?: string | null
          shipping_address?: Json | null
          payment_method?: string | null
          razorpay_order_id?: string | null
          created_at?: string | null
          updated_at?: string | null
        }
      }
      post_comments: {
        Row: {
          id: string | null
          post_id: string | null
          author_id: string | null
          content: string | null
          created_at: string | null
          updated_at: string | null
        }
        Insert: {
          id?: string | null
          post_id?: string | null
          author_id?: string | null
          content?: string | null
          created_at?: string | null
          updated_at?: string | null
        }
        Update: {
          id?: string | null
          post_id?: string | null
          author_id?: string | null
          content?: string | null
          created_at?: string | null
          updated_at?: string | null
        }
      }
      post_likes: {
        Row: {
          post_id: string | null
          user_id: string | null
          created_at: string | null
        }
        Insert: {
          post_id?: string | null
          user_id?: string | null
          created_at?: string | null
        }
        Update: {
          post_id?: string | null
          user_id?: string | null
          created_at?: string | null
        }
      }
      posts: {
        Row: {
          id: string | null
          author_id: string | null
          content: string | null
          tags: string[] | null
          image_url: string | null
          likes: number | null
          comments: number | null
          is_expert: boolean | null
          created_at: string | null
          comments_count: number | null
          likes_count: number | null
          images: string[] | null
        }
        Insert: {
          id?: string | null
          author_id?: string | null
          content?: string | null
          tags?: string[] | null
          image_url?: string | null
          likes?: number | null
          comments?: number | null
          is_expert?: boolean | null
          created_at?: string | null
          comments_count?: number | null
          likes_count?: number | null
          images?: string[] | null
        }
        Update: {
          id?: string | null
          author_id?: string | null
          content?: string | null
          tags?: string[] | null
          image_url?: string | null
          likes?: number | null
          comments?: number | null
          is_expert?: boolean | null
          created_at?: string | null
          comments_count?: number | null
          likes_count?: number | null
          images?: string[] | null
        }
      }
      products: {
        Row: {
          id: string | null
          seller_id: string | null
          name: string | null
          category: string | null
          description: string | null
          price: number | null
          discount: number | null
          stock_quantity: number | null
          images: string[] | null
          specifications: Json | null
          average_rating: number | null
          total_reviews: number | null
          is_active: boolean | null
          created_at: string | null
          updated_at: string | null
        }
        Insert: {
          id?: string | null
          seller_id?: string | null
          name?: string | null
          category?: string | null
          description?: string | null
          price?: number | null
          discount?: number | null
          stock_quantity?: number | null
          images?: string[] | null
          specifications?: Json | null
          average_rating?: number | null
          total_reviews?: number | null
          is_active?: boolean | null
          created_at?: string | null
          updated_at?: string | null
        }
        Update: {
          id?: string | null
          seller_id?: string | null
          name?: string | null
          category?: string | null
          description?: string | null
          price?: number | null
          discount?: number | null
          stock_quantity?: number | null
          images?: string[] | null
          specifications?: Json | null
          average_rating?: number | null
          total_reviews?: number | null
          is_active?: boolean | null
          created_at?: string | null
          updated_at?: string | null
        }
      }
      profiles: {
        Row: {
          id: string | null
          full_name: string | null
          phone: string | null
          avatar_url: string | null
          created_at: string | null
          role: string | null
          phone_number: string | null
          location: string | null
          preferences: Json | null
          user_id: string | null
        }
        Insert: {
          id?: string | null
          full_name?: string | null
          phone?: string | null
          avatar_url?: string | null
          created_at?: string | null
          role?: string | null
          phone_number?: string | null
          location?: string | null
          preferences?: Json | null
          user_id?: string | null
        }
        Update: {
          id?: string | null
          full_name?: string | null
          phone?: string | null
          avatar_url?: string | null
          created_at?: string | null
          role?: string | null
          phone_number?: string | null
          location?: string | null
          preferences?: Json | null
          user_id?: string | null
        }
      }
      reviews: {
        Row: {
          id: string | null
          product_id: string | null
          user_id: string | null
          rating: number | null
          comment: string | null
          created_at: string | null
        }
        Insert: {
          id?: string | null
          product_id?: string | null
          user_id?: string | null
          rating?: number | null
          comment?: string | null
          created_at?: string | null
        }
        Update: {
          id?: string | null
          product_id?: string | null
          user_id?: string | null
          rating?: number | null
          comment?: string | null
          created_at?: string | null
        }
      }
      transport_bookings: {
        Row: {
          id: string | null
          user_id: string | null
          pickup_farm_id: string | null
          vehicle_type: string | null
          capacity_tons: number | null
          destination: string | null
          pickup_date: string | null
          pickup_time: string | null
          contact_number: string | null
          notes: string | null
          status: string | null
          receipt_url: string | null
          created_at: string | null
          updated_at: string | null
        }
        Insert: {
          id?: string | null
          user_id?: string | null
          pickup_farm_id?: string | null
          vehicle_type?: string | null
          capacity_tons?: number | null
          destination?: string | null
          pickup_date?: string | null
          pickup_time?: string | null
          contact_number?: string | null
          notes?: string | null
          status?: string | null
          receipt_url?: string | null
          created_at?: string | null
          updated_at?: string | null
        }
        Update: {
          id?: string | null
          user_id?: string | null
          pickup_farm_id?: string | null
          vehicle_type?: string | null
          capacity_tons?: number | null
          destination?: string | null
          pickup_date?: string | null
          pickup_time?: string | null
          contact_number?: string | null
          notes?: string | null
          status?: string | null
          receipt_url?: string | null
          created_at?: string | null
          updated_at?: string | null
        }
      }
      yield_predictions: {
        Row: {
          id: string | null
          user_id: string | null
          farm_id: string | null
          expected_yield_tons: number | null
          estimated_profit: number | null
          risk_level: string | null
          recommended_improvements: Json | null
          ai_explanation: string | null
          weather_snapshot: Json | null
          soil_data_snapshot: Json | null
          created_at: string | null
        }
        Insert: {
          id?: string | null
          user_id?: string | null
          farm_id?: string | null
          expected_yield_tons?: number | null
          estimated_profit?: number | null
          risk_level?: string | null
          recommended_improvements?: Json | null
          ai_explanation?: string | null
          weather_snapshot?: Json | null
          soil_data_snapshot?: Json | null
          created_at?: string | null
        }
        Update: {
          id?: string | null
          user_id?: string | null
          farm_id?: string | null
          expected_yield_tons?: number | null
          estimated_profit?: number | null
          risk_level?: string | null
          recommended_improvements?: Json | null
          ai_explanation?: string | null
          weather_snapshot?: Json | null
          soil_data_snapshot?: Json | null
          created_at?: string | null
        }
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      [_ in never]: never
    }
    Enums: {
      [_ in never]: never
    }
  }
}

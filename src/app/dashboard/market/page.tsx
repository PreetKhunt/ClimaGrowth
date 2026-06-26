"use client";

import { useState } from "react";
import Script from "next/script";
import { ShoppingCart, TrendingUp, TrendingDown, Store, X, CheckCircle2 } from "lucide-react";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";

const cropPrices = [
  { name: "Wheat", price: "₹2,200/q", trend: "up", change: "+₹50" },
  { name: "Cotton", price: "₹6,800/q", trend: "down", change: "-₹120" },
  { name: "Soybean", price: "₹4,500/q", trend: "up", change: "+₹200" },
];

const products = [
  { id: 1, name: "Premium NPK Fertilizer 19:19:19", price: 1200, unit: "50kg bag", tag: "Best Seller" },
  { id: 2, name: "Organic Neem Pesticide", price: 450, unit: "1L bottle", tag: "Organic" },
  { id: 3, name: "High-Yield Wheat Seeds (HD-2967)", price: 900, unit: "40kg bag", tag: "Certified" },
  { id: 4, name: "Urea (Nitrogen Fertilizer)", price: 266, unit: "45kg bag", tag: "Govt Subsidized" },
  { id: 5, name: "Chlorpyrifos 20% EC Insecticide", price: 650, unit: "1L bottle", tag: "Pest Control" },
  { id: 6, name: "DAP (Di-Ammonium Phosphate)", price: 1350, unit: "50kg bag", tag: "Essential" },
  { id: 7, name: "Bio-fungicide Trichoderma", price: 300, unit: "1kg packet", tag: "Eco-Friendly" },
  { id: 8, name: "Glyphosate 41% SL Herbicide", price: 550, unit: "1L bottle", tag: "Weed Control" },
];

export default function MarketPage() {
  const [cart, setCart] = useState<any[]>([]);
  const [isCartOpen, setIsCartOpen] = useState(false);
  const [paymentSuccess, setPaymentSuccess] = useState(false);

  const addToCart = (product: any) => {
    setCart([...cart, product]);
  };

  const removeFromCart = (index: number) => {
    setCart(cart.filter((_, i) => i !== index));
  };

  const totalAmount = cart.reduce((sum, item) => sum + item.price, 0);

  const handlePayment = () => {
    if (cart.length === 0) return;

    // Simulate payment processing for demo purposes to avoid Razorpay invalid key errors
    setPaymentSuccess(true);
    setCart([]);
    setTimeout(() => {
      setPaymentSuccess(false);
      setIsCartOpen(false);
    }, 3000);
  };

  return (
    <div className="p-8 max-w-6xl">
      <Script src="https://checkout.razorpay.com/v1/checkout.js" strategy="lazyOnload" />

      <div className="mb-8 flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold tracking-tight">Market & Shop</h1>
          <p className="text-muted-foreground mt-1">Live crop prices and agricultural inputs</p>
        </div>
        <Button className="gap-2 rounded-full" onClick={() => setIsCartOpen(true)}>
          <ShoppingCart size={18} /> View Cart ({cart.length})
        </Button>
      </div>

      {isCartOpen && (
        <div className="fixed inset-0 z-50 bg-background/80 backdrop-blur-sm flex items-center justify-center p-4">
          <Card className="bg-card border-white/10 w-full max-w-lg shadow-2xl animate-in fade-in zoom-in-95">
            <div className="p-6 border-b border-white/5 flex justify-between items-center">
              <h2 className="text-xl font-bold flex items-center gap-2">
                <ShoppingCart size={20} className="text-primary" /> Your Cart
              </h2>
              <Button variant="ghost" size="sm" onClick={() => setIsCartOpen(false)}>
                <X size={18} />
              </Button>
            </div>
            
            <div className="p-6 min-h-[200px] max-h-[400px] overflow-y-auto space-y-4">
              {paymentSuccess ? (
                <div className="flex flex-col items-center justify-center text-center py-8 text-primary">
                  <CheckCircle2 size={48} className="mb-4" />
                  <h3 className="text-xl font-bold">Payment Successful!</h3>
                  <p className="text-sm text-muted-foreground mt-2">Your order has been placed and is being processed.</p>
                </div>
              ) : cart.length === 0 ? (
                <div className="flex flex-col items-center justify-center text-center py-12 text-muted-foreground">
                  <ShoppingCart size={48} className="mb-4 opacity-20" />
                  <p>Your cart is empty.</p>
                </div>
              ) : (
                cart.map((item, index) => (
                  <div key={index} className="flex justify-between items-center bg-white/5 p-3 rounded-lg">
                    <div>
                      <div className="font-medium text-sm">{item.name}</div>
                      <div className="text-xs text-muted-foreground">{item.unit}</div>
                    </div>
                    <div className="flex items-center gap-4">
                      <span className="font-bold">₹{item.price}</span>
                      <Button variant="ghost" size="sm" onClick={() => removeFromCart(index)} className="text-rose-400 hover:text-rose-300">
                        <X size={14} />
                      </Button>
                    </div>
                  </div>
                ))
              )}
            </div>
            
            {!paymentSuccess && cart.length > 0 && (
              <div className="p-6 border-t border-white/5 bg-black/20">
                <div className="flex justify-between items-center mb-4">
                  <span className="text-muted-foreground font-medium">Total Amount</span>
                  <span className="text-2xl font-bold text-primary">₹{totalAmount.toLocaleString()}</span>
                </div>
                <Button className="w-full text-lg h-12" onClick={handlePayment}>
                  Pay via Razorpay
                </Button>
              </div>
            )}
          </Card>
        </div>
      )}

      <h2 className="text-xl font-semibold mb-4">Live Crop Mandi Prices</h2>
      <div className="grid gap-4 md:grid-cols-3 mb-10">
        {cropPrices.map((crop, i) => (
          <Card key={i} className="bg-card/40 border-white/5 p-5 flex justify-between items-center">
            <div>
              <div className="text-sm font-medium text-muted-foreground">{crop.name}</div>
              <div className="text-2xl font-bold mt-1">{crop.price}</div>
            </div>
            <div className={`flex items-center gap-1 text-sm font-medium px-2 py-1 rounded-md ${crop.trend === 'up' ? 'text-primary bg-primary/10' : 'text-rose-400 bg-rose-400/10'}`}>
              {crop.trend === 'up' ? <TrendingUp size={16} /> : <TrendingDown size={16} />}
              {crop.change}
            </div>
          </Card>
        ))}
      </div>

      <h2 className="text-xl font-semibold mb-4">Agri-Commerce Store</h2>
      <div className="grid gap-6 md:grid-cols-3">
        {products.map(product => (
          <Card key={product.id} className="bg-card/40 border-white/5 p-6 flex flex-col justify-between">
            <div>
              <div className="w-full h-32 bg-white/5 rounded-lg mb-4 flex items-center justify-center text-white/20">
                <Store size={40} />
              </div>
              <div className="inline-block px-2 py-1 bg-white/10 rounded text-xs font-medium text-white/70 mb-2">{product.tag}</div>
              <h3 className="font-semibold text-lg leading-tight mb-2">{product.name}</h3>
              <p className="text-muted-foreground text-sm">{product.unit}</p>
            </div>
            <div className="mt-6 flex items-center justify-between">
              <span className="text-xl font-bold text-primary">₹{product.price}</span>
              <Button size="sm" onClick={() => addToCart(product)}>Add to Cart</Button>
            </div>
          </Card>
        ))}
      </div>
    </div>
  );
}

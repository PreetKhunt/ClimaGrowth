import { NextResponse } from 'next/server';
import Razorpay from 'razorpay';
import crypto from 'crypto';

export async function POST(req: Request) {
  try {
    const { amount, currency = 'INR' } = await req.json();

    const instance = new Razorpay({
      key_id: process.env.NEXT_PUBLIC_RAZORPAY_KEY_ID as string,
      key_secret: process.env.RAZORPAY_KEY_SECRET as string,
    });

    const options = {
      amount: amount * 100, // Amount in paise
      currency,
      receipt: `receipt_${crypto.randomBytes(4).toString('hex')}`,
    };

    const order = await instance.orders.create(options);

    return NextResponse.json(order, { status: 200 });
  } catch (error: any) {
    console.error('Error creating Razorpay order:', error);
    return NextResponse.json(
      { error: 'Failed to create Razorpay order' },
      { status: 500 }
    );
  }
}

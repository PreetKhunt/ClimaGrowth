import { NextRequest, NextResponse } from "next/server";
import { GoogleGenerativeAI } from "@google/generative-ai";

const apiKey = process.env.GEMINI_API_KEY;
const genAI = apiKey ? new GoogleGenerativeAI(apiKey) : null;

export async function POST(req: NextRequest) {
  if (!genAI) {
    return NextResponse.json(
      { error: "GEMINI_API_KEY is not configured in .env.local" },
      { status: 500 }
    );
  }

  try {
    const { messages } = await req.json();

    const model = genAI.getGenerativeModel({ 
      model: "gemini-1.5-flash",
      systemInstruction: `You are Gemini, an expert agricultural AI assistant for ClimaGrowth. 
You provide precise, scientific advice on crops, fertilizers, minerals, and farm management. 
Keep answers concise, actionable, and formatted nicely. Assume the user is a farmer looking to maximize yield.`
    });

    // Format previous messages for Gemini context
    // Gemini expects an array of { role: 'user' | 'model', parts: [{ text: string }] }
    // The first message must be from the user. Our UI starts with an assistant greeting.
    let rawHistory = messages.slice(0, -1);
    if (rawHistory.length > 0 && rawHistory[0].role === "assistant") {
      rawHistory = rawHistory.slice(1); // Remove the initial hardcoded greeting
    }

    const history = rawHistory.map((msg: any) => ({
      role: msg.role === "assistant" ? "model" : "user",
      parts: [{ text: msg.content }],
    }));

    const currentMessage = messages[messages.length - 1].content;

    const chat = model.startChat({
      history
    });

    const result = await chat.sendMessage(currentMessage);
    const text = result.response.text();

    return NextResponse.json({ text });
  } catch (error: any) {
    console.error("Gemini API Error:", error);
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}

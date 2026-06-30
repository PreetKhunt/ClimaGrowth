import { NextRequest, NextResponse } from "next/server";
import { z } from "zod";
import { generateChatResponse, ChatMessage } from "@/lib/ai/gemini";

// Define strict validation schema for the request body
const chatRequestSchema = z.object({
  messages: z.array(
    z.object({
      role: z.enum(["user", "assistant"]),
      content: z.string().min(1, "Message content cannot be empty"),
    })
  ).min(1, "At least one message is required"),
});

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();
    
    // Validate request body
    const result = chatRequestSchema.safeParse(body);
    
    if (!result.success) {
      return NextResponse.json(
        { error: "Invalid request payload", details: result.error.errors },
        { status: 400 }
      );
    }

    const { messages } = result.data;
    
    // Generate AI response via our robust Gemini service
    const text = await generateChatResponse(messages as ChatMessage[]);

    // We return { text } to maintain 100% frontend UI compatibility
    return NextResponse.json({ text });
    
  } catch (error: unknown) {
    console.error("[Chat API Route Error]", error);
    
    // Check if the error is a missing API key explicitly handled in gemini.ts
    const errMsg = (error as Error)?.message || String(error);
    if (errMsg.includes("GEMINI_API_KEY")) {
      return NextResponse.json({ error: errMsg }, { status: 500 });
    }
    
    return NextResponse.json(
      { error: "Internal server error while processing chat." },
      { status: 500 }
    );
  }
}

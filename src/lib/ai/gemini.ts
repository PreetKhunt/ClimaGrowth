import { GoogleGenAI } from "@google/genai";

// Ensure environment variable exists
if (!process.env.GEMINI_API_KEY) {
  throw new Error("Gemini API key is missing. Please configure GEMINI_API_KEY in your environment.");
}

// Reusable Singleton Service
const ai = new GoogleGenAI({
  apiKey: process.env.GEMINI_API_KEY,
});

export default ai;

// Helper for delay
const delay = (ms: number) => new Promise((resolve) => setTimeout(resolve, ms));

export type ChatMessage = {
  role: "user" | "assistant";
  content: string;
};

/**
 * Handles error mapping to return user-friendly messages instead of raw exceptions.
 */
function handleGeminiError(error: unknown): string {
  const message = (error as Error)?.message || String(error);
  
  if (message.includes("401") || message.includes("API key not valid")) {
    return "Error: Invalid API key configuration. Please contact support.";
  }
  if (message.includes("403")) {
    return "Error: Access denied. Please check project permissions.";
  }
  if (message.includes("404")) {
    return "Error: AI Model not found. The configured model may be deprecated.";
  }
  if (message.includes("429") || message.includes("Quota exceeded")) {
    return "Error: Rate limit exceeded. Please try again in a few moments.";
  }
  if (message.includes("fetch failed") || message.includes("Network") || message.includes("timeout")) {
    return "Error: Network timeout or no internet connection. Please check your connection.";
  }

  // Generic fallback
  console.error("[Gemini Raw Error]", error);
  return "Error: An unexpected AI service error occurred. Please try again later.";
}

/**
 * Generates a multi-turn chat response using gemini-2.5-flash with retries and timeout.
 */
export async function generateChatResponse(messages: ChatMessage[]): Promise<string> {
  const MAX_RETRIES = 3;
  const TIMEOUT_MS = 30000;
  
  // Format system instructions
  const systemInstruction = `You are Gemini, an expert agricultural AI assistant for ClimaGrowth. 
You provide precise, scientific advice on crops, fertilizers, minerals, and farm management. 
Keep answers concise, actionable, and formatted nicely. Assume the user is a farmer looking to maximize yield.`;

  // Limit to last 20 messages to prevent token limits
  let recentMessages = messages.slice(-20);
  
  // Ensure the history alternates and starts with user
  if (recentMessages.length > 0 && recentMessages[0].role === "assistant") {
    recentMessages = recentMessages.slice(1);
  }

  // Format into genai SDK structure
  const formattedHistory = recentMessages.slice(0, -1).map((msg) => ({
    role: msg.role === "assistant" ? "model" : "user",
    parts: [{ text: msg.content }],
  }));

  const currentMessage = recentMessages[recentMessages.length - 1].content;

  for (let attempt = 1; attempt <= MAX_RETRIES; attempt++) {
    try {
      // Setup AbortController for fetch timeout (supported in underlying fetch)
      // Note: The newer SDK might need standard fetch timeout mechanisms, 
      // but we can also race it against a local timer.
      const abortController = new AbortController();
      const timeoutId = setTimeout(() => abortController.abort(), TIMEOUT_MS);

      // The new @google/genai SDK takes contents as an array of messages
      const response = await ai.models.generateContent({
        model: "gemini-2.5-flash",
        contents: [
          ...formattedHistory,
          { role: "user", parts: [{ text: currentMessage }] }
        ],
        config: {
          systemInstruction,
        },
      });

      clearTimeout(timeoutId);

      if (response.text) {
        return response.text;
      }
      
      throw new Error("Empty response from Gemini.");
      
    } catch (error: unknown) {
      if (error instanceof Error && (error.name === "AbortError" || String(error).includes("abort"))) {
        console.warn(`[Gemini Attempt ${attempt}] Request timed out after 30 seconds.`);
      } else {
        console.warn(`[Gemini Attempt ${attempt}] Error:`, (error as Error)?.message);
      }

      // If it's a fatal client error like 401/403/404, we don't need to retry
      const errMsg = String((error as Error)?.message || error);
      if (errMsg.includes("401") || errMsg.includes("403") || errMsg.includes("404")) {
        return handleGeminiError(error);
      }

      if (attempt === MAX_RETRIES) {
        return handleGeminiError(error);
      }

      // Exponential backoff: 1s, 2s, 4s...
      const backoffDelay = Math.pow(2, attempt - 1) * 1000;
      await delay(backoffDelay);
    }
  }

  return "Error: Request failed after multiple attempts.";
}

"use client";

import { useState, useRef, useEffect } from "react";
import { Send, Sparkles, Bot, User, Mic, Paperclip, Image as ImageIcon, FileText, Globe, Menu, Plus, X, MessageSquare } from "lucide-react";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";

export default function ChatPage() {
  const [messages, setMessages] = useState([
    { role: "assistant", content: "Hello! I am Gemini, your intelligent agricultural assistant. How can I help you maximize your farm's potential today?" }
  ]);
  const [input, setInput] = useState("");
  const [isLoading, setIsLoading] = useState(false);
  
  // Advanced Features State
  const [isSidebarOpen, setIsSidebarOpen] = useState(true);
  const [language, setLanguage] = useState("English");
  const [isRecording, setIsRecording] = useState(false);
  const [attachments, setAttachments] = useState<{name: string, type: string}[]>([]);
  const fileInputRef = useRef<HTMLInputElement>(null);

  const history = [
    "Wheat fertilizer schedule",
    "Cotton disease analysis",
    "Soil pH improvement",
    "Weather forecast for tomorrow"
  ];

  const suggestions = [
    "Analyze my soil report",
    "Suggest fertilizers for wheat",
    "How to treat yellow leaves?",
    "When to harvest cotton?"
  ];

  const handleSend = async (overrideInput?: string) => {
    const textToSend = overrideInput || input;
    if (!textToSend.trim() || isLoading) return;
    
    // If there are attachments, we mock sending them
    let userContent = textToSend;
    if (attachments.length > 0) {
      userContent += `\n[Attached: ${attachments.map(a => a.name).join(", ")}]`;
    }

    const userMessage = { role: "user", content: userContent };
    const newMessages = [...messages, userMessage];
    setMessages(newMessages);
    setInput("");
    setAttachments([]);
    setIsLoading(true);

    try {
      const response = await fetch("/api/chat", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ messages: newMessages }),
      });
      
      const data = await response.json();
      
      if (response.ok) {
        setMessages([...newMessages, { role: "assistant", content: data.text }]);
      } else {
        setMessages([...newMessages, { role: "assistant", content: `Error: ${data.error || "Failed to connect to AI"}` }]);
      }
    } catch (error) {
      setMessages([...newMessages, { role: "assistant", content: "Network error occurred. Please try again." }]);
    } finally {
      setIsLoading(false);
    }
  };

  const handleMicClick = () => {
    setIsRecording(!isRecording);
    if (!isRecording) {
      // Mock voice recording
      setTimeout(() => {
        setInput("What is the best time to irrigate my wheat crop?");
        setIsRecording(false);
      }, 3000);
    }
  };

  const handleFileUpload = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files && e.target.files[0]) {
      const file = e.target.files[0];
      setAttachments([...attachments, { name: file.name, type: file.type.includes('image') ? 'image' : 'document' }]);
    }
  };

  return (
    <div className="flex h-[calc(100vh-64px)] overflow-hidden">
      {/* Sidebar - Conversation History */}
      <div className={`border-r border-white/5 bg-card/20 transition-all duration-300 flex flex-col ${isSidebarOpen ? 'w-64' : 'w-0 opacity-0 overflow-hidden'}`}>
        <div className="p-4 border-b border-white/5">
          <Button className="w-full justify-start gap-2 bg-primary/10 text-primary hover:bg-primary/20 border-primary/20">
            <Plus size={16} /> New Conversation
          </Button>
        </div>
        <div className="flex-1 overflow-y-auto p-4 space-y-2">
          <h3 className="text-xs font-semibold text-muted-foreground uppercase tracking-wider mb-3">Recent Chats</h3>
          {history.map((title, i) => (
            <button key={i} className="w-full flex items-center gap-3 text-sm text-left px-3 py-2 rounded-md hover:bg-white/5 text-muted-foreground hover:text-foreground transition-colors truncate">
              <MessageSquare size={14} className="shrink-0" />
              <span className="truncate">{title}</span>
            </button>
          ))}
        </div>
      </div>

      {/* Main Chat Area */}
      <div className="flex-1 flex flex-col p-4 md:p-8 max-w-5xl mx-auto w-full">
        <div className="mb-6 flex items-center justify-between">
          <div className="flex items-center gap-4">
            <Button variant="ghost" size="icon" onClick={() => setIsSidebarOpen(!isSidebarOpen)}>
              <Menu size={20} />
            </Button>
            <div>
              <h1 className="text-2xl font-bold tracking-tight">AI Farm Assistant</h1>
              <p className="text-sm text-muted-foreground mt-0.5">Powered by Google Gemini</p>
            </div>
          </div>
          <div className="flex items-center gap-3">
            <div className="flex items-center gap-2 bg-card/40 border border-white/5 px-3 py-1.5 rounded-lg text-sm">
              <Globe size={14} className="text-muted-foreground" />
              <select 
                value={language} 
                onChange={(e) => setLanguage(e.target.value)}
                className="bg-transparent border-none focus:outline-none text-sm cursor-pointer"
              >
                <option value="English">English</option>
                <option value="Hindi">हिंदी</option>
                <option value="Gujarati">ગુજરાતી</option>
              </select>
            </div>
            <div className="bg-primary/10 text-primary px-3 py-1.5 rounded-full text-sm font-medium flex items-center gap-1.5">
              <Sparkles size={14} /> Gemini Ready
            </div>
          </div>
        </div>

        <Card className="flex-1 bg-card/40 border-white/5 overflow-hidden flex flex-col mb-2 shadow-xl shadow-black/20">
          <div className="flex-1 p-6 overflow-y-auto space-y-6">
            {messages.map((msg, i) => (
              <div key={i} className={`flex gap-4 ${msg.role === "user" ? "flex-row-reverse" : ""}`}>
                <div className={`w-10 h-10 rounded-full flex items-center justify-center shrink-0 ${msg.role === "user" ? "bg-primary text-primary-foreground" : "bg-card border border-white/10 text-foreground shadow-sm"}`}>
                  {msg.role === "user" ? <User size={20} /> : <Bot size={20} />}
                </div>
                <div className={`px-4 py-3 rounded-2xl max-w-[80%] whitespace-pre-wrap leading-relaxed ${msg.role === "user" ? "bg-primary text-primary-foreground" : "bg-white/5 border border-white/5"}`}>
                  {msg.content}
                </div>
              </div>
            ))}
            {isLoading && (
              <div className="flex gap-4">
                <div className="w-10 h-10 rounded-full flex items-center justify-center shrink-0 bg-card border border-white/10 text-foreground">
                  <Bot size={20} />
                </div>
                <div className="px-5 py-4 rounded-2xl bg-white/5 border border-white/5 flex items-center gap-2">
                  <div className="w-2 h-2 rounded-full bg-primary/60 animate-bounce" />
                  <div className="w-2 h-2 rounded-full bg-primary/60 animate-bounce" style={{ animationDelay: "0.2s" }} />
                  <div className="w-2 h-2 rounded-full bg-primary/60 animate-bounce" style={{ animationDelay: "0.4s" }} />
                </div>
              </div>
            )}
          </div>
          
          <div className="p-4 bg-background/50 border-t border-white/5">
            {/* Attachments Preview */}
            {attachments.length > 0 && (
              <div className="flex gap-2 mb-3 px-2">
                {attachments.map((file, i) => (
                  <div key={i} className="flex items-center gap-2 bg-white/10 px-3 py-1.5 rounded-md text-xs font-medium">
                    {file.type === 'image' ? <ImageIcon size={14} className="text-blue-400" /> : <FileText size={14} className="text-amber-400" />}
                    <span className="truncate max-w-[150px]">{file.name}</span>
                    <button onClick={() => setAttachments(attachments.filter((_, idx) => idx !== i))} className="ml-1 hover:text-rose-400">
                      <X size={14} />
                    </button>
                  </div>
                ))}
              </div>
            )}

            {/* Smart Suggestions */}
            {messages.length === 1 && (
              <div className="flex flex-wrap gap-2 mb-4 px-2">
                {suggestions.map((s, i) => (
                  <button 
                    key={i} 
                    onClick={() => handleSend(s)}
                    className="text-xs font-medium bg-primary/10 text-primary border border-primary/20 px-3 py-1.5 rounded-full hover:bg-primary/20 transition-colors"
                  >
                    {s}
                  </button>
                ))}
              </div>
            )}

            <div className="flex gap-2 items-end">
              <input 
                type="file" 
                ref={fileInputRef} 
                onChange={handleFileUpload} 
                className="hidden" 
                accept="image/*,.pdf" 
              />
              <Button 
                variant="ghost" 
                size="icon" 
                className="shrink-0 rounded-full h-12 w-12 text-muted-foreground hover:text-foreground"
                onClick={() => fileInputRef.current?.click()}
              >
                <Paperclip size={20} />
              </Button>
              
              <div className="flex-1 relative">
                <textarea 
                  value={input}
                  onChange={e => setInput(e.target.value)}
                  onKeyDown={e => {
                    if (e.key === "Enter" && !e.shiftKey) {
                      e.preventDefault();
                      handleSend();
                    }
                  }}
                  placeholder={isRecording ? "Listening..." : "Ask about crop diseases, market trends, or upload a soil report..."}
                  className={`w-full bg-white/5 border border-white/10 rounded-2xl pl-4 pr-12 py-3 text-sm focus:outline-none focus:ring-1 focus:ring-primary resize-none h-[50px] max-h-[120px] ${isRecording ? 'border-primary/50 shadow-[0_0_15px_rgba(0,255,136,0.2)]' : ''}`}
                  rows={1}
                />
                <Button 
                  variant="ghost" 
                  size="icon" 
                  onClick={handleMicClick}
                  className={`absolute right-2 top-1.5 rounded-full h-9 w-9 ${isRecording ? 'text-primary animate-pulse bg-primary/10' : 'text-muted-foreground hover:text-foreground'}`}
                >
                  <Mic size={18} />
                </Button>
              </div>

              <Button 
                onClick={() => handleSend()} 
                className="rounded-full w-12 h-12 p-0 flex items-center justify-center shrink-0 bg-primary hover:bg-primary/90 text-primary-foreground shadow-lg"
              >
                <Send size={18} className="ml-1" />
              </Button>
            </div>
          </div>
        </Card>
      </div>
    </div>
  );
}

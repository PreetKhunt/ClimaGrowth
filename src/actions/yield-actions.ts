'use server';

import { safeAction } from '@/lib/actions/safe-action';
import { generateChatResponse } from '@/lib/ai/gemini';
import { revalidatePath } from 'next/cache';
import { z } from 'zod';

export const generateYieldPrediction = async (farmId: string) => {
  return safeAction(
    z.string().uuid(),
    farmId,
    async (validatedFarmId, { userId, supabase }) => {
      // 1. Fetch farm details
      const { data: farm, error: farmError } = await supabase
        .from('farms')
        .select('*')
        .eq('id', validatedFarmId)
        .single();
      
      if (farmError) throw new Error("Could not find farm details.");

      // 2. Call Gemini
      const prompt = `You are an expert AI agronomist for ClimaGrowth. I am providing details for a farm.
Based on typical climate, soil, and crop data, predict the yield and risks.

Farm Name: ${farm.name}
Area: ${farm.area_acres} Acres
Crop: ${farm.crop_type}
Soil: ${farm.soil_type}
Irrigation: ${farm.irrigation_type}

Return a strict JSON object with this structure:
{
  "expected_yield_tons": 25.5,
  "estimated_profit": 55000,
  "risk_level": "Low" | "Medium" | "High",
  "recommended_improvements": ["Improvement 1", "Improvement 2"],
  "ai_explanation": "A short summary explaining this prediction based on the provided inputs."
}
No markdown formatting, just pure JSON.`;

      const aiResponseStr = await generateChatResponse([{ role: 'user', content: prompt }]);
      
      let aiResult;
      try {
        const jsonStr = aiResponseStr.replace(/```json\n?|```/g, '').trim();
        aiResult = JSON.parse(jsonStr);
      } catch (e) {
        throw new Error("Failed to parse AI yield prediction results. Please try again.");
      }

      // 3. Save to Supabase
      const insertData = {
        user_id: userId,
        farm_id: farm.id,
        expected_yield_tons: aiResult.expected_yield_tons,
        estimated_profit: aiResult.estimated_profit,
        risk_level: aiResult.risk_level,
        recommended_improvements: aiResult.recommended_improvements || [],
        ai_explanation: aiResult.ai_explanation || '',
        weather_snapshot: { temperature: 32, humidity: 45 }, // Mock weather snapshot for now
        soil_data_snapshot: { ph: 6.5, moisture: 60 }
      };

      const { data: prediction, error } = await supabase
        .from('yield_predictions')
        .insert(insertData)
        .select()
        .single();

      if (error) throw new Error(error.message);

      revalidatePath('/dashboard/yield');
      return prediction;
    },
    {
      auditLog: {
        action: 'UPDATE_FARM', // Reusing an existing enum or generic string
        entityType: 'yield_prediction',
        getEntityId: (p) => p.id
      }
    }
  );
};

export const fetchLatestYieldPrediction = async (farmId?: string) => {
  return safeAction(
    z.string().uuid().optional(),
    farmId,
    async (fid, { userId, supabase }) => {
      let query = supabase
        .from('yield_predictions')
        .select('*')
        .eq('user_id', userId)
        .order('created_at', { ascending: false })
        .limit(1);
        
      if (fid) {
        query = query.eq('farm_id', fid);
      }

      const { data, error } = await query.single();
      
      if (error && error.code !== 'PGRST116') throw new Error(error.message); // PGRST116 is no rows returned
      return data || null;
    }
  );
};

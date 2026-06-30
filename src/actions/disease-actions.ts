'use server';

import { safeAction } from '@/lib/actions/safe-action';
import { diseaseScanSchema } from '@/lib/validations/farm';
import { generateChatResponse } from '@/lib/ai/gemini';
import { revalidatePath } from 'next/cache';

export const analyzeDisease = async (imageUrl: string, farmId?: string) => {
  return safeAction(
    diseaseScanSchema.pick({ image_url: true, farm_id: true }),
    { image_url: imageUrl, farm_id: farmId },
    async (validatedData, { userId, supabase }) => {
      // 1. Call Gemini for Analysis
      const prompt = `You are an expert plant pathologist AI. I will provide an image URL of a crop leaf.
Analyze it and return a strict JSON object with this exact structure:
{
  "disease_name": "Name of the disease (or 'Healthy' if no disease)",
  "confidence_score": 0.95,
  "symptoms": ["symptom 1", "symptom 2"],
  "cause": "Main cause of the disease",
  "treatment": "Recommended treatment steps",
  "recommended_fertilizers": ["Fertilizer A"],
  "recommended_pesticides": ["Pesticide B"],
  "prevention_tips": ["Tip 1", "Tip 2"]
}
If the image is not a plant, return disease_name as 'Invalid Image' and confidence_score as 0.

Image URL: ${validatedData.image_url}`;

      const aiResponseStr = await generateChatResponse([{ role: 'user', content: prompt }]);
      
      let aiResult;
      try {
        // Strip out markdown code blocks if Gemini returns them
        const jsonStr = aiResponseStr.replace(/```json\n?|```/g, '').trim();
        aiResult = JSON.parse(jsonStr);
      } catch (e) {
        throw new Error("Failed to parse AI analysis results. Please try again.");
      }

      if (aiResult.disease_name === 'Invalid Image') {
        throw new Error("The uploaded image does not appear to be a valid plant leaf.");
      }

      // 2. Save to Supabase
      const insertData = {
        user_id: userId,
        farm_id: validatedData.farm_id || null,
        image_url: validatedData.image_url,
        disease_name: aiResult.disease_name,
        confidence_score: aiResult.confidence_score,
        symptoms: aiResult.symptoms || [],
        cause: aiResult.cause || '',
        treatment: aiResult.treatment || '',
        recommended_fertilizers: aiResult.recommended_fertilizers || [],
        recommended_pesticides: aiResult.recommended_pesticides || [],
        prevention_tips: aiResult.prevention_tips || []
      };

      const { data: scan, error } = await supabase
        .from('disease_scans')
        .insert(insertData)
        .select()
        .single();

      if (error) throw new Error(error.message);

      revalidatePath('/dashboard/disease');
      return scan;
    },
    {
      auditLog: {
        action: 'CREATE_FARM', // Reusing an enum, ideally 'CREATE_DISEASE_SCAN' but need to update audit.ts
        entityType: 'disease_scan',
        getEntityId: (scan) => scan.id
      }
    }
  );
};

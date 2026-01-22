import OpenAI from 'openai';
import fs from 'fs';
import { DailyHealthMeasurement } from '../types/dailyHealthMeasurement';
import config from '../config/env';

export class AiRecognitionService {
    private static client: OpenAI;

    private static getClient(): OpenAI {
        if (!this.client) {
            this.client = new OpenAI({
                apiKey: process.env.ZHIPU_API_KEY || process.env.OPENAI_API_KEY,
                baseURL: process.env.AI_BASE_URL || 'https://open.bigmodel.cn/api/paas/v4/',
            });
        }
        return this.client;
    }

    /**
     * Recognize health data from an uploaded image file
     * @param filePath Path to the uploaded file
     * @returns Partial DailyHealthMeasurement data
     */
    static async recognizeHealthData(filePath: string): Promise<Partial<DailyHealthMeasurement>> {
        try {
            const client = this.getClient();
            const imageBuffer = fs.readFileSync(filePath);
            const base64Image = imageBuffer.toString('base64');
            const dataUrl = `data:image/jpeg;base64,${base64Image}`; // Assuming jpeg/png, standard base64 generic header often works or specific extension check

            const prompt = `
你是一个专业的健康数据录入助手。请识别这张图片（可能是体检单、血压计读数、血糖仪读数或体重秤读数）中的健康数据。
请提取以下字段，并以纯 JSON 格式返回，不要包含 markdown 格式标记 (如 \`\`\`json)：

- sbp: 收缩压 (由高压/收缩压读数) - number
- dbp: 舒张压 (由低压/舒张压读数) - number
- fpg: 空腹血糖 (FPG) - number
- ppg_2h: 餐后2小时血糖 (PPG 2h) - number
- weight: 体重 (kg) - number

要求：
1. 只返回识别到的字段，未识别到的字段不要包含在 JSON 中。
2. 忽略截图中的步数 (steps)、心率 (heart rate) 等其他数据。
3. 如果图片中没有上述任何健康数据，请返回空 JSON {}。
4. 确保返回的是合法的 JSON 字符串。
      `;

            const response = await client.chat.completions.create({
                model: 'glm-4v-flash', // Using the free/cost-effective vision model as planned
                messages: [
                    {
                        role: 'user',
                        content: [
                            { type: 'text', text: prompt },
                            {
                                type: 'image_url',
                                image_url: {
                                    url: dataUrl
                                }
                            }
                        ]
                    }
                ],
                temperature: 0.1, // Low temperature for more deterministic output
            });

            const content = response.choices[0]?.message?.content?.trim();

            if (!content) {
                return {};
            }

            // Cleanup potential markdown formatting if the model disobeys
            const jsonString = content.replace(/^```json\s*/, '').replace(/\s*```$/, '');

            try {
                const parsedData = JSON.parse(jsonString);

                const filteredData: Partial<DailyHealthMeasurement> = {};

                if (typeof parsedData.sbp === 'number') filteredData.sbp = parsedData.sbp;
                if (typeof parsedData.dbp === 'number') filteredData.dbp = parsedData.dbp;
                if (typeof parsedData.fpg === 'number') filteredData.fpg = parsedData.fpg;
                if (typeof parsedData.ppg_2h === 'number') filteredData.ppg_2h = parsedData.ppg_2h;
                if (typeof parsedData.weight === 'number') filteredData.weight = parsedData.weight;

                // Handle string format numbers too just in case
                if (typeof parsedData.sbp === 'string' && !isNaN(parseFloat(parsedData.sbp))) filteredData.sbp = parseFloat(parsedData.sbp);
                if (typeof parsedData.dbp === 'string' && !isNaN(parseFloat(parsedData.dbp))) filteredData.dbp = parseFloat(parsedData.dbp);
                if (typeof parsedData.fpg === 'string' && !isNaN(parseFloat(parsedData.fpg))) filteredData.fpg = parseFloat(parsedData.fpg);
                if (typeof parsedData.ppg_2h === 'string' && !isNaN(parseFloat(parsedData.ppg_2h))) filteredData.ppg_2h = parseFloat(parsedData.ppg_2h);
                if (typeof parsedData.weight === 'string' && !isNaN(parseFloat(parsedData.weight))) filteredData.weight = parseFloat(parsedData.weight);

                return filteredData;
            } catch (e) {
                console.error('Failed to parse AI response as JSON:', content);
                return {};
            }

        } catch (error) {
            console.error('AI Recognition Service Error:', error);
            throw new Error('智能识别服务暂时不可用，请稍后重试或手动输入');
        }
    }
}

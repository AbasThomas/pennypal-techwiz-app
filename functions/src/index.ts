/** Secure server boundary: set GROQ_API_KEY or HF_API_KEY with Firebase secrets. */
import {onCall, HttpsError} from 'firebase-functions/v2/https';
import {defineSecret} from 'firebase-functions/params';

const groqKey = defineSecret('GROQ_API_KEY');
const system = 'You are PennyPal, an educational student-finance guide. Give concise budgeting, saving, spending and habit guidance only. Never provide investment advice, transact, connect banks, or claim to be a financial adviser.';

export const askPennyPal = onCall({secrets: [groqKey]}, async (request) => {
  if (!request.auth) throw new HttpsError('unauthenticated', 'Please sign in.');
  const question = String(request.data?.question ?? '').trim();
  if (!question || question.length > 1000) throw new HttpsError('invalid-argument', 'Enter a question up to 1,000 characters.');
  const response = await fetch('https://api.groq.com/openai/v1/chat/completions', {
    method: 'POST', headers: {'Authorization': `Bearer ${groqKey.value()}`, 'Content-Type': 'application/json'},
    body: JSON.stringify({model: 'llama-3.1-8b-instant', messages: [{role: 'system', content: system}, {role: 'user', content: question}], temperature: .35, max_tokens: 350}),
  });
  if (!response.ok) throw new HttpsError('internal', 'The assistant is unavailable. Please try again.');
  const json = await response.json() as {choices?: Array<{message?: {content?: string}}>};
  return {answer: json.choices?.[0]?.message?.content ?? 'I could not prepare a response. Please try again.'};
});

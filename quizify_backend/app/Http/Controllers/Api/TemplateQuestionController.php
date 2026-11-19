<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\TemplateQuestion;
use Illuminate\Http\Request;

class TemplateQuestionController extends Controller
{
    public function showByTemplate($quizTemplateId)
    {
        $questions = TemplateQuestion::where('quiz_template_id', $quizTemplateId)->get();

        return response()->json([
            'success' => true,
            'data' => $questions
        ]);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'quiz_template_id' => 'required|integer|exists:quiz_templates,id',
            'question' => 'required|string',
            'option_a' => 'required|string',
            'option_b' => 'required|string',
            'option_c' => 'required|string',
            'option_d' => 'required|string',
            'correct_answer' => 'required|in:A,B,C,D',
        ]);

        $question = TemplateQuestion::create($validated);

        return response()->json([
            'success' => true,
            'data' => $question
        ], 201);
    }

    public function update(Request $request, $id)
    {
        $question = TemplateQuestion::findOrFail($id);

        $validated = $request->validate([
            'quiz_template_id' => 'required|integer|exists:quiz_templates,id',
            'question' => 'required|string',
            'option_a' => 'required|string',
            'option_b' => 'required|string',
            'option_c' => 'required|string',
            'option_d' => 'required|string',
            'correct_answer' => 'required|in:A,B,C,D',
        ]);

        $question->update($validated);

        return response()->json([
            'success' => true,
            'data' => $question
        ]);
    }

    public function destroy($id)
    {
        $question = TemplateQuestion::findOrFail($id);
        $question->delete();

        return response()->json([
            'success' => true,
            'message' => 'Soal template berhasil dihapus'
        ]);
    }
}

<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\QuizResult;
use Illuminate\Http\Request;

class QuizResultController extends Controller
{
    public function store(Request $request)
    {
        $validated = $request->validate([
            'quiz_template_id' => 'required|integer|exists:quiz_templates,id',
            'score' => 'required|integer',
            'correct_count' => 'required|integer',
            'total_questions' => 'required|integer',
        ]);

        $quizResult = QuizResult::create([
            'user_id' => $request->user()->id,
            'quiz_template_id' => $validated['quiz_template_id'],
            'score' => $validated['score'],
            'correct_count' => $validated['correct_count'],
            'total_questions' => $validated['total_questions'],
        ]);

        return response()->json([
            'success' => true,
            'data' => $quizResult,
        ], 201);
    }
}

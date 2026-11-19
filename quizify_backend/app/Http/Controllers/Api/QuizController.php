<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Quiz;
use App\Models\QuizTemplate;
use Illuminate\Http\Request;

class QuizController extends Controller
{
    public function index(Request $request)
    {
        $query = Quiz::query();

        if ($request->has('category_id')) {
            $query->where('category_id', $request->category_id);
        }

        return response()->json([
            'success' => true,
            'data' => $query->get(),
        ]);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'quiz_template_id' => 'required|exists:quiz_templates,id',
            'title' => 'nullable|string|max:255',
            'description' => 'nullable|string',
            'is_recommended' => 'boolean',
            'recommendation_label' => 'nullable|string|max:255',
            'recommendation_order' => 'nullable|integer',
            'is_active' => 'boolean',
        ]);

        $template = QuizTemplate::findOrFail($validated['quiz_template_id']);

        $quiz = Quiz::create([
            'category_id' => $template->category_id,
            'quiz_template_id' => $template->id,
            'title' => $validated['title'] ?? $template->title,
            'description' => $validated['description'] ?? $template->description,
            'is_recommended' => $validated['is_recommended'] ?? false,
            'recommendation_label' => $validated['recommendation_label'] ?? null,
            'recommendation_order' => $validated['recommendation_order'] ?? 0,
            'is_active' => $validated['is_active'] ?? true,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Quiz berhasil ditambahkan.',
            'data' => $quiz,
        ], 201);
    }

    public function show($id)
    {
        $quiz = Quiz::findOrFail($id);

        return response()->json([
            'success' => true,
            'data' => $quiz,
        ]);
    }

    public function update(Request $request, $id)
    {
        $quiz = Quiz::findOrFail($id);

        $validated = $request->validate([
            'title' => 'nullable|string|max:255',
            'description' => 'nullable|string',
            'is_recommended' => 'boolean',
            'recommendation_label' => 'nullable|string|max:255',
            'recommendation_order' => 'nullable|integer',
            'is_active' => 'boolean',
        ]);

        $quiz->update($validated);

        return response()->json([
            'success' => true,
            'message' => 'Quiz berhasil diperbarui.',
            'data' => $quiz,
        ]);
    }

    public function destroy($id)
    {
        $quiz = Quiz::findOrFail($id);
        $quiz->delete();

        return response()->json([
            'success' => true,
            'message' => 'Quiz berhasil dihapus.',
        ]);
    }

    public function play($id)
    {
        $quiz = Quiz::findOrFail($id);

        $questions = \DB::table('template_questions')
            ->where('quiz_template_id', $quiz->quiz_template_id)
            ->get();

        return response()->json([
            'success' => true,
            'data' => [
                'quiz' => $quiz,
                'questions' => $questions,
            ],
        ]);
    }
}
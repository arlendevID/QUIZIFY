<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\QuizTemplate;
use Illuminate\Http\Request;

class QuizTemplateController extends Controller
{
    public function index(Request $request)
    {
        $query = QuizTemplate::withCount('templateQuestions');

        if ($request->has('category_id')) {
            $query->where('category_id', $request->category_id);
        }

        return response()->json([
            'success' => true,
            'data' => $query->get()
        ]);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'category_id' => 'required|integer',
            'title' => 'required|string',
            'slug' => 'required|string|unique:quiz_templates,slug',
            'description' => 'nullable|string',
            'difficulty' => 'nullable|string',
            'duration_minutes' => 'nullable|integer',
        ]);

        $quizTemplate = QuizTemplate::create($validated)
            ->loadCount('templateQuestions');

        return response()->json([
            'success' => true,
            'data' => $quizTemplate
        ], 201);
    }

    public function update(Request $request, $id)
    {
        $quizTemplate = QuizTemplate::findOrFail($id);

        $validated = $request->validate([
            'category_id' => 'required|integer',
            'title' => 'required|string',
            'slug' => 'required|string|unique:quiz_templates,slug,' . $quizTemplate->id,
            'description' => 'nullable|string',
            'difficulty' => 'nullable|string',
            'duration_minutes' => 'nullable|integer',
        ]);

        $quizTemplate->update($validated);
        $quizTemplate->loadCount('templateQuestions');

        return response()->json([
            'success' => true,
            'data' => $quizTemplate
        ]);
    }

    public function destroy($id)
    {
        $quizTemplate = QuizTemplate::findOrFail($id);
        $quizTemplate->delete();

        return response()->json([
            'success' => true,
            'message' => 'Quiz template berhasil dihapus'
        ]);
    }
}

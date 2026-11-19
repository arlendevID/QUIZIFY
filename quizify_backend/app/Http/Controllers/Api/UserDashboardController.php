<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\QuizResult;
use App\Models\User;
use Illuminate\Http\Request;

class UserDashboardController extends Controller
{
    public function show(Request $request)
    {
        $user = $request->user();

        $totalQuizCompleted = QuizResult::where('user_id', $user->id)->count();
        $totalXp = (int) QuizResult::where('user_id', $user->id)->sum('score');
        $level = intdiv($totalXp, 100) + 1;

        $rankings = User::query()
            ->leftJoin('quiz_results', 'users.id', '=', 'quiz_results.user_id')
            ->select('users.id')
            ->selectRaw('COALESCE(SUM(quiz_results.score), 0) as total_xp')
            ->groupBy('users.id')
            ->orderByDesc('total_xp')
            ->orderBy('users.id')
            ->get();

        $rankIndex = $rankings->search(
            fn ($ranking) => (int) $ranking->id === (int) $user->id
        );

        return response()->json([
            'total_xp' => $totalXp,
            'level' => $level,
            'total_quiz_completed' => $totalQuizCompleted,
            'rank' => $rankIndex === false ? null : $rankIndex + 1,
        ]);
    }
}

<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;

class LeaderboardController extends Controller
{
    public function index()
    {
        $leaderboard = User::query()
            ->join('quiz_results', 'users.id', '=', 'quiz_results.user_id')
            ->select('users.id as user_id', 'users.name')
            ->selectRaw('SUM(quiz_results.score) as total_xp')
            ->groupBy('users.id', 'users.name')
            ->orderByDesc('total_xp')
            ->orderBy('users.id')
            ->get()
            ->values()
            ->map(function ($user, $index) {
                $totalXp = (int) $user->total_xp;

                return [
                    'user_id' => (int) $user->user_id,
                    'name' => $user->name,
                    'total_xp' => $totalXp,
                    'level' => intdiv($totalXp, 100) + 1,
                    'rank' => $index + 1,
                ];
            });

        return response()->json($leaderboard);
    }
}

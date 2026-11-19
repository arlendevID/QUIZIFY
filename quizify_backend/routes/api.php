<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\CategoryController;
use App\Http\Controllers\Api\QuizTemplateController;
use App\Http\Controllers\Api\TemplateQuestionController;
use App\Http\Controllers\Api\QuizController;
use App\Http\Controllers\Api\QuizResultController;
use App\Http\Controllers\Api\UserDashboardController;
use App\Http\Controllers\Api\LeaderboardController;

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);
Route::post('/logout', [AuthController::class, 'logout'])->middleware('auth:sanctum');

Route::get('/categories', [CategoryController::class, 'index']);

Route::get('/quiz-templates', [QuizTemplateController::class, 'index']);

Route::get('/template-questions/{quizTemplateId}', [TemplateQuestionController::class, 'showByTemplate']);
Route::get('/leaderboard', [LeaderboardController::class, 'index']);

Route::middleware('auth:sanctum')->post('/quiz-results', [QuizResultController::class, 'store']);
Route::middleware('auth:sanctum')->get('/user-dashboard', [UserDashboardController::class, 'show']);

Route::middleware(['auth:sanctum', 'admin'])->group(function () {
    Route::post('/quiz-templates', [QuizTemplateController::class, 'store']);
    Route::put('/quiz-templates/{id}', [QuizTemplateController::class, 'update']);
    Route::delete('/quiz-templates/{id}', [QuizTemplateController::class, 'destroy']);

    Route::post('/template-questions', [TemplateQuestionController::class, 'store']);
    Route::put('/template-questions/{id}', [TemplateQuestionController::class, 'update']);
    Route::delete('/template-questions/{id}', [TemplateQuestionController::class, 'destroy']);
});

Route::get('/quizzes', [QuizController::class, 'index']);
Route::post('/quizzes', [QuizController::class, 'store']);
Route::get('/quizzes/{id}', [QuizController::class, 'show']);
Route::put('/quizzes/{id}', [QuizController::class, 'update']);
Route::delete('/quizzes/{id}', [QuizController::class, 'destroy']);
Route::get('/quizzes/{id}/play', [QuizController::class, 'play']);

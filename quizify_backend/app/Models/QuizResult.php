<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class QuizResult extends Model
{
    protected $fillable = [
        'user_id',
        'quiz_template_id',
        'score',
        'correct_count',
        'total_questions',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function quizTemplate()
    {
        return $this->belongsTo(QuizTemplate::class);
    }
}

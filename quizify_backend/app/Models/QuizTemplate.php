<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class QuizTemplate extends Model
{
    protected $fillable = [
        'category_id',
        'title',
        'slug',
        'description',
        'difficulty',
        'duration_minutes',
    ];

    public function templateQuestions()
    {
        return $this->hasMany(TemplateQuestion::class);
    }
}

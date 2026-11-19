<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class TemplateQuestion extends Model
{
    protected $fillable = [
        'quiz_template_id',
        'question',
        'option_a',
        'option_b',
        'option_c',
        'option_d',
        'correct_answer',
    ];
}

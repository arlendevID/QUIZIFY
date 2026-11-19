<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Quiz extends Model
{
    protected $fillable = [
        'category_id',
        'quiz_template_id',
        'title',
        'description',
        'is_recommended',
        'recommendation_label',
        'recommendation_order',
        'is_active',
    ];
}
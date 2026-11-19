<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class QuizTemplateSeeder extends Seeder
{
    public function run(): void
    {
        $templates = [
            [1, 'Dasar Pemrograman', 'dasar-pemrograman', 'Quiz dasar logika dan pemrograman.', 'Mudah', 10],
            [1, 'Internet dan Jaringan', 'internet-jaringan', 'Quiz dasar jaringan komputer.', 'Sedang', 10],
            [2, 'Sinonim Kata', 'sinonim-kata', 'Quiz sinonim bahasa Indonesia.', 'Mudah', 8],
            [2, 'Antonim Kata', 'antonim-kata', 'Quiz antonim bahasa Indonesia.', 'Mudah', 8],
            [3, 'Aritmatika Dasar', 'aritmatika-dasar', 'Quiz operasi hitung dasar.', 'Mudah', 12],
            [4, 'Pengetahuan Umum', 'pengetahuan-umum', 'Quiz wawasan umum.', 'Sedang', 10],
        ];

        foreach ($templates as $t) {
            \DB::table('quiz_templates')->updateOrInsert(
                ['slug' => $t[2]],
                [
                    'category_id' => $t[0],
                    'title' => $t[1],
                    'description' => $t[3],
                    'difficulty' => $t[4],
                    'duration_minutes' => $t[5],
                    'created_at' => now(),
                    'updated_at' => now(),
                ]
            );
        }
    }
}
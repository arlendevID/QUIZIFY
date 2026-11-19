<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class TemplateQuestionSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        \DB::table('template_questions')->insert([

            // DASAR PEMROGRAMAN

            [
                'quiz_template_id' => 1,
                'question' => 'Apa fungsi utama variabel dalam pemrograman?',
                'option_a' => 'Menyimpan data',
                'option_b' => 'Menghapus program',
                'option_c' => 'Membuat jaringan',
                'option_d' => 'Mengganti sistem operasi',
                'correct_answer' => 'A',
                'created_at' => now(),
                'updated_at' => now(),
            ],

            [
                'quiz_template_id' => 1,
                'question' => 'Bahasa pemrograman yang sering digunakan untuk web adalah?',
                'option_a' => 'HTML',
                'option_b' => 'PHP',
                'option_c' => 'CPU',
                'option_d' => 'RAM',
                'correct_answer' => 'B',
                'created_at' => now(),
                'updated_at' => now(),
            ],

            [
                'quiz_template_id' => 1,
                'question' => 'Apa arti dari looping?',
                'option_a' => 'Percabangan',
                'option_b' => 'Pengulangan',
                'option_c' => 'Penyimpanan data',
                'option_d' => 'Penghapusan file',
                'correct_answer' => 'B',
                'created_at' => now(),
                'updated_at' => now(),
            ],

        ]);
    }
}
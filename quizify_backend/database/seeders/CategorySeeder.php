<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class CategorySeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $categories = [
            [
                'name' => 'Teknologi',
                'slug' => 'teknologi',
                'icon' => 'cpu',
                'color' => '#5865F2',
            ],
            [
                'name' => 'Bahasa',
                'slug' => 'bahasa',
                'icon' => 'language',
                'color' => '#9D50BB',
            ],
            [
                'name' => 'Matematika',
                'slug' => 'matematika',
                'icon' => 'calculate',
                'color' => '#22C55E',
            ],
            [
                'name' => 'Umum',
                'slug' => 'umum',
                'icon' => 'public',
                'color' => '#FFCF00',
            ],
        ];

        foreach ($categories as $category) {
            \DB::table('categories')->updateOrInsert(
                ['slug' => $category['slug']],
                [
                    'name' => $category['name'],
                    'icon' => $category['icon'],
                    'color' => $category['color'],
                    'created_at' => now(),
                    'updated_at' => now(),
                ]
            );
        }
    }
}
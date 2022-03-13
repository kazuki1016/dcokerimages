<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use App\Models\Class1;
use App\Models\Class2;
use App\Models\Item;

class DatabaseSeeder extends Seeder
{
	/**
	 * Seed the application's database.
	 *
	 * @return void
	 */
	public function run()
	{
		return $this->call([
			UserSeed::class,
			Class1Seeder::class,
			Class2Seeder::class,
			ItemSeeder::class
		]);
	}
}

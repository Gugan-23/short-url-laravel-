<?php

// routes/web.php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\ShortUrlController;
use App\Http\Controllers\ProfileController;
use App\Http\Controllers\Auth\AuthenticatedSessionController;
use App\Http\Controllers\Auth\RegisteredUserController;



Route::middleware('guest')->group(function () {

Route::get('/login', [AuthenticatedSessionController::class, 'create'])->name('login');
Route::post('/login', [AuthenticatedSessionController::class, 'store']);
Route::get('/register', [RegisteredUserController::class, 'create'])->name('register');
Route::post('/register', [RegisteredUserController::class, 'store']);
});

Route::middleware(['auth', 'verified'])->group(function () {
    Route::get('/dashboard', function () {
        return view('dashboard');
    })->name('dashboard');

Route::post('/logout', [AuthenticatedSessionController::class, 'destroy'])->name('logout');
   
    Route::get('/', [ShortUrlController::class, 'showForm'])->name('home');
    Route::post('/shorten', [ShortUrlController::class, 'shorten'])->name('shorten');
Route::delete('/url/{id}', [ShortUrlController::class, 'destroy'])->name('url.delete')->middleware('auth');

    Route::get('/profile', [ProfileController::class, 'edit'])->name('profile.edit');
    Route::patch('/profile', [ProfileController::class, 'update'])->name('profile.update');
    Route::delete('/profile', [ProfileController::class, 'destroy'])->name('profile.destroy');

    Route::get('/{short_code}', [ShortUrlController::class, 'redirect'])->name('redirect');
});

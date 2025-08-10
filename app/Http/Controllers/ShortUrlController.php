<?php

namespace App\Http\Controllers;

use App\Models\ShortUrl;
use Illuminate\Http\Request;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\Auth;

class ShortUrlController extends Controller
{
    public function showForm()
    {
        $urls = Auth::user()->shortUrls()->latest()->get(); // show user's URLs

        return view('shortener.home', compact('urls'));
    }

    public function shorten(Request $request)
    {
        $request->validate([
            'original_url' => 'required|url'
        ]);

        $user = Auth::user();

        do {
            $shortCode = Str::random(6);
        } while (ShortUrl::where('short_code', $shortCode)->exists());

        $shortUrl = ShortUrl::create([
            'user_id' => $user->id,
            'short_code' => $shortCode,
            'original_url' => $request->original_url,
        ]);

        return redirect()->route('home')->with('success', 'Short URL created: ' . url($shortUrl->short_code));
    }

    public function redirect($short_code)
    {
        $url = ShortUrl::where('short_code', $short_code)->firstOrFail();

        return redirect($url->original_url);
    }
    public function destroy($id)
{
    $url = ShortUrl::findOrFail($id);

    // Optional: check if user owns the URL if you store user_id

    $url->delete();

    return redirect()->back()->with('success', 'Short URL deleted successfully.');
}

}

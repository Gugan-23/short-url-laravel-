<x-app-layout>
    <div style="max-width: 700px; margin: auto;">
        <h1 style="text-align: center; margin-bottom: 20px;">URL Shortener</h1>

        @if(session('success'))
            <div style="color: green; margin-bottom: 20px; text-align: center;">
                {{ session('success') }}
            </div>
        @endif

        @if($errors->any())
            <div style="color: red; margin-bottom: 20px;">
                <ul>
                    @foreach($errors->all() as $error)
                        <li>{{ $error }}</li>
                    @endforeach
                </ul>
            </div>
        @endif

        <form action="{{ route('shorten') }}" method="POST" style="margin-bottom: 30px;">
            @csrf
            <input type="url" name="original_url" placeholder="Enter your long URL" required
                   style="width: 100%; padding: 10px; border: 1px solid #ccc; border-radius: 4px;">
            <button type="submit" 
                    style="margin-top: 10px; padding: 10px 20px; background-color: #3b82f6; color: white; border: none; border-radius: 4px; cursor: pointer;">
                Shorten
            </button>
        </form>

        @if($urls->count() > 0)
            <h3 style="margin-bottom: 10px;">Your Shortened URLs</h3>

            <table style="width: 100%; border-collapse: collapse;">
                <thead>
                    <tr style="background-color: #f3f4f6;">
                        <th style="padding: 10px; border: 1px solid #ddd; text-align: left;">Short URL</th>
                        <th style="padding: 10px; border: 1px solid #ddd; text-align: left;">Original URL</th>
                        <th style="padding: 10px; border: 1px solid #ddd; text-align: left;">Created At</th>
                        <th style="padding: 10px; border: 1px solid #ddd; text-align: center;">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    @foreach($urls as $url)
                        <tr>
                            <td style="padding: 10px; border: 1px solid #ddd;">
                                <a href="{{ url($url->short_code) }}" target="_blank" style="color: #2563eb;">
                                    {{ url($url->short_code) }}
                                </a>
                            </td>
                            <td style="padding: 10px; border: 1px solid #ddd;">
                                <a href="{{ $url->original_url }}" target="_blank" style="color: #2563eb;">
                                    {{ $url->original_url }}
                                </a>
                            </td>
                            <td style="padding: 10px; border: 1px solid #ddd;">
                                {{ $url->created_at->format('Y-m-d H:i') }}
                            </td>
                            <td style="padding: 10px; border: 1px solid #ddd; text-align: center;">
                                <form action="{{ route('url.delete', $url->id) }}" method="POST" onsubmit="return confirm('Are you sure you want to delete this URL?');" style="display:inline;">
                                    @csrf
                                    @method('DELETE')
                                    <button type="submit" style="background-color: #ef4444; color: white; border: none; padding: 6px 12px; border-radius: 4px; cursor: pointer;">
                                        Delete
                                    </button>
                                </form>
                            </td>
                        </tr>
                    @endforeach
                </tbody>
            </table>
        @endif
    </div>
</x-app-layout>

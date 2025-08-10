<x-app-layout>
    <x-slot name="header">
        <h2 class="font-semibold text-xl text-gray-800 dark:text-gray-200 leading-tight flex items-center justify-between">
            {{ __('Hello') }}

            <!-- Dark/Light Mode Toggle Button -->
            <button 
    x-data="{ darkMode: false }"
    x-init="
      // Initialize darkMode from localStorage or system preference
      darkMode = (localStorage.getItem('theme') === 'dark') || 
                 (!localStorage.getItem('theme') && window.matchMedia('(prefers-color-scheme: dark)').matches);
      $watch('darkMode', value => {
        if(value) {
          document.documentElement.classList.add('dark');
          localStorage.setItem('theme', 'dark');
        } else {
          document.documentElement.classList.remove('dark');
          localStorage.setItem('theme', 'light');
        }
      });
    "
    @click="darkMode = !darkMode"
    class="ml-4 px-3 py-1 rounded bg-gray-200 dark:bg-gray-700 text-gray-800 dark:text-gray-200 focus:outline-none"
    aria-label="Toggle Dark Mode"
>
    <template x-if="darkMode">
        <span>☀️ Light</span>
    </template>
    <template x-if="!darkMode">
        <span>🌙 Dark</span>
    </template>
</button>

        </h2>
    </x-slot>

    <div class="py-12">
        <div class="max-w-7xl mx-auto sm:px-6 lg:px-8">
            <div class="bg-white dark:bg-gray-800 overflow-hidden shadow-sm sm:rounded-lg">
                <div class="p-6 text-gray-900 dark:text-gray-100">
                

                    <div class="mt-6">
                        <a href="{{ route('home') }}" 
   class="inline-block px-6 py-3 bg-blue-600 text-white font-semibold rounded-lg shadow-md hover:bg-blue-700 hover:shadow-lg transition">
   Go to URL Shortener
</a>

                    </div>

                </div>
            </div>
        </div>
    </div>
</x-app-layout>

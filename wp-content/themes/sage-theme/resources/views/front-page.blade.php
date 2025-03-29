{{-- resources/views/front-page.blade.php --}}

@extends('layouts.app')

@section('content')
  <div class="container mx-auto py-12">
    <h1 class="text-4xl font-bold mb-4 bg-blue-300">Welcome to My Personal Site</h1>
    <p class="text-lg text-gray-600 mb-8">I'm a full-stack developer specializing in JavaScript/TypeScript.</p>

    {{-- Recent Posts --}}
    <h2 class="text-2xl font-semibold mb-4">Latest Posts</h2>
    <div class="grid md:grid-cols-2 gap-6">
      @foreach ($posts as $post)
        <a href="{{ get_permalink($post) }}" class="block border p-4 rounded hover:shadow">
          <h3 class="text-xl font-bold">{{ get_the_title($post) }}</h3>
          <p class="text-gray-600">{{ get_the_excerpt($post) }}</p>
        </a>
      @endforeach
    </div>
  </div>
@endsection


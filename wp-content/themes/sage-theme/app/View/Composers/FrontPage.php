<?php


namespace App\View\Composers;

use Roots\Acorn\View\Composer;

class FrontPage extends Composer
{
    protected static $views = [
        'front-page',
    ];

    public function with()
    {
        return [
            'posts' => get_posts([
                'numberposts' => 4,
                'post_status' => 'publish',
            ]),
        ];
    }
}

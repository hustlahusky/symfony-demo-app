<?php

declare(strict_types=1);

namespace App;

$_SERVER['APP_RUNTIME_OPTIONS'] = [
    'project_dir' => \dirname(__DIR__),
    'dotenv_path' => '.env',
];

$_SERVER['APP_RUNTIME_OPTIONS']['disable_dotenv'] = !\is_file($_SERVER['APP_RUNTIME_OPTIONS']['project_dir'] . '/' . $_SERVER['APP_RUNTIME_OPTIONS']['dotenv_path']);

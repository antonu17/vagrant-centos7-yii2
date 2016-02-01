class my_nginx {

  class{ 'nginx':
    package_name   => 'nginx18',
    require        => Yumrepo['webtatic'],
  }

  nginx::resource::vhost{ 'torbor.dev':
    www_root           => '/var/www/farm-market/frontend/web',
    try_files          => ['$uri', '$uri/', '/index.php?$args'],
    index_files        => ['index.php'],
  }

  nginx::resource::location{ 'torbor.dev':
    location           => '~ \.php$',
    www_root           => '/var/www/farm-market/frontend/web',
    vhost              => 'torbor.dev',
    index_files        => ['index.php'],
    try_files          => ['try_files', '$uri', '=404'],
    fastcgi            => '127.0.0.1:9000',
    fastcgi_param      => {
      'SCRIPT_FILENAME' => '$document_root/$fastcgi_script_name',
    },
    fastcgi_split_path => '^(.+\.php)(/.+)$',
  }

  nginx::resource::vhost{ 'admin.torbor.dev':
    www_root           => '/var/www/farm-market/backend/web',
    try_files          => ['$uri', '$uri/', '/index.php?$args'],
    index_files        => ['index.php'],
  }

  nginx::resource::location{ 'admin.torbor.dev':
    location           => '~ \.php$',
    www_root           => '/var/www/farm-market/backend/web',
    vhost              => 'admin.torbor.dev',
    index_files        => ['index.php'],
    try_files          => ['try_files', '$uri', '=404'],
    fastcgi            => '127.0.0.1:9000',
    fastcgi_param      => {
      'SCRIPT_FILENAME' => '$document_root/$fastcgi_script_name',
    },
    fastcgi_split_path => '^(.+\.php)(/.+)$',
  }

}
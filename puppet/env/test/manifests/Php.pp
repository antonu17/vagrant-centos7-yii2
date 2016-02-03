class my_php {

  class { 'php':
    require        => Yumrepo['webtatic'],
    package_prefix => 'php56w-',
    fpm            => true,
  }

  php::extension { 'mysql': }
  php::extension { 'pgsql': }
  php::extension { 'gd': }
  php::extension { 'mbstring': }
  php::extension { 'mcrypt': }
  php::extension { 'pdo': }
  php::extension { 'intl': }
  php::extension { 'xml': }
  php::extension { 'pecl-imagick': }
  php::extension { 'pecl-memcache': }
  php::extension { 'pecl-apcu': }

  php::config::setting { 'Date/date.timezone':
    file  => '/etc/php.ini',
    key   => 'Date/date.timezone',
    value => 'Europe/Moscow',
  }

  php::config::setting { 'PHP/expose_php':
    file  => '/etc/php.ini',
    key   => 'PHP/expose_php',
    value => 'Off',
  }

  php::config::setting { 'log_errors':
    file   => '/etc/php-fpm.d/www.conf',
    key    => 'www/php_admin_flag[log_errors]',
    value  => 'on',
    notify => Service['php-fpm'],
  }

  php::config::setting { 'error_log':
    file   => '/etc/php-fpm.d/www.conf',
    key    => 'www/php_admin_value[error_log]',
    value  => '/var/log/php-fpm/www-error.log',
    notify => Service['php-fpm'],
  }
}
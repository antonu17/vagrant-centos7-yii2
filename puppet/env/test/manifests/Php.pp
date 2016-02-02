class my_php {

  class { 'php':
    package        => "php56w",
    module_prefix  => 'php56w-',
    service        => 'nginx',
    require        => Yumrepo['webtatic'],
  }

  php::module { "cli": }
  php::module { "fpm":
    before => Service['php-fpm'],
  }
  php::module { "mysql":
    before => Service['php-fpm'],
  }
  php::module { "mbstring":
    before => Service['php-fpm'],
  }
  php::module { "mcrypt":
    before => Service['php-fpm'],
  }
  php::module { "gd":
    before => Service['php-fpm'],
  }
  php::module { "pdo":
    before => Service['php-fpm'],
  }
  php::module { "intl":
    before => Service['php-fpm'],
  }
  php::module { "xml":
    before => Service['php-fpm'],
  }

  service { 'php-fpm':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }
}
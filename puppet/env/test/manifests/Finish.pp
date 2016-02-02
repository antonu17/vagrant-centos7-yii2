class my_finish {

  exec { 'php init --env=Development --overwrite=All':
    cwd     => '/var/www/farm-market',
    path    => '/usr/bin',
    user    => 'developer',
    creates => '/var/www/farm-market/frontend/web/index.php',
  }

  file { '/var/log/php-fpm':
    mode => '777',
  }

  file { '/var/log/php-fpm/error.log':
    mode => '644',
  }

  file { '/etc/init.d/comet':
    ensure => 'present',
    source => '/var/www/comet',
    mode   => '755',
  }

  service { 'comet':
    require    => File['/etc/init.d/comet'],
    ensure     => running,
    enable     => true,
    start      => '/etc/init.d/comet start',
    stop       => '/etc/init.d/comet stop',
    restart    => '/etc/init.d/comet restart',
    hasstatus => false,
  }
}
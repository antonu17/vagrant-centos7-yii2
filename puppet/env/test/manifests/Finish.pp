class my_finish {

  exec { 'composer global require "fxp/composer-asset-plugin:~1.1.1"':
    path        => '/usr/bin:/usr/local/bin',
    user        => 'developer',
    environment => ['HOME=/var/www'],
    creates     => '/var/www/.config/composer/vendor/fxp/composer-asset-plugin/composer.json',
  }

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
    ensure => present,
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
    hasstatus  => true,
  }

  exec { 'Yiimigrate':
    command   => 'php yii migrate --migrationPath=/var/www/farm-market/console/migrations --interactive=0 && touch /home/vagrant/.yiimigrate; true',
    cwd       => '/var/www/farm-market',
    path      => '/usr/bin',
    user      => 'developer',
    provider  => shell,
    logoutput => true,
    onlyif    => 'ls -l /vagrant/dump/chemical/*.php >/dev/null 2>&1 && ls -l /vagrant/dump/torbor/*.php >/dev/null 2>&1 && test ! -e /home/vagrant/.yiimigrate'
  } ->

  exec { 'torbor_sql':
    path        => '/usr/bin:/usr/sbin',
    provider    => shell,
    logoutput   => true,
    command     => 'for sql in /vagrant/dump/torbor/*.sql; do echo "Applying ${sql}"; mysql -uroot -proot torbor < ${sql}; done && touch /var/lib/mysql/.torborsql',
    onlyif      => 'test -e /home/vagrant/.yiimigrate && test ! -e /var/lib/mysql/.torborsql',
  } ->

  exec { 'chemical_sql':
    path        => '/usr/bin:/usr/sbin',
    provider    => shell,
    logoutput   => true,
    command     => 'for sql in /vagrant/dump/chemical/*.sql; do echo "Applying ${sql}"; mysql -uroot -proot chemical < ${sql}; done && touch /var/lib/mysql/.chemicalsql',
    onlyif      => 'test -e /home/vagrant/.yiimigrate && test ! -e /var/lib/mysql/.chemicalsql',
  }
}
class my_finish {

  exec { 'php init --env=Development --overwrite=All':
    cwd     => '/var/www/farm-market',
    path    => '/usr/bin',
    user    => 'developer',
    creates => '/var/www/farm-market/frontend/web/index.php',
  }

  exec { 'composer global require "fxp/composer-asset-plugin:~1.1.1"':
    path        => '/usr/bin',
    user        => 'developer',
    environment => ['HOME=/var/www'],
    creates     => '/var/www/.config/composer/vendor/fxp/composer-asset-plugin/composer.json',
  }

  service { 'comet':
    ensure  => running,
    start   => '/var/www/node/startup.sh',
    stop    => '/var/www/node/shutdown.sh',
    pattern => '/usr/bin/node'
  }
}
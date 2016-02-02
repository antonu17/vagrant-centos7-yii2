class my_finish {

  exec { 'php init --env=Development --overwrite=All':
    cwd     => '/var/www/farm-market',
    path    => '/usr/bin',
    user    => 'developer',
    creates => '/var/www/farm-market/frontend/web/index.php',
  }

  service { 'comet':
    ensure  => running,
    start   => '/var/www/node/startup.sh',
    stop    => '/var/www/node/shutdown.sh',
    pattern => '/usr/bin/node'
  }
}
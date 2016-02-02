class my_composer {

  class { 'composer':
    command_name => 'composer',
    target_dir   => '/usr/bin',
    require      => Package['PhpModule_cli'],
  } ->

  exec { 'composer global require "fxp/composer-asset-plugin:~1.1.1"':
    path        => '/usr/bin',
    user        => 'developer',
    environment => ['HOME=/var/www']
  }
}
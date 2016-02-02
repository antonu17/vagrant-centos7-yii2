class my_composer {

  class { 'composer':
    command_name => 'composer',
    target_dir   => '/usr/bin',
    require      => Package['PhpModule_cli'],
  }
}
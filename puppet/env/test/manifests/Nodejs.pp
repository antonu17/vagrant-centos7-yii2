class my_nodejs {

  class { 'nodejs':
  } ->

  exec { 'sudo npm install npm -g':
    path        => '/usr/bin',
    refreshonly => true,
    subscribe   => Package['nodejs'],
  } ->

  package { 'forever':
    ensure   => 'present',
    provider => 'npm',
  }
}
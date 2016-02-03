class my_system {

  exec { 'yum update':
    command => 'yum clean all; yum -y update --exclude=kernel* && touch /root/yumupd',
    onlyif  => 'test ! -e /root/yumupd',
    path    => '/bin:/sbin:/usr/sbin',
    timeout => 0,
  } ->

  user { 'developer':
    allowdupe        => true,
    groups           => ['vagrant'],
    uid              => '1000',
    gid              => '1000',
    home             => '/var/www',
    password         => pw_hash('1q2w3e4r', 'SHA-512', 'yvf9714yr'),
    shell            => '/bin/bash',
  } ->

  file { '/var/www':
    mode => '777',
  } ->

  file { "/etc/localtime":
    ensure => link,
    target => "/usr/share/zoneinfo/Europe/Moscow",
  }
}
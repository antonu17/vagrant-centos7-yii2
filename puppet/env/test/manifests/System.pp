class my_system {

  user { 'developer':
    allowdupe        => true,
    groups           => ['vagrant'],
    uid              => '1000',
    gid              => '1000',
    home             => '/var/www',
    password         => pw_hash('1q2w3e4r', 'SHA-512', 'yvf9714yr'),
    shell            => '/bin/bash',
  }

  file { '/var/www':
    mode => '777',
  }

  file { "/etc/localtime":
    source  => "file:///usr/share/zoneinfo/Europe/Moscow",
  }
}
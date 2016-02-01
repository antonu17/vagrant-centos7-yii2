class my_firewall {

  class { ['my_fw::pre', 'my_fw::post']: }
  class { 'firewall': }

  Firewall {
    before  => Class['my_fw::post'],
    require => Class['my_fw::pre'],
  }

  firewall { '100 allow http and https access':
    dport   => [80, 443],
    proto   => tcp,
    action  => accept,
  }
  firewall { '101 allow mysql access':
    dport   => [3306],
    proto   => tcp,
    action  => accept,
  }
  firewall { '101 allow ssh access':
    dport   => [22],
    proto   => tcp,
    action  => accept,
  }
}
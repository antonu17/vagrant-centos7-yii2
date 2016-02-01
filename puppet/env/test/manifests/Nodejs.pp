class my_nodejs {
  class { 'nodejs':
    version => 'stable',
  }

  package { 'forever':
    provider => 'npm',
    require  => Class['nodejs']
  }
}
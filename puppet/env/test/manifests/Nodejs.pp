class my_nodejs {
  class { 'nodejs':
    version => 'stable',
  }

  package { 'express':
    provider => 'npm',
    require  => Class['nodejs']
  }

  package { 'forever':
    provider => 'npm',
    require  => Class['nodejs']
  }
}
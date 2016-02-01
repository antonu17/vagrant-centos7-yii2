class my_nodejs {
  class { 'nodejs': }

  package { 'forever':
    ensure   => 'present',
    provider => 'npm',
  }
}
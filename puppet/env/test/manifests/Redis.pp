class my_redis {
  class { 'redis':
    require => Yumrepo['epel'],
  }
}
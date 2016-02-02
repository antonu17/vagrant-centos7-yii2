class my_yum {

  include yum::repo::webtatic
  include yum::repo::epel

  package { 'mc':
    ensure => present
  }

  package { 'git':
    ensure => present
  }

  package { 'rubygems':
    ensure => present
  }

  package { 'vim-enhanced':
    ensure => present
  }
}

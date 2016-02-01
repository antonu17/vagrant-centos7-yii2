class my_elasticsearch {
  class { 'elasticsearch':
    manage_repo  => true,
    repo_version => '2.x',
  }

  elasticsearch::instance { 'es-01': }

}
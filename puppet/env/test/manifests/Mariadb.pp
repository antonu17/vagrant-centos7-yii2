class my_mariadb {
  class { '::mysql::server':
    root_password    => 'root',
    users            => {
      'dbaseadmin@%'         => {
        ensure                   => 'present',
        max_connections_per_hour => '0',
        max_queries_per_hour     => '0',
        max_updates_per_hour     => '0',
        max_user_connections     => '0',
        password_hash            => '*0F728F6FF63A991BD5FC71CC26C7E72EF7ECC435',
      },
      'dbaseuser@localhost'  => {
        ensure                   => 'present',
        max_connections_per_hour => '0',
        max_queries_per_hour     => '0',
        max_updates_per_hour     => '0',
        max_user_connections     => '0',
        password_hash            => '*0F728F6FF63A991BD5FC71CC26C7E72EF7ECC435',
      },
    },
    grants           => {
      'dbaseadmin@%/*.*'               => {
        ensure     => 'present',
        options    => ['GRANT'],
        privileges => ['ALL'],
        table      => '*.*',
        user       => 'dbaseadmin@%',
      },
      'dbaseuser@localhost/torbor.*'   => {
        ensure     => 'present',
        options    => ['GRANT'],
        privileges => ['ALL'],
        table      => 'torbor.*',
        user       => 'dbaseuser@localhost',
      },
      'dbaseuser@localhost/chemical.*' => {
        ensure     => 'present',
        options    => ['GRANT'],
        privileges => ['ALL'],
        table      => 'chemical.*',
        user       => 'dbaseuser@localhost',
      },
    },
    databases        => {
      'torbor'    => {
        ensure  => 'present',
        charset => 'utf8',
      },
      'chemical'  => {
        ensure  => 'present',
        charset => 'utf8',
      },
    },
    override_options => {
      'mysqld' => {
        'bind-address'           => '*',
        'character-set-server'   => 'utf8',
        'collation-server'       => 'utf8_general_ci',
        'lower_case_table_names' => '1',
      },
    },
  }
}
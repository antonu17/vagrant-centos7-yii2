stage { 'last': }
Stage['main'] -> Stage['last']

include my_system
include my_yum
include my_nginx
include my_php
include my_mariadb
include my_firewall
include my_redis
include my_nodejs
include my_java
include my_elasticsearch
include my_composer

class { 'my_finish':
  stage => last
}

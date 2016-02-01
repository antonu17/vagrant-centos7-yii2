class my_java {
  class { 'java':
    distribution => 'jre',
    package      => 'java-1.8.0-openjdk'
  }
}

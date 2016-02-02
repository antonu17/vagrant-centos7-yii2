class my_cron {

  cron { 'order/revision':
    command => "cd /var/www/farm-market && php yii order/revision",
    user    => 'vagrant',
  }

  cron { 'rates/update':
    command => "cd /var/www/farm-market && php yii rates/update",
    user    => 'vagrant',
    hour    => ['6-16'],
    minute  => '*/10',
  }

  cron { 'mail/send 1':
    command => "cd /var/www/farm-market && php yii mail/send 1",
    user    => 'vagrant',
  }

  cron { 'mail/send 2':
    command => "cd /var/www/farm-market && php yii mail/send 2",
    user    => 'vagrant',
    minute => '*/2',
  }

  cron { 'mail/send 3':
    command => "cd /var/www/farm-market && php yii mail/send 3",
    user    => 'vagrant',
    minute => '*/5',
  }
}
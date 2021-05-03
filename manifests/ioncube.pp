class voipmonitor::ioncube {
  #заливаем либу
  file {"/usr/lib/php/20180731/ioncube_loader_lin_7.3.so":
    ensure  => file,
    source  => 'puppet:///modules/voipmonitor/ioncube_loader_lin_7.3.so',
  } ->
  #делаем конфиг
  file {'/etc/php/7.3/mods-available/ioncube.ini':
    ensure  => file,
    content => 'zend_extension = /usr/lib/php/20180731/ioncube_loader_lin_7.3.so'
  } ->
  #кладем его в веб
  file {'/etc/php/7.3/apache2/conf.d/01-ioncube.ini':
    ensure  => link,
    target  => '/etc/php/7.3/mods-available/ioncube.ini',
    notify  => Service[$apache::service_name]
  } ->
  #и кли версию php
  file {'/etc/php/7.3/cli/conf.d/01-ioncube.ini':
    ensure  => link,
    target  => '/etc/php/7.3/mods-available/ioncube.ini',
    notify  => Service[$apache::service_name]
  }
}


class voipmonitor::gui {
  include voipmonitor::ioncube
  file {$voipmonitor::guidir:
    ensure  => directory,
    owner   => $::apache::params::user,
    mode    => '0755',
  } ->
  package {'gsfonts': 
    ensure => installed
  } ->
  file {"${voipmonitor::tmpdir}/gui.tar.gz":
    ensure  => file,
    source  => 'puppet:///modules/voipmonitor/voipmonitor-gui-24.62-SVN.71.tar.gz',
  } ->
  exec {'install_voipmonitor_gui':
    command => "tar -zxvf ./gui.tar.gz && cd voipmonitor-gui-* && cp -r . ${voipmonitor::guidir} && chown -R ${apache::params::user} ${voipmonitor::guidir}",
    cwd     => $voipmonitor::tmpdir,
    unless  => "test -f ${voipmonitor::guidir}/cdr.php",
    path    => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin',
    require => File['/etc/php/7.3/apache2/conf.d/01-ioncube.ini']
  } ->
  file {"${voipmonitor::guidir}/bin/phantomjs-2.1.1-x86_64":
    ensure  => file,
    source  => 'puppet:///modules/voipmonitor/phantomjs-2.1.1-x86_64',
    owner   => $::apache::params::user,
    mode    => '0755',
  } ->
  file {"${voipmonitor::guidir}/bin/sox-x86_64":
    ensure  => file,
    source  => 'puppet:///modules/voipmonitor/sox-x86_64',
    owner   => $::apache::params::user,
    mode    => '0755',
  } ->
  file {"${voipmonitor::guidir}/bin/tshark-2.3.0.3-x86_64":
    ensure  => file,
    source  => 'puppet:///modules/voipmonitor/tshark-2.3.0.3-x86_64',
    owner   => $::apache::params::user,
    mode    => '0755',
  } ->
  file {"${voipmonitor::guidir}/bin/mergecap-2.3.0.3-x86_64":
    ensure  => file,
    source  => 'puppet:///modules/voipmonitor/mergecap-2.3.0.3-x86_64',
    owner   => $::apache::params::user,
    mode    => '0755',
  } ->
  file {"${voipmonitor::guidir}/bin/t38_decode-2-i686":
    ensure  => file,
    source  => 'puppet:///modules/voipmonitor/t38_decode-2-i686',
    owner   => $::apache::params::user,
    mode    => '0755',
  } ->
  apache::vhost {'voipmonitor':
    servername => $::fqdn,
    port       => '2080',
    docroot    => $voipmonitor::guidir,
  }
}


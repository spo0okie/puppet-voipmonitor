class voipmonitor::sniffer {
  file {"${voipmonitor::tmpdir}/voipmon.tar.gz":
    ensure => file,
    source => 'puppet:///modules/voipmonitor/voipmonitor-27.8-src.tar.gz',
  } ->
  file {"/var/spool/voipmonitor/":
    ensure => directory,
    owner  => $::apache::params::user,
    mode   => '0777',
  } ->
  package {
    [
      'unixodbc-dev',
      'libcurl4-nss-dev',
      'libcurl4-openssl-dev',
      'libcurl4-gnutls-dev',
      'libjson-c-dev',
      'librrd-dev',
      'libglib2.0-dev',
      'fonts-urw-base35',
      'librsvg2-2',
      'libsnappy-dev',
    ]:
    ensure => installed;
  } ->
  exec {'install_voipmonitor_sniffer':
    command => 'tar -zxvf ./voipmon.tar.gz && cd voipmonitor*src && ./configure --libdir=/usr/lib64 && make && make install',
    cwd     => $voipmonitor::tmpdir,
    unless  => 'which voipmonitor',
    path    => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin',
    timeout => 1800,
    require => Package[$common::packages::kernel_devel],
  } ->
  exec {'install_voipmonitor_conf':
    command => 'echo tst && cd voipmonitor*src && cp config/voipmonitor.conf /etc/',
    cwd     => $voipmonitor::tmpdir,
    unless  => 'test -f /etc/voipmonitor.conf',
    path    => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'
  } ->
  exec {'install_voipmonitor_systemd':
    command => 'echo tst && cd voipmonitor*src && cp config/systemd/voipmonitor.service /etc/systemd/system',
    cwd     => $voipmonitor::tmpdir,
    unless  => 'test -f /etc/systemd/system/voipmonitor.service',
    path    => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'
  } ->
  #инициализация БД
  exec {'install_voipmonitor_db':
    command => 'echo "create database voipmonitor" | mysql',
    cwd     => $voipmonitor::tmpdir,
    unless  => 'echo "show databases" | mysql | grep voipmonitor',
    notify  => Service['voipmonitor'],
    path    => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'
  } ->
  exec {'arms-mysql-grant':
    command => "echo 'grant all on voipmonitor.* to voip_admin@\"%\" identified by \"V0ipPwd334\"' | mysql voipmonitor",
    path    => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin',
    unless  => "echo 'select user from mysql.user' | mysql | grep voip_admin"
  } ->

  service {'voipmonitor':
    enable  => true,
    ensure  => running
  }
  file {"/usr/local/etc/voipmonitor/":
    ensure  => directory,
    owner   => 'root',
    mode    => '0777',
  } ->
  file {"/usr/local/etc/voipmonitor/voipmon.cdr.trim.sh":
    ensure  => file,
    source  => 'puppet:///modules/voipmonitor/voipmon.cdr.trim.sh',
    mode    => '0755',
  }
  file {"/etc/rsyslog.d/voipmonitor.conf":
    ensure  => file,
    source  => 'puppet:///modules/voipmonitor/rsyslog.d/voipmonitor.conf',
    mode    => '0644',
    notify  => Service['rsyslog']
  }
}


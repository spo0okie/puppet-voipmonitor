class voipmonitor {
  $tmpdir = '/tmp/ast.voipmon_inst'
  $guidir = '/var/www/voipmonitor_gui'
  include asterisk
  include mysql_client
  file {$tmpdir:
    ensure=>directory
  }
  include voipmonitor::sniffer
  include voipmonitor::gui
}


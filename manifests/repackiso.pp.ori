class n1k-vsm::repackiso {
  
  $xx = generate('/usr/bin/env', '/usr/share/puppet/modules/n1k-vsm/bin/repackiso.py', "-i${n1k-vsm::isoimage}", "-d${n1k-vsm::domainid}", "-n${n1k-vsm::vsmname}", "-m${n1k-vsm::mgmtip}", "-s${n1k-vsm::mgmtnetmask}", "-g${n1k-vsm::mgmtgateway}", "-p${n1k-vsm::adminpasswd}", "-r${n1k-vsm::role}" , "-f/etc/puppet/files/${n1k-vsm::role}_repacked.iso")
}

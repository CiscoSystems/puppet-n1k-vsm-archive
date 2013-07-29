class vsm::repackiso {
  
  $xx = generate('/usr/bin/env', '/usr/share/puppet/modules/vsm/bin/repackiso.py', "-i${vsm::isoimage}", "-d${vsm::domainid}", "-n${vsm::vsmname}", "-m${vsm::mgmtip}", "-s${vsm::mgmtnetmask}", "-g${vsm::mgmtgateway}", "-p${vsm::adminpasswd}", "-r${vsm::role}" , "-f/etc/puppet/files/${vsm::role}_repacked.iso")
}

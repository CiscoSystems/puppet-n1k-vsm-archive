class n1k_vsm::repackiso {
  
  # cwchang to turn on later
  #$xx = generate('/usr/bin/env', '/usr/share/puppet/modules/n1k_vsm/bin/repackiso.py', "-i${n1k_vsm::isoimage}", "-d${n1k_vsm::domainid}", "-n${n1k_vsm::vsmname}", "-m${n1k_vsm::mgmtip}", "-s${n1k_vsm::mgmtnetmask}", "-g${n1k_vsm::mgmtgateway}", "-p${n1k_vsm::adminpasswd}", "-r${n1k_vsm::role}" , "-f/etc/puppet/files/${n1k_vsm::role}_repacked.iso")
}

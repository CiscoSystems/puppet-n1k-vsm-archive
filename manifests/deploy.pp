class n1k_vsm::deploy {
  include 'stdlib'
  # cwchang new
  $arg_pattern = '[a-zA-Z_0-9:]+'
  

  #ensure tap interfaces and deploy the vsm

  #cwchang old
  #$ctrltap = $n1k_vsm::ctrlinterface[0]
  #$ctrlmac = $n1k_vsm::ctrlinterface[1]
  #$ctrlbridge = $n1k_vsm::ctrlinterface[2]

  #cwchang new
  $ctrl0 = $n1k_vsm::ctrlinterface

  $ctrltap = regsubst($ctrl0, "^(${arg_pattern})[, ]+.*$", '\1')

  $ctrl1 = regsubst($ctrl0,  "${arg_pattern}[, ]*(.*)$", '\1')

  $ctrlmac = regsubst($ctrl1, "^(${arg_pattern})[, ]+.*$", '\1')
  $ctrl2 = regsubst($ctrl1, "${arg_pattern}[, ]*(.*)$", '\1')

  $ctrlbridge = regsubst($ctrl2, "^(${arg_pattern})[, ]*.*$", '\1')
   
  # cwchang old
  #$mgmttap = $n1k_vsm::mgmtinterface[0]
  #$mgmtmac = $n1k_vsm::mgmtinterface[1]
  #$mgmtbridge = $n1k_vsm::mgmtinterface[2]

  # cwchang new
  $mgmt0 = $n1k_vsm::mgmtinterface
  $mgmttap = regsubst($mgmt0, "^(${arg_pattern})[, ]+.*$", '\1')

  $mgmt1 = regsubst($mgmt0,  "${arg_pattern}[, ]*(.*)$", '\1')
  $mgmtmac = regsubst($mgmt1, "^(${arg_pattern})[, ]+.*$", '\1')

  $mgmt2 = regsubst($mgmt1,  "${arg_pattern}[, ]*(.*)$", '\1')
  $mgmtbridge = regsubst($mgmt2, "^(${arg_pattern})[, ]*.*$", '\1')

  # cwchang old
  #$pkttap = $n1k_vsm::pktinterface[0]
  #$pktmac = $n1k_vsm::pktinterface[1]
  #$pktbridge = $n1k_vsm::pktinterface[2]

  # cwchang new
  $pkt0 = $n1k_vsm::pktinterface
  $pkttap = regsubst($pkt0, "^(${arg_pattern})[, ]+.*$", '\1')

  $pkt1 = regsubst($pkt0,  "${arg_pattern}[, ]*(.*)$", '\1')
  $pktmac = regsubst($pkt1, "^(${arg_pattern})[, ]+.*$", '\1')

  $pkt2 = regsubst($pkt1,  "${arg_pattern}[, ]*(.*)$", '\1')
  $pktbridge = regsubst($pkt2, "^(${arg_pattern})[, ]*.*$", '\1')
 
#  tapint {"$ctrltap":
#     bridge => $ctrlbridge,
#     ensure => present
#  }
#
#  tapint {"$mgmttap":
#     bridge => $mgmtbridge,
#     ensure => present
#  }
#
#  tapint {"$pkttap":
#     bridge => $pktbridge,
#     ensure => present
#  }

  file { '/var/spool/vsm':
         owner => 'root',
         group => 'root',
         mode  => '664',
         ensure => directory
  }

  file { $imgfile:
         owner => 'root',
         group => 'root',
         mode => '666',
         source => "puppet:///files/${n1k_vsm::role}_repacked.iso",
         require => File['/var/spool/vsm']
  }

  exec { "create_disk":
         command => "/usr/bin/qemu-img create -f raw $n1k_vsm::diskfile $n1k_vsm::disksize}G",
         unless => "/usr/bin/virsh list | grep -c ' ${n1k_vsm::vsmname} .* running'"
  }

  $targetxmlfile = "/var/spool/vsm/vsm_${n1k_vsm::role}_deploy.xml"
  file { $targetxmlfile:
         owner => 'root',
         group => 'root',
         mode => '666',
         content => template('n1k_vsm/vsm_vm.xml.erb'),
         require => Exec["create_disk"]
  }

  exec { "launch_${n1k_vsm::role}_vsm":
         command => "/usr/bin/virsh create $targetxmlfile",
         unless => "/usr/bin/virsh list | grep -c ' ${n1k_vsm::vsmname} .* running'"
  }

  File['/var/spool/vsm'] -> File["$imgfile"] -> Exec["create_disk"] -> File["$targetxmlfile"] -> Exec["launch_${n1k_vsm::role}_vsm"]
}

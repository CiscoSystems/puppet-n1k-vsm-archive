class n1k-vsm::deploy {
  include 'stdlib'
  
  #ensure tap interfaces and deploy the vsm

  $ctrltap = $n1k-vsm::ctrlinterface[0]
  $ctrlmac = $n1k-vsm::ctrlinterface[1]
  $ctrlbridge = $n1k-vsm::ctrlinterface[2]
  $mgmttap = $n1k-vsm::mgmtinterface[0]
  $mgmtmac = $n1k-vsm::mgmtinterface[1]
  $mgmtbridge = $n1k-vsm::mgmtinterface[2]
  $pkttap = $n1k-vsm::pktinterface[0]
  $pktmac = $n1k-vsm::pktinterface[1]
  $pktbridge = $n1k-vsm::pktinterface[2]
 
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
         source => "puppet:///files/${n1k-vsm::role}_repacked.iso",
         require => File['/var/spool/vsm']
  }

  exec { "create_disk":
         command => "/usr/bin/qemu-img create -f raw ${n1k-vsm::diskfile} ${n1k-vsm::disksize}G",
         unless => "/usr/bin/virsh list | grep -c ' ${n1k-vsm::vsmname} .* running'"
  }

  $targetxmlfile = "/var/spool/vsm/vsm_${n1k-vsm::role}_deploy.xml"
  file { $targetxmlfile:
         owner => 'root',
         group => 'root',
         mode => '666',
         content => template('n1k-vsm/vsm_vm.xml.erb'),
         require => Exec["create_disk"]
  }

  exec { "launch_${n1k-vsm::role}_vsm":
         command => "/usr/bin/virsh create $targetxmlfile",
         unless => "/usr/bin/virsh list | grep -c ' ${n1k-vsm::vsmname} .* running'"
  }

  File['/var/spool/vsm'] -> File["$imgfile"] -> Exec["create_disk"] -> File["$targetxmlfile"] -> Exec["launch_${n1k-vsm::role}_vsm"]
}

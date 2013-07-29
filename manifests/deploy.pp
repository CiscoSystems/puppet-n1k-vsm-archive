class vsm::deploy {
  include 'stdlib'
  
  #ensure tap interfaces and deploy the vsm

  $ctrltap = $vsm::ctrlinterface[0]
  $ctrlmac = $vsm::ctrlinterface[1]
  $ctrlbridge = $vsm::ctrlinterface[2]
  $mgmttap = $vsm::mgmtinterface[0]
  $mgmtmac = $vsm::mgmtinterface[1]
  $mgmtbridge = $vsm::mgmtinterface[2]
  $pkttap = $vsm::pktinterface[0]
  $pktmac = $vsm::pktinterface[1]
  $pktbridge = $vsm::pktinterface[2]
 
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
         source => "puppet:///files/${vsm::role}_repacked.iso",
         require => File['/var/spool/vsm']
  }

  exec { "create_disk":
         command => "/usr/bin/qemu-img create -f raw ${vsm::diskfile} ${vsm::disksize}G",
         unless => "/usr/bin/virsh list | grep -c ' ${vsm::vsmname} .* running'"
  }

  $targetxmlfile = "/var/spool/vsm/vsm_${vsm::role}_deploy.xml"
  file { $targetxmlfile:
         owner => 'root',
         group => 'root',
         mode => '666',
         content => template('vsm/vsm_vm.xml.erb'),
         require => Exec["create_disk"]
  }

  exec { "launch_${vsm::role}_vsm":
         command => "/usr/bin/virsh create $targetxmlfile",
         unless => "/usr/bin/virsh list | grep -c ' ${vsm::vsmname} .* running'"
  }

  File['/var/spool/vsm'] -> File["$imgfile"] -> Exec["create_disk"] -> File["$targetxmlfile"] -> Exec["launch_${vsm::role}_vsm"]
}

class vsm::ovsprep {

  $kvmpackages = ["kvm", "libvirt-bin", "virtinst"]

  package { "kvmpackages":
        name => $kvmpackages,
        ensure => "installed"
  }

  exec { "removenet":
       command => "/usr/bin/virsh net-destroy default",
       unless => "/usr/bin/virsh net-info default | grep -c 'Active: .* no'"
  }
  
  exec { "disableautostart":
       command => "/usr/bin/virsh net-autostart --disable default",
       unless => "/usr/bin/virsh net-info default | grep -c 'Autostart: .* no'"
  }

  exec { "removebridgemodule":
       command => "/sbin/modprobe -r bridge"
  }

  $ovspackages = ["openvswitch-controller", "openvswitch-brcompat" ,"openvswitch-switch" ,"openvswitch-datapath-source"]
  package { $ovspackages:
        ensure => "installed"
  }

  $ovsdeffile = "/etc/default/openvswitch-switch"
  file {$ovsdeffile:
        content => template('vsm/openvswitch-default.erb"
  }

  $context = "/files/etc/network/interfaces"
  augeas { "${vsm::ovsbridge}":
        context => $context,
        changes => [
          "set auto[child::1 = "${name}"]/1 ${name}",
          "set iface[. = "${name}"] ${name}",
          "set iface[. = "${name}"]/family inet",
          "set iface[. = "${name}"]/method static",
          "set iface[. = "${name}"]/address ${vsm::nodeip}",
          "set iface[. = "${name}"]/netmask ${vsm::nodenetmask}",
          "set iface[. = "${name}"]/gateway ${vsm::nodegateway}",
          "set iface[. = "${name}"]/bridge_ports ${vsm::physicalinterfaceforovs}",
        ],
        notify => Service["networking"]
  }

  augeas { "${vsm::physicalinterfaceforovs}":
        context => $context,
        changes => [
          "set auto[child::1 = "${name}"]/1 ${name}",
          "set iface[. = "${name}"] ${name}",
          "set iface[. = "${name}"]/family inet",
          "set iface[. = "${name}"]/method manual",
        ],
        before => Augeas["${vsm::ovsbridge}"]
  }

  service { "networking":
       ensure  => "running",
       enable  => "true",
       notify => Service["openvswitch-switch"]
  }
  
  service {"openvswitch-switch":
       ensure  => "running",
       enable  => "true"
  }

  #Package["kvmpackages"] -> Exec['removenet'] -> Exec['disableautostart'] -> Exec['removebridgemodule'] -> Package["$ovspackages"] -> File[$ovsdeffile] -> Augeas["$vsm::ovsbridge"]

}

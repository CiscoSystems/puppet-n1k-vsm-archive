class n1k_vsm::ovsprep {

  service {"networking":
       ensure  => "running",
       enable  => "true",
       # 
       # cwchang old
       #
       #restart => "/etc/init.d/network restart",
       # 
       # cwchang new
       #
       restart => "service network restart"
  }
  
  #
  # cwchang old
  # in Redhat we don't need this
  #
  #exec { "rmspaceininterfaces":
       #command => "/bin/sed -i 's/^[ \t]*//' /etc/network/interfaces",
       #notify => Service["networking"]
  #}

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

  package { "ebtables":
       ensure => "purged"
  }

  exec { "removebridgemodule":
       command => "/sbin/modprobe -r bridge"
  }

  $ovspackages = ["openvswitch-controller", "openvswitch-brcompat" ,"openvswitch-switch" ,"openvswitch-datapath-source"]
  package { "ovspackages":
        name => $ovspackages,
        ensure => "installed"
  }

  $ovsdeffile = "/etc/default/openvswitch-switch"
  file {$ovsdeffile:
        content => template('n1k_vsm/openvswitch-default.erb')
  }

  #
  # cwchang new
  #
  augeas {"ovsbridge":
      context => "/files/etc/sysconfig/network-scripts/ifcfg-$n1k_vsm::ovsbridge",
      changes => [
          "set DEVICE $n1k_vsm::ovsbridge",
          "set DEVICETYPE ovs",
          "set IPADDR $n1k_vsm::nodeip",
          "set NETMASK $n1k_vsm::nodenetmask",
          "set TYPE OVSBridge",
          "set ONBOOT yes",
          "set BOOTPROTO static",
      ],  
  }   

  service {"openvswitch-switch":
       ensure  => "running",
       enable  => "true",
       notify => Service["networking"]
  }

  Package["kvmpackages"] -> Exec['removenet'] -> Exec['disableautostart'] -> Package["ebtables"] -> Exec['removebridgemodule'] -> Package["ovspackages"] -> File[$ovsdeffile] -> Augeas["$n1k_vsm::ovsbridge"] 
}

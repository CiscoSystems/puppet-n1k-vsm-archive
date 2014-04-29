class n1k_vsm::ovsprep {

  service {"networking":
       ensure  => "running",
       enable  => "true",
       restart => "/etc/init.d/network restart",
  }
  
  exec { "rmspaceininterfaces":
       command => "/bin/sed -i 's/^[ \t]*//' /etc/network/interfaces",
       notify => Service["networking"]
  }

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
  # cwchang old
  #
  #$context = "/files/etc/network/interfaces"
  #augeas { $ovsbridge:
        #name => $ovsbridge,
        #context => $context,
        #changes => [
          #"set auto[child::1 = '${ovsbridge}']/1 ${ovsbridge}",
          #"set iface[. = '${ovsbridge}'] ${ovsbridge}",
          #"set iface[. = '${ovsbridge}']/family inet",
          #"set iface[. = '${ovsbridge}']/method static",
          #"set iface[. = '${ovsbridge}']/address ${n1k-vsm::nodeip}",
          #"set iface[. = '${ovsbridge}']/netmask ${n1k-vsm::nodenetmask}",
          #"set iface[. = '${ovsbridge}']/gateway ${n1k-vsm::nodegateway}",
          #"set iface[. = '${ovsbridge}']/bridge_ports ${n1k-vsm::physicalinterfaceforovs}",
        #],
        #notify => Service["openvswitch-switch"]
  #}
#
  #augeas { $physicalinterfaceforovs:
        #name => $physicalinterfaceforovs,
        #context => $context,
        #changes => [
          #"set auto[child::1 = '${physicalinterfaceforovs}']/1 ${physicalinterfaceforovs}",
          #"set iface[. = '${physicalinterfaceforovs}'] ${physicalinterfaceforovs}",
          #"set iface[. = '${physicalinterfaceforovs}']/family inet",
          #"set iface[. = '${physicalinterfaceforovs}']/method manual",
          #"rm iface[. = '${physicalinterfaceforovs}']/address ",
          #"rm iface[. = '${physicalinterfaceforovs}']/netmask",
          #"rm iface[. = '${physicalinterfaceforovs}']/network",
          #"rm iface[. = '${physicalinterfaceforovs}']/broadcast",
          #"rm iface[. = '${physicalinterfaceforovs}']/dns-nameservers",
          #"rm iface[. = '${physicalinterfaceforovs}']/gateway",
          #"rm iface[. = '${physicalinterfaceforovs}']/bridge_ports",
        #],
        #before => Augeas["${ovsbridge}"]
  #}

  #
  # cwchang new
  #
  augeas {"$ovsbridge":
      context => "/files/etc/sysconfig/network-scripts/ifcfg-$ovsbridge",
      changes => [
          "set DEVICE $ovsbridge",
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

  Exec ['rmspaceininterfaces'] -> Package["kvmpackages"] -> Exec['removenet'] -> Exec['disableautostart'] -> Package["ebtables"] -> Exec['removebridgemodule'] -> Package["ovspackages"] -> File[$ovsdeffile] -> Augeas["$n1k_vsm::ovsbridge"] 

}

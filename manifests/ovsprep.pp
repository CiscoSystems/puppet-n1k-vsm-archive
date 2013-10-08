class n1k-vsm::ovsprep {

  exec { "removebridgemodule":
       command => "/sbin/modprobe -r bridge"
  }

  $kernelheaders_pkg = "linux-headers-$::kernelrelease"
  if ! defined(Package[$kernelheaders_pkg]) {
    package {"$kernelheaders_pkg":
      ensure => "installed"
    }
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

  $ovspackages = ["openvswitch-brcompat" ,"openvswitch-switch"]
  package { "ovspackages":
        name => $ovspackages,
        ensure => "installed"
  }

  $ovsdeffile = "/etc/default/openvswitch-switch"
  file {$ovsdeffile:
        content => template('n1k-vsm/openvswitch-default.erb')
  }

  service {"openvswitch-switch":
       ensure  => "running",
       enable  => "true",
       hasstatus   => false, # the supplied command returns true even if it's not running
       # Not perfect - should spot if either service is not running - but it'll do
       status      => "/etc/init.d/openvswitch-switch status | fgrep 'is running'",
  }

  service {"networking":
       ensure  => "running",
       enable  => "true",
       restart => "/etc/init.d/networking restart",
  }

  $context = "/files/etc/network/interfaces"
  augeas { $ovsbridge:
        name => $ovsbridge,
        context => $context,
        changes => [
          "set auto[child::1 = '${ovsbridge}']/1 ${ovsbridge}",
          "set iface[. = '${ovsbridge}'] ${ovsbridge}",
          "set iface[. = '${ovsbridge}']/family inet",
          "set iface[. = '${ovsbridge}']/method static",
          "set iface[. = '${ovsbridge}']/address ${n1k-vsm::nodeip}",
          "set iface[. = '${ovsbridge}']/netmask ${n1k-vsm::nodenetmask}",
          "set iface[. = '${ovsbridge}']/gateway ${n1k-vsm::nodegateway}",
          "set iface[. = '${ovsbridge}']/bridge_ports ${n1k-vsm::physicalinterfaceforovs}",
          "set iface[. = '${ovsbridge}']/dns-nameservers ${n1k-vsm::nodedns}",
        ],
        notify  => Service["networking"],
  }

  augeas { $physicalinterfaceforovs:
        name => $physicalinterfaceforovs,
        context => $context,
        changes => [
          "set auto[child::1 = '${physicalinterfaceforovs}']/1 ${physicalinterfaceforovs}",
          "set iface[. = '${physicalinterfaceforovs}'] ${physicalinterfaceforovs}",
          "set iface[. = '${physicalinterfaceforovs}']/family inet",
          "set iface[. = '${physicalinterfaceforovs}']/method manual",
          "rm iface[. = '${physicalinterfaceforovs}']/address ",
          "rm iface[. = '${physicalinterfaceforovs}']/netmask",
          "rm iface[. = '${physicalinterfaceforovs}']/network",
          "rm iface[. = '${physicalinterfaceforovs}']/broadcast",
          "rm iface[. = '${physicalinterfaceforovs}']/dns-nameservers",
          "rm iface[. = '${physicalinterfaceforovs}']/gateway",
          "rm iface[. = '${physicalinterfaceforovs}']/bridge_ports",
        ],
  }

  exec { "AddOvsBr":
       command => "/usr/bin/ovs-vsctl -- --may-exist add-br ${n1k-vsm::ovsbridge}",
  }

  Exec["removebridgemodule"] -> Package[$kernelheaders_pkg] -> Package["kvmpackages"] -> Exec["removenet"] -> Exec["disableautostart"] -> Package["ebtables"] -> Package["ovspackages"] -> File[$ovsdeffile] -> Service["openvswitch-switch"] -> Exec["AddOvsBr"] -> Augeas[$physicalinterfaceforovs] -> Augeas["$n1k-vsm::ovsbridge"]

}

class n1k_vsm::pkgprep_ovscfg {

  # Definition of sync points
  
  $Sync_Point_KVM = "##SYNC_POINT_KVM"
  $Sync_Point_Virsh_Network = "##SYNC_POINT_VIRSH_NETWORK"

  case "$::osfamily"  {
    "RedHat": {
      #
      # Order indepedent resources  
      #
      service {"Service_network":
        name   => "network",
        ensure => "running",
        restart => "/sbin/service network restart",
      }
      ->
      notify {"Service_network":
        message => "\n[INFO]\n Service_network \n name=network \n ensure=running \n enable=true \n restart=/sbin/service network restart\n",
      }
      # VSM dependent packages installation section
      #
      # Eng note
      # cwchang: Ideally we should have either of this logic
      # 1. Have an iteration thru the package list in the $pkgs.each ...
      #    Somehow this syntax needs to turn on future parser by document
      # 2. package resource should be able to run a name list 
      # Neither one works. We go for rudimentary one-by-one here for now.
      # Pitfalls observed:
      # 1. We cannot reassign variables for some reason
      # 2. We cannot leave spaces in name
      package {"Package_qemu-kvm-rhev":
        name   => "qemu-kvm-rhev",
        ensure => "installed",
        before => Notify["$Sync_Point_KVM"],
      }
      ->
      notify {"qemu-kvm-rhev":
        message => "\n[INFO]\n Package_qemu-kvm-rhev \n name=qemu-kvm-rhev \n ensure=installed\n",
      }

      package {"Package_virt-viewer":
        name   => "virt-viewer",
        ensure => "installed",
        before => Notify["$Sync_Point_KVM"],
      }
      ->
      notify {"Package_virt-viewer": 
        message => "\n[INFO]\n Package_virt-viewer \n name=virt-viewer \n ensure=installed \n",
      }
    
      package {"Package_virt-manager":
        name   => "virt-manager",
        ensure => "installed",
        before => Notify["$Sync_Point_KVM"],
      }
      ->
      notify {"Package_virt-manager": 
        message => "\n[INFO]\n Package_virt-manager \n name=virt-manager \n ensure=installed\n",
      }
    
      package {"Package_libvirt":
        name   => "libvirt",
        ensure => "installed",
        before => Notify["$Sync_Point_KVM"],
      }
      ->
      notify {"Package_libvirt": 
        message => "\n[INFO]\n Package_libvirt \n name=libvirt \n ensure=installed\n",
      }
    
      package {"Package_libvirt-python":
        name   => "libvirt-python",
        ensure => "installed",
        before => Notify["$Sync_Point_KVM"],
      }
      ->
      notify {"Package_libvirt-python": 
        message => "\n[INFO]\n Package_libvirt-python \n name=libvirt-python \n ensure=installed\n",
      }
    
      package {"Package_python-virtinst":
        name   => "python-virtinst",
        ensure => "installed",
        before => Notify["$Sync_Point_KVM"],
      }
      ->
      notify {"Package_python-virtinst": 
        message => "\n[INFO]\n Package_python-virtinst \n name=python-virtinst \n ensure=installed \n",
      }

      package {"Package_genisoimage":
        name   => "genisoimage",
        ensure => "installed",
        before => Notify["$Sync_Point_KVM"],
      }
      ->
      notify {"Package_genisoimage": 
        message => "\n[INFO]\n Package_genisoimage \n name=genisoimage \n ensure=installed \n",
      }


      notify{"$Sync_Point_KVM":}

      #
      # Virsh network exec configuration section 
      #
      exec {"Exec_removenet":
        command => "/usr/bin/virsh net-destroy default || /bin/true",
        unless => "/usr/bin/virsh net-info default | /bin/grep -c 'Active: .* no'",
        before => Notify["$Sync_Point_Virsh_Network"],
      }
      ->
      notify {"Exec_removenet":
        message => "\n[INFO]\n removenet \n command=/usr/bin/virsh net-destroy default || /bin/true \n unless=/usr/bin/virsh net-info default | /bin/grep -c 'Active: .* no'\n",
      }

      exec {"Exec_disableautostart":
        command => "/usr/bin/virsh net-autostart --disable default || /bin/true",
        unless => "/usr/bin/virsh net-info default | /bin/grep -c 'Autostart: .* no'",
        before => Notify["$Sync_Point_Virsh_Network"],
      }
      ->
      notify {"Exec_disableautostart":
        message => "\n[INFO]\n Exec_disableautostart' \n command=/usr/bin/virsh net-autostart --disable default || /bin/true \n unless /usr/bin/virsh net-info default | grep -c 'Autostart: .* no'",
      }
    
      notify{"$Sync_Point_Virsh_Network":}

      package {"Package_ebtables":
        name   => "ebtables",
        ensure => "purged",
      }
      ->
      notify {"Package_ebtables":
        message => "\n[INFO]\n Package_ebtables \n name=ebtables \n ensure=purged\n",
      }

      package {"Package_openvswitch":
        name   => "openvswitch",
        ensure => "installed",
      }
      ->
      notify {"Package_openvswitch": 
        message => "[INFO]\n Package_openvswitch name=openvswitch \n ensure=installed\n",
      }
      # 
      # bring up OVS and perform interface configuration 
      # 

      service {"Service_openvswitch":
        name   => "openvswitch",
        ensure => "running",
        enable => "true",
      }
      ->
      notify {"Service_openvswitch": 
        message => "\n[INFO]\n Service_openvswitch \n name=openvswitch \n ensure=running \n enable=true",
      }

    
      exec {"Exec_AddOvsBr":
        command => "/usr/bin/ovs-vsctl -- --may-exist add-br $n1k_vsm::ovsbridge",
      }
      ->
      notify {"Exec_AddOvsBr":
        message => "\n[INFO]\n Exec_AddOvsBr \n command=/usr/bin/ovs-vsctl -- --may-exist add-br $n1k_vsm::ovsbridge\n",
      }

      #
      # Modify Ovs bridge inteface configuation file
      #
      augeas {"Augeas_modify_ifcfg-$n1k_vsm::ovsbridge":
        name => "$n1k_vsm::ovsbridge",
        context => "/files/etc/sysconfig/network-scripts/ifcfg-$n1k_vsm::ovsbridge",
        changes => [
          "set DEVICE $n1k_vsm::ovsbridge", 
          "set BOOTPROTO none",
          "set IPADDR $n1k_vsm::nodeip",
          "set NETMASK $n1k_vsm::nodenetmask",
          "set ONBOOT yes",
          "set TYPE OVSBridge",
          "set DEVICETYPE ovs",
        ],
        notify => Service["Service_network"],
      }
      ->
      notify {"Augeas_modify_ifcfg-$n1k_vsm::ovsbridge":
        message => "\n[INFO]\n Augeas_modify_ifcfg-$n1k_vsm::ovsbridge \n name=$n1k_vsm::ovsbridge \n context=/files/etc/sysconfig/network-scripts/ifcfg-$n1k_vsm::ovsbridge \n",
      }

      #
      # Modify Physical Interface config file
      #
      augeas {"Augeas_modify_ifcfg-$n1k_vsm::physicalinterfaceforovs":
        name => "$n1k_vsm::physicalinterfaceforovs",
        context => "/files/etc/sysconfig/network-scripts/ifcfg-$n1k_vsm::physicalinterfaceforovs",
        changes => [
          "set ONBOOT yes",
          "set BOOTPROTO none",
          "set TYPE OVSPort",
          "set DEVICETYPE ovs",
          "set OVS_BRIDGE $n1k_vsm::ovsbridge",
          "rm IPADDR",
          "rm NETMASK",
        ],
      }
      ->
      notify {"Augeas_modify_ifcfg-$n1k_vsm::physicalinterfaceforovs":
        message => "\n[INFO]\n Augeas_modify_ifcfg-$n1k_vsm::physicalinterfaceforovs \n name=$n1k_vsm::physicalinterfacefor \n context=/files/etc/sysconfig/network-scripts/ifcfg-$n1k_vsm::physicalinterfaceforovs\n",
      }

      $intf=$n1k_vsm::physicalinterfaceforovs
      $phy_bridge="/tmp/phy_bridge"
      #
      # Move physical port around from host bridge if any, to ovs bridge
      # I have not figured out how in Puppet world to pass environmental variable around
      # Pardon for nonelgenance 
      #
      exec {"Exec_rebridge_$intf":
        command => "/usr/sbin/brctl show | /bin/grep $intf | /bin/sed 's/[\t ].*//' > $phy_bridge; /usr/bin/test -s $phy_bridge && /usr/sbin/brctl delif \$(cat $phy_bridge) $intf || /bin/true; /usr/bin/ovs-vsctl -- --may-exist add-port $n1k_vsm::ovsbridge $intf; /bin/rm -f $phy_bridge",
        notify => Service["Service_network"],
      }
      ->
      notify {"Exec_rebridge_$intf":
        message => "\n[INFO]\n Exec_rebridge_$intf",
      }

      #
      # Order enforcement logic
      # 

      Notify["$Sync_Point_KVM"] -> Notify["$Sync_Point_Virsh_Network"] -> Package["Package_ebtables"] -> Package["Package_openvswitch"] -> Service["Service_openvswitch"] -> Exec["Exec_AddOvsBr"]->Augeas["Augeas_modify_ifcfg-$n1k_vsm::ovsbridge"]->Augeas["Augeas_modify_ifcfg-$n1k_vsm::physicalinterfaceforovs"]->Exec["Exec_rebridge_$intf"]

    }
    "Ubuntu": {
    }
    default: {
      #
      # bail out other than supported OS
      #
      fail("<Error>: os[$os] is not supported")
    }
  }
}

class n1k_vsm::ovsprep {
  #
  # The reason to prepare a reource table here
  # 1. For different OS, we can have different set of parameters
  # 2. Ideally, we should be able to loop through the the resource hash table
  #    to perform mechanical installation with iteration.. but it's not working 
  #    now
  $ovsprep_resource_table = {
     "RedHat" => {
       #
       # Package installation section
       #      
       # VSM dependency
       "Package_qemu-kvm-rhev" => {
         "title" => "Package_qemu-kvm-rhev",
         "name" =>  "qemu-kvm-rhev", 
         "ensure" => "installed",
       },
       "Package_virt-viewer" => {
         "title" => "Package_virt-viewer",
         "name" =>  "virt-viewer", 
         "ensure" => "installed",
       },
       "Package_virt-manager" => {
         "title" => "Package_virt-manager",
         "name" =>  "virt-manager",
         "ensure" => "installed",
       },
       "Package_libvirt" => {
         "title" => "Package_libvirt",
         "name" =>  "libvirt",
         "ensure" => "installed",
       },
       "Package_libvirt-python" => {
         "title" => "Package_libvirt-python",
         "name" =>  "libvirt-python",
         "ensure" => "installed",
       },
       "Package_python-virtinst" => {
         "title" => "Package_python-virtinst",
         "name" =>  "python-virtinst",
         "ensure" => "installed",
       },
       # OVS dependency
       "Package_openvswitch" => { 
         "title" => "Package_openvswitch",
         "name" => "openvswitch",
         "ensure" => "installed",
       },
       #
       # Package purge section 
       #
       "Package_ebtables" => { 
         "title" => "Package_ebtables",
         "name" => "ebtables",
         "ensure" => "purged",
       },

       # 
       # Exec section
       #
      'Exec_removenet' => {
          "title" => "Exec_removenet",
          "command" => "/usr/bin/virsh net-destroy default || /bin/true",
          "clause" => ["unless", "/usr/bin/virsh net-info default | grep -c 'Active: .* no'"],
       },

      'Exec_disableautostart' => {
          "title" => "Exec_disableautostart",
          "command" => "/usr/bin/virsh net-autostart --disable default || /bin/true",
          "clause" => ["unless", "/usr/bin/virsh net-info default | grep -c 'Autostart: .* no'"],
       },

      'Exec_AddOvsBr' => {
          "title" => "Exec_AddOvsBr",
          "command" => "/usr/bin/ovs-vsctl -- --may-exist add-br $n1k_vsm::ovsbridge",
       },
       #
       # Service Section
       #
       'Service_openvswitch' => {
         "title" => "Service_openvswitch",
         "name" => "openvswitch",
         "ensure" => "running",
         "enable" => "true",
       },
       'Service_network' => {
         "title" => "Service_network",
         "name" => "network",
         "ensure" => "running",
         "enable" => "true",
         "restart" => "/sbin/service network restart",
       },

       #
       # Interface infra structure modification section
       #
       'Augeas_physicalinterfaceforovs' => {
         "title" => "Augeas_physicalinterfaceforovs",
         name => "$n1k_vsm::physicalinterfaceforovs",
         context => "/etc/sysconfig/network-scripts/ifcfg-$n1k_vsm::physicalinterfaceforovs",
         changes => ["set DEVICE $n1k_vsm::ovsbridge",
                     "set DEVICETYPE ovs",
                     "set IPADDR $n1k_vsm::nodeip",
                     "set NETMASK $n1k_vsm::nodenetmask",
                     "set TYPE OVSBridge",
                     "set ONBOOT yes",
                     "set BOOTPROTO static",],
        },
  
    },
    # Ubuntu yet to come ...
  }

  # Definition of sync points
  
  $Sync_Point_KVM = "##SYNC_POINT_KVM"
  $Sync_Point_Virsh_Network = "##SYNC_POINT_VIRSH_NETWORK"

   

  $os = $::osfamily

  #
  # bail out other than supported OS
  #
  $rtab = $ovsprep_resource_table[$os]

  if $rtab == undef {
    fail("<Error>: os[$os] is not supported")
  }

  #
  # Order indepedent resources  
  #
  notify {"${rtab['Service_network']['title']}": 
    message => "\n[INFO]\n ${rtab['Service_network']['title']} \n name=${rtab['Service_network']['name']}\n ensure=${rtab['Service_network']['ensure']}\n enable=${rtab['Service_network']['enable']}\n restart=${rtab['Service_network']['restart']}",
  }

  service {"${rtab['Service_network']['title']}":
    name   => "${rtab['Service_network']['name']}",
    ensure => "${rtab['Service_network']['ensure']}",
    restart => "${rtab['Service_network']['restart']}",
    require => Notify["${rtab['Service_network']['title']}"],
  }

  # VSM dependent packages installation section
  #
  # Eng note
  # cwchang: Ideally we should have either of this logic
  # 1. Have an iteration thru the package list in the " $pkgs.each ...
  #    Somehow this syntax needs to turn on future parser by document
  # 2. package resource should be able to run a name list 
  # Neither one works. We go for rudimentary one-by-one here for now.
  # Pitfalls observed:
  # 1. We cannot reassign variables for some reason
  # 2. We cannot leave spaces in name

  notify {"${rtab['Package_qemu-kvm-rhev']['title']}": 
    message => "\n[INFO]\n ${rtab['Package_qemu-kvm-rhev']['title']} \n name=${rtab['Package_qemu-kvm-rhev']['name']} \n ensure=${rtab['Package_qemu-kvm-rhev']['ensure']} \n",
  }

  package {"${rtab['Package_qemu-kvm-rhev']['title']}":
    name   => "${rtab['Package_qemu-kvm-rhev']['name']}",
    ensure => "${rtab['Package_qemu-kvm-rhev']['ensure']}",
    require => Notify["${rtab['Package_qemu-kvm-rhev']['title']}"],
    before => Notify["$Sync_Point_KVM"],
  }

  notify {"${rtab['Package_virt-viewer']['title']}": 
    message => "\n[INFO]\n ${rtab['Package_virt-viewer']['title']} \n name=${rtab['Package_virt-viewer']['name']} \n ensure=${rtab['Package_virt-viewer']['ensure']} \n",
  }

  package {"${rtab['Package_virt-viewer']['title']}":
    name   => "${rtab['Package_virt-viewer']['name']}",
    ensure => "${rtab['Package_virt-viewer']['ensure']}",
    require => Notify["${rtab['Package_virt-viewer']['title']}"],
    before => Notify["$Sync_Point_KVM"],
  }

  notify {"${rtab['Package_virt-manager']['title']}": 
    message => "\n[INFO]\n ${rtab['Package_virt-manager']['title']} \n name=${rtab['Package_virt-manager']['name']} \n ensure=${rtab['Package_virt-manager']['ensure']} \n",
  }

  package {"${rtab['Package_virt-manager']['title']}":
    name   => "${rtab['Package_virt-manager']['name']}",
    ensure => "${rtab['Package_virt-manager']['ensure']}",
    require => Notify["${rtab['Package_virt-manager']['title']}"],
    before => Notify["$Sync_Point_KVM"],
  }

  notify {"${rtab['Package_libvirt']['title']}": 
    message => "\n[INFO]\n ${rtab['Package_libvirt']['title']} \n name=${rtab['Package_libvirt']['name']} \n ensure=${rtab['Package_libvirt']['ensure']} \n",
  }

  package {"${rtab['Package_libvirt']['title']}":
    name   => "${rtab['Package_libvirt']['name']}",
    ensure => "${rtab['Package_libvirt']['ensure']}",
    require => Notify["${rtab['Package_libvirt']['title']}"],
    before => Notify["$Sync_Point_KVM"],
  }

  notify {"${rtab['Package_libvirt-python']['title']}": 
    message => "\n[INFO]\n ${rtab['Package_libvirt-python']['title']} \n name=${rtab['Package_libvirt-python']['name']} \n ensure=${rtab['Package_libvirt-python']['ensure']} \n",
  }

  package {"${rtab['Package_libvirt-python']['title']}":
    name   => "${rtab['Package_libvirt-python']['name']}",
    ensure => "${rtab['Package_libvirt-python']['ensure']}",
    require => Notify["${rtab['Package_libvirt-python']['title']}"],
    before => Notify["$Sync_Point_KVM"],
  }

  notify {"${rtab['Package_python-virtinst']['title']}": 
    message => "\n[INFO]\n ${rtab['Package_python-virtinst']['title']} \n name=${rtab['Package_python-virtinst']['name']} \n ensure=${rtab['Package_python-virtinst']['ensure']} \n",
  }

  package {"${rtab['Package_python-virtinst']['title']}":
    name   => "${rtab['Package_python-virtinst']['name']}",
    ensure => "${rtab['Package_python-virtinst']['ensure']}",
    require => Notify["${rtab['Package_python-virtinst']['title']}"],
    before => Notify["$Sync_Point_KVM"],
  }

  notify{"$Sync_Point_KVM":}

  # Virsh network exec configuration section 

  notify {"${rtab['Exec_removenet']['title']}": 
    message => "\n[INFO]\n ${rtab['Exec_removenet']['title']} \n command=${rtab['Exec_removenet']['command']} \n clause=${rtab['Exec_removenet']['clause'][0]} ${rtab['Exec_removenet']['clause'][1]} \n",
  }

  case "${rtab['Exec_removenet']['clause'][0]}" {
    "unless": {
        exec {"${rtab['Exec_removenet']['title']}":
          command => "${rtab['Exec_removenet']['command']}",
          unless => "${rtab['Exec_removenet']['clause'][1]}",
          require => Notify["${rtab['Exec_removenet']['title']}"],
          before => Notify["$Sync_Point_Virsh_Network"],
        }
    }
  }

  notify {"${rtab['Exec_disableautostart']['title']}": 
    message => "\n[INFO]\n ${rtab['Exec_disableautostart']['title']} \n command=${rtab['Exec_disableautostart']['command']} \n clause=${rtab['Exec_disableautostart']['clause'][0]} ${rtab['Exec_disableautostart']['clause'][1]} \n",
  }

  case "${rtab['Exec_disableautostart']['clause'][0]}" {
    "unless": {
        exec {"${rtab['Exec_disableautostart']['title']}":
          command => "${rtab['Exec_disableautostart']['command']}",
          unless => "${rtab['Exec_disableautostart']['clause'][1]}",
          require => Notify["${rtab['Exec_disableautostart']['title']}"],
          before => Notify["$Sync_Point_Virsh_Network"],
        }
    }
  }
  
  notify{"$Sync_Point_Virsh_Network":}

  notify {"${rtab['Package_ebtables']['title']}": 
    message => "\n[INFO]\n ${rtab['Package_ebtables']['title']} \n name=${rtab['Package_ebtables']['name']} \n ensure=${rtab['Package_ebtables']['ensure']} \n",
  }

  package {"${rtab['Package_ebtables']['title']}":
    name   => "${rtab['Package_ebtables']['name']}",
    ensure => "${rtab['Package_ebtables']['ensure']}",
    require => Notify["${rtab['Package_ebtables']['title']}"],
  }

  notify {"${rtab['Package_openvswitch']['title']}": 
    message => "\n[INFO]\n ${rtab['Package_openvswitch']['title']} \n name=${rtab['Package_openvswitch']['name']} \n ensure=${rtab['Package_openvswitch']['ensure']} \n",
  }

  package {"${rtab['Package_openvswitch']['title']}":
    name   => "${rtab['Package_openvswitch']['name']}",
    ensure => "${rtab['Package_openvswitch']['ensure']}",
    require => Notify["${rtab['Package_openvswitch']['title']}"],
  }


  # 
  # bring up OVS and perform interface configuration 
  # 

  notify {"${rtab['Service_openvswitch']['title']}": 
    message => "\n[INFO]\n ${rtab['Service_openvswitch']['title']} \n name=${rtab['Service_openvswitch']['name']} \n ensure=${rtab['Service_openvswitch']['ensure']} \n enable={rtab['Service_openvswitch']['enable']}",
  }

  service {"${rtab['Service_openvswitch']['title']}":
    name   => "${rtab['Service_openvswitch']['name']}",
    ensure => "${rtab['Service_openvswitch']['ensure']}",
    enable => "${rtab['Service_openvswitch']['enable']}",
    require => Notify["${rtab['Service_openvswitch']['title']}"],
  }

  notify {"${rtab['Exec_AddOvsBr']['title']}": 
    message => "\n[INFO]\n ${rtab['Exec_AddOvsBr']['title']} \n command=${rtab['Exec_AddOvsBr']['command']}\n",
  }
  
  exec {"${rtab['Exec_AddOvsBr']['title']}":
    command => "${rtab['Exec_AddOvsBr']['command']}",
    require => Notify["${rtab['Exec_AddOvsBr']['title']}"],
  }

  #
  # order enforcement
  # 

  Notify["$Sync_Point_KVM"] -> Notify["$Sync_Point_Virsh_Network"] -> Package["${rtab['Package_ebtables']['title']}"] -> Package["${rtab['Package_openvswitch']['title']}"] -> Service["${rtab['Service_openvswitch']['title']}"] -> Exec["${rtab['Exec_AddOvsBr']['title']}"]
}

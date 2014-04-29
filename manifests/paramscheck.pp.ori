class n1k-vsm::paramscheck {
  include 'stdlib'

   #yikes! no for loop, cannot pass nested array as it flattens it
   $intf = [$n1k-vsm::ctrllinterface, $n1k-vsm::mgmtinterface, $n1k-vsm::pktinterface]
   
   define checkintf ($tap=undef, $mac=undef, $br=undef) {
      if $tap == undef or $mac == undef  or $br == undef {
         fail("Error: parameter for ${name} interface is not correct, fix definition in site.pp")
      }
      if !is_mac_address($mac) {
        fail("Error: mac address specified ${mac} for ${name} interface is not valid")
      }
      $intf = $::interfaces
      if inline_template("<%= intf.split(',').include?(br) %>") == "true" {
      } else {
        fail("Error: bridge ${br} specified for ${name} interface does not exist")
      }
   }
   checkintf { "control":
      tap => $n1k-vsm::ctrlinterface[0],
      mac => $n1k-vsm::ctrlinterface[1],
      br => $n1k-vsm::ctrlinterface[2]
   }
   checkintf { "management":
      tap => $n1k-vsm::mgmtinterface[0],
      mac => $n1k-vsm::mgmtinterface[1],
      br => $n1k-vsm::mgmtinterface[2]
   }
   checkintf { "packet":
      tap => $n1k-vsm::pktinterface[0],
      mac => $n1k-vsm::pktinterface[1],
      br => $n1k-vsm::pktinterface[2]
   }

}

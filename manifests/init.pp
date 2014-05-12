class n1k_vsm(
    $configureovs = false,
    $ovsbridge,
    $physicalinterfaceforovs = 'eth5',
    $nodeip,
    $nodenetmask,
    $nodegateway,
    $vsmname,
    $consolepts = 2,
    $isoimage,
    $role = 'standalone',
    $domainid,
    $adminpasswd,
    $mgmtip,
    $mgmtnetmask,
    $mgmtgateway,
    $ctrlinterface,
    $mgmtinterface,
    $pktinterface,
    $memory = 4096000,
    $vcpu = 2,
    $disksize = 4)
{

    $b = inline_template('<%= File.basename(isoimage) %>')
    $imgfile  = "/var/spool/vsm/$b"
    $diskfile = "/var/spool/vsm/${role}_disk"

    $Debug_Print = "/usr/bin/printf"
    $Debug_Log = "/tmp/n1kv_vsm_puppet.log"

    #
    # Clean up debug log
    #
    file {"File_$Debug_Log":
      path => $Debug_Log,
      ensure => "absent",
    }

    include n1k_vsm::pkgprep_ovscfg
    include n1k_vsm::vsmprep
    include n1k_vsm::deploy

    File["File_$Debug_Log"] -> Class['n1k_vsm::pkgprep_ovscfg'] -> Class['n1k_vsm::vsmprep'] -> Class['n1k_vsm::deploy']
}

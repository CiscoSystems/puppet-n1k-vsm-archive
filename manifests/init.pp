class n1k-vsm(
    $configureovs = false,
    $ovsbridge,
    $physicalinterfaceforovs,
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

    include n1k-vsm::ovsprep
    include n1k-vsm::repackiso
    include n1k-vsm::deploy

    Class['n1k-vsm::ovsprep'] -> Class['n1k-vsm::repackiso'] -> Class['n1k-vsm::deploy']
}

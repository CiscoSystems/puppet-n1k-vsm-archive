class vsm(
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
    $memory = 2048000,
    $vcpu = 1,
    $disksize = 4)
{


    $b = inline_template('<%= File.basename(isoimage) %>')
    $imgfile  = "/var/spool/vsm/$b"
    $diskfile = "/var/spool/vsm/${role}_disk"

    include vsm::ovsprep
    include vsm::repackiso
    include vsm::deploy

    Class['vsm::ovsprep'] -> Class['vsm::repackiso'] -> Class['vsm::deploy']
}

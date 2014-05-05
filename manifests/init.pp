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

    include n1k_vsm::pkgprep_ovscfg
    include n1k_vsm::vsmprep
    include n1k_vsm::deploy

    Class['n1k_vsm::pkgprep_ovscfg'] -> Class['n1k_vsm::vsmprep'] -> Class['n1k_vsm::deploy']
}

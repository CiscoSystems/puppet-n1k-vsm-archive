class n1k_vsm::vsmprep {
  include 'stdlib'
  
  $VSM_Bin_Prepare_Sync_Point="##VSM_BIN_PREPARE_SYNC_POINT"
  $VSM_Spool_Dir="/var/spool/vsm"
  $VSM_Repackage_Script_Name="repackiso.py"
  $VSM_Repackage_Script="/tmp/$VSM_Repackage_Script_Name"

  #
  # prepare vsm spool folder
  #
  file {"File_VSM_Spool_Dir":
    path => "$VSM_Spool_Dir",
    ensure => "directory",
    owner => "root",
    group => "root",
    mode  => "664",
  }
  ->
  exec {"Debug_File_VSM_Spool_Dir":
    command => "${n1k_vsm::Debug_Print} \"[INFO]\n File_VSM_Spool_Dir\n path=$VSM_SPOOL_DIR ensure=directory \n owner=root \n group=root \n mode=664 \n\" >> ${n1k_vsm::Debug_Log}",
  }


  #
  # VSM package source parsing logic
  #
  $source = $n1k_vsm::n1kv_source

  $source_method = regsubst($source, "^(.+):.*", '\1')
  $dest = inline_template('<%= File.basename(source) %>')

  $VSM_DEST = "$VSM_Spool_Dir/$dest"
  $VSM_ISO = "vsm.iso"

  case "$source_method" {
    "http": {
      yumrepo {"cisco-foreman":
        baseurl => "$n1k_vsm::n1kv_source",
        descr => "Internal repo for Foreman",
        enabled => "1",
        gpgcheck => "1",
        gpgkey => "$n1kv_source::n1kv_source/RPM-GPG-KEY",
        before => Notify["$VSM_Bin_Prepare_Sync_Point"],
      }
      ->
      exec {"Debug-http-cisco-os":
        command => "${n1k_vsm::Debug_Print} \"[INFO]\n Debug-http-cisco-os \n baseurl=$n1k_vsm::n1kv_source \n descr=>Internal repo for Foreman \n enabled = 1 \n gpgcheck=1 \n gpgkey => $n1kv_source::n1kv_source/RPM-GPG-KEY\n\" >> ${n1k_vsm::Debug_Log}",
      }
    }

    "ftp": {
      yumrepo {"cisco-foreman":
        baseurl => "$n1k_vsm::n1kv_source",
        descr => "Internal repo for Foreman",
        enabled => "1",
        gpgcheck => "1",
        gpgkey => "${n1kv_source}/RPM-GPG-KEY",
        before => Notify["$VSM_Bin_Prepare_Sync_Point"],
      }
      ->
      exec {"Debug-ftp-cisco-os":
        command => "${n1k_vsm::Debug_Print} \"[INFO]\n Debug-ftp-cisco-os \n baseurl=$n1k_vsm::n1kv_source \n descr=>Internal repo for Foreman \n enabled = 1 \n gpgcheck=1 \n gpgkey => $n1kv_source::n1kv_source/RPM-GPG-KEY\n\" >> ${n1k_vsm::Debug_Log}",
      }
    
    }
    "puppet": {
      #
      # copy vsm iso image from master to local storage 
      #
      file {"File_VSM_Bin_Prepare":
        path => "$VSM_DEST",
        ensure => "present",
        owner => "root",
        group => "root",
        mode  => "664",
        source => "$n1k_vsm::n1kv_source",
        before => Notify["$VSM_Bin_Prepare_Sync_Point"],
      }
      ->
      exec {"Debug_File_VSM_Bin_Prepare":
        command => "${n1k_vsm::Debug_Print} \"[INFO]\n Notify_VSM_ISO_NAME \n path=$VSM_DEST ensure=directory \n owner=root\n group=root\n mode=664\ni source=$n1k_vsm::n1kv_source\" >> ${n1k_vsm::Debug_Log}",
      }
    }
    default: {
      fail("<Error>: Unknown sourcing method [$source_method] is not supported")
    }
  }

  if "$source_method" != "puppet" {
    package {"Package_VSM":
      name => "nexus-1000v-iso-6.5",
      ensure => "${n1k_vsm::n1kv_version}",
      before => Notify["$VSM_Bin_Prepare_Sync_Point"],
    }
  }

  #
  # See if an RPM to ISO is needed
  #
  exec {"Exec_RPM_TO_ISO":
    #
    # To do: extract and/or copy the vsm.iso ...
    #
    command => "/bin/echo",
    unless => "/usr/bin/file $VSM_DEST | /bin/grep -c ' ISO '",
    before => Notify["$VSM_Bin_Prepare_Sync_Point"],
  }

  notify {"$VSM_Bin_Prepare_Sync_Point":}
      
  #
  # copy repackiso.py to local place
  #
  file {"File_VSM_Repackage_Script_Name":
    path => "$VSM_Repackage_Script",
    ensure => "present",
    owner => "root",
    group => "root",
    mode  => "774",
    source => "puppet:///modules/n1k_vsm/$VSM_Repackage_Script_Name",
  }
  ->
  exec {"Debug_File_VSM_Repackage_Script_Name":
    command => "${n1k_vsm::Debug_Print} \"[INFO]\n Notify_VSM_Repackage_Script_Name \n path=$VSM_Repackage_Script \n ensure=present \n owner=root \n group=root \n mode=774\n source=puppet:///modules/n1k_vsm/$VSM_REPACKAGE_SCRIPT_NAME \n\" >> ${n1k_vsm::Debug_Log}",
  }

  #
  # Now generate ovf xml file and repackage the iso
  #
  exec {"Exec_VSM_Repackage_Script_Name":
    command => "${VSM_Repackage_Script} -i$VSM_ISO -d${n1k_vsm::domainid} -n${n1k_vsm::vsmname} -m${n1k_vsm::mgmtip} -s${n1k_vsm::mgmtnetmask} -g${n1k_vsm::mgmtgateway} -p${n1k_vsm::adminpasswd} -r${n1k_vsm::role} -f${VSM_Spool_Dir}/${n1k_vsm::role}_repacked.iso",
  }
  ->
  exec {"Debug_Exec_VSM_Repackage_Script_Name":
    command => "${n1k_vsm::Debug_Print} \"[INFO]\n Exec_VSM_Repackage_Script_Name\n command=$VSM_Repackage_Script -i$VSM_ISO -d${n1k_vsm::domainid} -n${n1k_vsm::vsmname} -m${n1k_vsm::mgmtip} -s${n1k_vsm::mgmtnetmask} -g${n1k_vsm::mgmtgateway} -p${n1k_vsm::adminpasswd} -r${n1k_vsm::role} -f${VSM_Spool_Dir}/${n1k_vsm::role}_repacked.iso \n\" >> ${n1k_vsm::Debug_Log}"
  }

  File["File_VSM_Spool_Dir"]-> Notify["$VSM_Bin_Prepare_Sync_Point"]->File["File_VSM_Repackage_Script_Name"]->Exec["Exec_VSM_Repackage_Script_Name"]

}

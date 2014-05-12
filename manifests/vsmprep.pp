class n1k_vsm::vsmprep {
  
  $VSM_ISO_DIR="/var/spool/vsm"

  #
  # prepare vsm spool folder
  #
  file {"File_VSM_ISO_DIR":
    path => "$VSM_ISO_DIR",
    ensure => "directory",
    owner => "root",
    group => "root",
    mode  => "664",
  }
  ->
  exec {"Debug_File_VSM_ISO_DIR":
    command => "${n1k_vsm::Debug_Print} \"[INFO]\n File_VSM_ISO_DIR\n path=$VSM_VSM_DIR ensure=directory \n owner=root \n group=root \n mode=664 \n\" >> ${n1k_vsm::Debug_Log}",
  }

  #
  # copy vsm image to local storage 
  #
  # call it vsm.iso for now...
  $VSM_ISO_NAME=$n1k_vsm::isoimage
  $VSM_ISO="$VSM_ISO_DIR/$VSM_ISO_NAME"

  file {"File_VSM_ISO_NAME":
    path => "$VSM_ISO",
    ensure => "present",
    owner => "root",
    group => "root",
    mode  => "664",
    source => "puppet:///modules/n1k_vsm/$VSM_ISO_NAME",
  }
  ->
  exec {"Debug_File_VSM_ISO_NAME":
    command => "${n1k_vsm::Debug_Print} \"[INFO]\n Notify_VSM_ISO_NAME \n path=$VSM_ISO_DIR ensure=directory \n owner=root\n group=root\n mode=664\n\" >> ${n1k_vsm::Debug_Log}",
  }


  $VSM_REPACKAGE_SCRIPT_NAME="repackiso.py"
  $VSM_REPACKAGE_SCRIPT="/tmp/$VSM_REPACKAGE_SCRIPT_NAME"
  
  #
  # copy repackiso.py to local place
  #
  file {"File_VSM_REPACKAGE_SCRIPT_NAME":
    path => "$VSM_REPACKAGE_SCRIPT",
    ensure => "present",
    owner => "root",
    group => "root",
    mode  => "774",
    source => "puppet:///modules/n1k_vsm/$VSM_REPACKAGE_SCRIPT_NAME",
  }
  ->
  exec {"Debug_File_VSM_REPACKAGE_SCRIPT_NAME":
    command => "${n1k_vsm::Debug_Print} \"[INFO]\n Notify_VSM_REPACKAGE_SCRIPT_NAME \n path=$VSM_REPACKAGE_SCRIPT \n ensure=present \n owner=root \n group=root \n mode=774\n source=puppet:///modules/n1k_vsm/$VSM_REPACKAGE_SCRIPT_NAME \n\" >> ${n1k_vsm::Debug_Log}",
  }

  #
  # Now generate ovf xml file and repackage the iso
  #
  exec {"Exec_VSM_REPACKAGE_SCRIPT_NAME":
    command => "${VSM_REPACKAGE_SCRIPT} -i$VSM_ISO -d${n1k_vsm::domainid} -n${n1k_vsm::vsmname} -m${n1k_vsm::mgmtip} -s${n1k_vsm::mgmtnetmask} -g${n1k_vsm::mgmtgateway} -p${n1k_vsm::adminpasswd} -r${n1k_vsm::role} -f${VSM_ISO_DIR}/${n1k_vsm::role}_repacked.iso > /tmp/FOO ",
  }
  ->
  exec {"Debug_Exec_VSM_REPACKAGE_SCRIPT_NAME":
    command => "${n1k_vsm::Debug_Print} \"[INFO]\n Exec_VSM_REPACKAGE_SCRIPT_NAME\n command=$VSM_REPACKAGE_SCRIPT -i$VSM_ISO -d${n1k_vsm::domainid} -n${n1k_vsm::vsmname} -m${n1k_vsm::mgmtip} -s${n1k_vsm::mgmtnetmask} -g${n1k_vsm::mgmtgateway} -p${n1k_vsm::adminpasswd} -r${n1k_vsm::role} -f${VSM_ISO_DIR}/${n1k_vsm::role}_repacked.iso \n\" >> ${n1k_vsm::Debug_Log}"
  }

  File["File_VSM_ISO_DIR"]-> File["File_VSM_ISO_NAME"]->File["File_VSM_REPACKAGE_SCRIPT_NAME"]->Exec["Exec_VSM_REPACKAGE_SCRIPT_NAME"]

}

<domain type='kvm'>
  <name>vsm</name>
  <uuid>85badf15-1234-4819-1234-8c3d50641375</uuid>
  <memory unit='KiB'>4096000</memory>
  <currentMemory unit='KiB'>2048000</currentMemory>
  <vcpu placement='static'>1</vcpu>
  <os>
    <type arch='x86_64' machine='rhel6.5.0'>hvm</type>
    <boot dev='cdrom'/>
    <boot dev='hd'/>
  </os>
  <features>
    <acpi/>
    <apic/>
    <pae/>
  </features>
  <clock offset='localtime'/>
  <on_poweroff>destroy</on_poweroff>
  <on_reboot>restart</on_reboot>
  <on_crash>restart</on_crash>
  <devices>
    <emulator>/usr/libexec/qemu-kvm</emulator>
    <disk type='file' device='disk'>
      <driver name='qemu' type='raw'/>
      <source file='/var/lib/libvirt/images/vsm.img'/>
      <target dev='hda' bus='ide'/>
      <address type='drive' controller='0' bus='0' target='0' unit='0'/>
    </disk>
    <disk type='file' device='cdrom'>
      <driver name='qemu' type='raw'/>
      <source file='/tmp/vsm.iso'/>
      <target dev='hdb' bus='ide'/>
      <readonly/>
      <address type='drive' controller='0' bus='0' target='0' unit='1'/>
    </disk>
    <controller type='usb' index='0'>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x01' function='0x2'/>
    </controller>
    <controller type='ide' index='0'>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x01' function='0x1'/>
    </controller>
    <interface type='bridge'>
      <mac address='0e:1f:1f:1f:45:2e'/>
      <source bridge='vsm-br'/>
      <virtualport type='openvswitch'>
        <parameters interfaceid='f41f1f99-dbed-9c7a-ea7e-dd959feef33d'/>
      </virtualport>
      <target dev='vsm-vnet0'/>
      <model type='e1000'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x05' function='0x0'/>
    </interface>
    <interface type='bridge'>
      <mac address='0e:23:32:23:45:3e'/>
      <source bridge='vsm-br'/>
      <virtualport type='openvswitch'>
        <parameters interfaceid='53a75044-f071-35bd-4464-d5c03e3f1935'/>
      </virtualport>
      <target dev='vsm-vnet1'/>
      <model type='e1000'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x06' function='0x0'/>
    </interface>
    <interface type='bridge'>
      <mac address='0e:1f:cd:cd:45:4e'/>
      <source bridge='vsm-br'/>
      <virtualport type='openvswitch'>
        <parameters interfaceid='a05af3aa-33e5-a2a9-1e08-4e8a4ea051de'/>
      </virtualport>
      <target dev='vsm-vnet2'/>
      <model type='e1000'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x07' function='0x0'/>
    </interface>
    <input type='mouse' bus='ps2'/>
    <graphics type='vnc' port='-1' autoport='yes' listen='0.0.0.0' keymap='en-us'>
      <listen type='address' address='0.0.0.0'/>
    </graphics>
    <video>
      <model type='cirrus' vram='9216' heads='1'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x02' function='0x0'/>
    </video>
    <memballoon model='virtio'>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x04' function='0x0'/>
    </memballoon>
  </devices>
  <seclabel type='none' model='selinux'/>
</domain>

require "puppet"

Puppet::Type.type(:tapint).provide(:tapmgmt) do
    desc "tap interface support"

    commands :tapcmd => "/usr/sbin/tunctl"
    commands :brcmd => "/usr/bin/ovs-vsctl"
    commands :ip => "/sbin/ip"
    commands :ovsctl => "/usr/bin/ovs-vsctl"
    commands :ifconf => "/sbin/ifconfig"

    def create
        tapcmd "-t", resource[:name]
        ifconf(resource[:name], "up")
        brcmd "add-port", resource[:bridge], resource[:name]
    end

    def destroy
        tapcmd "-d", resource[:name]
    end

    def exists?
        #ip('link', 'list').include? "resource[:name]:"
        #ip('link', 'list', resource[:name])
        ovsctl("list-ifaces", resource[:bridge]).include? resource[:name]
    rescue Puppet::ExecutionFailure
       return false
    end
end

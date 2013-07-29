require "puppet"

module Puppet
  Puppet::Type.newtype(:tapint) do
      @doc = "Manage tap interfaces"

      ensurable

      newparam(:name) do
        desc "The interface name"
        isnamevar
      end

      newparam(:bridge) do
       desc "The bridge name"
       #validate do |value|
       #end
      end
  end
end


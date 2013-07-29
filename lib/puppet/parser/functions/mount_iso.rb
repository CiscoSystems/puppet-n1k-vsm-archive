require "open3"
require "tmpdir"

module Puppet::Parser::Functions
  newfunction(:openiso, :type => :rvalue, :doc => <<-EOS
    Loop mounts a iso on temporary  mount point, copies contents to another temp dir and returns the
    destination temp dir 
    EOS
  ) do |args|

    raise(Puppet::ParseError, "mountiso(): Wrong number of arguments " +
      "given (#{args.size} for 1)") if args.size != 1

    $tmpmount = Dir.mktmpdir('vsm')
    $destdir = Dir.mktmpdir('vsm')
    stdin, stdout, stderr = Open3.popen3("mount -o loop #{args[0]} #{tmpmount}")
    
    stdin, stdout, stderr = Open3.popen3("cp -r #{tmpmount}/* #{destdir}/")

    stdin, stdout, stderr = Open3.popen3("umount #{tmpmount}")

    return $destdir 
  end
end

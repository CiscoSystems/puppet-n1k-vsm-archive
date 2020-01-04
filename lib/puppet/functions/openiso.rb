# This is an autogenerated function, ported from the original legacy version.
# It /should work/ as is, but will not have all the benefits of the modern
# function API. You should see the function docs to learn how to add function
# signatures for type safety and to document this function using puppet-strings.
#
# https://puppet.com/docs/puppet/latest/custom_functions_ruby.html
#
# ---- original file header ----
require "open3"
require "tmpdir"

# ---- original file header ----
#
# @summary
#       Loop mounts a iso on temporary  mount point, copies contents to another temp dir and returns the
#    destination temp dir 
#
#
Puppet::Functions.create_function(:'openiso') do
  # @param args
  #   The original array of arguments. Port this to individually managed params
  #   to get the full benefit of the modern function API.
  #
  # @return [Data type]
  #   Describe what the function returns here
  #
  dispatch :default_impl do
    # Call the method named 'default_impl' when this is matched
    # Port this to match individual params for better type safety
    repeated_param 'Any', :args
  end


  def default_impl(*args)
    

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

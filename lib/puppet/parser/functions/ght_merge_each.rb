module Puppet::Parser::Functions
  newfunction(:ght_merge_each, :type => :rvalue) do |args|
    enumerable = args[0]
    prefix = args[1] if args[1]

    result = enumerable.collect do |i|
      function_merge([i,prefix])
    end

    return result
  end
end

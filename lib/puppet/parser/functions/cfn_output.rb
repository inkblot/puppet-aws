require 'aws_puppet'
require 'fog'
require 'json'

module Puppet::Parser::Functions

	newfunction(:cfn_output, :type => :rvalue) do |args|
		stack_name = args[0]
		output_key = args[1]
		if AWSPuppet.cf
			AWSPuppet.cfn_output(stack_name, output_key)
		end
	end

end

require 'aws_puppet'
require 'fog'
require 'json'

module Puppet::Parser::Functions

	newfunction(:cfn_output, :type => :rvalue) do |args|
		stack_name = args[0]
		output_key = args[1]
		if AWSPuppet.cf
			AWSPuppet.cf.describe_stacks({
				'StackName' => stack_name
			}).body['Stacks'].first { |stack| stack['StackName'] == stack_name }['Outputs'].first { |output| output['OutputKey'] == output_key }['OutputValue']
		end
	end

end

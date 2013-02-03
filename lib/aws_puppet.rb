# ex:ts=2 sw=2 tw=72

require 'puppet'
require 'fog'

module AWSPuppet
	module_function

	def cfn_status(stack_name)
		cfn_stack(stack_name)['StackStatus']
	end

	def cfn_output(stack_name, output_key)
		cfn_stack(stack_name)['Outputs'].select { |output| output['OutputKey'] == output_key }['OutputValue']
	end

	def cfn_stack(name)
		cf.describe_stacks({
			'StackName' => name
		}).body['Stacks'].select { |stack| stack['StackName'] == name }.first
	end

	def cf
		@cf ||= CloudFormation.new(
			:aws_access_key_id => aws_access_key_id,
			:aws_secret_access_key => aws_secret_key
		)
	end

	def aws_access_key_id
		aws_config['aws_access_key_id']
	end

	def aws_secret_key
		aws_config['aws_secret_key']
	end

	def aws_config
		if config_file = aws_config_file
			YAML::load(File.open(config_file))
		else
			{}
		end
	end

	def aws_config_file
		expanded_config_file = nil
		if Puppet.settings[:aws_config].is_a?(String)
			expanded_config_file = File.expand_path(Puppet.settings[:aws_config])
		elsif Puppet.settings[:confdir].is_a?(String)
			expanded_config_file = File.expand_path(File.join(Puppet.settings[:confdir], 'aws.yaml'))
		end
		if expanded_config_file and File.exist?(expanded_config_file)
			expanded_config_file
		else
			nil
		end
	end

end

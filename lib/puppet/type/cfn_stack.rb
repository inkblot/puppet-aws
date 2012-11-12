# ex:ts=2 sw=2 tw=72

Puppet::Type.newtype(:cfn_stack) do

	desc <<-EOT
		Ensures that a specified AWS CloudFormation Stack is in the desired state.
	EOT

	ensurable

	newparam(:name, :namevar => true) do
		desc 'An arbitrary name for the CloudFormation stack.'
	end

	newparam(:template_file) do
		desc 'A file resource for a CloudFormation template.'
	end

	newparam(:template_url) do
		desc 'The URL of a CloudFormation template.'
	end

	newparam(:parameters) do
		desc 'A hash of parameters to use with the template.'
	end

	newparam(:aws_access_key_id) do
		desc 'The AWS Access Key Id to use for authentication with AWS.'
	end

	newparam(:aws_secret_access_key) do
		desc 'The AWS Secret Key that corresponds to the AWS Access Key Id.'
	end

	validate do
		if self[:template_file] and self[:template_url]
			raise(Puppet::Error, 'Only one of template_file or template_url may be specified')
		end
		unless self[:template_file] or self[:template_url]
			raise(Puppet::Error, 'One of template_file or template_url must be specified.')
		end
		unless self[:aws_access_key_id] and self[:aws_secret_access_key]
			raise(Puppet::Error, 'aws_access_key_id and aws_secret_access_key are required.')
		end
	end

	def refresh
		provider.update
	end
end

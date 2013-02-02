# ex:ts=2 sw=2 tw=72

require 'aws_puppet'

Puppet::Type.newtype(:cfn_stack) do

	desc <<-EOT
		Ensures that a specified AWS CloudFormation Stack is in the desired state.
	EOT

	ensurable do
		newvalue :present do
			provider.create
		end

		newvalue :latest do
			provider.latest
		end

		newvalue :absent do
			provider.destroy
		end

		def insync?(is)
			case should
				when :present
					if [ :latest, :present ].include?(is)
						true
					else
						false
					end
				else
					is == should
			end
		end

		def retrieve
			if provider.exists?
				if provider.latest?
					:latest
				else
					:present
				end
			else
				:absent
			end
		end
	end

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

	validate do
		if self[:template_file] and self[:template_url]
			raise(Puppet::Error, 'Only one of template_file or template_url may be specified')
		end
		unless self[:template_file] or self[:template_url]
			raise(Puppet::Error, 'One of template_file or template_url must be specified.')
		end
	end

	def refresh
		provider.update
	end
end

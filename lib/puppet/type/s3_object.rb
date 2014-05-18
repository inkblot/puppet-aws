# ex:ts=2 sw=2 tw=72

Puppet::Type.newtype(:s3_object) do

	desc <<-EOT
		Ensure that an object in an S3 bucket exists (or doesn't) with
correct content.
	EOT

	ensurable do
		newvalue :present do
			provider.create
		end

		newvalue :latest do
			provider.create
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
		desc 'The S3 URL of an object to be managed'
	end

  newparam(:access_key) do
		desc 'AWS access key'
	end

	newparam(:secret_key) do
		desc 'AWS secret key'
	end

	newparam(:acl) do
		desc 'Access control policy'
		defaultto :private
	end

	newparam(:source) do
		desc 'File path from which to get the object\'s content'
	end
end

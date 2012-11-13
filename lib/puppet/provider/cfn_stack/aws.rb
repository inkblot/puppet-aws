# ex:ts=2 sw=2 tw=72

require 'fog'
require 'digest/md5'

include Fog::AWS

Puppet::Type.type(:cfn_stack).provide(:aws) do

	def exists?
		!cf.describe_stacks.body['Stacks'].index { |stack| stack['StackName'] == @resource[:name] }.nil?
	end

	def latest?
		template_hash == deployed_template_hash
	end

	def create
		cf.create_stack(@resource[:name], get_options)
	end

	def latest
		if exists?
			update
		else
			create
		end
	end

	def update
		cf.update_stack(@resource[:name], get_options)
	end

	def destroy
		cf.delete_stack(@resource[:name])
	end

	private
	def cf
		CloudFormation.new(:aws_access_key_id => @resource[:aws_access_key_id], :aws_secret_access_key => @resource[:aws_secret_access_key])
	end

	def get_options
		options = {}
		if @resource[:template_file]
			options['TemplateBody'] = IO.read(@resource[:template_file])
		elsif @resource[:template_url]
			options['TemplateURL'] = @resource[:template_url]
		end
		if @resource[:parameters]
			options['Parameters'] = @resource[:parameters]
		end
		options
	end

	def deployed_template_hash
		if @resource[:template_file]
			Digest::MD5.hexdigest(cf.get_template(@resource[:name]).body['TemplateBody'])
		else
			''
		end
	end

	def template_hash
		if @resource[:template_file]
			Digest::MD5.hexdigest(IO.read(@resource[:template_file]))
		else
			''
		end
	end

end

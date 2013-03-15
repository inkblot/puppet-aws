# ex:ts=2 sw=2 tw=72

require 'aws_puppet'
require 'fog'
require 'digest/md5'

include Fog::AWS

Puppet::Type.type(:cfn_stack).provide(:aws) do

	def exists?
		!AWSPuppet.cf.describe_stacks.body['Stacks'].index { |stack| stack['StackName'] == @resource[:name] }.nil?
	end

	def latest?
		template_hash == deployed_template_hash
	end

	def create
		AWSPuppet.cf.create_stack(@resource[:name], get_options)
		interval = 10
		begin
			sleep(interval)
			interval = ((interval * 13).round / 10) % 60
		end while !exists? or AWSPuppet.cfn_status(@resource[:name]).end_with?('_IN_PROGRESS')
		if AWSPuppet.cfn_status(@resource[:name]) != 'CREATE_COMPLETE'
			destroy
			raise(Puppet::Error, 'Failed to create stack')
		end
	end

	def latest
		if exists?
			update
		else
			create
		end
	end

	def update
		AWSPuppet.cf.update_stack(@resource[:name], get_options)
		interval = 10
		begin
			sleep(interval)
			interval = ((interval * 13).round / 10) % 60
		end while AWSPuppet.cfn_status(@resource[:name]).end_with?('_IN_PROGRESS')
		if AWSPuppet.cfn_status(@resource[:name]) != 'UPDATE_COMPLETE'
			destroy
			raise(Puppet::Error, 'Failed to update stack')
		end
	end

	def destroy
		AWSPuppet.cf.delete_stack(@resource[:name])
		interval = 10
		begin
			sleep(interval)
			interval = ((interval * 13).round / 10) % 60
		end while exists?
	end

	private
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
			Digest::MD5.hexdigest(AWSPuppet.cf.get_template(@resource[:name]).body['TemplateBody'])
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

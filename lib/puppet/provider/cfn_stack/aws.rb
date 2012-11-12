# ex:ts=2 sw=2 tw=72

require 'fog'

include Fog::AWS

Puppet::Type.type(:cfn_stack).provide(:aws) do

	def exists?
		!cf.describe_stacks.body['Stacks'].index { |stack| stack['StackName'] == @resource[:name] }.nil?
	end

	def create
		options = {}
		if @resource[:template_file]
			options['TemplateBody'] = IO.read(@resource[:template_file])
		elsif @resource[:template_url]
			options['TemplateURL'] = @resource[:template_url]
		end
		if @resource[:parameters]
			options['Parameters'] = @resource[:parameters]
		end
		cf.create_stack(@resource[:name], options)
	end

	def update
		info "Want to update stack #{@resource[:name]}"
	end

	def destroy
		cf.delete_stack(@resource[:name])
	end

	private
	def cf
		CloudFormation.new(:aws_access_key_id => @resource[:aws_access_key_id], :aws_secret_access_key => @resource[:aws_secret_access_key])
	end

end

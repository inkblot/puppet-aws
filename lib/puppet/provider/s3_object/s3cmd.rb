# ex:ts=2 sw=2 tw=72

require 'tempfile'
require 'digest/md5'

Puppet::Type.type(:s3_object).provide(:s3cmd) do
  commands :s3cmd => 's3cmd'

	def initialize(value={})
		super(value)
		@properties = {}
	end

  def exists?
    !query.empty?
  end

  def latest?
    current_md5 == latest_md5
  end

  def create
		with_config do |config|
			s3cmd('put', '--config', config, acl_option, @resource[:source], @resource[:name])
		end
  end

  def destroy
    with_config do |config|
			s3cmd('del', '--config', config, @resource[:name])
		end
  end

  private

	def acl_option
		case @resource[:acl]
			when :public
				'--acl-public'
			when :private
				'--acl-private'
		end
  end

	def latest_md5
		Digest::MD5.hexdigest(IO.read(@resource[:source]))
	end

	def current_md5
		query[:md5]
	end

  def query
		unless @query
    	@query = with_config do |config|
				s3cmd('ls', '--config', config, '--list-md5', @resource[:name])
	    end.lines.map do |line|
				linearray = line.chomp.split(/\s+/, 5)
				{
					:name => linearray[4],
					:md5  => linearray[3]
				}
			end.select do |object|
				object[:name] == @resource[:name]
			end.first
		end
		@query
  end

  def with_config(&block)
    config = Tempfile.new('s3cfg-')
    config.write "access_key = #{@resource[:access_key]}\n"
    config.write "secret_key = #{@resource[:secret_key]}\n"
		config.close
		stuff = yield config.path
		config.unlink		
		stuff
  end
end

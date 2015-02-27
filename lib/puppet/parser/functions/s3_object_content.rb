# ex: syntax=ruby sw=2 ts=2 si et
require 'aws-sdk-v1'

module Puppet::Parser::Functions

  newfunction(:s3_object_content, :type => :rvalue) do |args|
    bucket = args[0]
    key = args[1]
    region = args[2] || 'us-east-1'

    c = AWS::S3::Client.new(:region => region)
    r = c.get_object(:bucket_name => bucket, :key => key)
    if r.successful?
      r.data[:data]
    else
      raise Puppet::Error "Could not read S3 object content"
    end
  end
end

# ex: syntax=ruby sw=2 ts=2 si et

require 'aws/cloud_formation'

module Puppet::Parser::Functions

  newfunction(:cfn_output, :type => :rvalue) do |args|
    stack_name = args[0]
    output_key = args[1]
    region = args[2] || 'us-east-1'
    c = AWS::CloudFormation.new(:region => region)
    s = c.stacks[stack_name]
    if s.exists?
      s.outputs.detect { |o| o.key === output_key }.value
    end
  end

end

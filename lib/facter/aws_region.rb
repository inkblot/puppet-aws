# ex: syntax=ruby ts=2 sw=2 si et
require 'facter'

Facter.add(:aws_region) do
  confine :ec2_metadata do |meta|
    Facter.debug("Attempting aws_region confinement using ec2_metadata=#{meta.inspect}")
    !meta.nil?
  end

  setcode do
    az = Facter.value(:ec2_metadata)['placement']['availability-zone']
    Facter.debug("Availability zone: #{az}")
    /(?<region>[a-z]+-[a-z]+-[0-9])[a-z]/ =~ az
    region
  end
end

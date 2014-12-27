# ex: syntax=ruby ts=2 sw=2 si et
require 'facter'

if Facter.value(:ec2_placement_availability_zone)
  Facter.add(:aws_region) do
    setcode do
      /(?<region>[a-z]+-[a-z]+-[0-9])[a-z]/ =~ Facter.value(:ec2_placement_availability_zone)
      region
    end
  end
end 

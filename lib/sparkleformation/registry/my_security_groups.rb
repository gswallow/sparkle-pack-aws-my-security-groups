require 'aws-sdk-core'

my_vpc = ::String.new
my_security_groups = ::Array.new
ec2 = ::Aws::EC2::Client.new

ec2.describe_vpcs.vpcs.each do |vpc|
  if !vpc.tags.keep_if{ |tag| tag.key.capitalize == "Environment" && tag.value == ENV['environment'] }.empty?
    my_vpc = vpc.vpc_id
  end
end

if my_vpc.empty?
  my_vpc = ec2.describe_vpcs.vpcs.collect { |vpc| vpc.vpc_id if vpc.is_default }.compact.first
end

my_security_groups = ec2.describe_security_groups.security_groups.collect { |sg| sg if sg.vpc_id == my_vpc }.compact

SfnRegistry.register(:all_security_group_ids) do
  my_security_groups.map(&:group_id)
end

SfnRegistry.register(:my_security_group_id) do |filter = ENV['sg']|
  my_security_groups.collect do |sg|
    sg.group_id if !sg.tags.find_index do |tag|
      tag.key == "Name" && tag.value == filter
    end.nil?
  end.compact.first
end

# Apaprently I use these
SfnRegistry.register(:all_security_group_names) do
  my_security_groups.map(&:group_name)
end

SfnRegistry.register(:my_security_group_name) do |filter = ENV['sg']|
  my_security_groups.collect do |sg|
    sg.group_name if !sg.tags.find_index do |tag|
      tag.key == "Name" && tag.value == filter
    end.nil?
  end.compact.first
end

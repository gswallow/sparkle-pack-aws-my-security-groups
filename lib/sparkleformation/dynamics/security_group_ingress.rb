# Use this dynamic to provide access between VPC security groups.
# For ingress rules governing access from CIDR blocks, specify ingress
# rules while creating a vpc_security_group object.

SparkleFormation.dynamic(:security_group_ingress) do |name, options={}|

  dynamic!(:ec2_security_group_ingress, name.gsub('-','_').to_sym).properties do
    source_security_group_id attr!(options[:source_sg], 'GroupId')
    ip_protocol options[:ip_protocol]
    from_port options[:from_port]
    to_port options[:to_port]
    group_id attr!(options[:target_sg], 'GroupId')
  end
end

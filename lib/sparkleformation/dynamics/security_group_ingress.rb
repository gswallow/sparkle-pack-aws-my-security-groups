SparkleFormation.dynamic(:security_group_ingress) do |name, options={}|

  dynamic!(:ec2_security_group_ingress, "#{name}_ingress".gsub('-','_').to_sym).properties do
    source_security_group_id attr!(options[:source_sg], 'GroupId')
    ip_protocol options[:ip_protocol]
    from_port options[:from_port]
    to_port options[:to_port]
    group_id attr!(options[:target_sg], 'GroupId')
  end
end

SparkleFormation.dynamic(:sg_ingress) do |_name, _config={}|

  resources("#{_name}_ingress".gsub('-','_').to_sym) do
    type 'AWS::EC2::SecurityGroupIngress'
    properties do
      source_security_group_id attr!(_config[:source_sg], 'GroupId')
      ip_protocol _config[:ip_protocol]
      from_port _config[:from_port]
      to_port _config[:to_port]
      group_id attr!(_config[:target_sg], 'GroupId')
    end
  end
end
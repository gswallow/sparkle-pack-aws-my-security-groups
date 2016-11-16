SparkleFormation.dynamic(:vpc_security_group) do |name, config|

  # {
  #   "Type" : "AWS::EC2::SecurityGroup",
  #   "Properties" : {
  #     "GroupDescription" : String,
  #     "SecurityGroupEgress" : [ Security Group Rule, ... ],
  #     "SecurityGroupIngress" : [ Security Group Rule, ... ],
  #     "Tags" :  [ Resource Tag, ... ],
  #     "VpcId" : String
  #   }
  # }

  # _config[:allow_icmp] allows inbound ICMP messages and echo replies
  # _config[:ingress_rules] and _config[:egress_rules] are arrays of hashes:
  #
  # [{ :cidr_ip => '0.0.0.0/0', ip_protocol => 'tcp', :from_port => '22', :to_port => '22' }]

  ingress_rules = ::Array.new
  ingress_rules.concat registry!(:inbound_icmp) if config.fetch(:allow_icmp, false)
  ingress_rules.concat config[:ingress_rules] if config.has_key?(:ingress_rules)

  egress_rules = ::Array.new
  egress_rules.concat config[:egress_rules] if config.has_key?(:egress_rules)

  dynamic!(:ec2_security_group, name.gsub('-', '_').to_sym).properties do
    group_description "#{name} security group"
    vpc_id ref!(:vpc)
    security_group_ingress array!(
                             *ingress_rules.map { |r| -> {
                               cidr_ip r[:cidr_ip]
                               ip_protocol r[:ip_protocol]
                               from_port r[:from_port]
                               to_port r[:to_port]
                             }}
                           )
    security_group_egress array!(
                             *egress_rules.map { |r| -> {
                               cidr_ip r[:cidr_ip]
                               ip_protocol r[:ip_protocol]
                               from_port r[:from_port]
                               to_port r[:to_port]
                             }}
                           )
    tags _array(
           -> {
             key 'Name'
             value "#{name}_sg".gsub('-','_').to_sym
           },
           -> {
             key 'Environment'
             value ENV['environment']
           }
         )
  end

  # Default rule for local (w/in security group) traffic.
  dynamic!(:ec2_security_group_ingress, "#{name}_local".gsub('-', '_').to_sym).properties do
    source_security_group_id attr!("#{name}_ec2_security_group".gsub('-','_').to_sym, :group_id)
    ip_protocol '-1'
    from_port '-1'
    to_port '-1'
    group_id attr!("#{name}_ec2_security_group".gsub('-','_').to_sym, :group_id)
  end
end

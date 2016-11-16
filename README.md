# sparkle-pack-aws-my-security-groups
SparklePack to auto-detect and create security groups within a certain VPC.
We identify AWS resources by tags.

h/t to [techshell](https://github.com/techshell) for this approach.

## Tags

- Everything that gets created on AWS has an `Environment` tag.
  - These tags generally match Chef environments, or "stacks."
- In order to use this Sparkle Pack, you must assign an `Environment` tag
to your VPC.
- Assign a `Name` tag, as well as an `Environment` tag, to each VPC you create.

## Environment variables

The following environment variables must be set in order to use this Sparkle
Pack:

- AWS_REGION
- AWS_DEFAULT_REGION (being deprecated?)
- AWS_ACCESS_KEY_ID
- AWS_SECRET_ACCESS_KEY
- AWS_CUSTOMER_ID (optional)
- environment

### Use Cases

This SparklePack adds registry entries that use the AWS SDK to detect security
groups within your VPC (based on `ENV['AWS_REGION']` and `ENV['environment']`).
By default, it will return whichever security group's `Name` tag matches
`ENV['sg']`, though you can specify a filter when calling the registry.  See 
below.

It also adds two dynamics: `vpc_security_group` and `security_group_ingress`, 
which can be called from other templates to add new security groups, or to add
ingress rules to existing security groups in a VPC.

## Usage 

Add the pack to your Gemfile and .sfn:

Gemfile: 
```ruby
source 'https://rubygems.org'
gem 'sfn' 
gem 'sparkle-pack-aws-aws-my-security-groups'
```

.sfn:
```ruby
Configuration.new do
  sparkle_pack [ 'sparkle-pack-aws-my-security-groups' ] ...
end
```

### Registries

In a SparkleFormation Template/Component/Dynamic:
```ruby
security_group = registry!(:my_security_group_id, 'filter')
```

The `my_security_group_id` registry will return a Subnet ID.  There is also
a `my_security_group_name` registry.

```ruby
security_groups = registry!(:all_security_group_ids)
```

The `all_security_group_ids` registry will return an array of all security
groups in the VPC.  There is also an `all_security_group_names` registry.

### Dynamics
```ruby
dynamic!(:vpc_security_group, 'web',
                              :ingress_rules => 
                                [ 
                                  { :cidr_ip => '0.0.0.0/0', :ip_protocol => 'tcp', :from_port => '80', :to_port => '80' },
                                  { :cidr_ip => '0.0.0.0/0', :ip_protocol => 'tcp', :from_port => '443', :to_port => '443' }
                                ])
```

The `vpc_security_group` dynamic will create a security group where every
member can initiate connections with other members in the same group. In this
example, you can also add ingress rules based on originating IP addresses
directly to the group.

```ruby
dynamic!(:vpc_security_group, 'database')
dynamic!(:security_group_ingress, 'web-to-database-mysql',
                                  :source_sg => :web_vpc_security_group, 
                                  :target_sg => :database_vpc_security_group,
                                  :ip_protocol => 'tcp',
                                  :from_port => '3306',
                                  :to_port => '3306')
```

The `security_group_ingress` dynamic will create a separate ingress rule, which you
can use to link security groups together (as opposed to allowing access based on
CIDR block).

Of course, there are many other usage patterns in AWS's CloudFormation template
language, but these two cases are currently implemented.
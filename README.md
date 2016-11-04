# sparkle-pack-aws-my-security-groups
SparklePack to auto-detect security groups within a certain VPC.  We identify
AWS resources by tags.

h/t to [techshell](https://github.com/techshell) for this approach.

### Tags

- Everything that gets created on AWS has an `Environment` tag.
  - These tags generally match Chef environments, or "stacks."
- In order to use this Sparkle Pack, you must assign an `Environment` tag
to your VPC.
- Assign a `Name` tag, as well as an `Environment` tag, to each VPC you create.

### Environment variables

The following environment variables must be set in order to use this Sparkle
Pack:

- AWS_REGION
- AWS_DEFAULT_REGION (being deprecated?)
- AWS_ACCESS_KEY_ID
- AWS_SECRET_ACCESS_KEY
- AWS_CUSTOMER_ID (optional)
- environment

### Use Cases

This SparklePack adds a registry entry that uses the AWS SDK to detect security
groups within your VPC (based on `ENV['AWS_REGION']` and `ENV['environment']`)
and returns a security group ID.  By default, it will return whichever security
group's `Name` gat matches `ENV['SG']`, though you can specify a filter when
calling the registry.  See below.

## Usage 

Add the pack to your Gemfile and .sfn:

Gemfile: 
```ruby source 'https://rubygems.org'
gem 'sfn' 
gem 'sparkle-pack-aws-aws-my-security-groups' ```

.sfn:
```ruby Configuration.new do
  sparkle_pack [ 'sparkle-pack-aws-my-security-groups' ] ...
end ```

In a SparkleFormation Template/Component/Dynamic:
```ruby security_group = registry!(:my_security_group_id, 'filter') ```

The `my_security_group_id` registry will return a Subnet ID.

```ruby security_groups = registry!(:all_security_group_ids) ```

The `all_security_group_ids` registry will return an array of all security
groups in the VPC.


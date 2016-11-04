Gem::Specification.new do |s|
  s.name = 'sparkle-pack-aws-my-security-groups'
  s.version = '0.0.1'
  s.licenses = ['MIT']
  s.summary = 'AWS My Security Groups SparklePack'
  s.description = 'SparklePack to detect security groups in a VPC whose Environment tag matches the "environment" environment variable.'
  s.authors = ['Greg Swallow']
  s.email = 'gswallow@indigobio.com'
  s.homepage = 'https://github.com/gswallow/sparkle-pack-aws-my-security-groups'
  s.files = Dir[ 'lib/sparkleformation/registry/*' ] + %w(sparkle-pack-aws-my-security-groups.gemspec lib/sparkle-pack-aws-my-security-groups.rb)
  s.add_runtime_dependency 'aws-sdk-core', '~> 2'
end

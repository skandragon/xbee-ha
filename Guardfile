guard 'rspec', cmd: 'bundle exec rspec' do
  watch(%r{^lib/(.+)\.rb$}) { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch(%r{^spec/.+\.rb$})
end
